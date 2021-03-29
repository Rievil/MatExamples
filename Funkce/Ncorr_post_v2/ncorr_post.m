function varargout = ncorr_post(varargin)
% NCORR_POST_v2 MATLAB code for ncorr_post.fig
%
%      To change the figure background look for "InvertHardCopy" !!!
%
%      NCORR_POST, by itself, creates a new NCORR_POST or raises the existing
%      singleton*.
%
%      H = NCORR_POST_v1_2 returns the handle to a new NCORR_POST or the handle to
%      the existing singleton*.
%
%      NCORR_POST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NCORR_POST.M with the given input arguments.
%
%      NCORR_POST('Property','Value',...) creates a new NCORR_POST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ncorr_post_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ncorr_post_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ncorr_post

% Last Modified by GUIDE v2.5 27-Dec-2015 12:19:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ncorr_post_OpeningFcn, ...
    'gui_OutputFcn',  @ncorr_post_OutputFcn, ...
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


% --- Executes just before ncorr_post is made visible.
function ncorr_post_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ncorr_post (see VARARGIN)

% Choose default command line output for ncorr_post
handles.output = hObject;

% move GUI to the center
movegui(gcf,'center');

% clear command window
clc

% save handles to mainGui and functions into root memory
setappdata(0,'handles_mainGui',gcf)                 % get handles to main GUI
setappdata(gcf, 'handles_updateAxes', @updateAxes)  % get handles to updateAxes function
set(0, 'DefaultFigureInvertHardCopy', 'off');       % printing figures with required background

% Add path to other folders
addpath(fullfile(pwd,'functions'))
addpath(fullfile(pwd,'files'))
addpath(fullfile(pwd,'export'))

% Remove axis
axes(handles.axes1); % set the current axes to axes1
axis off
axes(handles.axes2);
axis off
axes(handles.axes3);
axis off
axes(handles.axes4);
axis off
axes(handles.axes5);
axis off
axes(handles.axes6);
axis off

% prepare GUI
run initiateGUI_handles

% initiate quantities to display and other arrays
run initiateArrays

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ncorr_post wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ncorr_post_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton8 = Load data from Ncorr.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = struct;

% get the Ncorr data
run getNcorrData_v1_2
run initiateArrays

set(handles.pushbutton21,'Enable', 'on')
set(handles.pushbutton18,'Enable', 'on')
set(handles.pushbutton10,'Enable', 'on')
set(handles.pushbutton3,'Enable', 'on')
set(handles.pushbutton6,'Enable', 'on')
set(handles.pushbutton5,'Enable', 'on')
set(handles.pushbutton1,'Enable', 'on')
set(handles.pushbutton2,'Enable', 'on')
set(handles.pushbutton22,'Enable', 'on')
set(handles.pushbutton23,'Enable', 'on')
set(handles.pushbutton29,'Enable', 'on')
set(handles.pushbutton30,'Enable', 'on')
set(handles.listbox1,'Enable', 'on')
set(handles.slider1,'Enable', 'on')
set(handles.edit2,'Enable', 'on')
set(handles.edit3,'Enable', 'on')
set(handles.edit4,'Enable', 'on')

plottingData(1).currentImage = plottingData(1).nFiles; % display the last image
plottingData(1).currentQuantity = 1; % display strain xx
plottingData(1).transparency = 0.3;

plottingData(1).avgRadius = 3;
set(handles.edit5,'String', sprintf('%d',plottingData(1).avgRadius))

set(handles.listbox1,'String', plottingData(1).quantitiesToDisplay)
set(handles.popupmenu1,'String', plottingData(1).extensometerColor)
set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))

% set step-size edit box (edit10)
plottingData(1).stepSize = min(5,plottingData(1).nFiles);
set(handles.edit10,'String', num2str(plottingData(1).stepSize))

setappdata(handles_mainGui, 'plottingData', plottingData);
setappdata(handles_mainGui, 'handles', handles);

updateAxes

plottingData(1).upperBound = max(plottingData(end).strains_xx(:));
plottingData(1).lowerBound = min(plottingData(end).strains_xx(:));

setappdata(handles_mainGui, 'plottingData', plottingData);
setappdata(handles_mainGui, 'handles', handles);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).currentQuantity = get(hObject,'Value');

nSavedBounds = length(plottingData(1).lowerBound);
if  nSavedBounds < plottingData(1).currentQuantity
    plottingData(1).justInitialized = true;
elseif plottingData(1).lowerBound(plottingData(1).currentQuantity) == 0 && plottingData(1).upperBound(plottingData(1).currentQuantity) == 0
    plottingData(1).justInitialized = true;
else
    set(handles.edit2,'String', sprintf('%f', plottingData(1).lowerBound(plottingData(1).currentQuantity))) % lower bound
    set(handles.edit3,'String', sprintf('%f', plottingData(1).upperBound(plottingData(1).currentQuantity)))
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

if ~plottingData(1).isScaled && (plottingData(1).currentQuantity == 6 || plottingData(1).currentQuantity == 7)
    msgbox('The displacements have not been scaled to meters','Warning!')
end


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

shortNotation = char(plottingData(1).shortNotation(plottingData(1).currentQuantity));

if plottingData(1).zoomed
    shortNotation = [shortNotation,'_zoom'];
end

imageName = extractExtension(plottingData(plottingData(1).currentImage).names);
exportFolderName = strcat('export/',plottingData(1).projectName,'/',shortNotation);
exportImageName = strcat(exportFolderName,'/',plottingData(1).projectName,'-',imageName,'_',shortNotation,'.png');

