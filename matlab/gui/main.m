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

% Last Modified by GUIDE v2.5 03-Mar-2015 11:29:36

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


% --- Executes on selection change in sampleFrequency.
function sampleFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to sampleFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sampleFrequency contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sampleFrequency


% --- Executes during object creation, after setting all properties.
function sampleFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampleFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function durationTime_Callback(hObject, eventdata, handles)
% hObject    handle to durationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of durationTime as text
%        str2double(get(hObject,'String')) returns contents of durationTime as a double


% --- Executes during object creation, after setting all properties.
function durationTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
                set(handles.sampleFrequency, 'Value', raw{8,2});
                %set(handles.freqStr, 'String', num2str(raw{8,2}));
            else
                set(handles.freqStr, 'String', '');
            end
            if (isfloat(raw{9,2}))
                set(handles.durationTime, 'String', num2str(raw{9,2}));
            else
                set(handles.durationTime, 'String', '');
            end
            % % MG 2015-03-03 (mod start)
            % Set all radion buttons to zero first
            set(handles.monitor, 'Value', 0);
            set(handles.standardTest, 'Value', 0);
            set(handles.impactTest, 'Value', 0);
            set(handles.periodic, 'Value', 0);
            set(handles.steppedSine, 'Value', 0);
            set(handles.multisine, 'Value', 0);
            
            % Set the one to use to one
            if (raw{10,1})
                set(handles.monitor, 'Value', 1);
            elseif (raw{10,2})
                set(handles.standardTest, 'Value', 1);
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

        output{1, 1} = 'NB: Changing this file may corrupt it!!!';
        output{2, 1} = '#';
        output{3, 1} = 'Title1';
        output{3, 2} = get(handles.title1, 'String');
        output{4, 1} = 'Title2';
        output{4, 2} = get(handles.title2, 'String');
        output{5, 1} = 'Title3';
        output{5, 2} = get(handles.title3, 'String');
        output{6, 1} = 'Title4';
        output{6, 2}  = get(handles.title4, 'String');
        output{7, 1} = '##';
        output{8, 1} = 'SampleFreq';
        output{8, 2} = get(handles.sampleFrequency, 'Value');
        %disp(get(handles.sampleFrequency, 'String'));
        output{9, 1} = 'Duration';
        output{9, 2} = get(handles.durationTime, 'String');
        % % MG 2015-03-03 (mod start)
        output{10, 1} = get(handles.monitor, 'Value');
        output{10, 2} = get(handles.standardTest, 'Value');
        output{10, 3} = get(handles.impactTest, 'Value');
        output{10, 4} = get(handles.periodic, 'Value');
        output{10, 5} = get(handles.steppedSine, 'Value');
        output{10, 6} = get(handles.multisine, 'Value');
        % % MG (mod end)
        output{11, 1} = '###';
        
        offset = 11; %Last entry of header
        
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

