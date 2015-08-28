%shift_inpaint inpaints images with a shift-map
%
% image1, image2  : image file names
%
% Options:
%
%    levels         : the number of levels
%    iterations     : the number of iterations <= levels
%    irange,jrange  : initial shift ranges (in fraction of total w & h)
%    shifts         : the allowed shifts after the first level are
%                     [-shifts..shifts]
%
function [shiftI shiftJ, Iout] = shift_inpaint(image,imagemask, varargin)
	%Load the images
	Iorg = imread(image);
	IMorg = imread(imagemask);
	if length(size(IMorg))>2
		IMorg = rgb2gray(IMorg);
	end
	
	M = size(Iorg,1);
	N = size(Iorg,2);
	assert(all( [M N]==size(IMorg) ));

	%Default parameters
	%2^-(nLevels-1)*M = 30 <=>  nLevels = -(log(30) - log(M))/(log(2)) + 1
	nLevels = round(-(log(30) - log(M))/(log(2)) + 1);
	nIter   = nLevels;
	irange_start = 1;
	jrange_start = 1;
	shifts = 1;
	
	% Parse the arguments to the function
	for i = 1:length(varargin)
		str = varargin{i};
		if strcmp(str,'levels')
			nLevels = varargin{i+1};
		end
		if strcmp(str,'iterations')
			nIter = varargin{i+1};
		end
		if strcmp(str,'irange')
			irange_start = varargin{i+1};
		end
		if strcmp(str,'jrange')
			jrange_start = varargin{i+1};
		end
		if strcmp(str,'shifts')
			shifts = varargin{i+1};
		end
	end

	assert(nIter<=nLevels);


	% Proceed from the lowest part of the Gaussian pyramid
	for iter = 1:nIter
		%Resize factor
		fac = 2^-(nLevels-iter);
		
		I = imresize(Iorg,fac);
		IM = imresize(IMorg,fac);
		IM = uint8(IM >= 0.3);

		M = size(I,1);
		N = size(I,2);

		%Image gradient
		[Gx Gy] = gradient(double(rgb2gray(I)));

		if iter==1
			%Create empty starting shifts
			shiftI = zeros(M,N,'int32');
			shiftJ = zeros(M,N,'int32');
			%Starting shifts
			irange = [-M*irange_start+1 M*irange_start-1];
			jrange = [-N*jrange_start+1 N*jrange_start-1];
		else
			% Interpolate the shift-maps to double size
			X = linspace(1,N,size(shiftI,2));
			Y = linspace(1,M,size(shiftI,1));
			shiftI = int32(round( interp2(X,Y',2*double(shiftI),1:N,(1:M)','nearest') ));
			shiftJ = int32(round( interp2(X,Y',2*double(shiftJ),1:N,(1:M)','nearest') ));

			shiftI( IM==0 ) = 0;
			shiftJ( IM==0 ) = 0;

			%Fix the image so that no pixels are shifted outside
			for i = 1:M
				for j = 1:N
					if i+shiftI(i,j)<1 
						shiftI(i,j) = 1 - i;
					end
					if i+shiftI(i,j)>M 
						shiftI(i,j) = M - i;
					end
					if j+shiftJ(i,j)<1 
						shiftJ(i,j) = 1 - j;
					end
					if j+shiftJ(i,j)>N 
						shiftJ(i,j) = N - j;
					end
				end
			end

			%Fix the image so that no pixels are shifted inside the
			%forbidden zone
			cannot=0;
			for i = 1:M
				for j = 1:N
					if IM(i+shiftI(i,j), j+shiftJ(i,j)) == 1
						%Forbidden
						if i<M && i+shiftI(i+1,j)>=1 && i+shiftI(i+1,j)<=M && ...
								  j+shiftJ(i+1,j)>=1 && j+shiftJ(i+1,j)<=N && ...
								IM(i+shiftI(i+1,j), j+shiftJ(i+1,j)) == 0
							shiftI(i,j) = shiftI(i+1,j);
							shiftJ(i,j) = shiftJ(i+1,j);
						elseif i>1 && i+shiftI(i-1,j)>=1 && i+shiftI(i-1,j)<=M && ...
									  j+shiftJ(i-1,j)>=1 && j+shiftJ(i-1,j)<=N && ...
								IM(i+shiftI(i-1,j), j+shiftJ(i-1,j)) == 0
							shiftI(i,j) = shiftI(i-1,j);
							shiftJ(i,j) = shiftJ(i-1,j);
						elseif j<N && i+shiftI(i,j+1)>=1 && i+shiftI(i,j+1)<=M && ...
									  j+shiftJ(i,j+1)>=1 && j+shiftJ(i,j+1)<=N && ...
								IM(i+shiftI(i,j+1), j+shiftJ(i,j+1)) == 0
							shiftI(i,j) = shiftI(i,j+1);
							shiftJ(i,j) = shiftJ(i,j+1);
						elseif j>1 && i+shiftI(i,j-1)>=1 && i+shiftI(i,j-1)<=M && ...
									  j+shiftJ(i,j-1)>=1 && j+shiftJ(i,j-1)<=N && ...
								IM(i+shiftI(i,j-1), j+shiftJ(i,j-1)) == 0
							shiftI(i,j) = shiftI(i,j-1);
							shiftJ(i,j) = shiftJ(i,j-1);
						else
							cannot=cannot+1;
						end
					end
				end
			end
			
			if cannot>0
				fprintf('Could not fix %d pixels\n',cannot);
			end

			irange = shifts*[-1 1];
			jrange = shifts*[-1 1];
		end


		[shiftI shiftJ] = mex_shiftmap_inpaint(I,IM,Gx,Gy, irange, jrange, shiftI, shiftJ);



		%Build the image
		Iout = zeros(M,N,3,'uint8');
		for i = 1:M
			for j = 1:N
				if i+shiftI(i,j)<1 || j+shiftJ(i,j)<1 || i+shiftI(i,j)>M || j+shiftJ(i,j)>N
					Iout(i,j,2) = 255;
				else
					if IM(i+shiftI(i,j), j+shiftJ(i,j)) == 0
						Iout(i,j,1) = I(i+shiftI(i,j), j+shiftJ(i,j), 1);
						Iout(i,j,2) = I(i+shiftI(i,j), j+shiftJ(i,j), 2);
						Iout(i,j,3) = I(i+shiftI(i,j), j+shiftJ(i,j), 3);
					else
						Iout(i,j,1) = 255;
					end
				end
			end
		end


	end
	

end

