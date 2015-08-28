function [Iout,Idense] = build_output(I1,I2,shiftI,shiftJ,Iout_scale,animation_time)
% The purpose of this method is to build new images using a shift-map. The
% method uses a crude way of interpolating shifts as a means of reducing 'tear'.
% TODO: Could be made alot neater.

if nargin < 6
    animation_time = 1;
end
if nargin < 5
	Iout_scale = 1;
end
s = Iout_scale; % for convenience.


M1 = size(I1,1);
N1 = size(I1,2);
M2 = size(I2,1);
N2 = size(I2,2);

[posI,posJ] = shift2pos(round(shiftI*animation_time),round(shiftJ*animation_time));

posIr = round(posI*s);
posJr = round(posJ*s);
posIc = ceil(posI*s);
posJc = ceil(posJ*s);
posIf = floor(posI*s);
posJf = floor(posJ*s);
[shiftI_r,shiftJ_r] = pos2shift(posIr,posJr);
[shiftI_c,shiftJ_c] = pos2shift(posIc,posJc);
[shiftI_f,shiftJ_f] = pos2shift(posIf,posJf);

M2s = round(M2*s);
N2s = round(N2*s);

Iout = 255*ones(M2s,N2s,3,'uint8');
% Make sure to cover as much of Iout as possible, and avoid rounding errors.
for i = 1:M1
	for j = 1:N1
		if i+shiftI_c(i,j)>0 && j+shiftJ_c(i,j)>0 && i+shiftI_c(i,j)<=M2s && j+shiftJ_c(i,j)<=N2s
			Iout(i+shiftI_c(i,j),j+shiftJ_c(i,j),1) = I1(i, j, 1);
			Iout(i+shiftI_c(i,j),j+shiftJ_c(i,j),2) = I1(i, j, 2);
			Iout(i+shiftI_c(i,j),j+shiftJ_c(i,j),3) = I1(i, j, 3);
		end
	end
end
for i = 1:M1
	for j = 1:N1
		if i+shiftI_f(i,j)>0 && j+shiftJ_f(i,j)>0 && i+shiftI_f(i,j)<=M2s && j+shiftJ_f(i,j)<=N2s
			Iout(i+shiftI_f(i,j),j+shiftJ_f(i,j),1) = I1(i, j, 1);
			Iout(i+shiftI_f(i,j),j+shiftJ_f(i,j),2) = I1(i, j, 2);
			Iout(i+shiftI_f(i,j),j+shiftJ_f(i,j),3) = I1(i, j, 3);
		end
	end
end

Idense = zeros(M1,N1,3,'uint8');
for i = 1:M1
	for j = 1:N1
		if i+shiftI(i,j)>0 && j+shiftJ(i,j)>0 && i+shiftI(i,j)<=M2 && j+shiftJ(i,j)<=N2
			Idense(i,j,1) = I2(i+shiftI(i,j), j+shiftJ(i,j), 1);
			Idense(i,j,2) = I2(i+shiftI(i,j), j+shiftJ(i,j), 2);
			Idense(i,j,3) = I2(i+shiftI(i,j), j+shiftJ(i,j), 3);
		end
		if i+shiftI_r(i,j)>0 && j+shiftJ_r(i,j)>0 && i+shiftI_r(i,j)<=M2s && j+shiftJ_r(i,j)<=N2s
			Iout(i+shiftI_r(i,j),j+shiftJ_r(i,j),1) = I1(i, j, 1);
			Iout(i+shiftI_r(i,j),j+shiftJ_r(i,j),2) = I1(i, j, 2);
			Iout(i+shiftI_r(i,j),j+shiftJ_r(i,j),3) = I1(i, j, 3);
		end
	end
end