% % MG 2013-03-03 (mod start)
% % --- Executes on button press in previewButton.
% function previewButton_Callback(hObject, eventdata, handles)
% % hObject    handle to previewButton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
%     %   Get state of session if existing
%     preview = getappdata(0, 'previewStruct');
%     
%     try     running = ~isempty(preview) && preview.session.IsRunning;
%     catch,  running = false;
%     end
%     
%     if (~running)
%         preview.freeLogging = false;
%         preview.normLogging = false;
%         
%         %   Setup session
%         preview.session = daq.createSession('ni');
%         preview.session.IsContinuous = true;
%         
%         items = get(handles.sampleFrequency, 'String');
%         f = freqConverter(items{get(handles.sampleFrequency, 'Value')});        
%         preview.session.Rate = f;
%         
%         %   Get overall info
%         preview.logging.impact = get(handles.impactTest, 'Value');
%         
%         %   Add channels
%         data = get(handles.channelsTable, 'data');
%         [m n] = size(data);
%         j = 1;
%         preMin = 0;
%         preMax = 0;
%         preview.chanNames = {};
%         
%         for i = 1:m
%         
%             channelData.index = i;
%             channelData.active = data{i, 1};
%             channelData.channel = data{i, 2};
% %             channelData.signal = data{i, 3};
%             channelData.label = data{i, 3};
%             channelData.coupling = data{i, 4};
%             channelData.voltage = data{i, 5};
% %             channelData.sensorType = data{i, 7};
%             channelData.manufacturer = data{i, 6};
%             channelData.model = data{i, 7};
%             channelData.serialNumber = data{i, 8};
%             channelData.sensitivity = data{i, 9};
%             channelData.units = data{i, 10};
%             channelData.dof = data{i, 11};
%             channelData.direction = data{i, 12};
%             channelData.Min = -0.001;%- (channelData.voltage * channelData.sensitivity) - 1;
%             channelData.Max = 0.001;%(channelData.voltage * channelData.sensitivity) + 1;
%             
%             channelData.title1 = get(handles.title1, 'String');
%             channelData.title2 = get(handles.title2, 'String');
%             channelData.title3 = get(handles.title3, 'String');
%             channelData.title4 = get(handles.title4, 'String');
%             
%             
%             %   Check if channel is ok, if so, then add channel to
%             %   monitor
%             configOk =  channelData.active && ...
%                         ~isnan(channelData.voltage) && ...
%                         ~isnan(channelData.sensitivity);
%             
%             if (configOk)
%                 chan = textscan(channelData.channel, '%s%s', 'Delimiter', '/', 'CollectOutput', 1);
%                 
%                 if strcmp(channelData.coupling, 'IEPE')
%                     preview.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'IEPE');
%                 else
%                     analogChan = preview.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
%                     
%                     if strcmp(channelData.coupling, 'AC')
%                         analogChan.Coupling = 'AC';
%                     elseif strcmp(channelData.coupling, 'DC')
%                         analogChan.Coupling = 'DC';
%                     end
%                 end
%                                 
%                 %preview.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
%                 %preview.session.Channels(j).Sensitivity = channelData.sensitivity;
%                 
%                 absAmp = 5.1;%channelData.voltage / (channelData.sensitivity / 1000);     %   [m/s^2, g, whatever...]
%                 
%                 channelData.Min = - absAmp;
%                 channelData.Max = absAmp;
%                 
%                 preMin = min(preMin, channelData.Min);
%                 preMax = max(preMax, channelData.Max);
%                
%                 preview.channelData(j) = channelData;
%                 preview.chanNames(j) = {channelData.channel};
%                 j = j + 1; 
%             end
%         end
%         
%         preview.Min = -1.1;
%         preview.Max = 1.1;
% 
%         %   Check if any channels was added to the session
%         if (isempty(preview.session.Channels))
%             msgbox('No channels in session, might be because no channels have been activated yet.','No channels in session');
%             preview.session.release();
%             delete(preview.session);
%                     
%         %   Else create preview and start plotting
%         else
%             %   Sync and reject alias if low freqency
%             try preview.session.AutoSyncDSA = true; catch, end
% 
%             try
%                 lowFreq = f < 1000;
%                 for i = 1:length(preview.session.Channels)
%                     preview.session.Channels(i).EnhancedAliasRejectionEnable = lowFreq;
%                 end
%             catch
%                 lowFreq = 0;
%             end
% 
%             disp(['SyncDSA: ', num2str(preview.session.AutoSyncDSA), ' - Aliasrejection: ', num2str(lowFreq)]);
% 
%             %   Figure/plots/slider
%             preview.figure = figure('DoubleBuffer', 'on', ...
%                                     'Name', 'Monitor mode', ...
%                                     'NumberTitle', 'off', ...
%                                     'MenuBar', 'none', ...
%                                     'ToolBar', 'none', ...
%                                     'ResizeFcn', @previewResize, ...
%                                     'CloseRequestFcn', @(src, event) closePreview(src, event, handles));
%             
%             %   Add subplots
%             preview.subplots.master =   subplot(3, 1, 1);
%             preview.subplots.plot1 =    subplot(3, 2, 3);
%             preview.subplots.plot2 =    subplot(3, 2, 4);
%             preview.subplots.plot3 =    subplot(3, 2, 5);
%             preview.subplots.plot4 =    subplot(3, 2, 6);
%             preview.subplots.handles = [preview.subplots.plot1 ...
%                                         preview.subplots.plot2 ...
%                                         preview.subplots.plot3 ...
%                                         preview.subplots.plot4];
%                 
%             preview.barTitle = cell(1, length(preview.session.Channels));
%             for i = 1:length(preview.session.Channels)
%                 preview.barTitle(1, i) = {preview.channelData(i).channel};
%             end
% 
% %             minSection = 0;
% %             maxSection = floor(length(preview.session.Channels) / 4) + 1;
%                                     
% %             %   Add slider
% %             preview.slider = uicontrol(preview.figure,  'Style', 'slider', ...
% %                                                         'Position', [0 0 1 1], ...
% %                                                         'Min', minSection, ...
% %                                                         'Max', maxSection, ...
% %                                                         'sliderStep', [(1 / maxSection) (1.0)], ...
% %                                                         'Callback', @previewSliderUpdate);
% %                                                     
% %             %   Set current range
% %             sliderVal = 0;
% %             maxVal = maxSection;
% %             if (sliderVal ~= maxVal)
% %                 preview.currentMonitorRange = [1 2 3 4] + 4 * sliderVal;
% % 
% %                 if (max(preview.currentMonitorRange) > length(preview.session.Channels))
% %                     preview.currentMonitorRange = (1:mod(length(preview.session.Channels), 4)) + 4 * sliderVal;
% %                 end
% %             end
%                   
%             %   New UI controls
%             %%%%%%%%%%%%%%%%%%%%%%%%
%             
%             %   Set selector (which set of channels to be plotted)
%             minSection = 1;
%             if (~mod(length(preview.session.Channels), 4))
%                 maxSection = floor(length(preview.session.Channels) / 4);
%             else
%                 maxSection = floor(length(preview.session.Channels) / 4) + 1;
%             end
%             
%             setListString = 'Set #1';
%             for i = (minSection + 1):maxSection
%                 setListString = [setListString, '|Set #', num2str(i)];
%             end
%             
%             preview.setList = uicontrol(preview.figure, 'Style', 'popupmenu', ...
%                                                         'Position', [10 10 100 25], ...
%                                                         'String', setListString, ...
%                                                         'Callback', @previewMenuUpdate);
%                                                     
%             preview.currentMonitorRange = [1 2 3 4];
% 
%             if (max(preview.currentMonitorRange) > length(preview.session.Channels))
%                 preview.currentMonitorRange = (1:mod(length(preview.session.Channels), 4));
%             end
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%
%             
%             %   Ad Hoc Logging Button
%             preview.adHocLog = uicontrol(preview.figure,    'Style', 'pushbutton', ...
%                                                             'Position', [120 10 150 25], ...
%                                                             'String', 'Start free logging', ...
%                                                             'Callback', @previewAdHocLog);
%             %   Duration Log Button
% %             preview.normLog = uicontrol(preview.figure, 'Style', 'pushbutton', ...
% %                                                         'Position', [280 10 150 25], ...
% %                                                         'String', 'Start timed logging', ...
% %                                                         'Callback', @previewNormLog);
% %             
%             %   Add listener
%             preview.eventListener = addlistener(preview.session, 'DataAvailable', @plotPreview);
%                                                     
%             %   Start monitoring
%             set(handles.previewButton, 'String', 'Stop monitor');
%             
% %             try preview.session.AutoSyncDSA = true; catch, end
% %             disp(['DSA enabled: ', num2str(preview.session.AutoSyncDSA)]);
%             
%             preview.session.startBackground();
%         end
%         
%         %   Save state of preview
%         setappdata(0, 'previewStruct', preview);
%         
%     else
%         closePreview (hObject, eventdata, handles);
%     end
% % MG (mod end)

