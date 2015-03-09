function sessionObject = startInitialisation(hObject, eventdata, handles)

global DATAcontainer

% Define conversion between Hz and kHz;
kHz2Hz = 1000;
Hz2kHz = 0.001;

% Allocate memory
set(handles.statusStr, 'String', 'Allocating memory ...');
drawnow();

CHdata = get(handles.channelsTable, 'data');
channelData.active = CHdata{1, 1};
channelData.reference = CHdata{1, 2};
Chact=0;for i=1:size(CHdata,1),if CHdata{i,1},Chact=Chact+1;end,end
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
sessionObject.session = daq.createSession('ni');
if get(handles.monitor, 'Value') == 1 % if monitor, make it continuous
    sessionObject.freeLogging = false;
    sessionObject.normLogging = false;
    sessionObject.session.IsContinuous = true;
    sessionObject.session.Rate = eval(get(handles.fun1, 'String')) * kHz2Hz;
else % else set only rate
    sessionObject.session.Rate = eval(get(handles.fun1, 'String')) * kHz2Hz;
end
if get(handles.dataLogg, 'Value') == 1
    sessionObject.session.DurationInSeconds = eval(get(handles.fun2, 'String'));
end

% Add channels
data = get(handles.channelsTable, 'data');
[m, n] = size(data);
j = 1;

for i = 1:m
    channelData.index = i;
    channelData.active = data{i, 1};
    channelData.reference = data{i, 2};
    channelData.channel = data{i, 3};
    %channelData.signal = data{i, 4};
    channelData.coupling = data{i, 5};
    channelData.voltage = data{i, 6};
    %channelData.sensorType = data{i, 8};
    channelData.sensitivity = data{i, 10};
    
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
        
        %   Setup header
        sessionObject.MHEADER(j).Index = i;
        sessionObject.MHEADER(j).SeqNo = j;
        sessionObject.MHEADER(j).RespId = channelData.channel;
        sessionObject.MHEADER(j).Date = datestr(now,'mm-dd-yyyy HH:MM:SS');
        sessionObject.MHEADER(j).Title = get(handles.title1, 'String');
        sessionObject.MHEADER(j).Title2 = get(handles.title2, 'String');
        sessionObject.MHEADER(j).Title3 = get(handles.title3, 'String');
        sessionObject.MHEADER(j).Title4 = get(handles.title4, 'String');
        sessionObject.MHEADER(j).Label = data{i, 3};
        %   Added by Kent 17-02-2014
        sessionObject.MHEADER(j).SensorManufacturer = data{i, 6};
        sessionObject.MHEADER(j).SensorModel = data{i, 7};
        sessionObject.MHEADER(j).SensorSerialNumber = data{i, 8};
        sessionObject.MHEADER(j).SensorSensitivity = data{i, 9};
        %   %   %   %   %   %   %   %   %
        sessionObject.MHEADER(j).Unit = data{i, 10};
        sessionObject.MHEADER(j).Dof = data{i, 11};
        sessionObject.MHEADER(j).Dir = data{i, 12};
        %   sessionObject.MHEADER(j).Sensitivity = data{i,11}; % Esben 28-11-2013 Does not comply with specifications, another is added above this
        sessionObject.MHEADER(j).FunctionType = 1;
        
        if get(handles.monitor, 'Value') == 1
            sessionObject.channelData(j) = channelData;
            sessionObject.chanNames(j) = {channelData.channel};
        end
        
        %   Increment channels counter
        j = j + 1;
    end
end

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