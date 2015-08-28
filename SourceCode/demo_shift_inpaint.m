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

file = 'img/bungee0.png';
filemask = 'img/bungeemask.png';
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
imagesc(shiftI);
colorbar
axis equal
axis off

figure
subplot('position',[0 0 1 1]);
imagesc(shiftJ);
colorbar
axis equal
axis off

figure
subplot('position',[0 0 1 1]);
image(Iout);
axis equal
axis off