%   Handles the plotting for the preview
function plotPreview(src, event)
    preview = getappdata(0, 'previewStruct');

    try
        if (preview.logging.freeLogging)
            logData(src, event, preview.logging.files);
        end
    catch,  end
    
    numberOfChannels = length(preview.currentMonitorRange);
    
    dataLen = 15000;
    [m, n] = size(event.Data);
    
    persistent t d filterData;
    if (isempty(t) || isempty(d) || (min(t) > min(event.TimeStamps)))
        t = zeros(dataLen, 1);
        d = zeros(dataLen, n);
        filterData = zeros(1, n);
    end
    
    %   Update time and data values to be plotted
    t = circshift(t, -m);
    d = circshift(d, -m);
    t(dataLen - m + 1:dataLen, :) = event.TimeStamps;
    d(dataLen - m + 1:dataLen, 1:n) = event.Data;

    %   Update master monitor
%     oldFilterData = filterData .* 0.9;
%     filterData = mean(event.Data);
%     for i = 1:n
%         newData = filterData(1, i) / preview.channelData(i).Max;
%         
%         if (newData > oldFilterData(1, i))
%             filterData(1, i) = newData;
%         end
%     end
%     bar(preview.subplots.master, filterData);
    bar(preview.subplots.master, std(d));
    axis(preview.subplots.master, [0 (n + 1) -0.1 5.1]);

    
    %   Update channel monitors
    for i = 1:4
        if (i <= numberOfChannels)
            plot(preview.subplots.handles(i), t, d(:, preview.currentMonitorRange(i)));
%             axis(preview.subplots.handles(i), [min(t) max(t) preview.channelData(i).Min preview.channelData(i).Max]);
            chanData = preview.channelData(preview.currentMonitorRange(i));
            title(preview.subplots.handles(i), [chanData.channel, ' #', num2str(chanData.index)]);
        else
            cla(preview.subplots.handles(i));
            title(preview.subplots.handles(i), '');
        end
    end

function previewResize(src, event)
%     preview = getappdata(0, 'previewStruct');
%     pos = get(src, 'Position');
    %set(preview.slider, 'Position', [0 0 pos(3) 20]);
    
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
function previewMenuUpdate (hObject, eventData, handles)
    preview = getappdata(0, 'previewStruct');

    value = get(hObject, 'value');
    
    preview.currentMonitorRange = [1 2 3 4] + 4 * (value - 1);

    if (max(preview.currentMonitorRange) > length(preview.session.Channels))
        preview.currentMonitorRange = (1:mod(length(preview.session.Channels), 4)) + 4 * (value - 1);
    end
    
%     %   Set  titles
%     for i = 1:4
%         if (length(preview.currentMonitorRange) >= i)
%             chanData = preview.channelData(preview.currentMonitorRange(i));
%             title(preview.subplots.handles(i), [chanData.channel, ' #', chanData.index]);
%         else
%             title(preview.subplots.handles(i), '');
%         end
%     end
    
    setappdata(0, 'previewStruct', preview);

