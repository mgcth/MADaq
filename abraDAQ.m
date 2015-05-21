function varargout = abraDAQ(varargin)
% ABRADAQ MATLAB code for abraDAQ.fig
%
% Syntax:  output = abraDAQ()
%
% Inputs:
%    input - none
%
% Outputs:
%    output - none
%
% Example: 
%    abraDAQ()
%
% Other m-files required: folders in parent and subfolders
% Subfunctions: folders in parent and subfolders
% MAT-files required: none
%
% See also: NONE

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

% Acknowledgement
% The initial developement and core structure, with the TEDS functionality,
% of this program is acknowledged below.
%
% The development of this software was funded by the INTERREG 4 A program
% in Southern Denmark – Schleswig-K.E.R.N, Germany with funding from the
% European Fund for Regional Development.
%
% Author: Kent Stark Olsen <kent.stark.olsen@gmail.com>
% Created: 02-05-2013
% Revision: 24-02-2015 1.3 minor bug changes

% Last Modified by GUIDE v2.5 21-May-2015 08:03:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @abraDAQ_OpeningFcn, ...
    'gui_OutputFcn',  @abraDAQ_OutputFcn, ...
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

warning off;


% --- Executes just before abraDAQ is made visible.
function abraDAQ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to abraDAQ (see VARARGIN)

% Choose default command line output for abraDAQ
handles.output = hObject;

% Get working directory
handles.homePath = fileparts(mfilename('fullpath'));

% Include these files for program to work globally (ugly?)
addpath(genpath([handles.homePath,'/functions']));

% Version
handles.version = '0.1';
set(handles.figure1, 'Name', ['abraDAQ ', handles.version]);

% Empty channels table
data = {};
set(handles.channelsTable, 'data', data);
set(handles.outputTable, 'data', data);

% Load IEEE 1451.4 publist.xdl
% Source: http://standards.ieee.org/develop/regauth/manid/publist.xdl
[handles.pubListId, handles.pubListCompany] = openPubList([handles.homePath, '/data/publist.xdl']);

% Preview
handles.preview.reset = false;

% Update handles structure
guidata(hObject, handles);

global currentState
currentState= cell(6,9);

% Start with monitor and make other things invisible
set(handles.fun1,'String','50')
currentState{1,1} = get(handles.fun1,'String');
currentState{2,1} = get(handles.fun1,'String');
currentState{3,1} = get(handles.fun1,'String');
currentState{4,1} = get(handles.fun1,'String');
currentState{5,1} = get(handles.fun1,'String');
currentState{6,1} = get(handles.fun1,'String');
set(handles.fun2Text,'visible','off')
set(handles.fun2,'visible','off')
set(handles.fun3Text,'visible','off')
set(handles.fun3,'visible','off')
set(handles.fun4Text,'visible','off')
set(handles.fun4,'visible','off')
set(handles.fun5Text,'visible','off')
set(handles.fun5,'visible','off')
set(handles.fun6Text,'visible','off')
set(handles.fun6,'visible','off')
set(handles.fun7Text,'visible','off')
set(handles.fun7,'visible','off')
set(handles.fun8Text,'visible','off')
set(handles.fun8,'visible','off')
set(handles.fun9Text,'visible','off')
set(handles.fun9,'visible','off')

% UIWAIT makes abraDAQ wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = abraDAQ_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function title1_Callback(hObject, eventdata, handles)
% hObject    handle to title1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of title1 as text
%        str2double(get(hObject,'String')) returns contents of title1 as a double


% --- Executes during object creation, after setting all properties.
function title1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to title1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function title2_Callback(hObject, eventdata, handles)
% hObject    handle to title2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of title2 as text
%        str2double(get(hObject,'String')) returns contents of title2 as a double


% --- Executes during object creation, after setting all properties.
function title2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to title2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function title3_Callback(hObject, eventdata, handles)
% hObject    handle to title3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of title3 as text
%        str2double(get(hObject,'String')) returns contents of title3 as a double


% --- Executes during object creation, after setting all properties.
function title3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to title3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function title4_Callback(hObject, eventdata, handles)
% hObject    handle to title4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of title4 as text
%        str2double(get(hObject,'String')) returns contents of title4 as a double


% --- Executes during object creation, after setting all properties.
function title4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to title4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over scanButton.
function scanButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to scanButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in activateButton.
function activateButton_Callback(hObject, eventdata, handles)
% hObject    handle to activateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.channelsTable, 'data');
m = size(data);

for i=1:m
    data(i, 1) = {true};
end

set(handles.channelsTable, 'data', data);


% --- Executes on button press in deactivateButton.
function deactivateButton_Callback(hObject, eventdata, handles)
% hObject    handle to deactivateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.channelsTable, 'data');
m = size(data);

for i=1:m
    data(i, 1) = {false};
end

set(handles.channelsTable, 'data', data);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over activateButton.
function activateButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to activateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function freqStr_Callback(hObject, eventdata, handles)
% hObject    handle to freqStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqStr as text
%        str2double(get(hObject,'String')) returns contents of freqStr as a double


% --- Executes during object creation, after setting all properties.
function freqStr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventData, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closePreview (hObject, eventData, handles);

% Hint: delete(hObject) closes the figure
delete(hObject);


% Handles the streaming of data to disk
function logData(src, event, fileDescriptor)
%disp('Logging...');

