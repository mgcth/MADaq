function sessionObject = startInitialisation(hObject, eventdata, handles)

% Define conversion between Hz and kHz;
kHz2Hz = 1000;
Hz2kHz = 0.001;

% Update status bar
if handles.CalibrateButton.Value
  set(handles.statusStr, 'String', 'Calibrating ...');
else    
  set(handles.statusStr, 'String', 'Setting up system ...');
end  
drawnow();

% Get channel data
Chdata = get(handles.channelsTable, 'data');
channelData.active = find([Chdata{:, 1}] == 1);
channelData.reference = find([Chdata{:, 2}] == 1);
sessionObject.channelInfo.active = channelData.active;
sessionObject.channelInfo.reference = channelData.reference;
sessionObject.channelInfo.ao = 0;

Vendors=daq.getVendors;
for I=1:length(Vendors)
  if(Vendors(I).IsOperational)
    Vendor=Vendors(I).ID;
  end
end

% Setup session
daq.reset;
sessionObject.session = daq.createSession(Vendor);

if ~handles.CalibrateButton.Value
% If Oscilloscope, make it continuous
  if handles.Oscilloscope.Value == 1
    sessionObject.freeLogging = false;
    sessionObject.normLogging = false;
    sessionObject.session.IsContinuous = true;
  end
end

% Set rate
RateString=[get(handles.fun1, 'String') '       '];
if strcmpi(RateString(1:7),'default')
  sessionObject.session.Rate=eval(RateString(8:end))*kHz2Hz;%Default
  PrescribedRate=sessionObject.session.Rate;
else
  PrescribedRate=eval(get(handles.fun1, 'String')) * kHz2Hz;
  sessionObject.session.Rate = PrescribedRate;
end

% Collect info: Name and email
try,sessionObject.Metadata.Tester = handles.autoReport.UserData.TesterInfo{1};catch,end
try,sessionObject.Metadata.Email = handles.autoReport.UserData.TesterInfo{2};catch,end
try,sessionObject.Metadata.Affiliation = handles.autoReport.UserData.TesterInfo{3};catch,end

% Date
sessionObject.Metadata.TestDate = datestr(now,'mm-dd-yyyy HH:MM:SS');

% Titles
sessionObject.Metadata.TestTitles{1} = get(handles.title1, 'String');
sessionObject.Metadata.TestTitles{2} = get(handles.title2, 'String');
sessionObject.Metadata.TestTitles{3} = get(handles.title3, 'String');
sessionObject.Metadata.TestTitles{4} = get(handles.title4, 'String');

% Measurement type and options. Check which test
if handles.CalibrateButton.Value
    
elseif handles.Oscilloscope.Value == 1 % if oscilloscope
    sessionObject.Metadata.TestType = 'Oscilloscope';
    sessionObject.Metadata.TestSettings{1,1} = get(handles.fun1Text,'String');
    sessionObject.Metadata.TestSettings{1,2} = get(handles.fun1,'String');
    
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
    
elseif get(handles.periodic,'Value') == 1 % if periodic Test
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
    
% elseif get(handles.steppedSine,'Value') == 1 % if steppedsine Test
%     sessionObject.Metadata.TestType = 'Stepped sine input';
%     sessionObject.Metadata.TestSettings{1,1} = get(handles.fun1Text,'String');
%     sessionObject.Metadata.TestSettings{1,2} = get(handles.fun1,'String');
%     sessionObject.Metadata.TestSettings{2,1} = get(handles.fun2Text,'String');
%     sessionObject.Metadata.TestSettings{2,2} = get(handles.fun2,'String');
%     sessionObject.Metadata.TestSettings{3,1} = get(handles.fun3Text,'String');
%     sessionObject.Metadata.TestSettings{3,2} = get(handles.fun3,'String');
%     sessionObject.Metadata.TestSettings{4,1} = get(handles.fun4Text,'String');
%     sessionObject.Metadata.TestSettings{4,2} = get(handles.fun4,'String');
%     sessionObject.Metadata.TestSettings{5,1} = get(handles.fun5Text,'String');
%     sessionObject.Metadata.TestSettings{5,2} = get(handles.fun5,'String');
%     sessionObject.Metadata.TestSettings{6,1} = get(handles.fun6Text,'String');
%     sessionObject.Metadata.TestSettings{6,2} = get(handles.fun6,'String');
%     sessionObject.Metadata.TestSettings{7,1} = get(handles.fun7Text,'String');
%     sessionObject.Metadata.TestSettings{7,2} = get(handles.fun7,'String');
    
