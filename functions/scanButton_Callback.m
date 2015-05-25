% --- Executes on button press in scanButton.
function scanButton_Callback(hObject, eventdata, handles)
% hObject    handle to scanButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user dataIn (see GUIDATA)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

% If packaged as app, .mex files not allowed so packed as .mat files and
% renamed here
file1mat = [handles.homePath, '\functions\teds\getTEDS.mat'];
file1mex = [handles.homePath, '\functions\teds\getTEDS.mexw64'];
file2mat = [handles.homePath, '\functions\teds\resetDevice.mat'];
file2mex = [handles.homePath, '\functions\teds\resetDevice.mexw64'];
if exist(file1mat, 'file') == 2 && exist(file2mat, 'file') == 2
    movefile(file1mat, file1mex)
    movefile(file2mat, file2mex)
end

% Columns in the two tables
COLUMNSinINPUTTABLE = 14;
COLUMNSinOUTPUTTABLE = 14;

% Waitbar
WB=waitbar(0);
set(WB,'Name','Scanning channels');
WB.Children.Title.String='Preparing ...';

% Get old dataIn and dataOut if it exist
oldDataIn = get(handles.channelsTable, 'data');
[oldInN, oldInM] = size(oldDataIn);
oldDataOut = get(handles.outputTable, 'data');
[oldOutN, oldOutM] = size(oldDataOut);

% Update status bar
set(handles.statusStr, 'String', 'Scanning hardware for avaible channels and sensors...');
guidata(hObject, handles);
drawnow();

% Get state of monitor if existing and close it
preview = getappdata(0, 'previewStruct');

try     running = ~isempty(preview) && preview.session.IsRunning;
catch,  running = false;
end

if (running)
    closePreview (hObject, eventdata, handles);
end

% Load TEDS Parser DLL
%loadlibrary('tedsLib', 'tedsLib.h');

% Get available devices
daq.reset;
devices = daq.getDevices;

% Calculate size of cell for input channels
m = COLUMNSinINPUTTABLE; mm = COLUMNSinOUTPUTTABLE; n = 0; nn = 0;
for i = 1:length(devices)
    % calllib('tedsLib', 'resetDevice', devices(i).ID); % Reset device
    for j = 1:length(devices(i).Subsystems)
        if (strcmp(devices(i).Subsystems(j).SubsystemType, 'AnalogInput'))
            n = n + devices(i).Subsystems(j).NumberOfChannelsAvailable;
        end
        
         if (strcmp(devices(i).Subsystems(j).SubsystemType, 'AnalogOutput'))
            nn = nn + devices(i).Subsystems(j).NumberOfChannelsAvailable;
        end
    end
end

% If number of channels corresponds to the current number of input channels
% then dont delete colums LABEL, DOF and DIR
if (oldInN == n)
    keepColumnsIn  = true;
    dataIn = oldDataIn;
else
    keepColumnsIn  = false;
    dataIn = cell(n, m);
end

% Same for output channels
if (oldOutN == nn)
    keepColumnsOut  = true;
    dataOut = oldDataOut;
else
    keepColumnsOut  = false;
    dataOut = cell(nn, mm);
end

% Scan all channels on all devices for waitbar
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