function previewAdHocLog (hObject, eventData, handles)

    preview = getappdata(0, 'previewStruct');
    
    try     running = ~isempty(preview) && preview.adHocLogging;
    catch,  running = false;
    end

    if (~running)
        preview.adHocLogging = true;
        %disp('Starting ad hoc logging ...');
        
        %   Add imp-check
        if preview.logging.impact
            choice = questdlg(  'Remember that the impact hammer should be connected to first channel in array, do you want to continue?', ...
                                'Impact test', ...
                                'Yes','No','No');
            if strcmp(choice, 'No')
                return
            end
        end
                
        for j = 1:length(preview.channelData)
            preview.logging.MHEADER(j).SeqNo = j;
            preview.logging.MHEADER(j).RespId = preview.channelData(j).channel;
            preview.logging.MHEADER(j).Date = datestr(now,'mm-dd-yyyy HH:MM:SS');
            preview.logging.MHEADER(j).Title = preview.channelData(j).title1;
            preview.logging.MHEADER(j).Title2 = preview.channelData(j).title2;
            preview.logging.MHEADER(j).Title3 = preview.channelData(j).title3;
            preview.logging.MHEADER(j).Title4 = preview.channelData(j).title4;
            preview.logging.MHEADER(j).Label = preview.channelData(j).label;
            preview.logging.MHEADER(j).SensorManufacturer = preview.channelData(j).manufacturer;
            preview.logging.MHEADER(j).SensorModel = preview.channelData(j).model;
            preview.logging.MHEADER(j).SensorSerialNumber = preview.channelData(j).serialNumber;
            preview.logging.MHEADER(j).SensorSensitivity = preview.channelData(j).sensitivity;
            preview.logging.MHEADER(j).Unit = preview.channelData(j).units;
            preview.logging.MHEADER(j).Dof = preview.channelData(j).dof;
            preview.logging.MHEADER(j).Dir = preview.channelData(j).direction;
            preview.logging.MHEADER(j).FunctionType = 1;
            
        end
        
        %   Make files for data collection
        dateString = datestr(now,'mm-dd-yyyy_HH-MM-SS');
        homeDir = char(java.lang.System.getProperty('user.home'));
        dataDir = [homeDir, '/DataLogger/', dateString];
        preview.logging.dataDir = dataDir;
        mkdir(dataDir);

        logFile = [dataDir, '/time.bin'];
        preview.logging.files(1) = fopen(logFile, 'a');
        for i = 1:length(preview.logging.MHEADER)
            logFile = [dataDir, '/channel', num2str(i), '.bin'];
            preview.logging.files(i + 1) = fopen(logFile, 'a');
        end
                
        %setappdata(0, 'previewStruct', preview);
        
        %   Add listener
        preview.freeLogEventListener = addlistener(preview.session, 'DataAvailable', @(src, event) logData(src, event, preview.logging.files));
        
        set(preview.adHocLog, 'String', 'Stop free logging');
        drawnow;
        
% % TA (start mod)
%        global DATAcontainer
%        ts=timeseries(DATAcontainer.data,DATAcontainer.t);
%        assignin('base','logdata',ts);  
% % TA (end)
        
    else
        preview.adHocLogging = false;
        %disp('Stopping ad hoc logging ...');
        
        delete(preview.freeLogEventListener);
        
        actualFs = preview.session.Rate;
        
        for i = 1:length(preview.logging.files)
            fclose(preview.logging.files(i));
        end

        dataDir = preview.logging.dataDir;

        %   Convert .bin-files to .mat-files
        binFile = [dataDir, '/time.bin'];
        matFile = [dataDir, '/time.mat'];
        file = fopen(binFile, 'r');
        Data = fread(file, 'double');
        Header.NoValues = length(Data);
        Header.xStart = 0;
        Header.xIncrement = 1. / actualFs;
        Header.Unit = 's';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~preview.logging.impact
            save(matFile, 'Header', 'Data');
        end
        fclose(file);
        delete(binFile);
        
        j = length(preview.logging.files);
        for i = 1:(j - 1)
            binFile = [dataDir, '/channel', num2str(i), '.bin'];
            matFile = [dataDir, '/channel', num2str(i), '.mat'];
            file = fopen(binFile, 'r');
            Data = fread(file, 'double');

            sens=preview.logging.MHEADER(i).SensorSensitivity;
            if isnan(sens)==0 && sens~=0
                Data=Data/(sens/1000);
            end
            Header = preview.logging.MHEADER(i);
            Header.NoValues = length(Data);
            Header.xStart = 0;
            Header.xIncrement = 1. / actualFs;
            if preview.logging.impact
                outData{i} = Data;
                outHeader(i) = Header;
                fclose(file);
                delete(binFile);
            else
                save(matFile, 'Header', 'Data');
                fclose(file);
                delete(binFile);
            end
        end
        
        if preview.logging.impact
            Data = outData;
            Header = outHeader;
            save([dataDir,'/data.imptime'], 'Data', 'Header', '-mat');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         save(matFile, 'Header', 'Data');
