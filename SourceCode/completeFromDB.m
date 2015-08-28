function isCompleted = completeFromDB()

    isCompleted = 'false';
    dirName = 'C:\project\PuzzleDazzle\DB\';              
    files = dir( fullfile(dirName,'*.jpg') );   
    files = {files.name}';                      

    global input_puzzle_red
    global puzzle_from_DB
    ImageCompare = input_puzzle_red;
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
            puzzle_from_DB = imread(fname);
        end 
    end
    
    if (minDif < 0.001)
        assignin('base','puzzle_from_DB',puzzle_from_DB);
        imageFromDB();
        % here was "waitforbuttonpress"
        pause(1);
        global DB_found
        isCompleted = DB_found;    
    end 