elseif handles.multisine.Value == 1 % if multisine Test
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
    sessionObject.Metadata.TestSettings{7,1} = get(handles.fun7Text,'String');
    sessionObject.Metadata.TestSettings{7,2} = get(handles.fun7,'String');
    
end

% Add input channels
dataIn = get(handles.channelsTable, 'data');
% [m, n] = size(dataIn);
activated = find([dataIn{:, 1}] == 1);
j = 1; jj = 1; channelNumber = []; cardName = '';

for i = activated
    channelData.index = i;
    channelData.active = dataIn{i, 1};
    channelData.reference = dataIn{i, 2};
    channelData.channel = dataIn{i, 3};
    channelData.label = dataIn{i, 4};
    channelData.coupling = dataIn{i, 5};
    channelData.type = dataIn{i, 6};
    channelData.voltage = dataIn{i, 7};
    channelData.sensitivity = dataIn{i, 11};
    
    % Check if channel is ok, if so, then add channel to monitor
    configOk =  channelData.active && ...
                ~isnan(channelData.voltage) && ...
                ~isnan(channelData.sensitivity);    
    if (configOk)
        %   Add channel to session
        chan = textscan(channelData.channel, '%s%s', 'Delimiter', '/', 'CollectOutput', 1);
        
        tic
        % piece of shit code, but i blame Mathworks for a poor
        % implementation too (or is it NI?)
        if strcmp(channelData.type, 'Voltage')
            % dumpt the found IEPE channels
            if ~isempty(channelNumber)
                sessionObject.session.addAnalogInputChannel(cardName, channelNumber, 'IEPE');
            end
            analogChan = sessionObject.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
            if strcmp(channelData.coupling, 'AC')
                analogChan.Coupling = 'AC';
            elseif strcmp(channelData.coupling, 'DC')
                analogChan.Coupling = 'DC';
            end
            
            jj = 1;
            channelNumber = [];
        else
            if  (j && jj == 1)
                tmpSlotNumber = regexp(chan{1}{1, 2},'\d','match');
                channelNumber(jj) = str2num([tmpSlotNumber{:}]);
                cardName = chan{1}{1, 1};
            else
                if strcmp(cardName, chan{1}{1,1})
                    tmpSlotNumber = regexp(chan{1}{1, 2},'\d','match');
                    channelNumber(jj) = str2num([tmpSlotNumber{:}]);
                else
                    for jjj=1:length(channelNumber)
                      sessionObject.session.addAnalogInputChannel(cardName, channelNumber(jjj), 'IEPE');
                    end
                                        
                    % Start with the next set
                    cardName = chan{1}{1, 1};
                    if strcmp(channelData.type, 'Voltage')
                        % dumpt the found IEPE channels
                        if ~isempty(channelNumber)
                            sessionObject.session.addAnalogInputChannel(cardName, channelNumber, 'IEPE');
                        end
                        analogChan = sessionObject.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
                        
                        if strcmp(channelData.coupling, 'AC')
                            analogChan.Coupling = 'AC';
                        elseif strcmp(channelData.coupling, 'DC')
                            analogChan.Coupling = 'DC';
                        end
                        
                        jj = 1;
                        channelNumber = [];
                    else
                        jj = 1;
                        channelNumber = [];
                        tmpSlotNumber = regexp(chan{1}{1, 2},'\d','match');
                        channelNumber(jj) = str2num([tmpSlotNumber{:}]);                       
                    end
                end
                
            end
        end
        jj = jj + 1;
        
        % If the last card make an addition
        if i == activated(end)
            if ~isempty(channelNumber)
                sessionObject.session.addAnalogInputChannel(cardName, channelNumber, 'IEPE');
            end
        end
        
        times(j) = toc;
        % Setup header
        sessionObject.Metadata.Sensor.Index{j} = i;
        sessionObject.Metadata.Sensor.Number{j} = j;
        if dataIn{i, 2}
            sessionObject.Metadata.Sensor.Reference{j} = 'Yes';
        else
            sessionObject.Metadata.Sensor.Reference{j} = 'No';
        end
        sessionObject.Metadata.Sensor.Channel{j} = dataIn{i, 3};%channelData.channel;
        sessionObject.Metadata.Sensor.Label{j} = dataIn{i, 4};
        sessionObject.Metadata.Sensor.Coupling{j} = dataIn{i, 5};
        sessionObject.Metadata.Sensor.Type{j} = dataIn{i, 6};
        sessionObject.Metadata.Sensor.Voltage{j} = dataIn{i, 7};
        sessionObject.Metadata.Sensor.Manufacturer{j} = dataIn{i, 8};
        sessionObject.Metadata.Sensor.Model{j} = dataIn{i, 9};
        sessionObject.Metadata.Sensor.SerialNumber{j} = dataIn{i, 10};
        sessionObject.Metadata.Sensor.Sensitivity{j} = dataIn{i, 11};
        sessionObject.Metadata.Sensor.Unit{j} = dataIn{i, 12};
        sessionObject.Metadata.Sensor.Dof{j} = dataIn{i, 13};
        sessionObject.Metadata.Sensor.Dir{j} = dataIn{i, 14};
                
        % Increment channels counter
        j = j + 1;
        
        % Update status bar
        set(handles.statusStr, 'String', ['Added sensor ', num2str(j-1), ' of ', num2str(length(activated)), ' ...']);
        drawnow(); pause(0.1);
    end
