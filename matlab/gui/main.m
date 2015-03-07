function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Acknowledgement
% The development of this software was funded by the INTERREG 4 A program
% in Southern Denmark – Schleswig-K.E.R.N, Germany with funding from the
% European Fund for Regional Development.
%
% Author:     Kent Stark Olsen <kent.stark.olsen@gmail.com>
% Created:    02-05-2013
% Revision:   24-02-2015 1.3 minor bug changes

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 06-Mar-2015 14:28:50

% % ----- TA 2015-02-27 (mod start)
% global DATAcontainer
% DATAcontainer.t=[];DATAcontainer.data=[];
% % ----- TA (mod end)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @main_OpeningFcn, ...
    'gui_OutputFcn',  @main_OutputFcn, ...
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

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

%   Get working directory
handles.homePath = evalin('base', 'homePath');

%   Version
handles.version = 'beta 2.0';
set(handles.figure1, 'Name', ['Data Logger ', handles.version]);

%   Empty channels table
data = {};
set(handles.channelsTable, 'data', data);

%   Load IEEE 1451.4 publist.xdl
%   Source: http://standards.ieee.org/develop/regauth/manid/publist.xdl
[handles.pubListId, handles.pubListCompany] = openPubList([handles.homePath, '/data/publist.xdl']);

%   Preview
handles.preview.reset = false;

% Update handles structure
guidata(hObject, handles);

% Start with monitor and make other things invisible
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

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

error = false;
loadFile = false;
directory = [handles.homePath, '\conf'];
selection = '';
raw = {};