tempFigure = figure('Position', [100, 100, 800, 600]);
updateAxes_figureSaving

if ~isequal(exist(char(strcat('export/',plottingData(1).projectName)), 'dir'),7) % check whether the destination folder exists
    mkdir(strcat(pwd,'/export'),char(plottingData(1).projectName))
end
if ~isequal(exist(char(exportFolderName), 'dir'),7) % check whether the destination folder exists
    mkdir(strcat(pwd,char(strcat('/export/',plottingData(1).projectName))),shortNotation)
end

print(tempFigure,'-dpng',char(exportImageName))
close(tempFigure)
msgbox('Figure saved successfuly');


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

progressbar(0)
for i = 1:plottingData(1).nFiles
    plottingData(1).currentImage = i;
    set(handles.edit4,'String', sprintf('%d', plottingData(1).currentImage))
    
    imageName = extractExtension(plottingData(plottingData(1).currentImage).names);
    exportFolderName = strcat('export/',plottingData(1).projectName,'/',plottingData(1).shortNotation(plottingData(1).currentQuantity));
    exportImageName = strcat(exportFolderName,'/',plottingData(1).projectName,'-',imageName,'_',...
        char(plottingData(1).shortNotation(plottingData(1).currentQuantity)),'.png');
    
    tempFigure = figure('Position', [100, 100, 800, 600]);
    setappdata(handles_mainGui, 'plottingData', plottingData);
    updateAxes_figureSaving
    
    set(tempFigure, 'color', [0 0 0])
    set(tempFigure, 'InvertHardCopy', 'off');
    cb = colorbar;
    set(cb,'YColor',[1 1 1]);
    
    if ~isequal(exist(char(strcat('export/',plottingData(1).projectName)), 'dir'),7) % check whether the destination folder exists
        mkdir(strcat(pwd,'/export'),char(plottingData(1).projectName))
    end
    if ~isequal(exist(char(exportFolderName), 'dir'),7) % check whether the destination folder exists
        mkdir(strcat(pwd,char(strcat('/export/',plottingData(1).projectName))),char(plottingData(1).shortNotation(plottingData(1).currentQuantity)))
    end
    print(tempFigure,'-dpng',char(exportImageName))
    close(tempFigure)
    progressbar(i/plottingData(1).nFiles)
end
msgbox('All figures saved successfuly');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

currentFolder = pwd; % do not delete, necessary for run scaleDisplacements
run scaleDisplacements
plottingData(1).pxDistance = pxDistance; % distance between 2 pixels [m]
handles_textBox = findobj('Style','text','Tag','text44'); % find handle of static text
set(handles_textBox,'String', sprintf('%f mm',plottingData(1).pxDistance*1000)) % update the static text field

for i = 1:plottingData(1).nFiles
    plottingData(i).displacements_x_scaled = plottingData(i).displacements_x*plottingData(1).pxDistance;
    plottingData(i).displacements_y_scaled = plottingData(i).displacements_y*plottingData(1).pxDistance;
end
plottingData(1).isScaled = true;
set(handles.pushbutton24,'Enable', 'on')

set(handles.slider6, 'Max', plottingData(1).imgSize(2)*plottingData(1).pxDistance*1000);
set(handles.slider7, 'Max', plottingData(1).imgSize(1)*plottingData(1).pxDistance*1000);
set(handles.slider8, 'Max', plottingData(1).imgSize(2)*plottingData(1).pxDistance*1000);
set(handles.slider9, 'Max', plottingData(1).imgSize(1)*plottingData(1).pxDistance*1000);

setappdata(handles_mainGui, 'plottingData', plottingData);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).currentImage = plottingData(1).currentImage-1;
set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))

if plottingData(1).nVirtualExtensometers ~= 0
    P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
    P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
    run updateEditsAndSliders
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).currentImage = plottingData(1).currentImage+1;
set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))

if plottingData(1).nVirtualExtensometers ~= 0
    P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
    P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
    run calculateRelativeDisplacement
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).currentImage = 1;
set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))

if plottingData(1).nVirtualExtensometers ~= 0
    P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
    P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
    run calculateRelativeDisplacement
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).currentImage = plottingData(1).nFiles;
set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))

if plottingData(1).nVirtualExtensometers ~= 0
    P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
    P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
    run calculateRelativeDisplacement
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).stepSize = str2double(get(handles.edit10,'String'));

if plottingData(1).currentImage > plottingData(1).stepSize
    plottingData(1).currentImage = plottingData(1).currentImage-plottingData(1).stepSize;
else
    plottingData(1).currentImage = 1;
end
set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))

if plottingData(1).nVirtualExtensometers ~= 0
    P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
    P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
    run calculateRelativeDisplacement
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).stepSize = str2double(get(handles.edit10,'String'));

if plottingData(1).nFiles > plottingData(1).currentImage+plottingData(1).stepSize
    plottingData(1).currentImage = plottingData(1).currentImage+plottingData(1).stepSize;
else
    plottingData(1).currentImage = plottingData(1).nFiles;
end
set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))

if plottingData(1).nVirtualExtensometers ~= 0
    P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
    P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
    run calculateRelativeDisplacement
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

imNum = str2double(get(hObject,'String'));
plottingData(1).currentImage = min(max(imNum,1),plottingData(1).nFiles);
set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))