%         fclose(menuAbout);
%         delete(binFile);
% 
%         j = length(preview.logging.files);
%         for i = 1:(j - 1)
%             binFile = [dataDir, '/channel', num2str(i), '.bin'];
%             matFile = [dataDir, '/channel', num2str(i), '.mat'];
%             menuAbout = fopen(binFile, 'r');
%             Data = fread(menuAbout, 'double');
%             Header = preview.logging.MHEADER(i);
%             Header.NoValues = length(Data);
%             Header.xStart = 0;
%             Header.xIncrement = 1. / actualFs;
%             save(matFile, 'Header', 'Data');
%             fclose(menuAbout);
%             delete(binFile);
%         end
    set(preview.adHocLog, 'String', 'Start free logging');
    drawnow;
% % TA (start mod)
%        global DATAcontainer
%        ts=timeseries(DATAcontainer.data,DATAcontainer.t);
%        assignin('base','logdata',ts);  
% % TA (end)
    end
    
%     set(preview.adHocLog, 'String', 'Start free logging');
%     drawnow;
    
    setappdata(0, 'previewStruct', preview);
    
    
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
%             dataDir = [homeDir, '/DataLogger/', dateString];
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

function closePreview (currentHandle, events, handles)

    preview = getappdata(0, 'previewStruct');

    if (~isempty(preview))
        
        try logging = preview.adHocLogging;
        catch, logging = false;
        end
        
        if (~logging)        
            try preview.session.stop();         catch, end
            try preview.session.release();      catch, end
            try delete(preview.session);        catch, end
            try delete(preview.figure);         catch, end
            try rmappdata(0, 'previewStruct');  catch, end
        
            %   Clear DAQ
            daq.reset;
        else
            msgbox('Make sure to stop the free logging before closing the monitor','Free logging in progress...');
        end
    end
        
    %set(handles.previewButton, 'String', 'Start monitor');
    drawnow();

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

% Check which test
if handles.monitor.Value == 1 % if monitor
    
        %   Get state of session if existing
    preview = getappdata(0, 'previewStruct');
    
    try     running = ~isempty(preview) && preview.session.IsRunning;
    catch,  running = false;
    end
    
    if (~running)
        preview.freeLogging = false;
        preview.normLogging = false;
        
        %   Setup session
        preview.session = daq.createSession('ni');
        preview.session.IsContinuous = true;
        
        items = get(handles.sampleFrequency, 'String');
        f = freqConverter(items{get(handles.sampleFrequency, 'Value')});        
        preview.session.Rate = f;
        
        %   Get overall info
        preview.logging.impact = get(handles.impactTest, 'Value');
        
        %   Add channels
        data = get(handles.channelsTable, 'data');
        [m n] = size(data);
        j = 1;
        preMin = 0;
        preMax = 0;
        preview.chanNames = {};
        
        for i = 1:m
        
            channelData.index = i;
            channelData.active = data{i, 1};
            channelData.channel = data{i, 2};
%             channelData.signal = data{i, 3};
            channelData.label = data{i, 3};
            channelData.coupling = data{i, 4};
            channelData.voltage = data{i, 5};
%             channelData.sensorType = data{i, 7};
            channelData.manufacturer = data{i, 6};
            channelData.model = data{i, 7};
            channelData.serialNumber = data{i, 8};
            channelData.sensitivity = data{i, 9};
            channelData.units = data{i, 10};
            channelData.dof = data{i, 11};
            channelData.direction = data{i, 12};
            channelData.Min = -0.001;%- (channelData.voltage * channelData.sensitivity) - 1;
            channelData.Max = 0.001;%(channelData.voltage * channelData.sensitivity) + 1;
            
            channelData.title1 = get(handles.title1, 'String');
            channelData.title2 = get(handles.title2, 'String');
            channelData.title3 = get(handles.title3, 'String');
            channelData.title4 = get(handles.title4, 'String');
            
            
            %   Check if channel is ok, if so, then add channel to
            %   monitor
            configOk =  channelData.active && ...
                        ~isnan(channelData.voltage) && ...
                        ~isnan(channelData.sensitivity);
            
            if (configOk)
                chan = textscan(channelData.channel, '%s%s', 'Delimiter', '/', 'CollectOutput', 1);
                
                if strcmp(channelData.coupling, 'IEPE')
                    preview.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'IEPE');
                else
                    analogChan = preview.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
                    
                    if strcmp(channelData.coupling, 'AC')
                        analogChan.Coupling = 'AC';
                    elseif strcmp(channelData.coupling, 'DC')
                        analogChan.Coupling = 'DC';
                    end
                end
                                
                %preview.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
                %preview.session.Channels(j).Sensitivity = channelData.sensitivity;
                
                absAmp = 5.1;%channelData.voltage / (channelData.sensitivity / 1000);     %   [m/s^2, g, whatever...]
                
                channelData.Min = - absAmp;
                channelData.Max = absAmp;
                
                preMin = min(preMin, channelData.Min);
                preMax = max(preMax, channelData.Max);
               
                preview.channelData(j) = channelData;
                preview.chanNames(j) = {channelData.channel};
                j = j + 1; 
            end
        end
        
        preview.Min = -1.1;
        preview.Max = 1.1;

        %   Check if any channels was added to the session
        if (isempty(preview.session.Channels))
            msgbox('No channels in session, might be because no channels have been activated yet.','No channels in session');
            preview.session.release();
            delete(preview.session);
                    
        %   Else create preview and start plotting
        else
            %   Sync and reject alias if low freqency
            try preview.session.AutoSyncDSA = true; catch, end

            try
                lowFreq = f < 1000;
                for i = 1:length(preview.session.Channels)
                    preview.session.Channels(i).EnhancedAliasRejectionEnable = lowFreq;
                end
            catch
                lowFreq = 0;
            end

            disp(['SyncDSA: ', num2str(preview.session.AutoSyncDSA), ' - Aliasrejection: ', num2str(lowFreq)]);

            %   Figure/plots/slider
            preview.figure = figure('DoubleBuffer', 'on', ...
                                    'Name', 'Monitor mode', ...
                                    'NumberTitle', 'off', ...
                                    'MenuBar', 'none', ...
                                    'ToolBar', 'none', ...
                                    'ResizeFcn', @previewResize, ...
                                    'CloseRequestFcn', @(src, event) closePreview(src, event, handles));
            
            %   Add subplots
            preview.subplots.master =   subplot(3, 1, 1);
            preview.subplots.plot1 =    subplot(3, 2, 3);
            preview.subplots.plot2 =    subplot(3, 2, 4);
            preview.subplots.plot3 =    subplot(3, 2, 5);
            preview.subplots.plot4 =    subplot(3, 2, 6);
            preview.subplots.handles = [preview.subplots.plot1 ...
                                        preview.subplots.plot2 ...
                                        preview.subplots.plot3 ...
                                        preview.subplots.plot4];
                
            preview.barTitle = cell(1, length(preview.session.Channels));
            for i = 1:length(preview.session.Channels)
                preview.barTitle(1, i) = {preview.channelData(i).channel};
            end