%   Input dialog for menuAbout selection
while (~loadFile)
    d = dir(directory);
    str = {d.name};
    [select, status] = listdlg( 'PromptString','Select a file:',...
        'SelectionMode','single',...
        'ListString',str);
    drawnow; pause(0.1);                       %   Prevent MatLab from hanging
    
    selection = [directory, '\', d(select).name];
    type = exist(selection, 'file');
    
    if (status ~= 0)
        
        if (type == 2)      %   File
            loadFile = true;
            
            % load
            %disp(['Selection: ', selection]);
            try
                [num, txt, raw] = xlsread(selection);
            catch e
                errorMsg = {'An error occured, try again.'; ...
                    ['Exception: ', e.identifier]};
                msgbox(errorMsg, 'Exception', 'error');
                drawnow; pause(0.1);                       %   Prevent MatLab from hanging
                set(handles.statusStr, 'String', ['Exception: ', e.identifier]);
                error = true;
            end
        elseif (type == 7)  %   Directory
            directory = selection;
            %disp(['Dir: ', directory]);
        end
        
    else    % cancel operation
        loadFile = true;
        error = true;
    end
end

if (~error)
    %   Get titles
    if (strcmp(raw{2,1}, '#'))
        if (ischar(raw{3,2}))
            set(handles.title1, 'String', raw{3,2});
        else
            set(handles.title1, 'String', '');
        end
        if (ischar(raw{4,2}))
            set(handles.title2, 'String', raw{4,2});
        else
            set(handles.title2, 'String', '');
        end
        if (ischar(raw{5,2}))
            set(handles.title3, 'String', raw{5,2});
        else
            set(handles.title3, 'String', '');
        end
        if (ischar(raw{6,2}))
            set(handles.title4, 'String', raw{6,2});
        else
            set(handles.title4, 'String', '');
        end
    end
    
    %   Get measurement settings
    if (strcmp(raw{7,1}, '##'))
        if (isfloat(raw{8,2}))
            set(handles.fun1, 'Value', raw{8,2});
            %set(handles.freqStr, 'String', num2str(raw{8,2}));
        else
            set(handles.freqStr, 'String', '');
        end
        if (isfloat(raw{9,2}))
            set(handles.fun2, 'String', num2str(raw{9,2}));
        else
            set(handles.fun2, 'String', '');
        end
        % % MG 2015-03-03 (mod start)
        % Set all radion buttons to zero first
        set(handles.monitor, 'Value', 0);
        set(handles.dataLogg, 'Value', 0);
        set(handles.impactTest, 'Value', 0);
        set(handles.periodic, 'Value', 0);
        set(handles.steppedSine, 'Value', 0);
        set(handles.multisine, 'Value', 0);
        
        % Set the one to use to one
        if (raw{10,1})
            set(handles.monitor, 'Value', 1);
        elseif (raw{10,2})
            set(handles.dataLogg, 'Value', 1);
        elseif (raw{10,3})
            set(handles.impactTest, 'Value', 1);
        elseif (raw{10,4})
            set(handles.periodic, 'Value', 1);
        elseif (raw{10,5})
            set(handles.steppedSine, 'Value', 1);
        elseif (raw{10,6})
            set(handles.multisine, 'Value', 1);
        end
        % % MG (mod end)
    end
    
    %   Get channels
    [n, m] = size(raw);
    nn = n - 11;
    data = cell(nn, m);
    
    if (strcmp(raw{11,1}, '###'))
        for i = 12:n
            
            %   Copy data and check for NaNs in inappropiate places (Hint: No NaNs in string elements)
            temp = cell(1, 12);
            
            temp{1, 1} = raw{i, 1};     %   Active
            temp{1, 5} = raw{i, 5};     %   Voltage
            temp{1, 7} = raw{i, 7};     %   Manufacturer ID
            temp{1, 8} = raw{i, 8};   %   Serial number
            temp{1, 9} = raw{i, 9};   %   Sensitivity
            temp{1, 11} = raw{i, 11};   %   Dof
            
            if (ischar(raw{i, 2}))      %   Channel
                temp{1, 2} = raw{i, 2};
            else
                temp{1, 2} = '';
            end
            
            %                 if (ischar(raw{i, 3}))      %   Signal type
            %                     temp{1, 3} = raw{i, 3};
            %                 else
            %                     temp{1, 3} = '';
            %                 end
            
            if (ischar(raw{i, 3}))      %   Label
                temp{1, 3} = raw{i, 3};
            else
                temp{1, 3} = '';
            end
            
            if (ischar(raw{i, 4}))      %   Coupling
                temp{1, 4} = raw{i, 4};
            else
                temp{1, 4} = '';
            end
            
            %                 if (ischar(raw{i, 7}))      %   Transducer type
            %                     temp{1, 7} = raw{i, 7};
            %                 else
            %                     temp{1, 7} = '';
            %                 end
            
            if (ischar(raw{i, 6}))      %   Manufacturer
                temp{1, 6} = raw{i, 6};
            else
                temp{1, 6} = '';
            end
            
            if (ischar(raw{i, 10}))      %   Units
                temp{1, 10} = raw{i, 10};
            else
                temp{1, 10} = '';
            end
            
            if (ischar(raw{i, 12}))      %   Direction
                temp{1, 12} = raw{i, 12};
            else
                temp{1, 12} = '';
            end
            
            data(i - 11, :) = temp(1, :);
            %data(i - 10, :) = { raw{i, 1}, raw{i, 2}, raw{i, 3}, raw{i, 4}, ...
            %                    raw{i, 5}, raw{i, 6}, raw{i, 7}, raw{i, 8}, ...
            %                    raw{i, 9}, raw{i, 10}, raw{i, 11}, raw{i, 12}};
        end
    end
    set(handles.channelsTable, 'data', data);
    
    %   Update status bar
    set(handles.statusStr, 'String', [selection, ' is now loaded ...']);
    
    guidata(hObject, handles);
end

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg('Enter name of the file to save', 'Save configuration');
drawnow; pause(0.1);                       %   Prevent MatLab from hanging

if (~isempty(answer))
    data = get(handles.channelsTable, 'data');
    [m, n] = size(data);
    output = cell(10 + m, n);
    
    output{1, 1} = 'NB: Changing this file may corrupt it!';
    output{2, 1} = '#';
    output{3, 1} = 'Title1';
    output{3, 2} = get(handles.title1, 'String');
    output{4, 1} = 'Title2';
    output{4, 2} = get(handles.title2, 'String');
    output{5, 1} = 'Title3';
    output{5, 2} = get(handles.title3, 'String');
    output{6, 1} = 'Title4';
    output{6, 2} = get(handles.title4, 'String');
    output{7, 1} = '##';
    output{8, 1} = 'SampleFreq';
    output{8, 2} = get(handles.fun1, 'Value');
    %disp(get(handles.fun1, 'String'));
    % % MG 2015-03-03 (mod start)
    if handles.monitor.Values == 1 
        
    elseif handles.dataLogg.Values == 1 ...
            || handles.impactTest.Values == 1 || handles.steppedSine.Values == 1
        output{9, 1} = 'Duration';
        output{9, 2} = get(handles.fun2, 'String');
    elseif handles.monitor.Values == 1
    end
    output{10, 1} = 'Duration';
    output{10, 2} = get(handles.fun2, 'String');
    output{11, 1} = 'Duration';
    output{11, 2} = get(handles.fun2, 'String');
    output{12, 1} = 'Duration';
    output{12, 2} = get(handles.fun2, 'String');
    output{13, 1} = 'Duration';
    output{13, 2} = get(handles.fun2, 'String');
    output{14, 1} = 'Duration';
    output{14, 2} = get(handles.fun2, 'String');
    output{15, 1} = 'Duration';
    output{15, 2} = get(handles.fun2, 'String');
    output{16, 1} = 'Duration';
    output{16, 2} = get(handles.fun2, 'String');
    output{17, 1} = get(handles.monitor, 'Value');
    output{17, 2} = get(handles.dataLogg, 'Value');
    output{17, 3} = get(handles.impactTest, 'Value');
    output{17, 4} = get(handles.periodic, 'Value');
    output{17, 5} = get(handles.steppedSine, 'Value');
    output{17, 6} = get(handles.multisine, 'Value');
    output{18, 1} = '###';
    % % MG (mod end)
    
    offset = 18; %Last entry of header
    
    for i = 1:m
        output{offset + i, 1} = data{i, 1};     %   Active
        output{offset + i, 2} = data{i, 2};     %   Channel
        %output{10 + i, 3} = data{i, 3};        %   Signal
        output{offset + i, 3} = data{i, 3};     %   Label
        output{offset + i, 4} = data{i, 4};     %   Coupling
        output{offset + i, 5} = data{i, 5};     %   Voltage
        %output{10 + i, 7} = data{i, 7};        %   Transducer type
        output{offset + i, 6} = data{i, 6};     %   Manufacturer
        output{offset + i, 7} = data{i, 7};     %   Manufacturer ID
        output{offset + i, 8} = data{i, 8};     %   Serial number
        output{offset + i, 9} = data{i, 9};     %   Sensitivity
        output{offset + i, 10} = data{i, 10};   %   Units
        output{offset + i, 11} = data{i, 11};   %   Dof
        output{offset + i, 12} = data{i, 12};   %   Direction
    end
    
    file = [handles.homePath, '/conf/', answer{1,1}, '.conf'];
    try
        if exist(file, 'file')
            delete(file);
        end
        xlswrite(file, output);
        set(handles.statusStr, 'String', [file, ' was saved to the disk ...']);
    catch e
        errorMsg = {'An error occured, try again.'; ...
            ['Exception: ', e.identifier]};
        msgbox(errorMsg, 'Exception', 'error');
        drawnow; pause(0.1);                       %   Prevent MatLab from hanging
        set(handles.statusStr, 'String', ['Exception: ', e.identifier]);
    end
    
end

% --- Executes on button press in scanButton.
function scanButton_Callback(hObject, eventdata, handles)
% hObject    handle to scanButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ----- TA 2015-02-27 (mod start)
WB=waitbar(0);
set(WB,'Name','Scanning channels');
WB.Children.Title.String='Preparing ...';
% ----- TA (mod end)

%   Get old data
oldData = get(handles.channelsTable, 'data');

[oldN, oldM] = size(oldData);

set(handles.statusStr, 'String', 'Scanning hardware for avaible channels and sensors...');
guidata(hObject, handles);
drawnow();

%   Get state of monitor if existing and close it
preview = getappdata(0, 'previewStruct');

try     running = ~isempty(preview) && preview.session.IsRunning;
catch,  running = false;
end

if (running)
    closePreview (hObject, eventdata, handles);
end

%   Load TEDS Parser DLL
%     loadlibrary('tedsLib', 'tedsLib.h');

%   Get available devices
daq.reset;
devices = daq.getDevices;

%   Calculate size of cell
m = 12; n = 0;
for i = 1:length(devices)
    %         calllib('tedsLib', 'resetDevice', devices(i).ID); % Reset device
    for j = 1:length(devices(i).Subsystems)
        if (strcmp(devices(i).Subsystems(j).SubsystemType, 'AnalogInput'))
            n = n + devices(i).Subsystems(j).NumberOfChannelsAvailable;
        end
    end
end

%   If number of channels corresponds to the current number of channels
%   then dont delete colums LABEL, DOF og DIR
if (oldN == n)
    keepColumns = true;
    data = oldData;
else
    keepColumns = false;
    data = cell(n, m);
end

%disp([num2str(n), '    ', num2str(m)])
%disp(['Keep columns: ', num2str(keepColumns)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Scan all channels on all devices
%   Check devices

% ----- TA 2015-02-27 (mod start)
Nch=0;
for currentDevice = 1:length(devices)
    if (devices(currentDevice).isvalid)
        for subsys = 1:length(devices(currentDevice).Subsystems)
            for channel = 1:devices(currentDevice).Subsystems(subsys).NumberOfChannelsAvailable
                Nch=Nch+1;
            end
        end
    end
end
% ----- TA (mod end)


i = 1;Ich=0;
for currentDevice = 1:length(devices)
    %         disp(['Scanning device: ', devices(currentDevice).ID, ' ...']);
    resetDevice(devices(currentDevice).ID);
    
    if (devices(currentDevice).isvalid)
        for subsys = 1:length(devices(currentDevice).Subsystems)
            
            %   Get input
            if (strcmp(devices(currentDevice).Subsystems(subsys).SubsystemType, 'AnalogInput'))
                %   Get input channels
                for channel = 0:devices(currentDevice).Subsystems(subsys).NumberOfChannelsAvailable - 1
                    %                         fprintf(['Scanning channel: ai', num2str(channel), ' on device: ', devices(currentDevice).ID ,' ... ']);
                    Ich=Ich+1;waitbar(Ich/Nch,WB);WB.Children.Title.String=['Scanning: ' devices(currentDevice).ID];
                    
                    chanStr = [devices(currentDevice).ID, '/ai', num2str(channel)];
                    s = getTEDS(chanStr);
                    
                    if (s.ErrorCode == 0)
                        %                             fprintf('Sensor found.\n');
                        %   Loop through manufactures
                        manufacturer = '';
                        for manId = 1:length(handles.pubListId)
                            if (handles.pubListId(manId) == s.ManufacturerId)
                                manufacturer = handles.pubListCompany(manId);
                            end
                        end
                        
                        %                             sens = calllib('tedsLib', 'getSens', chanStr);
                        
                        %   Extract unit
                        unit = s.Unit;  %   Extract unit
                        
                        if strcmp(unit(1:2), 'V/')
                            if strcmp(unit(3), '(')
                                unit = unit(4:length(unit)-1);
                            else
                                unit = unit(3:length(unit));
                            end
                        end
                        
                        if (keepColumns)
                            data(i, 1) = {false};
                            data(i, 2) = {chanStr};
                            %%data(i, 3) = {'Input'};
                            data(i, 3) = oldData(i, 3);
                            data(i, 4) = {'IEPE'};
                            %data(i, 5) = {max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
                            data(i, 5) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
                            %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
                            %%data(i, 7) = {'IEPE'};
                            data(i, 6) = {char(manufacturer)};
                            data(i, 7) = {num2str(s.ModelNumber)};
                            data(i, 8) = {num2str(s.SerialNumber)};
                            data(i, 9) = {(s.Sensitivity) * 1000};
                            data(i, 10) = {unit};
                            data(i, 11) = oldData(i, 11);
                            data(i, 12) = oldData(i, 12);
                        else
                            %                                 data(i, :) = {false, chanStr, ' ', 'AC', devices(currentDevice).Subsystems.RangesAvailable.Max, char(manufacturer), s.ModelNumber, s.SerialNumber, s.Sensitivity, {''}, NaN, ' '};
                            data(i, 1) = {false};
                            data(i, 2) = {chanStr};
                            %%data(i, 3) = {'Input'};
                            data(i, 3) = {' '};
                            data(i, 4) = {'IEPE'};
                            %data(i, 5) = {10};%max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
                            data(i, 5) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
                            %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
                            %%data(i, 7) = {'IEPE'};
                            data(i, 6) = {char(manufacturer)};
                            data(i, 7) = {num2str(s.ModelNumber)};
                            data(i, 8) = {num2str(s.SerialNumber)};
                            data(i, 9) = {(s.Sensitivity) * 1000};
                            data(i, 10) = {unit};
                            data(i, 11) = {NaN};
                            data(i, 12) = {' '};
                        end
                    else
                        %                             fprintf('Sensor not found!\n');
                        
                        if (keepColumns)
                            data(i, 1) = {false};
                            data(i, 2) = {chanStr};
                            %data(i, 3) = {'Input'};
                            data(i, 3) = oldData(i, 3);
                            data(i, 4) = {' '};
                            data(i, 5) = {NaN};
                            %data(i, 7) = {'Voltage'};
                            data(i, 6) = {' '};
                            data(i, 7) = {num2str(NaN)};
                            data(i, 8) = {num2str(NaN)};
                            data(i, 9) = {NaN};
                            data(i, 10) = {' '};
                            data(i, 11) = oldData(i, 11);
                            data(i, 12) = oldData(i, 12);
                        else
                            data(i, :) = {false, chanStr, ' ', ' ', NaN, ' ', NaN, NaN, NaN, ' ', NaN, ' '};
                        end
                    end
                    
                    i = i + 1;
                    set(handles.channelsTable, 'data', data);   %   Experimental
                    guidata(hObject, handles);                  %   Experimental
                    drawnow();                                  %   Experimental
                end
            end
            
            %   Get output channels
        end
    else
        fprintf('No devices found\n ');
    end
    % ----- TA 2015-02-27 (mod start)
    %         handles.channelsTable.CellSelectionCallback='disp(''CellSelect'')';
    %         handles.channelsTable.KeyPressFcn='disp(''Press'')';
    %         handles.channelsTable.ButtonDownFcn='disp(''ButtonDown'')';
    %         handles.channelsTable.KeyReleaseFcn='disp(''Release'')';
    SensorsInLabFile=which('SensorsInLab.xlsx');
    if ~isempty(SensorsInLabFile)
        [CLL,rawCells]=xls2cell(SensorsInLabFile,5);
        CLL{1}(1,1)={' '};% Replace column header with blank
        handles.channelsTable.ColumnFormat{8}=CLL{:};
    end
    handles.channelsTable.CellEditCallback={@celleditcallback,rawCells};
    % ----- TA 2015-02-27 (end)
    
end
try,delete(WB),catch,end;% TA 2015-02-28

%   Unload TEDS Parser DLL
%     unloadlibrary('tedsLib');

%   Clear DAQ
daq.reset;

set(handles.channelsTable, 'data', data);
set(handles.statusStr, 'String', 'Scanning hardware complete - READY');
guidata(hObject, handles);

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

% function previewSliderUpdate(hObject, eventData, handles)
%     preview = getappdata(0, 'previewStruct');
%
%     sliderVal = floor(get(hObject, 'value'));
%     maxVal = get(hObject, 'Max');
%     if (sliderVal ~= maxVal)
%         preview.currentMonitorRange = [1 2 3 4] + 4 * sliderVal;
%
%         if (max(preview.currentMonitorRange) > length(preview.session.Channels))
%             preview.currentMonitorRange = (1:mod(length(preview.session.Channels), 4)) + 4 * sliderVal;
%         end
%     end
%
%     setappdata(0, 'previewStruct', preview);
%

% function previewAdHocLog (hObject, eventData, handles)
%     logNow = now;
%     preview = getappdata(0, 'previewStruct');
%
%     if (~preview.normLogging)
%         if (~preview.freeLogging)
%             preview.freeLogging = true;
%             preview.session.stop();
%
%             for j = 1:length(preview.channelData)
%                 preview.logging.MHEADER(j).SeqNo = j;
%                 preview.logging.MHEADER(j).RespId = preview.channelData(j).channel;
%                 preview.logging.MHEADER(j).Date = datestr(logNow,'mm-dd-yyyy HH:MM:SS');
%                 preview.logging.MHEADER(j).Title = '';%get(handles.title1, 'String');
%                 preview.logging.MHEADER(j).Title2 = '';%get(handles.title2, 'String');
%                 preview.logging.MHEADER(j).Title3 = '';%get(handles.title3, 'String');
%                 preview.logging.MHEADER(j).Title4 = '';%get(handles.title4, 'String');
%                 preview.logging.MHEADER(j).Label = preview.channelData(j).label;
%                 preview.logging.MHEADER(j).Units = preview.channelData(j).units;
%                 preview.logging.MHEADER(j).Dof = preview.channelData(j).dof;
%                 preview.logging.MHEADER(j).Dir = preview.channelData(j).direction;
%             end
%
%               Make files for data collection
%             dateString = datestr(logNow,'mm-dd-yyyy_HH-MM-SS');
%             homeDir = char(java.lang.System.getProperty('user.home'));
%             dataDir = [homeDir, '/datalogg/', dateString];
%             mkdir(dataDir);
%
%             logFile = [dataDir, '/time.bin'];
%             preview.logging.files(1) = fopen(logFile, 'a');
%             for i = 1:length(preview.logging.MHEADER)
%                 logFile = [dataDir, '/channel', num2str(i), '.bin'];
%                 preview.logging.files(i + 1) = fopen(logFile, 'a');
%             end
%
%             preview.logging.dataDir = dataDir;
%             setappdata(0, 'previewStruct', preview);
%
%             try preview.session.AutoSyncDSA = true; catch, end
%             disp(['DSA enabled: ', num2str(preview.session.AutoSyncDSA)]);
%
%             preview.session.startBackground();
%
%         else
%               Get actual frequency
%             actualFs = preview.session.Rate;
%
%             preview.freeLogging = false;
%             preview.session.stop();
%
%             for i = 1:length(preview.logging.files)
%                 fclose(preview.logging.files(i));
%             end
%
%             dataDir = preview.logging.dataDir;
%
%               Convert .bin-files to .mat-files
%             binFile = [dataDir, '/time.bin'];
%             matFile = [dataDir, '/time.mat'];
%             menuAbout = fopen(binFile, 'r');
%             Data = fread(menuAbout, 'double');
%             Header.NoValues = length(Data);
%             Header.xStart = 0;
%             Header.xIncrement = 1 / actualFs;
%             Header.Unit = 's';
%             save(matFile, 'Header', 'Data');
%             fclose(menuAbout);
%             delete(binFile);
%
%             j = length(preview.logging.files);
%             for i = 1:(j - 1)
%                 binFile = [dataDir, '/channel', num2str(i), '.bin'];
%                 matFile = [dataDir, '/channel', num2str(i), '.mat'];
%                 menuAbout = fopen(binFile, 'r');
%                 Data = fread(menuAbout, 'double');
%                 Header = preview.logging.MHEADER(i);
%                 Header.NoValues = length(Data);
%                 Header.xStart = 0;
%                 Header.xIncrement = 1 / actualFs;
%                 Header.Unit = 's';
%                 save(matFile, 'Header', 'Data');
%                 fclose(menuAbout);
%                 delete(binFile);
%             end
%
%             try preview.session.AutoSyncDSA = true; catch, end
%             disp(['DSA enabled: ', num2str(preview.session.AutoSyncDSA)]);
%
%             preview.session.startBackground();
%
%         end
%     end
%
%     setappdata(0, 'previewStruct', preview);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventData, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closePreview (hObject, eventData, handles);

% Hint: delete(hObject) closes the figure
delete(hObject);

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

startButton(hObject, eventdata, handles)

%   Handles the streaming of data to disk
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

% % MG 2015-03-03 (mod start)
% --- Executes on button press in monitor.
function monitor_Callback(hObject, eventdata, handles)
% hObject    handle to monitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of monitor
val = get(hObject,'Value');
if (val)
    set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.periodic, 'Value', 0);
    set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    
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
else
    set(handles.monitor, 'Value', 1);
end


% --- Executes on button press in dataLogg.
function dataLogg_Callback(hObject, eventdata, handles)
% hObject    handle to dataLogg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dataLogg
val = get(hObject,'Value');
if (val)
    set(handles.monitor, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.periodic, 'Value', 0);
    set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    
    set(handles.fun2Text,'visible','on')
    set(handles.fun2Text,'string','Duration [s]:')
    set(handles.fun2,'visible','on')
    set(handles.fun2,'string','10')
    
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
else
    set(handles.dataLogg, 'Value', 1);
end

% --- Executes on button press in impactTest.
function impactTest_Callback(hObject, eventdata, handles)
% hObject    handle to impactTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of impactTest
val = get(hObject,'Value');
if (val)
    set(handles.monitor, 'Value', 0);
    set(handles.dataLogg, 'Value', 0);
    set(handles.periodic, 'Value', 0);
    set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    
    set(handles.fun2Text,'visible','on')
    set(handles.fun2Text,'string','Duration [s]:')
    set(handles.fun2,'visible','on')
    set(handles.fun2,'string','10')
    
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
else
    set(handles.impactTest, 'Value', 1);
end

% --- Executes on button press in periodic.
function periodic_Callback(hObject, eventdata, handles)
% hObject    handle to monitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of periodic
val = get(hObject,'Value');
if (val)
    set(handles.monitor, 'Value', 0);
    set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    
    set(handles.fun2Text,'visible','on')
    set(handles.fun2Text,'string','Cycle duration [s]:')
    set(handles.fun2,'visible','on')
    set(handles.fun2,'string','5')
    set(handles.fun3Text,'visible','on')
    set(handles.fun3Text,'string','Periodic function:')
    set(handles.fun3,'visible','on')
    set(handles.fun3,'string','Function')
    set(handles.fun4Text,'visible','on')
    set(handles.fun4Text,'string','Repeats:')
    set(handles.fun4,'visible','on')
    set(handles.fun4,'string','3')
    set(handles.fun5Text,'visible','on')
    set(handles.fun5Text,'string','Initiation repeats:')
    set(handles.fun5,'visible','on')
    set(handles.fun5,'string','1')
    set(handles.fun6Text,'visible','on')
    set(handles.fun6Text,'string','Max amplitude:')
    set(handles.fun6,'visible','on')
    set(handles.fun6,'string','1')
    set(handles.fun7Text,'visible','on')
    set(handles.fun7Text,'string','Freq. range [Hz]:')
    set(handles.fun7,'visible','on')
    set(handles.fun7,'string','[1 1000]')
    set(handles.fun8Text,'visible','off')
    set(handles.fun8,'visible','off')
    set(handles.fun9Text,'visible','off')
    set(handles.fun9,'visible','off')
else
    set(handles.periodic, 'Value', 1);
end

% --- Executes on button press in steppedSine.
function steppedSine_Callback(hObject, eventdata, handles)
% hObject    handle to monitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of steppedSine
val = get(hObject,'Value');
if (val)
    set(handles.monitor, 'Value', 0);
    set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.periodic, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    
    set(handles.fun2Text,'visible','on')
    set(handles.fun2Text,'string','Frequency list:')
    set(handles.fun2,'visible','on')
    set(handles.fun2,'string','Matlab expr.')
    set(handles.fun3Text,'visible','on')
    set(handles.fun3Text,'string','Amplitude list:')
    set(handles.fun3,'visible','on')
    set(handles.fun3,'string','3')
    set(handles.fun4Text,'visible','on')
    set(handles.fun4Text,'string','Min. # cycles:')
    set(handles.fun4,'visible','on')
    set(handles.fun4,'string','50')
    set(handles.fun5Text,'visible','on')
    set(handles.fun5Text,'string','Distorsion level:')
    set(handles.fun5,'visible','on')
    set(handles.fun5,'string','0.0001')
    set(handles.fun6Text,'visible','on')
    set(handles.fun6Text,'string','Distorsion orders:')
    set(handles.fun6,'visible','on')
    set(handles.fun6,'string','2')
    
    %if 
    
    set(handles.fun7Text,'visible','off')
    set(handles.fun7,'visible','off')
    set(handles.fun8Text,'visible','off')
    set(handles.fun8,'visible','off')
    set(handles.fun9Text,'visible','off')
    set(handles.fun9,'visible','off')
else
    set(handles.steppedSine, 'Value', 1);
end

% --- Executes on button press in multisine.
function multisine_Callback(hObject, eventdata, handles)
% hObject    handle to monitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multisine
h = msgbox('Function not yet implemented.');
set(handles.multisine, 'Value', 0);
%     val = get(hObject,'Value');
%     if (val)
%         set(handles.monitor, 'Value', 0);
%         set(handles.dataLogg, 'Value', 0);
%         set(handles.impactTest, 'Value', 0);
%         set(handles.periodic, 'Value', 0);
%         set(handles.steppedSine, 'Value', 0);
%     else
%         set(handles.multisine, 'Value', 1);
%     end
% % MG (mod end)

function out_freq = freqConverter (freq)

if strcmp(freq, '20')
    out_freq = 20;
elseif strcmp(freq, '100')
    out_freq = 100;
elseif strcmp(freq, '1k')
    out_freq = 1000;
elseif strcmp(freq, '2k')
    out_freq = 2000;
elseif strcmp(freq, '5k')
    out_freq = 5000;
elseif strcmp(freq, '10k')
    out_freq = 10000;
elseif strcmp(freq, '20k')
    out_freq = 20000;
elseif strcmp(freq, '50k')
    out_freq = 50000;
elseif strcmp(freq, '100k')
    out_freq = 100000;
elseif strcmp(freq, '200k')
    out_freq = 200000;
else
    out_freq = 0;
end


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
h = msgbox('iDaq Structural Dyanmics (iDaqSD) version 0.1. Developed at University of Southern Denmark and Chalmers University of Technology.');

% --------------------------------------------------------------------
function menuItemHelp_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = msgbox('Visit https://github.com/mgcth/MADaq/wiki for more information.');

% --- Executes on selection change in fun1.
function fun1_Callback(hObject, eventdata, handles)
% hObject    handle to fun1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fun1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fun1


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
