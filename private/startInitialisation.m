function sessionObject = startInitialisation(hObject, eventdata, handles)

% Define conversion between Hz and kHz;
kHz2Hz = 1000;
Hz2kHz = 0.001;

% Update status bar
set(handles.statusStr, 'String', 'Setting up system ...');
drawnow();

% Get channel data
Chdata = get(handles.channelsTable, 'data');
channelData.active = find([Chdata{:, 1}] == 1);
channelData.reference = find([Chdata{:, 2}] == 1);
sessionObject.channelInfo.active = channelData.active;
sessionObject.channelInfo.reference = channelData.reference;

% Setup session
daq.reset;
sessionObject.session = daq.createSession('ni');

% If monitor, make it continuous
if get(handles.monitor, 'Value') == 1
    sessionObject.freeLogging = false;
    sessionObject.normLogging = false;
    sessionObject.session.IsContinuous = true;
end

% If data logging, set the time
if get(handles.dataLogg, 'Value') == 1
    sessionObject.session.DurationInSeconds = eval(get(handles.fun2, 'String'));
end

% Set rate
sessionObject.session.Rate = eval(get(handles.fun1, 'String')) * kHz2Hz;

% Collect info
% Name and email
sessionObject.Metadata.Tester = handles.autoReport.UserData.TesterInfo{1};
sessionObject.Metadata.Email = handles.autoReport.UserData.TesterInfo{2};
sessionObject.Metadata.Affiliation = handles.autoReport.UserData.TesterInfo{3};

% Date
sessionObject.Metadata.TestDate = datestr(now,'mm-dd-yyyy HH:MM:SS');

% Titles
sessionObject.Metadata.TestTitles{1} = get(handles.title1, 'String');
sessionObject.Metadata.TestTitles{2} = get(handles.title2, 'String');
sessionObject.Metadata.TestTitles{3} = get(handles.title3, 'String');
sessionObject.Metadata.TestTitles{4} = get(handles.title4, 'String');

% Measurement type and options
% Check which test
if get(handles.monitor,'Value') == 1 % if monitor
    sessionObject.Metadata.TestType = 'Monitor';
    
    sessionObject.Metadata.TestSettings{1,1} = get(handles.fun1Text,'String');
    sessionObject.Metadata.TestSettings{1,2} = get(handles.fun1,'String');
    
elseif get(handles.dataLogg,'Value') == 1 % if standard test
    sessionObject.Metadata.TestType = 'Data logging';
    
    sessionObject.Metadata.TestSettings{1,1} = get(handles.fun1Text,'String');
    sessionObject.Metadata.TestSettings{1,2} = get(handles.fun1,'String');
    sessionObject.Metadata.TestSettings{2,1} = get(handles.fun2Text,'String');
    sessionObject.Metadata.TestSettings{2,2} = get(handles.fun2,'String');
    
elseif get(handles.impactTest,'Value') == 1 % if impactTest
    sessionObject.Metadata.TestType = 'Impact test';
    
    sessionObject.Metadata.TestSettings{1,1} = get(handles.fun1Text,'String');
    sessionObject.Metadata.TestSettings{1,2} = get(handles.fun1,'String');
    sessionObject.Metadata.TestSettings{2,1} = get(handles.fun2Text,'String');
    sessionObject.Metadata.TestSettings{2,2} = get(handles.fun2,'String');
    sessionObject.Metadata.TestSettings{3,1} = get(handles.fun3Text,'String');
    sessionObject.Metadata.TestSettings{3,2} = get(handles.fun3,'String');
    sessionObject.Metadata.TestSettings{4,1} = get(handles.fun4Text,'String');
    sessionObject.Metadata.TestSettings{4,2} = get(handles.fun4,'String');
    sessionObject.Metadata.TestSettings{5,1} = get(handles.fun5Text,'String');
    sessionObject.Metadata.TestSettings{5,2} = get(handles.fun5,'String');
    
elseif get(handles.periodic,'Value') == 1 % if impactTest
    sessionObject.Metadata.TestType = 'Periodic input';
    
    sessionObject.Metadata.TestSettings{1,1} = get(handles.fun1Text,'String');
    sessionObject.Metadata.TestSettings{1,2} = get(handles.fun1,'String');
    sessionObject.Metadata.TestSettings{2,1} = get(handles.fun2Text,'String');
    sessionObject.Metadata.TestSettings{2,2} = get(handles.fun2,'String');
    sessionObject.Metadata.TestSettings{3,1} = get(handles.fun3Text,'String');
    sessionObject.Metadata.TestSettings{3,2} = get(handles.fun3,'String');
    sessionObject.Metadata.TestSettings{4,1} = get(handles.fun4Text,'String');
    sessionObject.Metadata.TestSettings{4,2} = get(handles.fun4,'String');
    sessionObject.Metadata.TestSettings{5,1} = get(handles.fun5Text,'String');
    sessionObject.Metadata.TestSettings{5,2} = get(handles.fun5,'String');
    sessionObject.Metadata.TestSettings{6,1} = get(handles.fun6Text,'String');
    sessionObject.Metadata.TestSettings{6,2} = get(handles.fun6,'String');
    sessionObject.Metadata.TestSettings{7,1} = get(handles.fun7Text,'String');
    sessionObject.Metadata.TestSettings{7,2} = get(handles.fun7,'String');
    