% Populate table with channels
i = 1;Ich=0;
j = 1;Och=0;
for currentDevice = 1:length(devices)
    % disp(['Scanning device: ', devices(currentDevice).ID, ' ...']);
    resetDevice(devices(currentDevice).ID);
    
    if (devices(currentDevice).isvalid)
        for subsys = 1:length(devices(currentDevice).Subsystems)
            
            % Get input
            if (strcmp(devices(currentDevice).Subsystems(subsys).SubsystemType, 'AnalogInput'))
                % Get input channels
                for channel = 0:devices(currentDevice).Subsystems(subsys).NumberOfChannelsAvailable - 1
                    % fprintf(['Scanning channel: ai', num2str(channel), ' on device: ', devices(currentDevice).ID ,' ... ']);
                    Ich=Ich+1;waitbar(Ich/Nch,WB);WB.Children.Title.String=['Scanning: ' devices(currentDevice).ID];
                    
                    chanStr = [devices(currentDevice).ID, '/ai', num2str(channel)];
                    s = getTEDS(chanStr);
                    
                    if (s.ErrorCode == 0)
                        % fprintf('Sensor found.\n');
                        % Loop through manufactures
                        manufacturer = '';
                        for manId = 1:length(handles.pubListId)
                            if (handles.pubListId(manId) == s.ManufacturerId)
                                manufacturer = handles.pubListCompany(manId);
                            end
                        end
                        
                        % sens = calllib('tedsLib', 'getSens', chanStr);
                        
                        % Extract unit
                        unit = s.Unit;  % Extract unit
                        
                        if strcmp(unit(1:2), 'V/')
                            if strcmp(unit(3), '(')
                                unit = unit(4:length(unit)-1);
                            else
                                unit = unit(3:length(unit));
                            end
                        end
                        
                        if (keepColumnsIn )
                            dataIn(i, 1) = {false};
                            dataIn(i, 2) = {false};
                            dataIn(i, 3) = {chanStr};
                            %%dataIn(i, 4) = {'Input'};
                            dataIn(i, 4) = oldDataIn(i, 4);
                            dataIn(i, 5) = {'AC'};
                            dataIn(i, 6) = {'IEPE'};
                            %dataIn(i, 7) = {max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
                            dataIn(i, 7) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
                            %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
                            %%dataIn(i, 9) = {'IEPE'};
                            dataIn(i, 8) = {char(manufacturer)};
                            dataIn(i, 9) = {num2str(s.ModelNumber)};
                            dataIn(i, 10) = {num2str(s.SerialNumber)};
                            dataIn(i, 11) = {(s.Sensitivity) * 1000};
                            dataIn(i, 12) = {unit};
                            dataIn(i, 13) = oldDataIn(i, 12);
                            dataIn(i, 14) = oldDataIn(i, 13);
                        else
                            % dataIn(i, :) = {false, chanStr, ' ', 'AC', devices(currentDevice).Subsystems.RangesAvailable.Max, char(manufacturer), s.ModelNumber, s.SerialNumber, s.Sensitivity, {''}, NaN, ' '};
                            dataIn(i, 1) = {false};
                            dataIn(i, 2) = {false};
                            dataIn(i, 3) = {chanStr};
                            %%dataIn(i, 4) = {'Input'};
                            dataIn(i, 4) = {' '};
                            dataIn(i, 5) = {'AC'};
                            dataIn(i, 6) = {'IEPE'};
                            %dataIn(i, 7) = {10};%max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
                            dataIn(i, 7) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
                            %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
                            %%dataIn(i, 9) = {'IEPE'};
                            dataIn(i, 8) = {char(manufacturer)};
                            dataIn(i, 9) = {num2str(s.ModelNumber)};
                            dataIn(i, 10) = {num2str(s.SerialNumber)};
                            dataIn(i, 11) = {(s.Sensitivity) * 1000};
                            dataIn(i, 12) = {unit};
                            dataIn(i, 13) = {NaN};
                            dataIn(i, 14) = {' '};
                        end
                    else
                        % fprintf('Sensor not found!\n');
                        
                        if (keepColumnsIn )
                            dataIn(i, 1) = {false};
                            dataIn(i, 2) = {false};
                            dataIn(i, 3) = {chanStr};
                            %dataIn(i, 4) = {'Input'};
                            dataIn(i, 4) = oldDataIn(i, 4);
                            dataIn(i, 5) = {' '};
                            dataIn(i, 6) = {' '};
                            dataIn(i, 7) = {NaN};
                            %dataIn(i, 9) = {'Voltage'};
                            dataIn(i, 8) = {' '};
                            dataIn(i, 9) = {num2str(NaN)};
                            dataIn(i, 10) = {num2str(NaN)};
                            dataIn(i, 11) = {NaN};
                            dataIn(i, 12) = {' '};
                            dataIn(i, 13) = oldDataIn(i, 12);
                            dataIn(i, 14) = oldDataIn(i, 13);
                        else
                            dataIn(i, :) = {false, false, chanStr, ' ', ' ',' ', NaN, ' ', NaN, NaN, NaN, ' ', NaN, ' '};
                        end
                    end
                    
                    i = i + 1;
                    set(handles.channelsTable, 'data', dataIn);   %   Experimental
                    guidata(hObject, handles);                      %   Experimental
                    drawnow();                                      %   Experimental
                end
            end
            
            % Get output channels
            if (strcmp(devices(currentDevice).Subsystems(subsys).SubsystemType, 'AnalogOutput'))
                % Get output channels
                for channel = 0:devices(currentDevice).Subsystems(subsys).NumberOfChannelsAvailable - 1
                    % fprintf(['Scanning channel: ai', num2str(channel), ' on device: ', devices(currentDevice).ID ,' ... ']);
                    Och=Och+1;waitbar(Och/Nch,WB);WB.Children.Title.String=['Scanning: ' devices(currentDevice).ID];
                    
                    chanStr = [devices(currentDevice).ID, '/ao', num2str(channel)];
                    s = getTEDS(chanStr);
                    
                    if (s.ErrorCode == 0)
                        % fprintf('Sensor found.\n');
                        % Loop through manufactures
                        manufacturer = '';
                        for manId = 1:length(handles.pubListId)
                            if (handles.pubListId(manId) == s.ManufacturerId)
                                manufacturer = handles.pubListCompany(manId);
                            end
                        end
                        
                        % sens = calllib('tedsLib', 'getSens', chanStr);
                        
                        % Extract unit
                        unit = s.Unit;  % Extract unit
                        
                        if strcmp(unit(1:2), 'V/')
                            if strcmp(unit(3), '(')
                                unit = unit(4:length(unit)-1);
                            else
                                unit = unit(3:length(unit));
                            end
                        end
                        
                        if (keepColumnsIn )
                            dataOut(j, 1) = {false};
                            dataOut(j, 2) = {false};
                            dataOut(j, 3) = {chanStr};
                            %%dataOut(j, 4) = {'Input'};
                            dataOut(j, 4) = oldDataIn(j, 4);
                            dataOut(j, 5) = {'AC'};
                            dataOut(j, 6) = {'IEPE'};
                            %dataOut(j, 7) = {max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
                            dataOut(j, 7) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
                            %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
                            %%dataOut(j, 9) = {'IEPE'};
                            dataOut(j, 8) = {char(manufacturer)};
                            dataOut(j, 9) = {num2str(s.ModelNumber)};
                            dataOut(j, 10) = {num2str(s.SerialNumber)};
                            dataOut(j, 11) = {(s.Sensitivity) * 1000};
                            dataOut(j, 12) = {unit};
                            dataOut(j, 13) = oldDataIn(j, 12);
                            dataOut(j, 14) = oldDataIn(j, 13);
                        else
                            % dataOut(j, :) = {false, chanStr, ' ', 'AC', devices(currentDevice).Subsystems.RangesAvailable.Max, char(manufacturer), s.ModelNumber, s.SerialNumber, s.Sensitivity, {''}, NaN, ' '};
                            dataOut(j, 1) = {false};
                            dataOut(j, 2) = {false};
                            dataOut(j, 3) = {chanStr};
                            %%dataOut(j, 4) = {'Input'};
                            dataOut(j, 4) = {' '};
                            dataOut(j, 5) = {'AC'};
                            dataOut(j, 6) = {'IEPE'};
                            %dataOut(j, 7) = {10};%max(devices(currentDevice).Subsystems.RangesAvailable.Max)};
                            dataOut(j, 7) = {max(max(devices(currentDevice).Subsystems(1).RangesAvailable.double))};
                            %vpa(devices(currentDevice).Subsystems.RangesAvailable.Max);
                            %%dataOut(j, 9) = {'IEPE'};
                            dataOut(j, 8) = {char(manufacturer)};
                            dataOut(j, 9) = {num2str(s.ModelNumber)};
                            dataOut(j, 10) = {num2str(s.SerialNumber)};
                            dataOut(j, 11) = {(s.Sensitivity) * 1000};
                            dataOut(j, 12) = {unit};
                            dataOut(j, 13) = {NaN};
                            dataOut(j, 14) = {' '};
                        end
                    else
                        % fprintf('Sensor not found!\n');
                        
                        if (keepColumnsIn )
                            dataOut(j, 1) = {false};
                            dataOut(j, 2) = {false};
                            dataOut(j, 3) = {chanStr};
                            %dataOut(j, 4) = {'Input'};
                            dataOut(j, 4) = oldDataIn(j, 4);
                            dataOut(j, 5) = {' '};
                            dataOut(j, 6) = {' '};
                            dataOut(j, 7) = {NaN};
                            %dataOut(j, 9) = {'Voltage'};
                            dataOut(j, 8) = {' '};
                            dataOut(j, 9) = {num2str(NaN)};
                            dataOut(j, 10) = {num2str(NaN)};
                            dataOut(j, 11) = {NaN};
                            dataOut(j, 12) = {' '};
                            dataOut(j, 13) = oldDataIn(j, 12);
                            dataOut(j, 14) = oldDataIn(j, 13);
                        else
                            dataOut(j, :) = {false, false, chanStr, ' ', ' ',' ', NaN, ' ', NaN, NaN, NaN, ' ', NaN, ' '};
                        end
                    end
                    
                    j = j + 1;
                    set(handles.outputTable, 'data', dataOut);   %   Experimental
                    guidata(hObject, handles);                      %   Experimental
                    drawnow();                                      %   Experimental
                end
            end
            
        end
    else
        fprintf('No devices found\n ');
    end
    
end

% Load in sensor information from xls database
SensorsInLabFile=[handles.homePath, '\conf\SensorsInLab.xlsx'];
if ~isempty(SensorsInLabFile)
    [CLL,rawCells]=xls2cell(SensorsInLabFile,5);
    CLL{1}(1,1)={' '};% Replace column header with blank
    handles.channelsTable.ColumnFormat{10}=CLL{:};
end
handles.channelsTable.CellEditCallback={@celleditcallback,rawCells};

% Delete waitbar
try,delete(WB),catch,end;

% Unload TEDS Parser DLL
%unloadlibrary('tedsLib');

% Clear DAQ
daq.reset;

set(handles.channelsTable, 'data', dataIn);
set(handles.outputTable, 'data', dataOut);
set(handles.statusStr, 'String', 'Scanning hardware complete - READY');
guidata(hObject, handles);

% If packaged as app, .mex files not allowed so packed as .mat files and
% renamed here, revert back here
clear mex % to make them movable
if exist(file1mex, 'file') == 3 && exist(file2mex, 'file') == 3
    movefile(file1mex, file1mat)
    movefile(file2mex, file2mat)
end