if plottingData(1).nVirtualExtensometers ~= 0
    P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
    P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
    run calculateRelativeDisplacement
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

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

function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

[inputFileName,inputPath] = uigetfile({'*.mat'},'MultiSelect', 'off',...
    'Select the project',[pwd,'/savedProjects']);

handles_msgBox = msgbox('This may take a while, please wait...','Loading a project');

load([inputPath,inputFileName])
run calculateOtherQuantities

run initiateArrays
set(handles.listbox1,'String', plottingData(1).quantitiesToDisplay)
set(handles.popupmenu1,'String', plottingData(1).extensometerColor)

run initiateGUI_handles
run loadGUI_handles

set(handles.edit4,'String', sprintf('%d',plottingData(1).currentImage))
plottingData(1).currentExtColor = get(handles.popupmenu1,'Value'); % get extensometer color

if ~isfield(plottingData,'stepSize')
    plottingData(1).stepSize = min(5,plottingData(1).nFiles);
    set(handles.edit10,'String', num2str(plottingData(1).stepSize))
else
    set(handles.edit10,'String', sprintf('%d',plottingData(1).stepSize))
end

if ~isfield(plottingData,'version')
    plottingData(1).avgRadius = 3;
    plottingData(1).imgSize = size(plottingData(1).originalImage);
    plottingData(1).nVirtualExtensometers = 0;
    
    tempUpperBound = ones(1,size(plottingData(1).quantitiesToDisplay,1))*plottingData(1).upperBound;
    tempLowerBound = ones(1,size(plottingData(1).quantitiesToDisplay,1))*plottingData(1).lowerBound;
    plottingData(1).upperBound = tempUpperBound;
    plottingData(1).lowerBound = tempLowerBound;
else
    if plottingData(1).nVirtualExtensometers > 0
        P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
        P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
        run updateEditsAndSliders
        run calculateRelativeDisplacement
    end
end

set(handles.edit5,'String', sprintf('%d',plottingData(1).avgRadius))

if plottingData(1).isScaled
    set(handles.slider6, 'Max', plottingData(1).imgSize(2)*plottingData(1).pxDistance*1000);
    set(handles.slider7, 'Max', plottingData(1).imgSize(1)*plottingData(1).pxDistance*1000);
    set(handles.slider8, 'Max', plottingData(1).imgSize(2)*plottingData(1).pxDistance*1000);
    set(handles.slider9, 'Max', plottingData(1).imgSize(1)*plottingData(1).pxDistance*1000);
    
    handles_textBox = findobj('Style','text','Tag','text44'); % find handle of static text
    set(handles_textBox,'String', sprintf('%f mm',plottingData(1).pxDistance*1000)) % update the static text field
end

setappdata(handles_mainGui, 'plottingData', plottingData);
setappdata(handles_mainGui, 'handles', handles);
updateAxes

close(handles_msgBox)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

% msgbox
handles_msgBox = msgbox('This may take a while, please wait...','Saving the project');
plottingData(1).version = '2.0';
plottingData(1).stepSize = str2double(get(handles.edit10,'String'));

% remove redundant data
plottingData = rmfield(plottingData,'principalStrain_max');
plottingData = rmfield(plottingData,'principalStrain_min');
plottingData = rmfield(plottingData,'principalAngle_t');
plottingData = rmfield(plottingData,'principalAngle_c');
plottingData = rmfield(plottingData,'strain_xx_princ');
plottingData = rmfield(plottingData,'strain_yy_princ');
plottingData = rmfield(plottingData,'hydrostaticStrain');
plottingData = rmfield(plottingData,'deviatoricStrain');

% saving the files
save(strcat('savedProjects/',char(plottingData(1).projectName),'.mat'),'plottingData','-v7.3')
run saveGUI_handles
run calculateOtherQuantities
close(handles_msgBox)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).transparency = get(hObject,'Value');

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).lowerBound(plottingData(1).currentQuantity)= str2double(get(hObject,'String'));
plottingData(1).upperBound(plottingData(1).currentQuantity)= str2double(get(handles.edit2,'String'));

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
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

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).upperBound(plottingData(1).currentQuantity)= str2double(get(hObject,'String'));
plottingData(1).lowerBound(plottingData(1).currentQuantity)= str2double(get(handles.edit3,'String'));

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

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

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).autoscaleBounds = get(hObject,'Value');

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).showOutOfRoi = get(hObject,'Value');

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).plotExtensometers = get(hObject,'Value');

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in checkbox1.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');
updateAxes

% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

run plotExtensometers

%%%%%%%%%%%%%%%%%%%%%%%%% ZOOMING SWITCH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

tempFigure = figure('Position', [100, 100, 800, 600]);
updateAxes_figureSaving

zoomRect = round(getrect(gca)); zoomRect(3) = zoomRect(1)+zoomRect(3); zoomRect(4) = zoomRect(2)+zoomRect(4);
plottingData(1).zoomed = true;
plottingData(1).zoomFactor = (zoomRect(3)-zoomRect(1))/size(plottingData(1).roiOriginalImage,2);
plottingData(1).originOffset = [zoomRect(1), zoomRect(2)];
plottingData(1).zoomRect = zoomRect;

% extract the chosen rectangle from the image
plottingData(1).plot_x_zoomed = zoomRect(1):1:zoomRect(3);
plottingData(1).plot_y_zoomed = zoomRect(2):1:zoomRect(4);
plottingData(1).roiOriginalImage_zoomed = plottingData(1).roiOriginalImage(...
    zoomRect(2):zoomRect(4),zoomRect(1):zoomRect(3),:);
