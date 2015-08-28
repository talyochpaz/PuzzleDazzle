function [posI,posJ] = shift2pos(shiftI,shiftJ)

M = size(shiftI,1);
N = size(shiftJ,2);

posI = zeros(M,N);
posJ = zeros(M,N);

for i=1:M
	for j=1:N
		posI(i,j) = i + shiftI(i,j);
		posJ(i,j) = j + shiftJ(i,j);
	end
end


