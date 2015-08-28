function create_field(hparent, nx, ny, width, padding)
global newImgCell
%'String','<html><img src="file:/C:\Project\PuzzleDazzle\images\puzzlePieces.jpg"/></html>',...
        % Create button grid
        for p = 1:nx
                for q = 1:ny
                        bpos = [                  % Button spec:
                           40+(p-1)*(width+padding)  %  - X
                           360-((q-1)*(width+padding))  %  - Y
                           width                  %  - W
                           width                  %  - H
                        ];
                        bpos2 = [                  % Button spec:
                           40+(p-1)*(width+padding*3)  %  - X
                           385-(q-1)*(width+padding)  %  - Y
                           width                  %  - W
                           width/3                %  - H
                        ];
                        if p==1
                            showedImgCell{q} = newImgCell{q};
                            showedImgCell{q} =imresize(showedImgCell{q}, [80 80]);
                            uicontrol('style','push',    ...
                                      'pos', bpos,       ...
                                      'cdata',showedImgCell{q},...
                                      'Units','pixels',  ...
                                      'Tag', sprintf('X%dY%d',p,q) );
                        else
                        uicontrol(                              ...
                           'Units',     'pixels',               ...
                           'Tag',       sprintf('X%dY%d',p,q),  ...
                           'Style',     'pushbutton',                 ...
                           'Parent',    hparent,                ...
                           'Position',  bpos2 ,                  ... 
                           'String',    'download',              ...
                           'CallBack', {@download_Callback, newImgCell{q} }    ...
                        );
                end;
        end;
     end;

    
    function download_Callback(hObj,evnt, piece)
    [fileName, pathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
      '*.*','All Files' },'Save Image',...
      'C:\Work\newfile.jpg');
      global resize_factor;
      global shrink_factor;
      global DB_found;
      if strcmp(DB_found,'true')
          imwrite (imresize(piece, resize_factor),strcat(pathName, fileName));
      else
          imwrite (imresize(piece, resize_factor/shrink_factor),strcat(pathName, fileName));
      end;
    end
end