plottingData(1).outOfRoiImage_zoomed = plottingData(1).outOfRoiImage(...
    zoomRect(2):zoomRect(4),zoomRect(1):zoomRect(3),:);
plottingData(1).roi_zoomed = plottingData(1).roi(...
    zoomRect(2):zoomRect(4),zoomRect(1):zoomRect(3),:);

% get the limits for plotted data (colormaps, vector fields)
relativeScaling = size(plottingData(1).displacements_x,2)/size(plottingData(1).roiOriginalImage,2);
plottingData(1).plot_x_quantities_zoomed = round(relativeScaling*[zoomRect(2), zoomRect(4)]);
plottingData(1).plot_y_quantities_zoomed = round(relativeScaling*[zoomRect(1), zoomRect(3)]);

close(tempFigure)

set(handles.pushbutton19,'Enable', 'on')
setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).zoomed = false;

set(handles.pushbutton19,'Enable', 'off') % goes last to swith off after it is used
setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).currentExtColor = get(hObject,'Value');

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

progressbar(0)
for i = 1:plottingData(1).nFiles
    plottingData(1).currentImage = i;
    
    imageName = extractExtension(plottingData(plottingData(1).currentImage).names);
    exportFolderName = strcat('export/',plottingData(1).projectName,'/',plottingData(1).shortNotation(plottingData(1).currentQuantity));
    
    exportImageName = strcat(exportFolderName,'/',plottingData(1).projectName,'-',imageName,'_',...
        char(plottingData(1).shortNotation(plottingData(1).currentQuantity)),'.png');
    
    tempFigure = figure('Position', [100, 100, 800, 600]);
    setappdata(handles_mainGui, 'plottingData', plottingData);
    updateAxes_figureSaving
    if ~isequal(exist(char(strcat('export/',plottingData(1).projectName)), 'dir'),7) % check whether the destination folder exists
        mkdir(strcat(pwd,'/export'),char(plottingData(1).projectName))
    end
    if ~isequal(exist(char(exportFolderName), 'dir'),7) % check whether the destination folder exists
        mkdir(strcat(pwd,char(strcat('/export/',plottingData(1).projectName))),char(plottingData(1).shortNotation(plottingData(1).currentQuantity)))
    end
    
    print(tempFigure,'-dpng',char(exportImageName))
    close(tempFigure)
    progressbar(i/plottingData(1).nFiles)
end

% Make avi movie

exportVideoFolderName = strcat('export/',plottingData(1).projectName,'/video_',plottingData(1).shortNotation(plottingData(1).currentQuantity));
exportVideoName = strcat(exportVideoFolderName,'/',plottingData(1).projectName,'-video_',...
    char(plottingData(1).shortNotation(plottingData(1).currentQuantity)),'.avi');

if ~isequal(exist(char(exportVideoFolderName), 'dir'),7) % check whether the destination folder exists
    mkdir(strcat(pwd,char(strcat('/export/',plottingData(1).projectName)),'/video_',char(plottingData(1).shortNotation(plottingData(1).currentQuantity))))
end

writerObj = VideoWriter(char(exportVideoName));
writerObj.FrameRate = 4; % frames per second

open(writerObj);
for i = 1:plottingData(1).nFiles
    plottingData(1).currentImage = i;
    imageName = extractExtension(plottingData(plottingData(1).currentImage).names);
    imageToVideo = strcat(exportFolderName,'/',plottingData(1).projectName,'-',imageName,'_',...
        char(plottingData(1).shortNotation(plottingData(1).currentQuantity)),'.png');
    writeVideo(writerObj,imread(char(imageToVideo)));
end
close(writerObj);
implay(char(exportVideoName))


%% Virtual Extensometers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).avgRadius = str2double(get(hObject,'String'));
P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
run updateEditsAndSliders
run calculateRelativeDisplacement

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).actualExtensometer = get(hObject,'Value');
P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
run updateEditsAndSliders
run calculateRelativeDisplacement

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).nVirtualExtensometers = plottingData(1).nVirtualExtensometers+1;
auxArray = 1:plottingData(1).nVirtualExtensometers;
plottingData(1).listOfExtensometers = strread(num2str(auxArray),'%s');
set(handles.listbox2,'String', plottingData(1).listOfExtensometers)
set(handles.listbox2,'Value', plottingData(1).nVirtualExtensometers)
plottingData(1).actualExtensometer = plottingData(1).nVirtualExtensometers;

newFigure = figure;
imshow(plottingData(1).originalImage)
axis image; %axis off;
xlabel({'Choose 2 points defining a certain distance by right-button';...
      'clicking your mouse, while zooming in by left-button clicking.'})
[position_x position_y] = ginput2(2);
close(newFigure)
P1 = [position_x(1), position_y(1)]; % used in calculateRelativeDisplacement
P2 = [position_x(2), position_y(2)]; % used in calculateRelativeDisplacement
run updateEditsAndSliders
run calculateRelativeDisplacement