end

for i = 1:length(activated)
    channelData.coupling = dataIn{activated(i), 5};
    
    if strcmp(channelData.coupling, 'AC')
        sessionObject.session.Channels(i).Coupling = 'AC';
    elseif strcmp(channelData.coupling, 'DC')
        sessionObject.session.Channels(i).Coupling = 'DC';
    end
    
end

%%                                                      Add output channels
if ~handles.CalibrateButton.Value
%   if handles.periodic.Value==1 || handles.steppedSine.Value==1 || ...
%         handles.multisine.Value==1 || handles.Oscilloscope.Value==1
  if handles.periodic.Value==1 || ...
        handles.multisine.Value==1 || handles.Oscilloscope.Value==1
    dataOut = get(handles.outputTable, 'data');
    [mm, nn] = size(dataOut);
    j = 1;
    for i = 1:mm
%         channelDataOut.coupling = dataOut{i,5};
        
        if dataOut{i,1} == 1
            sessionObject.channelInfo.ao = sessionObject.channelInfo.ao+1;
            chan = textscan(dataOut{i,2}, '%s%s', 'Delimiter', '/', 'CollectOutput', 1);
            sessionObject.session.addAnalogOutputChannel(char(chan{1}(1)), 0, 'Voltage');
                        
            % Increment channels counter
            j = j + 1;
            
            % Update status bar
            set(handles.statusStr, 'String', ['Added output ', num2str(j-1), ' of ', num2str(length(activated)), ' ...']);
            drawnow(); pause(0.1);

        end
    end
  end
end  

%%                          Check if any channels were added to the session
if (isempty(sessionObject.session.Channels))
    msgbox('No channels in session, might be because no channels have been activated yet.','No channels in session');
    sessionObject.session.release();
    delete(sessionObject.session);
    
    set(handles.statusStr, 'String', 'Measurement failed ...');
    drawnow();
    
else
    if get(handles.periodic,'Value') == 1  
        % Allocate memory for measurement
        allocateMemory(handles);
    end
    
    if handles.CalibrateButton.Value
      set(handles.statusStr, 'String', 'Calibration in progress ...');
    else    
      set(handles.statusStr, 'String', 'Measurement in progress ...');
    end  
    drawnow();
    
%% Sync and reject alias if low freqency
    try sessionObject.session.AutoSyncDSA = true; catch, end   
    try
        lowFreq = f < 1000;
        for i = 1:length(sessionObject.session.Channels)
            sessionObject.session.Channels(i).EnhancedAliasRejectionEnable = lowFreq;
        end
    catch
        lowFreq = 0;
    end
%     try
%       disp(['SyncDSA: ', num2str(sessionObject.session.AutoSyncDSA), ' - Aliasrejection: ', num2str(lowFreq)]);
%     catch
%       disp('SyncDSA not available on this unit');
%     end  
end

if abs(PrescribedRate-sessionObject.session.Rate)>1
  disp(['Rate has changed from prescribed rate at: ' int2str(PrescribedRate) ' into: ' int2str(sessionObject.session.Rate)])
end  