function varargout = pickPiece(varargin)
% PICKPIECE MATLAB code for pickPiece.fig
%      PICKPIECE, by itself, creates a new PICKPIECE or raises the existing
%      singleton*.
%
%      H = PICKPIECE returns the handle to a new PICKPIECE or the handle to
%      the existing singleton*.
%
%      PICKPIECE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PICKPIECE.M with the given input arguments.
%
%      PICKPIECE('Property','Value',...) creates a new PICKPIECE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pickPiece_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pickPiece_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pickPiece

% Last Modified by GUIDE v2.5 03-Jun-2015 18:25:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pickPiece_OpeningFcn, ...
                   'gui_OutputFcn',  @pickPiece_OutputFcn, ...
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


% --- Executes just before pickPiece is made visible.
function pickPiece_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pickPiece (see VARARGIN)

% Choose default command line output for pickPiece
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% create an axes that spans the whole gui
ah = axes('unit', 'normalized', 'position', [0 0 1 1]);

% import the background image and show it on the axes
bg = imread('C:\Project\PuzzleDazzle\backgrounds\try2.png'); imagesc(bg);

% prevent plotting over the background and turn the axis off
set(ah,'handlevisibility','off','visible','off')

global DB_found;
if strcmp(DB_found,'false')
  set(handles.tryAgain, 'visible', 'on');
end

% UIWAIT makes pickPiece wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pickPiece_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% show pieces
global count_pieces
create_field(hObject, 2, count_pieces ,80, 10);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in downloadAll.
function downloadAll_Callback(hObject, eventdata, handles)
% hObject    handle to downloadAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bigImage;
[fileName, pathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
  '*.*','All Files' },'Save Image',...
  'C:\Work\newfile.jpg');
  global resize_factor;
  global shrink_factor;
  global DB_found;
  if strcmp(DB_found,'true')
      imwrite (imresize(bigImage, resize_factor),strcat(pathName, fileName));
  else
      imwrite (imresize(bigImage, resize_factor/shrink_factor),strcat(pathName, fileName));
  end;



% --- Executes on button press in tryAgain.
function tryAgain_Callback(hObject, eventdata, handles)
% hObject    handle to tryAgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global try_again;
try_again = try_again + 1;
assignin('base','try_again',try_again);
if try_again >= 6
    errordlg('Cant try more than 3 times!', 'Error');
    disp('Cant try more than 6 times!');
else
    close('pickPiece');
    completePuzzle();
end;


% --- Executes during object creation, after setting all properties.
function tryAgain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tryAgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