%             minSection = 0;
%             maxSection = floor(length(preview.session.Channels) / 4) + 1;
                                    
%             %   Add slider
%             preview.slider = uicontrol(preview.figure,  'Style', 'slider', ...
%                                                         'Position', [0 0 1 1], ...
%                                                         'Min', minSection, ...
%                                                         'Max', maxSection, ...
%                                                         'sliderStep', [(1 / maxSection) (1.0)], ...
%                                                         'Callback', @previewSliderUpdate);
%                                                     
%             %   Set current range
%             sliderVal = 0;
%             maxVal = maxSection;
%             if (sliderVal ~= maxVal)
%                 preview.currentMonitorRange = [1 2 3 4] + 4 * sliderVal;
% 
%                 if (max(preview.currentMonitorRange) > length(preview.session.Channels))
%                     preview.currentMonitorRange = (1:mod(length(preview.session.Channels), 4)) + 4 * sliderVal;
%                 end
%             end
                  
            %   New UI controls
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            %   Set selector (which set of channels to be plotted)
            minSection = 1;
            if (~mod(length(preview.session.Channels), 4))
                maxSection = floor(length(preview.session.Channels) / 4);
            else
                maxSection = floor(length(preview.session.Channels) / 4) + 1;
            end
            
            setListString = 'Set #1';
            for i = (minSection + 1):maxSection
                setListString = [setListString, '|Set #', num2str(i)];
            end
            
            preview.setList = uicontrol(preview.figure, 'Style', 'popupmenu', ...
                                                        'Position', [10 10 100 25], ...
                                                        'String', setListString, ...
                                                        'Callback', @previewMenuUpdate);
                                                    
            preview.currentMonitorRange = [1 2 3 4];

            if (max(preview.currentMonitorRange) > length(preview.session.Channels))
                preview.currentMonitorRange = (1:mod(length(preview.session.Channels), 4));
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            %   Ad Hoc Logging Button
            preview.adHocLog = uicontrol(preview.figure,    'Style', 'pushbutton', ...
                                                            'Position', [120 10 150 25], ...
                                                            'String', 'Start free logging', ...
                                                            'Callback', @previewAdHocLog);
            %   Duration Log Button
%             preview.normLog = uicontrol(preview.figure, 'Style', 'pushbutton', ...
%                                                         'Position', [280 10 150 25], ...
%                                                         'String', 'Start timed logging', ...
%                                                         'Callback', @previewNormLog);
%             
            %   Add listener
            preview.eventListener = addlistener(preview.session, 'DataAvailable', @plotPreview);
                                                    
            %   Start monitoring
            set(handles.previewButton, 'String', 'Stop monitor');
            
%             try preview.session.AutoSyncDSA = true; catch, end
%             disp(['DSA enabled: ', num2str(preview.session.AutoSyncDSA)]);
            
            preview.session.startBackground();
        end
        
        %   Save state of preview
        setappdata(0, 'previewStruct', preview);
        
    else
        closePreview (hObject, eventdata, handles);
    end
    