% % ----- TA 2015-02-27 (mod start)
%     global DATAcontainer
%     DATAcontainer.t=[DATAcontainer.t;event.TimeStamps(:)];
%     DATAcontainer.data=[DATAcontainer.data;event.Data(:)];
% ----- TA (mod end)

[m, n] = size(event.Data);

fwrite(fileDescriptor(1), event.TimeStamps, 'double');

for i = 1:n
    fwrite(fileDescriptor(i + 1), event.Data(:,i), 'double');
end


% --- Executes on button press in clearButton.
function clearButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = cell(0, 0);
set(handles.channelsTable, 'data', data);


% --------------------------------------------------------------------
function menuAbout_Callback(hObject, eventdata, handles)
% hObject    handle to menuAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuItemAbout_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = msgbox('abraDAQ National Instruments MATLAB Data Acquisition and Experimental Modal Analysis library version 0.5. Developed at Chalmers University of Technology and University of Southern Denmark.');


% --------------------------------------------------------------------
function menuItemHelp_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = msgbox('Visit https://github.com/mgcth/abraDAQ/wiki for more information.');


% --- Executes on selection change in fun1.
function fun1_Callback(hObject, eventdata, handles)
% hObject    handle to fun1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fun1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fun1

% Define conversion between Hz and kHz;
kHz2Hz = 1000;
Hz2kHz = 0.001;

% Get the set frequency
freq = str2double(get(handles.fun1,'String')) * kHz2Hz;

% Check if the hardware info is stored
if ~exist('devices')
    daq.reset;
    devices = daq.getDevices;
end

% Find the rate limit of all the devices
numberDevices = length(devices);
counter = 1;
for i = 1:numberDevices
    numberSubsystems = length(devices(i));
    
    for j = 1: numberSubsystems
        rateLimit = devices(i).Subsystems(j).RateLimit;
        minRateLimit(counter) = min(rateLimit);
        maxRateLimit(counter) = max(rateLimit);
    end
    
    counter = counter + 1;
end

% Check so that the set rate limit is in the valid range, if not chnage it
% and notify the user.
if freq > min(maxRateLimit)
    tmpString = sprintf('Sample rate to high. Maximum allowed %3.2f [kHz].', min(maxRateLimit) * Hz2kHz);
    msgbox(tmpString)
    freq = min(maxRateLimit);
    set(handles.fun1,'String',num2str(freq * Hz2kHz));
elseif freq < max(minRateLimit)
    tmpString = sprintf('Sample rate to low. Minimum allowed %3.2f [kHz].', max(minRateLimit) * Hz2kHz);
    msgbox(tmpString)
    freq = max(minRateLimit);
    set(handles.fun1,'String',num2str(freq * Hz2kHz));
end

currentState(handles,1);

% --- Executes during object creation, after setting all properties.
function fun1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun2_Callback(hObject, eventdata, handles)
% hObject    handle to fun2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fun2 as text
%        str2double(get(hObject,'String')) returns contents of fun2 as a double

currentState(handles,2);

% --- Executes during object creation, after setting all properties.
function fun2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun3_Callback(hObject, eventdata, handles)
% hObject    handle to fun3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fun3 as text
%        str2double(get(hObject,'String')) returns contents of fun3 as a double

currentState(handles,3);

% --- Executes during object creation, after setting all properties.
function fun3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun4_Callback(hObject, eventdata, handles)
% hObject    handle to fun4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fun4 as text
%        str2double(get(hObject,'String')) returns contents of fun4 as a double

currentState(handles,4);

% --- Executes during object creation, after setting all properties.
function fun4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun5_Callback(hObject, eventdata, handles)
% hObject    handle to fun5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fun5 as text
%        str2double(get(hObject,'String')) returns contents of fun5 as a double

currentState(handles,5);

% --- Executes during object creation, after setting all properties.
function fun5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun6_Callback(hObject, eventdata, handles)
% hObject    handle to fun6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fun6 as text
%        str2double(get(hObject,'String')) returns contents of fun6 as a double

currentState(handles,6);

% --- Executes during object creation, after setting all properties.
function fun6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun7_Callback(hObject, eventdata, handles)
% hObject    handle to fun7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fun7 as text
%        str2double(get(hObject,'String')) returns contents of fun7 as a double

currentState(handles,7);

% --- Executes during object creation, after setting all properties.
function fun7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun8_Callback(hObject, eventdata, handles)
% hObject    handle to fun8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fun8 as text
%        str2double(get(hObject,'String')) returns contents of fun8 as a double

currentState(handles,8);

% --- Executes during object creation, after setting all properties.
function fun8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun9_Callback(hObject, eventdata, handles)
% hObject    handle to fun9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fun9 as text
%        str2double(get(hObject,'String')) returns contents of fun9 as a double

currentState(handles,9);

% --- Executes during object creation, after setting all properties.
function fun9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fun9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in autoReport.
function autoReport_Callback(hObject, eventdata, handles)
% hObject    handle to autoReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoReport

% If tick, get some more info
if get(handles.autoReport,'Value')
    prompt = {'Your name:','Your email:','Affiliation:'};
    dlg_title = 'Input';
    num_lines = 1;
    if isempty(handles.autoReport.UserData)
        def = {'','',''};
    else
        def = {handles.autoReport.UserData.TesterInfo{1},handles.autoReport.UserData.TesterInfo{2},handles.autoReport.UserData.TesterInfo{3}};
    end
    handles.autoReport.UserData.TesterInfo = inputdlg(prompt,dlg_title,num_lines,def);
end

