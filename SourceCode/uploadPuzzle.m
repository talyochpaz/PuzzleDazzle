function varargout = uploadPuzzle(varargin)
% UPLOADPUZZLE MATLAB code for uploadPuzzle.fig
%      UPLOADPUZZLE, by itself, creates a new UPLOADPUZZLE or raises the existing
%      singleton*.
%
%      H = UPLOADPUZZLE returns the handle to a new UPLOADPUZZLE or the handle to
%      the existing singleton*.
%
%      UPLOADPUZZLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UPLOADPUZZLE.M with the given input arguments.
%
%      UPLOADPUZZLE('Property','Value',...) creates a new UPLOADPUZZLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uploadPuzzle_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uploadPuzzle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help uploadPuzzle

% Last Modified by GUIDE v2.5 20-Apr-2015 16:54:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uploadPuzzle_OpeningFcn, ...
                   'gui_OutputFcn',  @uploadPuzzle_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before uploadPuzzle is made visible.
function uploadPuzzle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to uploadPuzzle (see VARARGIN)

% Choose default command line output for uploadPuzzle
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes uploadPuzzle wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = uploadPuzzle_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% create an axes that spans the whole gui
ah = axes('unit', 'normalized', 'position', [0 0 1 1]);

% import the background image and show it on the axes
bg = imread('C:\Project\PuzzleDazzle\backgrounds\generic.png'); imagesc(bg);

% prevent plotting over the background and turn the axis off
set(ah,'handlevisibility','off','visible','off')

global input_puzzle_red
global input_puzzle_white
if isempty(input_puzzle_red)==false
    set(handles.checkbox2, 'visible', 'on');
    set(handles.checkbox2, 'value', true);
    set(handles.checkbox2, 'enable', 'off');
end
if isempty(input_puzzle_white)==false
    set(handles.checkbox1, 'visible', 'on');
    set(handles.checkbox1, 'value', true);
    set(handles.checkbox1, 'enable', 'off');
end



% --- Executes on button press in uploadWhiteButton.
function uploadWhiteButton_Callback(hObject, eventdata, handles)
% hObject    handle to uploadWhiteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global input_puzzle_white
    disp('Load white image button pressed ...')
    
    % Create a file dialog for images
    [filename, user_cancelled] = imgetfile;
    if user_cancelled
            disp('User pressed cancel')
    else
            disp(['User selected ', filename])

    % Read the selected image into the variable
    input_puzzle_white = imread(filename);
    
    % Copy input_puzzle to base workspace, overwriting the content !!!
    assignin('base','input_puzzle_white',input_puzzle_white);  
    
    % Now you have input_puzzle variable in the base workspace
	%figure('name', 'Input Puzzle (white background)');
	%imshow(input_puzzle_white);

    set(handles.checkbox1, 'visible', 'on');
    set(handles.checkbox1, 'value', true);
    set(handles.checkbox1, 'enable', 'off');
    
    end

    % --- Executes on button press in uploadRedButton.
function uploadRedButton_Callback(hObject, eventdata, handles)
% hObject    handle to uploadRedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global input_puzzle_red
    disp('Load red image button pressed ...')
    
    % Create a file dialog for images
    [filename, user_cancelled] = imgetfile;
    if user_cancelled
            disp('User pressed cancel')
    else
            disp(['User selected ', filename])

    % Read the selected image into the variable
    input_puzzle_red = imread(filename);
    
    % Copy input_puzzle to base workspace, overwriting the content !!!
    assignin('base','input_puzzle_red',input_puzzle_red);  
    
    % Now you have input_puzzle variable in the base workspace
	%figure('name', 'Input Puzzle (red background)');
	%imshow(input_puzzle_red);
    
    set(handles.checkbox2, 'visible', 'on');
    set(handles.checkbox2, 'value', true);
    set(handles.checkbox2, 'enable', 'off');

    end
    
% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA))
    global input_puzzle_red
    global input_puzzle_white
    if isempty(input_puzzle_red)==true && isempty(input_puzzle_white)==true
        errordlg('No images were found - please upload', 'Upload Error');
        disp('No images were found - please upload');
    elseif isempty(input_puzzle_red)==true
        errordlg('Red image wasnt found - please upload', 'Upload Error');
        disp('Red image wasnt found - please upload');
    elseif isempty(input_puzzle_white)==true
        errordlg('White image wasnt found - please upload', 'Upload Error');
        disp('White image wasnt found - please upload');
    elseif isequal(size(input_puzzle_red),size(input_puzzle_white))==false
        errordlg('Images dimensions must match!', 'Upload Error');
        disp('Images dimensions must match!');
    else
       close('uploadPuzzle');
       insertPuzzleSize();
    end      

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global input_puzzle_red
    global input_puzzle_white
    input_puzzle_red = [];
    input_puzzle_white = [];
    assignin('base','input_puzzle_red',input_puzzle_red);
    assignin('base','input_puzzle_white',input_puzzle_white);
    close('uploadPuzzle');
    

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