set(handles.edit5,'Enable', 'on')
set(handles.edit6,'Enable', 'on')
set(handles.edit7,'Enable', 'on')
set(handles.edit8,'Enable', 'on')
set(handles.edit9,'Enable', 'on')
set(handles.slider6,'Enable', 'on')
set(handles.slider7,'Enable', 'on')
set(handles.slider8,'Enable', 'on')
set(handles.slider9,'Enable', 'on')
set(handles.listbox2,'Enable', 'on')
set(handles.checkbox4,'Enable', 'on')
set(handles.popupmenu1,'Enable', 'on')
set(handles.pushbutton17,'Enable', 'on')
set(handles.pushbutton24,'Enable', 'on')
set(handles.pushbutton25,'Enable', 'on')
set(handles.pushbutton26,'Enable', 'on')


setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

for i = plottingData(1).actualExtensometer:plottingData(1).nVirtualExtensometers-1
    plottingData(i).monitoringPoints = plottingData(i+1).monitoringPoints;
end

plottingData(1).nVirtualExtensometers = plottingData(1).nVirtualExtensometers-1;

if plottingData(1).nVirtualExtensometers ~= 0
    auxArray = 1:plottingData(1).nVirtualExtensometers;
    plottingData(1).listOfExtensometers = strread(num2str(auxArray),'%s');
    set(handles.listbox2,'String', plottingData(1).listOfExtensometers)
    set(handles.listbox2,'Value', plottingData(1).nVirtualExtensometers)
    plottingData(1).actualExtensometer = plottingData(1).nVirtualExtensometers;
    
    P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
    P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
    run updateEditsAndSliders
    run calculateRelativeDisplacement
else
    set(handles.listbox2,'String', 'all deleted')
    set(handles.listbox2,'Value', 1)
    set(handles.edit5,'Enable', 'off')
    set(handles.edit6,'Enable', 'off')
    set(handles.edit7,'Enable', 'off')
    set(handles.edit8,'Enable', 'off')
    set(handles.edit9,'Enable', 'off')
    set(handles.slider6,'Enable', 'off')
    set(handles.slider7,'Enable', 'off')
    set(handles.slider8,'Enable', 'off')
    set(handles.slider9,'Enable', 'off')
    set(handles.listbox2,'Enable', 'off')
    set(handles.checkbox4,'Enable', 'off')
    set(handles.popupmenu1,'Enable', 'off')
    set(handles.pushbutton17,'Enable', 'off')
    set(handles.pushbutton25,'Enable', 'off')
    set(handles.pushbutton26,'Enable', 'off')
    set(handles.pushbutton27,'Enable', 'off')
end

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

run saveExtensometerData


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
run calculateRelativeDisplacement

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
P1(1) = str2double(get(hObject,'String'))/(plottingData(1).pxDistance*1000);
run updateEditsAndSliders

set(handles.pushbutton27,'Enable', 'on')
set(handles.pushbutton27,'ForegroundColor', [1,0,0])
set(handles.pushbutton27,'FontSize', 12)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
P1(2) = str2double(get(hObject,'String'))/(plottingData(1).pxDistance*1000);
run updateEditsAndSliders

set(handles.pushbutton27,'Enable', 'on')
set(handles.pushbutton27,'ForegroundColor', [1,0,0])
set(handles.pushbutton27,'FontSize', 12)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
P1(1) = get(hObject,'Value')/(plottingData(1).pxDistance*1000);
run updateEditsAndSliders

set(handles.pushbutton27,'Enable', 'on')
set(handles.pushbutton27,'ForegroundColor', [1,0,0])
set(handles.pushbutton27,'FontSize', 12)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
P1(2) = get(hObject,'Value')/(plottingData(1).pxDistance*1000);
run updateEditsAndSliders

set(handles.pushbutton27,'Enable', 'on')
set(handles.pushbutton27,'ForegroundColor', [1,0,0])
set(handles.pushbutton27,'FontSize', 12)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
P2(1) = str2double(get(hObject,'String'))/(plottingData(1).pxDistance*1000);
run updateEditsAndSliders

set(handles.pushbutton27,'Enable', 'on')
set(handles.pushbutton27,'ForegroundColor', [1,0,0])
set(handles.pushbutton27,'FontSize', 12)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
P2(2) = str2double(get(hObject,'String'))/(plottingData(1).pxDistance*1000);
run updateEditsAndSliders

set(handles.pushbutton27,'Enable', 'on')
set(handles.pushbutton27,'ForegroundColor', [1,0,0])
set(handles.pushbutton27,'FontSize', 12)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
P2(1) = get(hObject,'Value')/(plottingData(1).pxDistance*1000);
run updateEditsAndSliders

set(handles.pushbutton27,'Enable', 'on')
set(handles.pushbutton27,'ForegroundColor', [1,0,0])
set(handles.pushbutton27,'FontSize', 12)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

P1 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(1),plottingData(plottingData(1).actualExtensometer).monitoringPoints(3)];
P2 = [plottingData(plottingData(1).actualExtensometer).monitoringPoints(2),plottingData(plottingData(1).actualExtensometer).monitoringPoints(4)];
P2(2) = get(hObject,'Value')/(plottingData(1).pxDistance*1000);
run updateEditsAndSliders

set(handles.pushbutton27,'Enable', 'on')
set(handles.pushbutton27,'ForegroundColor', [1,0,0])
set(handles.pushbutton27,'FontSize', 12)

setappdata(handles_mainGui, 'plottingData', plottingData);
updateAxes

% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% Function to update axes
function updateAxes
handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');
handles = getappdata(handles_mainGui, 'handles');

axes(handles.axes1) % to work with axes1

% plot the original image
if ~plottingData(1).zoomed
    handlesImage = imagesc(plottingData(1).plot_x,plottingData(1).plot_y,plottingData(1).roiOriginalImage);
