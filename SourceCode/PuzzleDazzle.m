function varargout = PuzzleDazzle(varargin)
% PUZZLEDAZZLE MATLAB code for PuzzleDazzle.fig
%      PUZZLEDAZZLE, by itself, creates a new PUZZLEDAZZLE or raises the existing
%      singleton*.
%
%      H = PUZZLEDAZZLE returns the handle to a new PUZZLEDAZZLE or the handle to
%      the existing singleton*.
%
%      PUZZLEDAZZLE('CALLBACK',hObject,eventData,handles,...) calls the
%      localclecr
%      function named CALLBACK in PUZZLEDAZZLE.M with the given input arguments.
%
%      PUZZLEDAZZLE('Property','Value',...) creates a new PUZZLEDAZZLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PuzzleDazzle_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PuzzleDazzle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PuzzleDazzle

% Last Modified by GUIDE v2.5 07-Jun-2015 20:30:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PuzzleDazzle_OpeningFcn, ...
                   'gui_OutputFcn',  @PuzzleDazzle_OutputFcn, ...
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


% --- Executes just before PuzzleDazzle is made visible.
function PuzzleDazzle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PuzzleDazzle (see VARARGIN)

% Choose default command line output for PuzzleDazzle
handles.output = hObject;

% create an axes that spans the whole gui
ah = axes('unit', 'normalized', 'position', [0 0 1 1]);

% import the background image and show it on the axes
bg = imread('C:\project\PuzzleDazzle\backgrounds\Puzzle_1111.jpg'); imagesc(bg);

% prevent plotting over the background and turn the axis off
set(ah,'handlevisibility','off','visible','off')

% making sure the background is behind all the other uicontrols
uistack(ah, 'bottom');

% Update handles structure
guidata(hObject, handles);

global try_again;
try_again = 0;
assignin('base','try_again',try_again);


% UIWAIT makes PuzzleDazzle wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PuzzleDazzle_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uploadPuzzle();



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_puzzle_red
global input_puzzle_white
if isempty(input_puzzle_red)==true || isempty(input_puzzle_white)==true
    errordlg('No puzzles were found - please upload puzzle', 'Complete Error');
else
    completePuzzle();
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

p =  get(0,'MonitorPositions');
global input_puzzle_white
global completed_puzzle
global puzzle_parts
if isempty(input_puzzle_white) || isempty(completed_puzzle) || isempty(puzzle_parts)
    errordlg('No results to show', 'Error');
    disp('No results to show');
else
    %figure('name', 'Puzzle Mask','position', [1,1,(p(3)/3),(p(4)/3)]),imshow(puzzle_mask, 'InitialMagnification','fit');
    figure('name', 'Original Puzzle', 'position', [1,1,(p(3)/3),(p(4)/3)]),imshow(input_puzzle_white, 'InitialMagnification','fit');
    figure('name', 'Completed Puzzle','position', [(p(3)/3),1,(p(3)/3),(p(4)/3)]),imshow(completed_puzzle, 'InitialMagnification','fit');
    figure('name', 'Missing Pieces', 'position', [2*(p(3)/3),1,(p(3)/3),(p(4)/3)]),imshow(puzzle_parts, 'InitialMagnification','fit');
    %figure('name', 'Final Pieces', 'position', [2*(p(3)/3),1,(p(3)/3),(p(4)/3)]),imshow(bigImage, 'InitialMagnification','fit');
    %imwrite(imresize(bigImage,0.576), 'heliResize1.jpg');
end;
