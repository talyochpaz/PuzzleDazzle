//
//
//  Shift-map image inpainting
//
//  Implementation of the ICCV 2009 paper
//
//  Petter Strandmark 2010
//  petter@maths.lth.se
//
#include <vector>
#include <new>
#include <sstream>
#include <cmath>
#include <memory>
#include <stdexcept>
using namespace std;

#include "mex.h"

#include "gc/GCoptimization.h"

#include "cppmatrix.h"
#include "mexutils.h"
#define TIMING
#include "mextiming.h"

int M,N;
int max_shift_i, min_shift_i, max_shift_j, min_shift_j;

const Graph::captype infinity = 1e9;

//
// Convert between 1D indices and 2D
//
void ind2sub(int ind, int& i, int& j)
{
	i = ind%M;
	j = ind/M;
}

//
// Convert between labels and actual shifts
//
int shift2lab(int di, int dj)
{
	return (di - min_shift_i) + (max_shift_i-min_shift_i+1)*(dj - min_shift_j);
}
void lab2shift(int lab, int& di, int& dj)
{
	di = lab % (max_shift_i-min_shift_i+1);
	dj = (lab-di)/(max_shift_i-min_shift_i+1) + min_shift_j;
	di = di  + min_shift_i;
}


//
// Energy terms
//
struct ForDataFn{
	ForDataFn(){}
	matrix<double> gradx;
	matrix<double> grady;
	matrix<unsigned char> image;
	matrix<unsigned char> mask;
	matrix<int> shiftI;
	matrix<int> shiftJ;
};

Graph::captype smoothFn(int p1, int p2, int l1, int l2, void *void_data)
{
	const int beta = 2;
	
	ForDataFn *data = (ForDataFn *) void_data;
	
	int i1,i2,j1,j2,di1,di2,dj1,dj2;
	ind2sub(p1,i1,j1);
	ind2sub(p2,i2,j2);
	lab2shift(l1,di1,dj1);
	lab2shift(l2,di2,dj2);
	//Add prior shift
	di1 += data->shiftI[p1];
	dj1 += data->shiftJ[p1];
	di2 += data->shiftI[p2];
	dj2 += data->shiftJ[p2];
	
	//Are the shift-maps equal?
	if (di1 == di2 && dj1 == dj2) {
		//No cost if the shift-maps are equal
		return 0; 
	}

	//Will this shift end up outside the image?
	if (i1+di1<0 || i1+di1>=M || j1+dj1<0 || j1+dj1>=N) {
		return 0; //Data term already assigns this infinity
	}
	//Will this shift end up outside the image?
	if (i1+di2<0 || i1+di2>=M || j1+dj2<0 || j1+dj2>=N) {
		return 0; //Data term already assigns this infinity
	}
	
	int r1     = data->image(i1+di1,j1+dj1);
	int g1     = data->image(i1+di1,j1+dj1, 1);
	int b1     = data->image(i1+di1,j1+dj1, 2);
	int gradx1 = data->gradx(i1+di1,j1+dj1);
	int grady1 = data->grady(i1+di1,j1+dj1);
	
	int r2     = data->image(i1+di2,j1+dj2);
	int g2     = data->image(i1+di2,j1+dj2, 1);
	int b2     = data->image(i1+di2,j1+dj2, 2);
	int gradx2 = data->gradx(i1+di2,j1+dj2);
	int grady2 = data->grady(i1+di2,j1+dj2);	
		
		
	int dr = r1 - r2;
	int dg = g1 - g2;
	int db = b1 - b2;
	int dgradx = gradx1 - gradx2;
	int dgrady = grady1 - grady2;	

	return dr*dr + dg*dg + db*db + beta*(dgradx*dgradx + dgrady*dgrady); 
}

Graph::captype dataFn(int p, int l, void *void_data)
{
	ForDataFn *data = (ForDataFn *) void_data;
	
	int i,j,di,dj;
	ind2sub(p,i,j);
	lab2shift(l,di,dj);
	//Add prior shift
	di += data->shiftI[p];
	dj += data->shiftJ[p];
	
	//Will this shift end up outside the image?
	if (i+di<0 || i+di>=M || j+dj<0 || j+dj>=N) {
		return infinity;
	}
	
	//Will this shift end up inside the area to
	//be removed?
	if ( data->mask(i+di,j+dj) == 1 ) {
		return infinity;
	}
	
	//Is this shift moving pixels outside the mask?
	if ( data->mask(i,j) == 0  && (di!=0||dj!=0) ) {
		return infinity;
	}
	
	return 0;
}

