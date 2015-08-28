%
% Demo script that calls shift_inpaint with a test image
% See shift_inpaint.m for a description of the parameters
%
% Run make_inpaint.m before running this file to build the
% MEX file. You will need a C++ compiler.
% 
% Petter Strandmark, Linus Svärm 2010
% {petter,linus}@maths.lth.se
%

close all
clc
clear all



%create mask
B_orig=imread('img/unicorn1.jpg');
C_orig=imread('img/unicorn2.jpg');
%D_orig=imread('img/originalPuzzle.jpg');
flag=1;
resizeFactor=1;
while (flag == 1)
	C = imresize(C_orig, resizeFactor);
	B = imresize(B_orig, resizeFactor);
	[r1, c1, d1] = size(C);
	if ( (r1 < 600) && (c1 < 700))
		flag = 0;
	end
	resizeFactor = resizeFactor - 0.05;
end

%D=imresize(D_orig, resizeFactor+0.05);

imwrite(B,'img/Shrink.jpg');
file = 'img/Shrink.jpg';
A =  B-C;
figure,imshow(A);
title('Original image');
r = A(:, :, 1);
g = A(:, :, 2);
b = A(:, :, 3);
justGreen = g - r/2 - b/2;
bw = justGreen > 50;
original_bw=bw;


%zero padding for mask

for k=1:6
i=1;
j=1;
	while( i<size(bw,1))
		while( j<(size(bw,2)-1))
			if bw(i,j)==1 && bw(i,j+1)==0

				bw(i,j+1)=1;
				j=j+1;
			end;
			if bw(i,j)==0 && bw(i,j+1)==1
				bw(i,j)=1;
			end;
			j=j+1;
		end;
		j=1;
		i=i+1;
	end;

	while( j<(size(bw,2)))
		while( i<(size(bw,1)-1))
			if bw(i,j)==1 && bw(i+1,j)==0
				bw(i+1,j)=1;
				i=i+1;
			end;
			if bw(i,j)==0 && bw(i+1,j)==1
				bw(i,j)=1;
			end;
			i=i+1;
		end;
		i=1;
		j=j+1;
	end;
end;


imwrite(bw,'img/mask.png')
filemask = 'img/mask.png';
figure,imshow(bw);
title('ONLY GREEN');

levels = 4;
irange = 0.25;
jrange = 0.25;

tic
[shiftI shiftJ, Iout] = shift_inpaint(file,filemask,'levels',levels,'iterations',4,'shifts',1,'irange',irange,'jrange',jrange);
toc %3.1415 (!!) seconds on my computer

figure
subplot('position',[0 0 1 1]);
I = imread(file);
IM = imread(filemask);
image(I.*uint8(repmat(IM,[1 1 3])==0));
axis equal
axis off



figure
subplot('position',[0 0 1 1]);
image(Iout);
axis equal
axis off

puzzleParts=extract_pieces(Iout,original_bw);

figure
subplot('position',[0 0 1 1]);
image(puzzleParts);
axis equal
axis off


%% unify missing puzzle pieces 
%find puzzle pieces
st = regionprops(original_bw, 'BoundingBox' );
%init varibale
nRows = round((length(st) + 1)/2);
nCols =2;
imgCell = cell(nRows,nCols);
longestRow=0;
longestCol=0;
%insert missing puzlle pieces into cell array
for k = 1 : length(st)
	thisBB = st(k).BoundingBox; 
	subImage = imcrop(puzzleParts, thisBB);
	[r1, c1 , d1] = size(subImage);
	longestRow=max(longestRow,r1);
	longestCol=max(longestCol,c1);
	nchannels = size(subImage,3);
	imgCell{k} = subImage;
	rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],... 
	'EdgeColor','r','LineWidth',2 );
end;

%fill in NaN values with zeros
imgCell(cellfun(@isempty,imgCell)) = {uint8(zeros(longestRow,longestCol,nchannels))};

%zero padding in order to match matrix dimention
for k = 1 : length(st)
	imgCell{k} = [ imgCell{k}, zeros(size(imgCell{k},1), longestCol-size(imgCell{k},2), nchannels); ...
	zeros(longestRow-size(imgCell{k},1), longestCol, nchannels)];
end;

%concatenate images
bigImage=cell2mat(imgCell);
%convert black backgroung to white
idx = all(bigImage==0,3);
bigImage(repmat(idx,[1,1,3]))=255;
figure;imshow(bigImage);