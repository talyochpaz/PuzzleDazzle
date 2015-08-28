function varargout = completePuzzle(varargin)
% COMPLETEPUZZLE MATLAB code for completePuzzle.fig
%      COMPLETEPUZZLE, by itself, creates a new COMPLETEPUZZLE or raises the existing
%      singleton*.
%
%      H = COMPLETEPUZZLE returns the handle to a new COMPLETEPUZZLE or the handle to
%      the existing singleton*.
%
%      COMPLETEPUZZLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPLETEPUZZLE.M with the given input arguments.
%
%      COMPLETEPUZZLE('Property','Value',...) creates a new COMPLETEPUZZLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before completePuzzle_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to completePuzzle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help completePuzzle

% Last Modified by GUIDE v2.5 27-Apr-2015 13:52:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @completePuzzle_OpeningFcn, ...
                   'gui_OutputFcn',  @completePuzzle_OutputFcn, ...
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


% --- Executes just before completePuzzle is made visible.
function completePuzzle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to completePuzzle (see VARARGIN)

% Choose default command line output for completePuzzle
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% create an axes that spans the whole gui
ah = axes('unit', 'normalized', 'position', [0 0 1 1]);

% import the background image and show it on the axes
bg = imread('C:\Project\PuzzleDazzle\backgrounds\generic.png'); imagesc(bg);

% prevent plotting over the background and turn the axis off
set(ah,'handlevisibility','off','visible','off')

h1 = uicontrol('style','push',  'pos', [115,115,255,108], 'String','<html><img src="file:/C:\Project\PuzzleDazzle\backgrounds\ezgif.com-resize.gif"/></html>');

% UIWAIT makes completePuzzle wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = completePuzzle_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

global try_again;
global puzzle_mask
global DB_found
global completed_puzzle
global puzzle_parts

% search in DB on the 1st time only
if try_again < 1

    disp('Trying to find puzzle in DB...');
    DB_found = completeFromDB();
    assignin('base','DB_found',DB_found);

end;

if strcmp(DB_found,'true')
    disp('Found puzzle in DB!');
    
    % create mask
    disp('Creating mask...');
    puzzle_mask = createMask();
    assignin('base','puzzle_mask',puzzle_mask);
    disp('Mask was created');
    global puzzle_from_DB
    completed_puzzle = puzzle_from_DB;
    
else 
    disp('Puzzle wasnt found in DB, starting inapint...');
    completeInpaint();
    global inpainted_puzzle
    completed_puzzle = inpainted_puzzle;
    global resized_mask
    puzzle_mask = resized_mask;
    assignin('base','puzzle_mask',resized_mask);
end

% extract pieces
puzzle_parts = extractPieces(completed_puzzle, puzzle_mask);
    
    
% unify pieces
global count_pieces
global bigImage
global newImgCell
[imgCell, newImgCell, count_pieces] = unifyPieces( puzzle_mask, puzzle_parts );
%concatenate images
bigImage=cell2mat(imgCell);
%convert black backgroung to white
idx = all(bigImage==0,3);
bigImage(repmat(idx,[1,1,3]))=255;
assignin('base','bigImage',bigImage);

% show results
close('completePuzzle');
pickPiece();
assignin('base','completed_puzzle',completed_puzzle);
assignin('base','puzzle_parts',puzzle_parts);

