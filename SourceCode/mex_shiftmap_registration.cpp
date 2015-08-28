//
//
//  Shift-map image registration
//
//  Based on the ICCV 2009 paper
//
//	smoothFnRot() is a more rotation invaraint version of smoothFn().
//
//	TODOs:
//	* Color handling is very naive. Should preferably be robust to different ligthing conditions.
//		One idea would be to use Mutual Information like Kim and Kolmogorov.
//	* Using the gradients of images probably could improve the registration, but it remains to 
//		find a way to make it (at least semi-) rotation invariant.
//  * It might be a good idea to decrease the cost of discontinuities at large image gradients.
//  * During iteration of labels, it might be a good idea to begin with the ones used be the keypoints.
//	* It might be good to skip the discontinuity cost when at least one pixel is shifted outside.
//		or at least when both neighbors are shifted outside.
//

#include <vector>
#include <new>
#include <sstream>
#include <cmath>
#include <memory>
#include <stdexcept>
using namespace std;

#include "gc/GCoptimization.h"

#include "cppmatrix.h"
#include "mexutils.h"
#define TIMING
#include "mextiming.h"

const int kpLength 					= 200;
const double cutoff					= 0.998;
const double cS_cutoff				= 0.3;
const double cV_cutoff				= 0.3;


int M1,N1,M2,N2;
int max_shift_i, min_shift_i, max_shift_j, min_shift_j;

const Graph::captype outsidePenalty = 80;
const int beta						= 10;
const double max_color_diff			= 0.2;



//
// Convert between 1D indices and 2D
//
int sub2ind(int i, int j, int M)
{
	return M*j + i;
}
void ind2sub(int ind, int& i, int& j, int M)
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
	matrix<double> c1;
	matrix<double> c2;
	matrix<float> kp1;
	matrix<float> kp2;
	matrix<int> shiftI;
	matrix<int> shiftJ;
};

Graph::captype smoothFn(int p1, int p2, int l1, int l2, void *void_data)
{
	// Measures the true distance in the second image.
	// Also sets the distance == 1pixel as the minumum energy.
	
	ForDataFn *data = (ForDataFn *) void_data;
	
	int i1,i2,j1,j2,di1,di2,dj1,dj2;
	ind2sub(p1,i1,j1,M1);
	ind2sub(p2,i2,j2,M1);
	lab2shift(l1,di1,dj1); 
	lab2shift(l2,di2,dj2);
	// Add prior shift
	di1 += data->shiftI[p1];
	dj1 += data->shiftJ[p1];
	di2 += data->shiftI[p2];
	dj2 += data->shiftJ[p2];
	
	// Coordinates of true end pixels
	int epi1 = i1 + di1;
	int epj1 = j1 + dj1;
	int epi2 = i2 + di2;
	int epj2 = j2 + dj2;

	// Skip smoothness penalty only if both pixels are outside of the screen.
	if ((epi1 < 0 || epi1 >= M2 || epj1 < 0 || epj1 >= N2) && (epi2 < 0 || epi2 >= M2 || epj2 < 0 || epj2 >= N2))
		return 0;

	float dist = std::sqrt( double( (epi1-epi2)*(epi1-epi2) + (epj1-epj2)*(epj1-epj2) ));

	return beta*std::abs(dist-1.0);
}

Graph::captype dataFn(int p, int l, void *void_data)
{
	ForDataFn *data = (ForDataFn *) void_data;
	
	int i,j,di,dj;
	ind2sub(p,i,j,M1);
	lab2shift(l,di,dj);
	// Add prior shift
	di += data->shiftI[p];
	dj += data->shiftJ[p];
	
	// Will this shift end up outside the image?
	if (i+di<0 || i+di>=M2 || j+dj<0 || j+dj>=N2) {
		return outsidePenalty;
	}

	double h1    = data->c1(i,j,0);
	double s1    = data->c1(i,j,1);
	double v1    = data->c1(i,j,2);
	double h2    = data->c2(i+di,j+dj,0);
	double s2    = data->c2(i+di,j+dj,1);
	double v2    = data->c2(i+di,j+dj,2);

	// Are the colors sufficiently similar?
	// Pixels that are dark or have low saturation have unrealiable color; skip those.
	if (s1 > cS_cutoff && v1 > cV_cutoff && s2 > cS_cutoff && v2 > cV_cutoff) {
		// realiable color
		double dh = std::abs(h1 - h2);
		if (dh > max_color_diff && dh < (1.0-max_color_diff))
			return outsidePenalty*10;							// TODO: Godtyckligt och omotiverat. Fixa!!!!
	}

	float dist = 0;
	int ind1 = kpLength*(i*N1+j);
	int ind2 = kpLength*((i+di)*N2+(j+dj));
	float tmp;	
	for (int k=0; k < kpLength; k++) {
		tmp = data->kp1[ind1+k] - data->kp2[ind2+k];
		dist += tmp*tmp;
	}

	return 100*std::sqrt(dist); 
}

