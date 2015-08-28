function [ mask ] = createMask( )

global input_puzzle_white;
global input_puzzle_red;

B = input_puzzle_white;
C = input_puzzle_red;

A =  B-C;

% Extract each color
r = A(:, :, 1);
g = A(:, :, 2);
b = A(:, :, 3);

% Calculate Green
justGreen = g - r/2 - b/2;

% Threshold the image
bw = justGreen > 50;

imwrite(bw,'img/mask.png')
mask = bw;

end