elseif handles.standardTest.Value == 1 % if standard test
% TA (start mod)
       global DATAcontainer
       CHdata = get(handles.channelsTable, 'data');
       channelData.active = CHdata{1, 1};
       Chact=0;for i=1:size(CHdata,1),if CHdata{i,1},Chact=Chact+1;end,end
       if Chact==0,error('Seems that no channels are active');end
       [uv,sv]=memory;
       memmax=sv.PhysicalMemory.Available;
       ntmax=round(memmax/4/Chact/2);% Don't use more that half of available memory
       DATAcontainer.nt=0;
       DATAcontainer.t=zeros(ntmax,1);;
       DATAcontainer.data=zeros(ntmax,Chact);
       DATAcontainer.ntmax=ntmax;
% TA (end)

    %   Add imp-check
    impact = 0;
    if get(handles.impactTest,'Value')
        choice = questdlg(  'Remember that the impact hammer should be connected to first channel in array, do you want to continue?', ...
                            'Impact test', ...
                            'Yes','No','No');
        if strcmp(choice, 'No')
            return
        end
        
        impact = 1;
    end

    set(handles.statusStr, 'String', 'Setting up logging ...');
    drawnow();
    
    dateString = datestr(now,'mm-dd-yyyy_HH-MM-SS');

    %   Setup session
    logging.session = daq.createSession('ni');
    
    items = get(handles.sampleFrequency, 'String');
    f = freqConverter(items{get(handles.sampleFrequency, 'Value')});
    logging.session.Rate = f;

    logging.session.DurationInSeconds = str2double(get(handles.durationTime, 'String'));

    %   Add channels
    data = get(handles.channelsTable, 'data');
    [m n] = size(data);
    j = 1;
    
    for i = 1:m

        channelData.index = i;
        channelData.active = data{i, 1};
        channelData.channel = data{i, 2};
        %channelData.signal = data{i, 3};
        channelData.coupling = data{i, 4};
        channelData.voltage = data{i, 5};
        %channelData.sensorType = data{i, 7};
        channelData.sensitivity = data{i, 9};
        
        %   Check if channel is ok, if so, then add channel to
        %   monitor
        configOk =  channelData.active && ...
                    ~isnan(channelData.voltage) && ...
                    ~isnan(channelData.sensitivity);
                    %strcmp(channelData.signal, 'Input') && ...
                    
                    %~strcmp(channelData.sensorType, ' ') && ...
                    

        if (configOk)
            %   Add channel to session
            chan = textscan(channelData.channel, '%s%s', 'Delimiter', '/', 'CollectOutput', 1);
            
            if strcmp(channelData.coupling, 'IEPE')
                logging.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'IEPE');
            else
                analogChan = logging.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
                %analogChan.EnhancedAliasRejectionEnable = lowFreq;

                if strcmp(channelData.coupling, 'AC')
                    analogChan.Coupling = 'AC';
                elseif strcmp(channelData.coupling, 'DC')
                    analogChan.Coupling = 'DC';
                end
            end
            
            %logging.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');%channelData.sensorType);
            %logging.session.Channels(j).Sensitivity = channelData.sensitivity;
            
            %   Setup header
            logging.MHEADER(j).SeqNo = j;
            logging.MHEADER(j).RespId = channelData.channel;
            logging.MHEADER(j).Date = datestr(now,'mm-dd-yyyy HH:MM:SS');
            logging.MHEADER(j).Title = get(handles.title1, 'String');
            logging.MHEADER(j).Title2 = get(handles.title2, 'String');
            logging.MHEADER(j).Title3 = get(handles.title3, 'String');
            logging.MHEADER(j).Title4 = get(handles.title4, 'String');
            logging.MHEADER(j).Label = data{i, 3};
            %   Added by Kent 17-02-2014
            logging.MHEADER(j).SensorManufacturer = data{i, 6};
            logging.MHEADER(j).SensorModel = data{i, 7};
            logging.MHEADER(j).SensorSerialNumber = data{i, 8};
            logging.MHEADER(j).SensorSensitivity = data{i, 9};
            %   %   %   %   %   %   %   %   %
            logging.MHEADER(j).Unit = data{i, 10};   
            logging.MHEADER(j).Dof = data{i, 11};
            logging.MHEADER(j).Dir = data{i, 12};
            %   logging.MHEADER(j).Sensitivity = data{i,11}; % Esben 28-11-2013 Does not comply with specifications, another is added above this
            logging.MHEADER(j).FunctionType = 1;
            
            %   Increment channels counter
            j = j + 1;
        end
    end

    %   Check if any channels was added to the session
    if (isempty(logging.session.Channels))
        msgbox('No channels in session, might be because no channels have been activated yet.','No channels in session');
        logging.session.release();
        delete(logging.session);
        
        set(handles.statusStr, 'String', 'Logging failed ...');
        drawnow();

    %   Else start logging data
    else
        set(handles.statusStr, 'String', 'Logging data from sensors ...');
        drawnow();
        
        %   Sync and reject alias if low freqency
        try logging.session.AutoSyncDSA = true; catch, end

        try
            lowFreq = f < 1000;
            for i = 1:length(logging.session.Channels)
                logging.session.Channels(i).EnhancedAliasRejectionEnable = lowFreq;
            end
        catch
            lowFreq = 0;
        end

        disp(['SyncDSA: ', num2str(logging.session.AutoSyncDSA), ' - Aliasrejection: ', num2str(lowFreq)]);