elseif get(handles.steppedSine,'Value') == 1 % if impactTest
    sessionObject.Metadata.TestType = 'Stepped sine input';
    
    sessionObject.Metadata.TestSettings{1,1} = get(handles.fun1Text,'String');
    sessionObject.Metadata.TestSettings{1,2} = get(handles.fun1,'String');
    sessionObject.Metadata.TestSettings{2,1} = get(handles.fun2Text,'String');
    sessionObject.Metadata.TestSettings{2,2} = get(handles.fun2,'String');
    sessionObject.Metadata.TestSettings{3,1} = get(handles.fun3Text,'String');
    sessionObject.Metadata.TestSettings{3,2} = get(handles.fun3,'String');
    sessionObject.Metadata.TestSettings{4,1} = get(handles.fun4Text,'String');
    sessionObject.Metadata.TestSettings{4,2} = get(handles.fun4,'String');
    sessionObject.Metadata.TestSettings{5,1} = get(handles.fun5Text,'String');
    sessionObject.Metadata.TestSettings{5,2} = get(handles.fun5,'String');
    sessionObject.Metadata.TestSettings{6,1} = get(handles.fun6Text,'String');
    sessionObject.Metadata.TestSettings{6,2} = get(handles.fun6,'String');
    
elseif handles.multisine.Value == 1 % if impactTest
    sessionObject.Metadata.TestType = 'Multisine input';
    
    sessionObject.Metadata.TestSettings{1,1} = get(handles.fun1Text,'String');
    sessionObject.Metadata.TestSettings{1,2} = get(handles.fun1,'String');
    sessionObject.Metadata.TestSettings{2,1} = get(handles.fun2Text,'String');
    sessionObject.Metadata.TestSettings{2,2} = get(handles.fun2,'String');
    sessionObject.Metadata.TestSettings{3,1} = get(handles.fun3Text,'String');
    sessionObject.Metadata.TestSettings{3,2} = get(handles.fun3,'String');
    sessionObject.Metadata.TestSettings{4,1} = get(handles.fun4Text,'String');
    sessionObject.Metadata.TestSettings{4,2} = get(handles.fun4,'String');
    sessionObject.Metadata.TestSettings{5,1} = get(handles.fun5Text,'String');
    sessionObject.Metadata.TestSettings{5,2} = get(handles.fun5,'String');
    sessionObject.Metadata.TestSettings{6,1} = get(handles.fun6Text,'String');
    sessionObject.Metadata.TestSettings{6,2} = get(handles.fun6,'String');
    
end

% Add input channels
dataIn = get(handles.channelsTable, 'data');
[m, n] = size(dataIn);
j = 1;

for i = 1:m%[3:m 1:2]
    channelData.index = i;
    channelData.active = dataIn{i, 1};
    channelData.reference = dataIn{i, 2};
    channelData.channel = dataIn{i, 3};
    %channelData.signal = dataIn{i, 4};
    channelData.coupling = dataIn{i, 5};
    channelData.voltage = dataIn{i, 6};
    %channelData.sensorType = dataIn{i, 8};
    channelData.sensitivity = dataIn{i, 10};
    
    % Check if channel is ok, if so, then add channel to monitor
    configOk =  channelData.active && ...
        ~isnan(channelData.voltage) && ...
        ~isnan(channelData.sensitivity);
    %strcmp(channelData.signal, 'Input') && ...
    
    %~strcmp(channelData.sensorType, ' ') && ...
    
    if (configOk)
        %   Add channel to session
        chan = textscan(channelData.channel, '%s%s', 'Delimiter', '/', 'CollectOutput', 1);
        
        if strcmp(channelData.coupling, 'IEPE')
            sessionObject.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'IEPE');
        else
            analogChan = sessionObject.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
            %analogChan.EnhancedAliasRejectionEnable = lowFreq;
            
            if strcmp(channelData.coupling, 'AC')
                analogChan.Coupling = 'AC';
            elseif strcmp(channelData.coupling, 'DC')
                analogChan.Coupling = 'DC';
            end
        end
        
        %logging.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');%channelData.sensorType);
        %logging.session.Channels(j).Sensitivity = channelData.sensitivity;
        
        % Setup header
