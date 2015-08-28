function [ imgCell, newImgCell, count_pieces ] = unifyPieces( puzzle_mask, puzzle_parts )

%find puzzle pieces
st = regionprops(puzzle_mask, 'BoundingBox' );

%init varibale
nRows = round((length(st) + 1)/2);
nCols =2;
imgCell = cell(nRows,nCols);
longestRow=0;
longestCol=0;

count_pieces = 0;
global DB_found
if strcmp(DB_found,'true')
    thresh = 200;
else
    thresh = 40;
end;

%figure; imshow(puzzle_parts);

r1c1 = zeros(length(st),2);
%insert missing puzlle pieces into cell array
for k = 1 : length(st)
	thisBB = st(k).BoundingBox; 
	subImage = imcrop(puzzle_parts, thisBB);
	[r1, c1 , d1] = size(subImage);
%     r1c1(k,:) = [r1 c1];
    if r1>thresh && c1>thresh
        count_pieces = count_pieces+1;
        longestRow=max(longestRow,r1);
        longestCol=max(longestCol,c1);
        nchannels = size(subImage,3);
        imgCell{count_pieces} = subImage;
        rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 );
    end;
end;
% [~,I] = sort(r1c1);
% sorted = r1c1(I)
imgCell = imgCell(1:count_pieces);
%fill in NaN values with zeros
imgCell(cellfun(@isempty,imgCell)) = {uint8(zeros(longestRow,longestCol,nchannels))};
%save individual pieces 
for k = 1 : count_pieces
  %convert black backgroung to white
  idx = all(imgCell{k}==0,3);  
  imgCell{k}(repmat(idx,[1,1,3]))=255;
end;

newImgCell = imgCell;

%zero padding in order to match matrix dimention
for k = 1 : count_pieces
	imgCell{k} = [ imgCell{k}, zeros(size(imgCell{k},1), longestCol-size(imgCell{k},2), nchannels); ...
	zeros(longestRow-size(imgCell{k},1), longestCol, nchannels)];
end;

end