% TA (start mod)
%         %   Make files for data collection
%         homeDir = char(java.lang.System.getProperty('user.home'));
%         dataDir = [homeDir, '/DataLogger/', dateString];
%         mkdir(dataDir);
%         
%         logFile = [dataDir, '/time.bin'];
%         logging.files(1) = fopen(logFile, 'a');
%         for i = 1:(j - 1)
%             logFile = [dataDir, '/channel', num2str(i), '.bin'];
%             logging.files(i + 1) = fopen(logFile, 'a');
%         end
% TA (end mod)
                
        %   Add listener
% TA (start mod)
%         logging.eventListener = addlistener(logging.session, 'DataAvailable', @(src, event) logData(src, event, logging.files));
        logging.eventListener = addlistener(logging.session, 'DataAvailable', @(src, event) logDataTA(src, event));
% TA (end mod)

        %   Start logging
        logging.session.startForeground();
        
        %   Get actual rate
        actualFs = logging.session.Rate;
        
        %   Will remain here until data logging is finished ...
        
        %   Close open output.bin file and open it again for reading data
% TA (start mod)
%         for i = 1:length(logging.files)
%             fclose(logging.files(i));
%         end
%         
%         set(handles.statusStr, 'String', 'Converting binaries to .mat-files');
%         drawnow();
%         
%         %   Convert .bin-files to .mat-files
%         binFile = [dataDir, '/time.bin'];
%         matFile = [dataDir, '/time.mat'];
%         file = fopen(binFile, 'r');
%         Data = fread(file, 'double');
%         Header.NoValues = length(Data);
%         Header.xStart = 0;
%         Header.xIncrement = 1. / actualFs;
%         if ~impact
%             save(matFile, 'Header', 'Data');
%         end
%         fclose(file);
%         delete(binFile);
% TA (end mod)
                
        
%         for i = 1:(j - 1)
%             binFile = [dataDir, '/channel', num2str(i), '.bin'];
%             matFile = [dataDir, '/channel', num2str(i), '.mat'];
%             file = fopen(binFile, 'r');
%             Data = fread(file, 'double');
%             %sensitivity % Esben 28-11-2013
%             sens=logging.MHEADER(i).SensorSensitivity;
%             if isnan(sens)==0 && sens~=0
%                 Data=Data/(sens/1000);
%             end
%             Header = logging.MHEADER(i);
%             Header.NoValues = length(Data);
%             Header.xStart = 0;
%             Header.xIncrement = 1. / actualFs;
%             if impact
%                 outData{i} = Data;
%                 outHeader(i) = Header;
%                 fclose(file);
%                 delete(binFile);
%             else
%                 save(matFile, 'Header', 'Data');
%                 fclose(file);
%                 delete(binFile);
%             end
%         end
        
        %if impact
        %    Data = outData;
        %    Header = outHeader;
        %    save([dataDir,'/data.imptime'], 'Data', 'Header', '-mat');
        %end
        
        %   Clean-up
        logging.session.release();
        delete(logging.session);
        
        %   Clear DAQ
        daq.reset;
 
        set(handles.statusStr, 'String', 'READY!  DAQ data available at workbench.');
        drawnow();
        
% TA (start mod)
       Nt=DATAcontainer.nt;
       DAQdata2WS(1,DATAcontainer.t(1:Nt),DATAcontainer.data(1:Nt,:),CHdata);
% TA (end)

    end
elseif handles.impactTest.Value == 1 % if impactTest
end
    
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
        set(handles.standardTest, 'Value', 0);
        set(handles.impactTest, 'Value', 0);
        set(handles.periodic, 'Value', 0);
        set(handles.steppedSine, 'Value', 0);
        set(handles.multisine, 'Value', 0);
    else
        set(handles.monitor, 'Value', 1);
    end
   
    
% --- Executes on button press in standardTest.
function standardTest_Callback(hObject, eventdata, handles)
% hObject    handle to standardTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of standardTest
    val = get(hObject,'Value');
    if (val)
        set(handles.monitor, 'Value', 0);
        set(handles.impactTest, 'Value', 0);
        set(handles.periodic, 'Value', 0);
        set(handles.steppedSine, 'Value', 0);
        set(handles.multisine, 'Value', 0);
    else
        set(handles.standardTest, 'Value', 1);
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
        set(handles.standardTest, 'Value', 0);
        set(handles.periodic, 'Value', 0);
        set(handles.steppedSine, 'Value', 0);
        set(handles.multisine, 'Value', 0);
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
        set(handles.standardTest, 'Value', 0);
        set(handles.impactTest, 'Value', 0);
        set(handles.steppedSine, 'Value', 0);
        set(handles.multisine, 'Value', 0);
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
        set(handles.standardTest, 'Value', 0);
        set(handles.impactTest, 'Value', 0);
        set(handles.periodic, 'Value', 0);
        set(handles.multisine, 'Value', 0);
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
%         set(handles.standardTest, 'Value', 0);
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
    h = msgbox('Visit https://github.com/mgcth/idaq_sd/wiki for more information.');