else
    handlesImage = imagesc(plottingData(1).plot_x_zoomed,plottingData(1).plot_y_zoomed,plottingData(1).roiOriginalImage_zoomed);
end
axis off; axis image
hold on

if ~plottingData(1).zoomed
    eval(['quantityToPlot = ',char(plottingData(1).plotString(plottingData(1).currentQuantity)),';'])
    if ~plottingData(1).justInitialized
        plottingData(1).lowerBound(plottingData(1).currentQuantity)= str2double(get(handles.edit2,'String'));
        plottingData(1).upperBound(plottingData(1).currentQuantity)= str2double(get(handles.edit3,'String'));
        caxis([plottingData(1).lowerBound(plottingData(1).currentQuantity),plottingData(1).upperBound(plottingData(1).currentQuantity)]); % sets limits to the colorbar
    end
    handles_map = imagesc(plottingData(1).plot_x,plottingData(1).plot_y,quantityToPlot); % plots the colormap
    colorbar % creates a colorbar
    set(handles_map,'AlphaData',(1-plottingData(1).transparency)) % transparency settings
    
    % switch the background off
    if plottingData(1).showOutOfRoi
        imagesc(plottingData(1).plot_x,plottingData(1).plot_y,plottingData(1).outOfRoiImage,...
            'alphadata',plottingData(1).roi ~= 1);
    else
        imagesc(plottingData(1).plot_x,plottingData(1).plot_y,plottingData(1).roiOriginalImage,...
            'alphadata',plottingData(1).roi ~= 1);
    end
else
    eval(['quantityToPlot = ',char(plottingData(1).plotString(plottingData(1).currentQuantity)),...
        '(plottingData(1).plot_x_quantities_zoomed(1):plottingData(1).plot_x_quantities_zoomed(2),plottingData(1).plot_y_quantities_zoomed(1):plottingData(1).plot_y_quantities_zoomed(2));'])
    if ~plottingData(1).justInitialized
        plottingData(1).lowerBound(plottingData(1).currentQuantity)= str2double(get(handles.edit2,'String'));
        plottingData(1).upperBound(plottingData(1).currentQuantity)= str2double(get(handles.edit3,'String'));
        caxis([plottingData(1).lowerBound(plottingData(1).currentQuantity),plottingData(1).upperBound(plottingData(1).currentQuantity)]); % sets limits to the colorbar
    end
    handles_map = imagesc(plottingData(1).plot_x_zoomed,plottingData(1).plot_y_zoomed,quantityToPlot); % plots the colormap
    colorbar % creates a colorbar
    set(handles_map,'AlphaData',(1-plottingData(1).transparency)) % transparency settings
    
    % switch the background off
    if plottingData(1).showOutOfRoi
        handlesImage_2 = imagesc(plottingData(1).plot_x_zoomed,plottingData(1).plot_y_zoomed,...
            plottingData(1).outOfRoiImage_zoomed,'alphadata',plottingData(1).roi_zoomed ~= 1);
    else
        handlesImage_2 = imagesc(plottingData(1).plot_x_zoomed,plottingData(1).plot_y_zoomed,...
            plottingData(1).roiOriginalImage_zoomed,'alphadata',plottingData(1).roi_zoomed ~= 1);
    end
end

% disable previous / next step button for the first / last image
if plottingData(1).currentImage == plottingData(1).nFiles
    set(handles.pushbutton6,'Enable', 'off')
    set(handles.pushbutton23,'Enable', 'off')
    set(handles.pushbutton30,'Enable', 'off')
    set(handles.pushbutton5,'Enable', 'on')
    set(handles.pushbutton22,'Enable', 'on')
    set(handles.pushbutton29,'Enable', 'on')
elseif plottingData(1).currentImage == 1
    set(handles.pushbutton5,'Enable', 'off')
    set(handles.pushbutton22,'Enable', 'off')
    set(handles.pushbutton29,'Enable', 'off')
    set(handles.pushbutton6,'Enable', 'on')
    set(handles.pushbutton23,'Enable', 'on')
    set(handles.pushbutton30,'Enable', 'on')
else
    set(handles.pushbutton5,'Enable', 'on')
    set(handles.pushbutton6,'Enable', 'on')
    set(handles.pushbutton22,'Enable', 'on')
    set(handles.pushbutton23,'Enable', 'on')
    set(handles.pushbutton29,'Enable', 'on')
    set(handles.pushbutton30,'Enable', 'on')
end

imageName = extractExtension(plottingData(plottingData(1).currentImage).names);
handles_fileName = findobj('Style','text','Tag','text9'); % find handle of static text
set(handles_fileName,'String', imageName) % update the static text field

% on the first run (or if autoscaleBounds option is checked) set the lower and upper bounds
if plottingData(1).justInitialized || plottingData(1).autoscaleBounds
    minToPlot = min(quantityToPlot(:));
    maxToPlot = max(quantityToPlot(:));
    plottingData(1).justInitialized = false;
    set(handles.edit2,'String', sprintf('%.9f',minToPlot))
    set(handles.edit3,'String', sprintf('%.9f',maxToPlot))
    caxis([minToPlot,maxToPlot]); % sets limits to the colorbar
end

