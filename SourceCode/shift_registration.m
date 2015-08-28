
% [shiftI, shiftJ, Iout, Ireverse] = shift_registration(image_src, image_dest, varargin)
% shift_registration registers one image onto another image.
% 
%
% image_src, image_dest  : image file names of rgb-images. 
%                          image_src is registered onto image_dest.
%
% The DAISY function compute_daisy() must be in the path. 
%
% Options:
%
%    levels         : the number of levels
%    iterations     : the number of levels to actually compute <= levels
%    irange,jrange  : initial shift ranges (in fraction of total w & h of image_dest)
%    shifts         : the allowed shifts after the first level are 
%					  [-shifts..shifts]. If shifts = -1, an adaptive shift
%					  range is used.
%    verbose        : Output intermediate images {true/false}
%

function [shiftI, shiftJ, Iout, Ireverse] = shift_registration(image_src, image_dest, varargin)
	
    % Load the images
	Iorg1 = imread(image_src);
	Iorg2 = imread(image_dest);

    M1S = size(Iorg1,1);
    N1S = size(Iorg1,2);
    M2S = size(Iorg2,1);
    N2S = size(Iorg2,2);
	
    % Default parameters
	% 2^-(nLevels-1)*M = 30 <=>  nLevels = -(log(30) - log(M))/(log(2)) + 1
	nLevels = round(-(log(30) - log(max(M1S,M2S)))/(log(2)) + 1);
	nIter   = nLevels;
	irange_start = 1;
	jrange_start = 1;
	shifts = -1;
    verbose = false;
	
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
		if strcmp(str,'verbose')
			verbose = varargin{i+1};
		end
    end

	assert(nIter<=nLevels);
    
    % Compute DAISY descriptors.
    disp('Computing DAISY descriptors.')
    
    % DAISY parameters.
	% See DAISY implemenation readme for explenations.
    R  = 15; RQ = 3; TQ = 8; HQ = 8; SI = 1; LI = 1; NT = 3;
    daisy_vector_length = (RQ*TQ+1)*HQ;
    
    daisy1 = compute_daisy(Iorg1, R, RQ, TQ, HQ, SI, LI, NT);
    daisy1 = daisy1.descs';
    daisy1 = reshape(daisy1, [daisy_vector_length N1S M1S]);
    daisy1 = permute(daisy1, [3 2 1]);

    daisy2 = compute_daisy(Iorg2, R, RQ, TQ, HQ, SI, LI, NT);
    daisy2 = daisy2.descs';
    daisy2 = reshape(daisy2, [daisy_vector_length N2S M2S]);
    daisy2 = permute(daisy2, [3 2 1]);


    % Perform shiftmap registration over gradually higher resolutions...
    for iter = 1:nIter
        fac = 2^-(nLevels-iter);

        I1 = imresize(Iorg1,fac);
        I2 = imresize(Iorg2,fac);
        HSV1 = rgb2hsv(I1);
        HSV2 = rgb2hsv(I2);

        M1 = size(I1,1);
        N1 = size(I1,2);
        M2 = size(I2,1);
        N2 = size(I2,2);
        dp = fac^-1;

        % Setup shifts and allowed shift ranges.
        if iter==1
            % Create empty starting shifts
            shiftI = zeros(M1,N1,'int32');
            shiftJ = zeros(M1,N1,'int32');
			% Set starting shifts
			irange = [-M2*irange_start+1 M2*irange_start-1];
			jrange = [-N2*jrange_start+1 N2*jrange_start-1];
        else
            % Interpolate the old shift-maps to double size
            X = linspace(1,N1,size(shiftI,2));
            Y = linspace(1,M1,size(shiftI,1));
            shiftI = int32(round( interp2(X,Y',2*double(shiftI),1:N1,(1:M1)','linear') ));
            shiftJ = int32(round( interp2(X,Y',2*double(shiftJ),1:N1,(1:M1)','linear') ));

            % adaptive range. better?
			if shifts == -1
				r = nLevels-iter+1; 		
				irange = r*[-1 1];
				jrange = r*[-1 1];
			else
				irange = shifts*[-1 1];
				jrange = shifts*[-1 1];
			end
        end


        kp1 = []; kp2 = [];	
        if iter < nLevels
            % Interpolate DAISY descriptors corresponding to the smaller images.
            kp1 = imresize(daisy1(dp:end-dp+1,dp:end-dp+1,:),[M1 N1],'method','bilinear','antialiasing',false);		
            kp1 = reshape(permute(kp1,[3 2 1]), [daisy_vector_length M1*N1]);
            kp2 = imresize(daisy2(dp:end-dp+1,dp:end-dp+1,:),[M2 N2],'method','bilinear','antialiasing',false);		
            kp2 = reshape(permute(kp2,[3 2 1]), [daisy_vector_length M2*N2]);
            [shiftI shiftJ] = mex_shiftmap_registration(HSV1, HSV2, kp1, kp2, [M1 N1], [M2 N2], irange, jrange, shiftI, shiftJ);
        else
            % To save some memory...
            daisy1 = reshape(permute(daisy1,[3 2 1]), [daisy_vector_length M1*N1]);
            daisy2 = reshape(permute(daisy2,[3 2 1]), [daisy_vector_length M2*N2]);
            [shiftI shiftJ] = mex_shiftmap_registration(HSV1, HSV2, daisy1, daisy2, [M1 N1], [M2 N2], irange, jrange, shiftI, shiftJ);
        end

        if verbose
            figure(iter); clf;

            subplot(3,2,1)
            imagesc(shiftI);
			title('Horisontal shift.');
            axis image
			
            subplot(3,2,2)
            imagesc(shiftJ);
			title('Vertical shift.');
            axis image
            
			subplot(3,2,3)
            imagesc(I2);
			title('Destination image.');
            axis image

            subplot(3,2,4)
            imagesc(I1);
			title('Source image.');
            axis image

            % Build images
			[Iout,Ireverse] = build_output(I1,I2,shiftI,shiftJ,1);

            subplot(3,2,5)
            imagesc(Iout);
			title('Src shifted to dst.');
            axis image
			
			subplot(3,2,6)
            imagesc(Ireverse);
			title('Dst reverse-shifted to src.');
            axis image
        end
    end

	[Iout,Ireverse] = build_output(I1,I2,shiftI,shiftJ,1);

	

