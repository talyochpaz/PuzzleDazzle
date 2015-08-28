function varargout = imageFromDB(varargin)
% IMAGEFROMDB MATLAB code for imageFromDB.fig
%      IMAGEFROMDB, by itself, creates a new IMAGEFROMDB or raises the existing
%      singleton*.
%
%      H = IMAGEFROMDB returns the handle to a new IMAGEFROMDB or the handle to
%      the existing singleton*.
%
%      IMAGEFROMDB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEFROMDB.M with the given input arguments.
%
%      IMAGEFROMDB('Property','Value',...) creates a new IMAGEFROMDB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageFromDB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageFromDB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageFromDB

% Last Modified by GUIDE v2.5 27-May-2015 14:33:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imageFromDB_OpeningFcn, ...
                   'gui_OutputFcn',  @imageFromDB_OutputFcn, ...
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


% --- Executes just before imageFromDB is made visible.
function imageFromDB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imageFromDB (see VARARGIN)

% Choose default command line output for imageFromDB
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% create an axes that spans the whole gui
ah = axes('unit', 'normalized', 'position', [0 0 1 1]);

% import the background image and show it on the axes
bg = imread('C:\Project\PuzzleDazzle\backgrounds\genericBigger.png'); imagesc(bg);

% prevent plotting over the background and turn the axis off
set(ah,'handlevisibility','off','visible','off')


global puzzle_from_DB
image(puzzle_from_DB)
axes(handles.axes1)
axis off
axis image

% UIWAIT makes imageFromDB wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imageFromDB_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
w = waitforbuttonpress;
while w>0
   w = waitforbuttonpress;
end


% --- Executes on button press in YesButton.
function YesButton_Callback(hObject, eventdata, handles)
% hObject    handle to YesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DB_found
DB_found = 'true';
assignin('base','DB_found',DB_found);
close('imageFromDB');



% --- Executes on button press in NoButton.
function NoButton_Callback(hObject, eventdata, handles)
% hObject    handle to NoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DB_found
DB_found = 'false';
assignin('base','DB_found',DB_found);
close('imageFromDB');