% display the data from virtual extensometers
if plottingData(1).monitoringPoints(1) > 0 && plottingData(1).nVirtualExtensometers ~= 0
    for i = 1:plottingData(1).nVirtualExtensometers   
        if plottingData(1).zoomed
            if sum(sum([plottingData(1).zoomRect(1) < plottingData(i).monitoringPoints(1:2); plottingData(1).zoomRect(3) > plottingData(i).monitoringPoints(1:2); plottingData(1).zoomRect(2) < plottingData(i).monitoringPoints(3:4); plottingData(1).zoomRect(4) > plottingData(i).monitoringPoints(3:4)])) == 8
                plot(plottingData(i).monitoringPoints(1:2),plottingData(i).monitoringPoints(3:4),'+','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:),'MarkerSize',5)
                if get(handles.checkbox7,'Value') % check whether to plot the averaging radius
                    aR = plottingData(i).avgRadius;
                    p1x = plottingData(i).monitoringPoints(1); p1y = plottingData(i).monitoringPoints(3); p2x = plottingData(i).monitoringPoints(2); p2y = plottingData(i).monitoringPoints(4);
                    plot([p1x-aR,p1x+aR,p1x+aR,p1x-aR],[p1y-aR,p1y-aR,p1y+aR,p1y+aR],'-','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
                    plot([p2x-aR,p2x+aR,p2x+aR,p2x-aR],[p2y-aR,p2y-aR,p2y+aR,p2y+aR],'-','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
                end
                text(plottingData(i).monitoringPoints(1),plottingData(i).monitoringPoints(3),[' ',num2str(i),'a'],'FontSize',9,'HorizontalAlignment','Left','VerticalAlignment','Middle','Margin',35,'FontWeight','demi','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
                text(plottingData(i).monitoringPoints(2),plottingData(i).monitoringPoints(4),[' ',num2str(i),'b'],'FontSize',9,'HorizontalAlignment','Left','VerticalAlignment','Middle','Margin',35,'FontWeight','demi','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
            end
        else
            plot(plottingData(i).monitoringPoints(1:2),plottingData(i).monitoringPoints(3:4),'+','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:),'MarkerSize',5)
            if get(handles.checkbox7,'Value') % check whether to plot the averaging radius
                aR = plottingData(i).avgRadius;
                p1x = plottingData(i).monitoringPoints(1); p1y = plottingData(i).monitoringPoints(3); p2x = plottingData(i).monitoringPoints(2); p2y = plottingData(i).monitoringPoints(4);
                plot([p1x-aR,p1x+aR,p1x+aR,p1x-aR],[p1y-aR,p1y-aR,p1y+aR,p1y+aR],'-','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
                plot([p2x-aR,p2x+aR,p2x+aR,p2x-aR],[p2y-aR,p2y-aR,p2y+aR,p2y+aR],'-','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
            end
            text(plottingData(i).monitoringPoints(1),plottingData(i).monitoringPoints(3),[' ',num2str(i),'a'],'FontSize',9,'HorizontalAlignment','Left','VerticalAlignment','Middle','Margin',35,'FontWeight','demi','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
            text(plottingData(i).monitoringPoints(2),plottingData(i).monitoringPoints(4),[' ',num2str(i),'b'],'FontSize',9,'HorizontalAlignment','Left','VerticalAlignment','Middle','Margin',35,'FontWeight','demi','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
        end
    end
end

hold off

setappdata(handles_mainGui, 'plottingData', plottingData);
setappdata(handles_mainGui, 'handles', handles);


%% function to update axes when saving a figure

function updateAxes_figureSaving
handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');
handles = getappdata(handles_mainGui, 'handles');

% plot the original image
if ~plottingData(1).zoomed
    handlesImage = imagesc(plottingData(1).plot_x,plottingData(1).plot_y,plottingData(1).roiOriginalImage);
else
    handlesImage = imagesc(plottingData(1).plot_x_zoomed,plottingData(1).plot_y_zoomed,plottingData(1).roiOriginalImage_zoomed);
end
axis off; axis image
hold on

if ~plottingData(1).zoomed
    eval(['quantityToPlot = ',char(plottingData(1).plotString(plottingData(1).currentQuantity)),';'])
    if ~plottingData(1).justInitialized
        plottingData(1).lowerBound(plottingData(1).currentQuantity)= str2double(get(handles.edit2,'String'));
        plottingData(1).upperBound(plottingData(1).currentQuantity)= str2double(get(handles.edit3,'String'));
        caxis([plottingData(1).lowerBound(plottingData(1).currentQuantity),plottingData(1).upperBound(plottingData(1).currentQuantity)]); % sets limits to the colorbar
    end
    handles_map = imagesc(plottingData(1).plot_x,plottingData(1).plot_y,quantityToPlot); % plots the colormap
    colorbar % creates a colorbar
    set(handles_map,'AlphaData',(1-plottingData(1).transparency)) % transparency settings
    
    % switch the background off
    if plottingData(1).showOutOfRoi
        imagesc(plottingData(1).plot_x,plottingData(1).plot_y,plottingData(1).outOfRoiImage,...
            'alphadata',plottingData(1).roi ~= 1);
    else
        imagesc(plottingData(1).plot_x,plottingData(1).plot_y,plottingData(1).roiOriginalImage,...
            'alphadata',plottingData(1).roi ~= 1);
    end
else
    eval(['quantityToPlot = ',char(plottingData(1).plotString(plottingData(1).currentQuantity)),...
        '(plottingData(1).plot_x_quantities_zoomed(1):plottingData(1).plot_x_quantities_zoomed(2),plottingData(1).plot_y_quantities_zoomed(1):plottingData(1).plot_y_quantities_zoomed(2));'])
    if ~plottingData(1).justInitialized
        plottingData(1).lowerBound(plottingData(1).currentQuantity)= str2double(get(handles.edit2,'String'));
        plottingData(1).upperBound(plottingData(1).currentQuantity)= str2double(get(handles.edit3,'String'));
        caxis([plottingData(1).lowerBound(plottingData(1).currentQuantity),plottingData(1).upperBound(plottingData(1).currentQuantity)]); % sets limits to the colorbar
    end
    handles_map = imagesc(plottingData(1).plot_x_zoomed,plottingData(1).plot_y_zoomed,quantityToPlot); % plots the colormap
    colorbar % creates a colorbar
    set(handles_map,'AlphaData',(1-plottingData(1).transparency)) % transparency settings
    
    % switch the background off
    if plottingData(1).showOutOfRoi
        handlesImage_2 = imagesc(plottingData(1).plot_x_zoomed,plottingData(1).plot_y_zoomed,...
            plottingData(1).outOfRoiImage_zoomed,'alphadata',plottingData(1).roi_zoomed ~= 1);
    else
        handlesImage_2 = imagesc(plottingData(1).plot_x_zoomed,plottingData(1).plot_y_zoomed,...
            plottingData(1).roiOriginalImage_zoomed,'alphadata',plottingData(1).roi_zoomed ~= 1);
    end
end

% on the first run (or if autoscaleBounds option is checked) set the lower and upper bounds
if plottingData(1).justInitialized || plottingData(1).autoscaleBounds
    minToPlot = min(quantityToPlot(:));
    maxToPlot = max(quantityToPlot(:));
    plottingData(1).justInitialized = false;
    set(handles.edit2,'String', sprintf('%.9f',minToPlot))
    set(handles.edit3,'String', sprintf('%.9f',maxToPlot))
    caxis([minToPlot,maxToPlot]); % sets limits to the colorbar
end

% display marks for virtual extensometers
if plottingData(1).plotExtensometers
    for i = 1:plottingData(1).nVirtualExtensometers   
        if plottingData(1).zoomed
            if sum(sum([plottingData(1).zoomRect(1) < plottingData(i).monitoringPoints(1:2); plottingData(1).zoomRect(3) > plottingData(i).monitoringPoints(1:2); plottingData(1).zoomRect(2) < plottingData(i).monitoringPoints(3:4); plottingData(1).zoomRect(4) > plottingData(i).monitoringPoints(3:4)])) == 8
                plot(plottingData(i).monitoringPoints(1:2),plottingData(i).monitoringPoints(3:4),'+','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:),'MarkerSize',5)
                if get(handles.checkbox7,'Value') % check whether to plot the averaging radius
                    aR = plottingData(i).avgRadius;
                    p1x = plottingData(i).monitoringPoints(1); p1y = plottingData(i).monitoringPoints(3); p2x = plottingData(i).monitoringPoints(2); p2y = plottingData(i).monitoringPoints(4);
                    plot([p1x-aR,p1x+aR,p1x+aR,p1x-aR],[p1y-aR,p1y-aR,p1y+aR,p1y+aR],'-','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
                    plot([p2x-aR,p2x+aR,p2x+aR,p2x-aR],[p2y-aR,p2y-aR,p2y+aR,p2y+aR],'-','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
                end
                text(plottingData(i).monitoringPoints(1),plottingData(i).monitoringPoints(3),[' ',num2str(i),'a'],'FontSize',9,'HorizontalAlignment','Left','VerticalAlignment','Middle','Margin',35,'FontWeight','demi','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
                text(plottingData(i).monitoringPoints(2),plottingData(i).monitoringPoints(4),[' ',num2str(i),'b'],'FontSize',9,'HorizontalAlignment','Left','VerticalAlignment','Middle','Margin',35,'FontWeight','demi','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
            end
        else
            plot(plottingData(i).monitoringPoints(1:2),plottingData(i).monitoringPoints(3:4),'+','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:),'MarkerSize',5)
            if get(handles.checkbox7,'Value') % check whether to plot the averaging radius
                aR = plottingData(i).avgRadius;
                p1x = plottingData(i).monitoringPoints(1); p1y = plottingData(i).monitoringPoints(3); p2x = plottingData(i).monitoringPoints(2); p2y = plottingData(i).monitoringPoints(4);
                plot([p1x-aR,p1x+aR,p1x+aR,p1x-aR],[p1y-aR,p1y-aR,p1y+aR,p1y+aR],'-','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
                plot([p2x-aR,p2x+aR,p2x+aR,p2x-aR],[p2y-aR,p2y-aR,p2y+aR,p2y+aR],'-','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
            end
            text(plottingData(i).monitoringPoints(1),plottingData(i).monitoringPoints(3),[' ',num2str(i),'a'],'FontSize',9,'HorizontalAlignment','Left','VerticalAlignment','Middle','Margin',35,'FontWeight','demi','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
            text(plottingData(i).monitoringPoints(2),plottingData(i).monitoringPoints(4),[' ',num2str(i),'b'],'FontSize',9,'HorizontalAlignment','Left','VerticalAlignment','Middle','Margin',35,'FontWeight','demi','Color',plottingData(1).extensometerRGB(plottingData(1).currentExtColor,:))
        end
    end
end

colormap jet
hold off
setappdata(handles_mainGui, 'plottingData', plottingData);
setappdata(handles_mainGui, 'handles', handles);
