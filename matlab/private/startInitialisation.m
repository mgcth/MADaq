function sessionObject = startInitialisation(hObject, eventdata, handles)

global DATAcontainer

% Define conversion between Hz and kHz;
kHz2Hz = 1000;
Hz2kHz = 0.001;

% Allocate memory
set(handles.statusStr, 'String', 'Allocating memory ...');
drawnow();

CHdata = get(handles.channelsTable, 'data');
channelData.active = find([CHdata{:, 1}] == 1);
channelData.reference = find([CHdata{:, 2}] == 1);
sessionObject.channelInfo.active = channelData.active;
sessionObject.channelInfo.reference = channelData.reference;

Chact = sum([CHdata{:, 1}]);
Chref = sum([CHdata{:, 2}]);
if Chact==0,error('Seems that no channels are active');end
[uv,sv]=memory;
memmax=sv.PhysicalMemory.Available;
ntmax=round(memmax/4/Chact/2/5);% Don't use more that half of available memory, only 1/5 of that for now
DATAcontainer.nt=0;
DATAcontainer.t=zeros(ntmax,1);
DATAcontainer.data=zeros(ntmax,Chact);
DATAcontainer.ntmax=ntmax;

set(handles.statusStr, 'String', 'Setting up system ...');
drawnow();

% Setup session
daq.reset;
sessionObject.session = daq.createSession('ni');
if get(handles.monitor, 'Value') == 1 % if monitor, make it continuous
    sessionObject.freeLogging = false;
    sessionObject.normLogging = false;
    sessionObject.session.IsContinuous = true;
end
if get(handles.dataLogg, 'Value') == 1
    sessionObject.session.DurationInSeconds = eval(get(handles.fun2, 'String'));
end
sessionObject.session.Rate = eval(get(handles.fun1, 'String')) * kHz2Hz;

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
        sessionObject.MHEADER(j).Index = i;
        sessionObject.MHEADER(j).SeqNo = j;
        sessionObject.MHEADER(j).RespId = channelData.channel;
        sessionObject.MHEADER(j).Date = datestr(now,'mm-dd-yyyy HH:MM:SS');
        sessionObject.MHEADER(j).Title = get(handles.title1, 'String');
        sessionObject.MHEADER(j).Title2 = get(handles.title2, 'String');
        sessionObject.MHEADER(j).Title3 = get(handles.title3, 'String');
        sessionObject.MHEADER(j).Title4 = get(handles.title4, 'String');
        sessionObject.MHEADER(j).Label = dataIn{i, 3};
        % Added by Kent 17-02-2014
        sessionObject.MHEADER(j).SensorManufacturer = dataIn{i, 6};
        sessionObject.MHEADER(j).SensorModel = dataIn{i, 7};
        sessionObject.MHEADER(j).SensorSerialNumber = dataIn{i, 8};
        sessionObject.MHEADER(j).SensorSensitivity = dataIn{i, 9};
        %   %   %   %   %   %   %   %   %
        sessionObject.MHEADER(j).Unit = dataIn{i, 10};
        sessionObject.MHEADER(j).Dof = dataIn{i, 11};
        sessionObject.MHEADER(j).Dir = dataIn{i, 12};
        % sessionObject.MHEADER(j).Sensitivity = dataIn{i,11}; % Esben 28-11-2013 Does not comply with specifications, another is added above this
        sessionObject.MHEADER(j).FunctionType = 1;
        
        if get(handles.monitor, 'Value') == 1
            sessionObject.channelData(j) = channelData;
            sessionObject.chanNames(j) = {channelData.channel};
        end
        
        % Increment channels counter
        j = j + 1;
    end
end

% Add output channels
%if get(handles.periodic,'Value') == 1 || get(handles.steppedSine,'Value') == 1 || ...
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
%end

% Check if any channels was added to the session
if (isempty(sessionObject.session.Channels))
    msgbox('No channels in session, might be because no channels have been activated yet.','No channels in session');
    sessionObject.session.release();
    delete(sessionObject.session);
    clear('DATAcontainer');
    
    set(handles.statusStr, 'String', 'Measurement failed ...');
    drawnow();
    
else
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