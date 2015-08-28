% clc;
% clear all;
% close all;

dirName = 'C:\project\PuzzleDazzle\DB\';              
files = dir( fullfile(dirName,'*.jpg') );   
files = {files.name}';                      

ImageCompare =imread('C:\project\PuzzleDazzle\images\unicorn2.jpg');
Imaged = im2double(ImageCompare);
Imageg = rgb2gray(Imaged); 
hn1 = imhist(Imageg)./numel(Imageg);
minDif = 1;
    
for i=1:numel(files)
    fname = fullfile(dirName,files{i});    
    I =imread(fname);
    %  convert images to type double (range from from 0 to 1 instead of from 0 to 255)
    Imaged = im2double(I);
    % reduce three channel [ RGB ]  to one channel [ grayscale ]
    Imageg = rgb2gray(Imaged); 
    % Calculate the Normalized Histogram of Image 1 and Image 2
    hn2 = imhist(Imageg)./numel(Imageg); 
    % Calculate the histogram error/ Difference
    dif = sum((hn1 - hn2).^2);
    % find the minimum difference
    if ( dif < minDif )
        minDif = dif;
        matchImg = imread(fname);
    end 
end

if (minDif < 0.001)
    figure;
    imshow (matchImg);
end 

% %% tall add
% I1 =imread('C:\Project\images\puzzleMissing1.jpg');
% I2 =imread('C:\Project\images\originalImg.jpg');
% I3 =imread('C:\Project\images\puzzleMissing2.jpg');
% I4 =imread('C:\Project\images\fromInternet1.jpg');
% I5 =imread('C:\Project\images\fromInternet2.jpg');
% %I5 =imread('C:\Project\images\completePuzzle.jpg');
% 
% 
% %%
% %  convert images to type double (range from from 0 to 1 instead of from 0 to 255)
% Imaged1 = im2double(I1);
% Imaged2 = im2double(I2);
% Imaged3 = im2double(I3);
% Imaged4 = im2double(I4);
% Imaged5 = im2double(I5);
% 
% % reduce three channel [ RGB ]  to one channel [ grayscale ]
% Imageg1 = rgb2gray(Imaged1); 
% Imageg2 = rgb2gray(Imaged2); 
% Imageg3 = rgb2gray(Imaged3); 
% Imageg4 = rgb2gray(Imaged4); 
% Imageg5 = rgb2gray(Imaged5); 
% 
% % Calculate the Normalized Histogram of Image 1 and Image 2
% hn1 = imhist(Imageg1)./numel(Imageg1); 
% hn2 = imhist(Imageg2)./numel(Imageg2); 
% hn3 = imhist(Imageg3)./numel(Imageg3); 
% hn4 = imhist(Imageg4)./numel(Imageg4); 
% hn5 = imhist(Imageg5)./numel(Imageg5); 
% 
% % Calculate the histogram error/ Difference
% f1 = sum((hn1 - hn2).^2)
% f2 = sum((hn1 - hn3).^2) 
% f3 = sum((hn1 - hn4).^2) 
% f4 = sum((hn1 - hn5).^2) 