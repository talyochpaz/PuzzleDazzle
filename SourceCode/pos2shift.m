function [shiftI,shiftJ] = pos2shift(posI,posJ)

M = size(posI,1);
N = size(posJ,2);

shiftI = zeros(M,N,'int32');
shiftJ = zeros(M,N,'int32');

for i=1:M
	for j=1:N
		shiftI(i,j) = posI(i,j) - i;
		shiftJ(i,j) = posJ(i,j) - j;
	end
end