%         sessionObject.Metadata.Sensor{j}.Index = i;
%         sessionObject.Metadata.Sensor{j}.Number = j;
%         sessionObject.Metadata.Sensor{j}.Reference = dataIn{i, 2};
%         sessionObject.Metadata.Sensor{j}.Channel = dataIn{i, 3};%channelData.channel;
%         sessionObject.Metadata.Sensor{j}.Label = dataIn{i, 4};
%         sessionObject.Metadata.Sensor{j}.Coupling = dataIn{i, 5};
%         sessionObject.Metadata.Sensor{j}.Voltage = dataIn{i, 6};
%         sessionObject.Metadata.Sensor{j}.SensorManufacturer = dataIn{i, 7};
%         sessionObject.Metadata.Sensor{j}.SensorModel = dataIn{i, 8};
%         sessionObject.Metadata.Sensor{j}.SensorSerialNumber = dataIn{i, 9};
%         sessionObject.Metadata.Sensor{j}.SensorSensitivity = dataIn{i, 10};
%         sessionObject.Metadata.Sensor{j}.Unit = dataIn{i, 11};
%         sessionObject.Metadata.Sensor{j}.Dof = dataIn{i, 12};
%         sessionObject.Metadata.Sensor{j}.Dir = dataIn{i, 13};
        sessionObject.Metadata.Sensor.Index{j} = i;
        sessionObject.Metadata.Sensor.Number{j} = j;
        sessionObject.Metadata.Sensor.Reference{j} = dataIn{i, 2};
        sessionObject.Metadata.Sensor.Channel{j} = dataIn{i, 3};%channelData.channel;
        sessionObject.Metadata.Sensor.Label{j} = dataIn{i, 4};
        sessionObject.Metadata.Sensor.Coupling{j} = dataIn{i, 5};
        sessionObject.Metadata.Sensor.Voltage{j} = dataIn{i, 6};
        sessionObject.Metadata.Sensor.Manufacturer{j} = dataIn{i, 7};
        sessionObject.Metadata.Sensor.Model{j} = dataIn{i, 8};
        sessionObject.Metadata.Sensor.SerialNumber{j} = dataIn{i, 9};
        sessionObject.Metadata.Sensor.Sensitivity{j} = dataIn{i, 10};
        sessionObject.Metadata.Sensor.Unit{j} = dataIn{i, 11};
        sessionObject.Metadata.Sensor.Dof{j} = dataIn{i, 12};
        sessionObject.Metadata.Sensor.Dir{j} = dataIn{i, 13};
        
        %sessionObject.Metadata.Sensor{j}.FunctionType = 1;
        
        if get(handles.monitor, 'Value') == 1
            sessionObject.channelData(j) = channelData;
            sessionObject.chanNames(j) = {channelData.channel};
        end
        
        % Increment channels counter
        j = j + 1;
    end
end

% Add output channels to periodic, steppedSine and multisine
if get(handles.periodic,'Value') == 1 || get(handles.steppedSine,'Value') == 1 || ...
        get(handles.multisine,'Value') == 1
    dataOut = get(handles.outputTable, 'data');
    [mm, nn] = size(dataOut);
    j = 1;
    
    for i = 1:mm
        if dataOut{i,1} == 1
            chan = textscan(dataOut{i,3}, '%s%s', 'Delimiter', '/', 'CollectOutput', 1);
            sessionObject.session.addAnalogOutputChannel(char(chan{1}(1)), 0, 'Voltage');
            
            % Increment channels counter
            j = j + 1;
        end
    end
end

% Check if any channels was added to the session
if (isempty(sessionObject.session.Channels))
    msgbox('No channels in session, might be because no channels have been activated yet.','No channels in session');
    sessionObject.session.release();
    delete(sessionObject.session);
    
    set(handles.statusStr, 'String', 'Measurement failed ...');
    drawnow();
    
else
    % Allocate memory for measurement
    allocateMemory(handles);
    
    set(handles.statusStr, 'String', 'Measurement in progress ...');
    drawnow();
    
    % Sync and reject alias if low freqency
    try sessionObject.session.AutoSyncDSA = true; catch, end
    
    try
        lowFreq = f < 1000;
        for i = 1:length(sessionObject.session.Channels)
            sessionObject.session.Channels(i).EnhancedAliasRejectionEnable = lowFreq;
        end
    catch
        lowFreq = 0;
    end
    
    disp(['SyncDSA: ', num2str(sessionObject.session.AutoSyncDSA), ' - Aliasrejection: ', num2str(lowFreq)]);
end