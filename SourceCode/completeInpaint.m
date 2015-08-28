function [  ] = completeInpaint( )

global input_puzzle_white
global input_puzzle_red
global try_again
global shrink_factor

% resize images for inpaint
flag=1;
resizeFactor=1;
while (flag == 1)
	C = imresize(input_puzzle_red, resizeFactor);
	B = imresize(input_puzzle_white, resizeFactor);
	[r1, c1, d1] = size(C);
	if ( (r1 < 600) && (c1 < 700))
		flag = 0;
        shrink_factor = resizeFactor;
        assignin('base','shrink_factor',shrink_factor);
	end
	resizeFactor = resizeFactor - 0.05;
end

% save shrink image
imwrite(B,'img/Shrink.jpg');
file = 'img/Shrink.jpg';

A =  B-C;
r = A(:, :, 1);
g = A(:, :, 2);
b = A(:, :, 3);
justGreen = g - r/2 - b/2;
bw = justGreen > 50;
original_bw = bw;

%zero padding for mask
for k=1:(6 - try_again)
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

levels = 4;
irange = 0.25;
jrange = 0.25;

tic
[shiftI shiftJ, Iout] = shift_inpaint(file,filemask,'levels',levels,'iterations',4,'shifts',1,'irange',irange,'jrange',jrange);
toc

global inpainted_puzzle
global resized_mask
inpainted_puzzle = Iout;
resized_mask = original_bw;
assignin('base','inpainted_puzzle',inpainted_puzzle);
assignin('base','resized_mask',resized_mask);

 end

