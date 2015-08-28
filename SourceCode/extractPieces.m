function img = extractPieces(DBimage,imagemask)
	img=DBimage.*uint8(repmat(imagemask,[1 1 3]));	
end