void mexFunctionReal(int			nlhs, 		/* number of expected outputs */
				 mxArray		*plhs[],	/* mxArray output pointer array */
				 int			nrhs, 		/* number of inputs */
				 const mxArray	*prhs[]		/* mxArray input pointer array */)
{
	//
	// Get input
	//	
	ASSERT( nlhs == 2 && nrhs == 8);
	
	matrix<unsigned char> mxI(prhs[0]);
	matrix<unsigned char> mxMask(prhs[1]);
	matrix<double> mxGradx(prhs[2]);
	matrix<double> mxGrady(prhs[3]);
	matrix<double> mxIrange(prhs[4]);
	matrix<double> mxJrange(prhs[5]);
	matrix<int> mxShiftI(prhs[6]);
	matrix<int> mxShiftJ(prhs[7]);
	ASSERT(mxI.O == 3);
	M = mxI.M;
	N = mxI.N;
	ASSERT(mxIrange.numel() == 2);
	ASSERT(mxJrange.numel() == 2);
	ASSERT( mxMask.M == M && mxMask.N == N );
	ASSERT( mxGradx.M == M && mxGradx.N == N );
	ASSERT( mxGrady.M == M && mxGrady.N == N );
	ASSERT( mxShiftI.M == M && mxShiftI.N == N );
	ASSERT( mxShiftJ.M == M && mxShiftJ.N == N );
	
	//
	// Range of shifts to consider
	//
	ASSERT( mxIrange[0]>=-M+1 && mxIrange[1]<=M-1 );
	ASSERT( mxJrange[0]>=-N+1 && mxJrange[1]<=N-1 );
	max_shift_i = mxIrange[1];
	min_shift_i = mxIrange[0];
	max_shift_j = mxJrange[1];
	min_shift_j = mxJrange[0];
	// Compute number of labels
	const int num_labels = (max_shift_i-min_shift_i+1)*(max_shift_j-min_shift_j+1);
	
	
	mexPrintf("Shift-map %d x %d  with %d labels\n",M,N,num_labels);
	mexPrintf("I-range %d ... %d \n",min_shift_i,max_shift_i);
	mexPrintf("J-range %d ... %d \n",min_shift_j,max_shift_j);
	
	//
	// Create graph
	//
	
	auto_ptr<GCoptimizationGridGraph> gc(new GCoptimizationGridGraph(M,N,num_labels) );

	// set up the needed data to pass to function for the data costs
	ForDataFn toFn;
	toFn.image = mxI;
	toFn.gradx = mxGradx;
	toFn.grady = mxGrady;
	toFn.mask = mxMask;
	toFn.shiftI = mxShiftI;
	toFn.shiftJ = mxShiftJ;
	
	gc->setDataCost(&dataFn,&toFn);
	gc->setSmoothCost(&smoothFn, &toFn);
	
	// Initialize shift-map to 0
	mexPrintf("Starting shift-map: di=0, dj=0\n");
	int zero_label = shift2lab(0,0);
	for (int i=0;i<M*N;++i) {
		gc->setLabel(i,zero_label);
	}

	
	// Print energy informaion
	double energy = gc->compute_energy();
	double dataEnergy = gc->giveDataEnergy();
	double smoothEnergy = gc->giveSmoothEnergy();
	mexPrintf("Start energy : %16.0f\n",energy);
	mexPrintf("Start data   : %16.0f\n",dataEnergy);
	mexPrintf("Start smooth : %16.0f\n",smoothEnergy);
	flush_output();
	

	double old_energy = energy+1;
	int iter = 1;
	startTime();
	while ( old_energy > energy  && iter <= 100)
	{
		old_energy = energy;
		//energy = gc->expansion(1);
		for (int lab=0;  lab < num_labels;  lab++ )
		{
			gc->alpha_expansion(lab);
		}
		energy = gc->compute_energy();
		dataEnergy = gc->giveDataEnergy();
		smoothEnergy = gc->giveSmoothEnergy();
		double time_taken = endTime(); // Measure the time taken since last call to endtime
		mexPrintf("Iteration %3d:   T:%16.0f   D:%16.0f   S:%16.0f  time: %.2f sec\n",iter,energy,dataEnergy,smoothEnergy,time_taken);
		flush_output();
		endTime(); //Don't measure the time taken by the output
		iter++;
	}
	
	//
	// Create output
	//
    matrix<int> shiftI_out(M,N);
    matrix<int> shiftJ_out(M,N);
    plhs[0] = shiftI_out;
    plhs[1] = shiftJ_out;

    for ( int  ind = 0; ind < M*N; ind++ ) {
        int di,dj;
        int lab = gc->whatLabel(ind);
        lab2shift(lab,di,dj);
        shiftI_out[ind] = di + mxShiftI[ind];
        shiftJ_out[ind] = dj + mxShiftJ[ind];
    }
}

void mexFunction(int			nlhs, 		/* number of expected outputs */
				 mxArray		*plhs[],	/* mxArray output pointer array */
				 int			nrhs, 		/* number of inputs */
				 const mxArray	*prhs[]		/* mxArray input pointer array */)
{
	try {
		mexFunctionReal(nlhs,plhs,nrhs,prhs);
	}
	catch (bad_alloc& ) {
		mexErrMsgTxt("Out of memory");
	}
	catch (exception& e) {
		mexErrMsgTxt(e.what());
	}
	catch (GCException e){
		mexErrMsgTxt(e.message);
	}
	catch (...) {
		mexErrMsgTxt("Unknown exception");
	}
}
