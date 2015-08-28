%
% Demo script that calls shift_registration with a test images
% See shift_registration.m for a description of the parameters
%
% Run make_registration.m before running this file to build the
% MEX file. You will need a C++ compiler.
% 
% Petter Strandmark, Linus Svärm 2010
% {petter,linus}@maths.lth.se
%

close all
clear all
clc

file1 = 'img/bear1.jpg';
file2 = 'img/bear2.jpg';
levels = 5;
iterations = 4;
irange = 0.5;
jrange = 0.5;

tic
[shiftI shiftJ, Iout, Ireverse] = ...
	shift_registration(file1,file2,'levels',levels,'iterations',iterations,'shifts',1,'irange',irange,'jrange',jrange,'verbose',true);
toc % 59 seconds on our computer.

figure
imagesc(Iout); axis image; axis off; 
title('Source image shifted to destination image.')

figure
imagesc(Ireverse); axis image; axis off; 
title('Destination image "reverse"-shifted to source image.')


