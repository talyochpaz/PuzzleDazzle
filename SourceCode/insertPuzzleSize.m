function varargout = insertPuzzleSize(varargin)
% INSERTPUZZLESIZE MATLAB code for insertPuzzleSize.fig
%      INSERTPUZZLESIZE, by itself, creates a new INSERTPUZZLESIZE or raises the existing
%      singleton*.
%
%      H = INSERTPUZZLESIZE returns the handle to a new INSERTPUZZLESIZE or the handle to
%      the existing singleton*.
%
%      INSERTPUZZLESIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSERTPUZZLESIZE.M with the given input arguments.
%
%      INSERTPUZZLESIZE('Property','Value',...) creates a new INSERTPUZZLESIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before insertPuzzleSize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to insertPuzzleSize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help insertPuzzleSize

% Last Modified by GUIDE v2.5 26-May-2015 21:58:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @insertPuzzleSize_OpeningFcn, ...
                   'gui_OutputFcn',  @insertPuzzleSize_OutputFcn, ...
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


% --- Executes just before insertPuzzleSize is made visible.
function insertPuzzleSize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to insertPuzzleSize (see VARARGIN)

% Choose default command line output for insertPuzzleSize
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes insertPuzzleSize wait for user response (see UIRESUME)
% uiwait(handles.insertPuzzleSize);


% --- Outputs from this function are returned to the command line.
function varargout = insertPuzzleSize_OutputFcn(hObject, eventdata, handles) 
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



function WidthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to WidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WidthEdit as text
%        str2double(get(hObject,'String')) returns contents of WidthEdit as a double


% --- Executes during object creation, after setting all properties.
function WidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  close('insertPuzzleSize');


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    width_cm = get(handles.WidthEdit, 'String');
    height_cm = get(handles.HeightEdit, 'String');
    if isempty(width_cm) && isempty(height_cm)
      errordlg('Please insert width and height !', 'Dimensions Error');
    elseif isempty(width_cm)
      errordlg('Please insert width !', 'Dimensions Error');
    elseif isempty(height_cm)
      errordlg('Please insert height !', 'Dimensions Error');
    elseif all(ismember(width_cm, '0123456789+-.eEdD'))==false
      errordlg('Width is invalid, please enter a number!', 'Dimensions Error'); 
    elseif all(ismember(height_cm, '0123456789+-.eEdD'))==false
      errordlg('Height is invalid, please enter a number!', 'Dimensions Error');
    else
        global input_puzzle_white
        global resize_factor
        height_cm = str2num(height_cm);
        width_cm = str2num(width_cm);
        [height_pixles, width_pixles, depth] = size(input_puzzle_white);
        resize_factor = ( height_cm * 37.8 ) / height_pixles;
        assignin('base','resize_factor',resize_factor);
        close('insertPuzzleSize');
    end     



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to HeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeightEdit as text
%        str2double(get(hObject,'String')) returns contents of HeightEdit as a double


% --- Executes during object creation, after setting all properties.
function HeightEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