void mexFunctionReal(	int		nlhs, 		/* number of expected outputs */
		 			mxArray	*plhs[],	/* mxArray output pointer array */
			 		int		nrhs, 		/* number of inputs */
				 	const mxArray	*prhs[]		/* mxArray input pointer array */)
{
	//
	// Get input
	//	
	ASSERT( nlhs == 2 && nrhs == 10);
	matrix<double> mxC1  = prhs[0];
	matrix<double> mxC2	 = prhs[1];
	matrix<float> mxKP1 = prhs[2];
	matrix<float> mxKP2 = prhs[3];
	matrix<double> mxKPSize1 = prhs[4];
	matrix<double> mxKPSize2 = prhs[5];
	matrix<double> mxIrange = prhs[6];
	matrix<double> mxJrange = prhs[7];
	matrix<int> mxShiftI = prhs[8];
	matrix<int> mxShiftJ = prhs[9];

	ASSERT( mxC1.O == 3 );
	ASSERT( mxC2.O == 3 );
	ASSERT( mxKPSize1.numel() == 2 );
	ASSERT( mxKPSize2.numel() == 2 );
	ASSERT(  mxIrange.numel() == 2 );
	ASSERT(  mxJrange.numel() == 2 );
	
	M1 = mxKPSize1[0];
	N1 = mxKPSize1[1];
	M2 = mxKPSize2[0];
	N2 = mxKPSize2[1];
	ASSERT( mxC1.M == M1 && mxC1.N == N1); // fulhack
	ASSERT( mxC2.M == M2 && mxC2.N == N2);
	ASSERT( mxShiftI.M == M1 && mxShiftI.N == N1);
	ASSERT( mxShiftJ.M == M1 && mxShiftJ.N == N1);
	ASSERT( mxKP1.numel() == kpLength*M1*N1);
	ASSERT( mxKP2.numel() == kpLength*M2*N2);
	
	//
	// Range of shifts to consider
	//
	ASSERT(mxIrange[0]>=-std::max(M1,M2)+1 && mxIrange[1]<=std::max(M1,M2)-1);
	ASSERT(mxJrange[0]>=-std::max(N1,N2)+1 && mxJrange[1]<=std::max(N1,N2)-1);
	max_shift_i = mxIrange[1];
	min_shift_i = mxIrange[0];
	max_shift_j = mxJrange[1];
	min_shift_j = mxJrange[0];
	// Compute number of labels
	const int num_labels = (max_shift_i-min_shift_i+1)*(max_shift_j-min_shift_j+1);
	
	
	mexPrintf("Shift-map %d x %d  with %d labels\n",M1,N1,num_labels);
	mexPrintf("I-range %d ... %d \n",min_shift_i,max_shift_i);
	mexPrintf("J-range %d ... %d \n",min_shift_j,max_shift_j);
	
	//
	// Create graph
	//
	GCoptimizationGridGraph gc_obj(M1,N1,num_labels);
	GCoptimizationGridGraph* gc = &gc_obj;

	// set up the needed data to pass to function for the data costs
	ForDataFn toFn;
	toFn.c1		= mxC1;
	toFn.c2		= mxC2;
	toFn.kp1 	= mxKP1;
	toFn.kp2 	= mxKP2;
	toFn.shiftI = mxShiftI;
	toFn.shiftJ = mxShiftJ;
	
	gc->setDataCost(&dataFn,&toFn);
	gc->setSmoothCost(&smoothFn, &toFn);
	
	// Initialize shift-map to 0
	mexPrintf("Starting shift-map: di=0, dj=0\n");
	int zero_label = shift2lab(0,0);
	for (int i=0;i<M1*N1;++i) {
		gc->setLabel(i,zero_label);
	}

	// Print energy informaion
	double energy = gc->compute_energy();
	double dataEnergy = gc->giveDataEnergy();
	double smoothEnergy = gc->giveSmoothEnergy();
	mexPrintf("Start energy : %16.0f\n",energy);
	mexPrintf("Start data   : %16.0f\n",dataEnergy);
	mexPrintf("Start smooth : %16.0f\n",smoothEnergy);
	mexPrintf("Stopping when old_energy*%f < new_energy.\n",cutoff);
	flush_output();
	
	double old_energy = energy/cutoff + 1;
	int iter = 1;
	startTime();
	while ( cutoff*old_energy > energy  && iter <= 100)
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
		iter++;
		endTime(); //Don't measure the time taken by the output
	}
	
	mexPrintf("Final energy : %16.0f\n",gc->compute_energy());
	
    
     
     
	//
	// Create output
	//
	matrix<int> shiftI_out(M1,N1);
	matrix<int> shiftJ_out(M1,N1);
	plhs[0] = shiftI_out;
	plhs[1] = shiftJ_out;
	
	for ( int  ind = 0; ind < M1*N1; ind++ ) {
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

