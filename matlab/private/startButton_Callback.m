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
        
        items = get(handles.fun1, 'String');
        f = str2double(get(handles.fun1, 'String')); %freqConverter(items{get(handles.fun1, 'Value')});
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
            set(handles.startButton, 'String', 'Stop monitor');
            
            %             try preview.session.AutoSyncDSA = true; catch, end
            %             disp(['DSA enabled: ', num2str(preview.session.AutoSyncDSA)]);
            
            preview.session.startBackground();
        end
        
        %   Save state of preview
        setappdata(0, 'previewStruct', preview);
        
    else
        closePreview (hObject, eventdata, handles);
        set(handles.startButton, 'String', 'Start measurement');
    end
    
elseif handles.dataLogg.Value == 1 % if standard test
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
    
    items = get(handles.fun1, 'String');
    f = str2double(get(handles.fun1, 'String')); %freqConverter(items{get(handles.fun1, 'Value')});
    logging.session.Rate = f;
    
    logging.session.DurationInSeconds = str2double(get(handles.fun2, 'String'));
    
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
        %         dataDir = [homeDir, '/datalogg/', dateString];
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
elseif handles.periodic.Value == 1 % if impactTest
    
    
    % TA (start mod)
    % global DATAcontainer
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
    
    set(handles.statusStr, 'String', 'Setting up logging ...');
    drawnow();
    
    dateString = datestr(now,'mm-dd-yyyy_HH-MM-SS');
    
    %   Setup session
    periodic.session = daq.createSession('ni');
    
    items = get(handles.fun1, 'String');
    f = str2double(get(handles.fun1, 'String')); %freqConverter(items{get(handles.fun1, 'Value')});
    periodic.session.Rate = f;
    
    periodic.session.DurationInSeconds = str2double(get(handles.fun2, 'String'));
    
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
                periodic.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'IEPE');
            else
                analogChan = periodic.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
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
            periodic.MHEADER(j).SeqNo = j;
            periodic.MHEADER(j).RespId = channelData.channel;
            periodic.MHEADER(j).Date = datestr(now,'mm-dd-yyyy HH:MM:SS');
            periodic.MHEADER(j).Title = get(handles.title1, 'String');
            periodic.MHEADER(j).Title2 = get(handles.title2, 'String');
            periodic.MHEADER(j).Title3 = get(handles.title3, 'String');
            periodic.MHEADER(j).Title4 = get(handles.title4, 'String');
            periodic.MHEADER(j).Label = data{i, 3};
            %   Added by Kent 17-02-2014
            periodic.MHEADER(j).SensorManufacturer = data{i, 6};
            periodic.MHEADER(j).SensorModel = data{i, 7};
            periodic.MHEADER(j).SensorSerialNumber = data{i, 8};
            periodic.MHEADER(j).SensorSensitivity = data{i, 9};
            %   %   %   %   %   %   %   %   %
            periodic.MHEADER(j).Unit = data{i, 10};
            periodic.MHEADER(j).Dof = data{i, 11};
            periodic.MHEADER(j).Dir = data{i, 12};
            %   periodic.MHEADER(j).Sensitivity = data{i,11}; % Esben 28-11-2013 Does not comply with specifications, another is added above this
            periodic.MHEADER(j).FunctionType = 1;
            
            %   Increment channels counter
            j = j + 1;
        end
    end
    
    %   Check if any channels was added to the session
    if (isempty(periodic.session.Channels))
        msgbox('No channels in session, might be because no channels have been activated yet.','No channels in session');
        periodic.session.release();
        delete(periodic.session);
        
        set(handles.statusStr, 'String', 'Logging failed ...');
        drawnow();
        
        %   Else start periodic data
    else
        set(handles.statusStr, 'String', 'Logging data from sensors ...');
        drawnow();
        
        %   Sync and reject alias if low freqency
        try periodic.session.AutoSyncDSA = true; catch, end
        
        try
            lowFreq = f < 1000;
            for i = 1:length(periodic.session.Channels)
                periodic.session.Channels(i).EnhancedAliasRejectionEnable = lowFreq;
            end
        catch
            lowFreq = 0;
        end
        
        disp(['SyncDSA: ', num2str(periodic.session.AutoSyncDSA), ' - Aliasrejection: ', num2str(lowFreq)]);
        
        
        %   Add listener
        % TA (start mod)
        %         periodic.eventListener = addlistener(periodic.session, 'DataAvailable', @(src, event) logData(src, event, periodic.files));
        periodic.eventListener = addlistener(periodic.session, 'DataAvailable', @(src, event) logDataTA(src, event));
        % TA (end mod)
        
        %   Start periodic
        periodic.session.startForeground();
        
        %   Get actual rate
        actualFs = periodic.session.Rate;
        
        %   Will remain here until data periodic is finished ...
        
        
        
        
        
        
        %                                                        Initiate and test  
    Fs=periodic.session.Rate;Ts=1/Fs;
    
    
    
    
    
  try
    [t,Load]=eval(char(handles.fun3.String));
  catch
    errormsg(2);
  end
  MaxAmpl=eval(handles.fun6.String);
  MaxLoad=max(abs(Load));Fspan=eval(handles.fun7.String);
  Cycles=str2double(handles.fun4.String);Skipps=str2double(handles.fun5.String);
  Tend=str2double(handles.fun2.String);
  dt=t(2)-t(1);
  t(end+1)=t(end)+dt;t(end+1)=Tend;
  Load(end+1)=0;Load(end+1)=0;
  Ts=1/Fs;
  Load=interp1(t,(MaxAmpl/MaxLoad)*Load,t(1):Ts:t(end));
    
    
    
    
    
    Refch=1; %%DUMMY for now!  find(CH.active==CH.refch);
    Nch=Chact;%length(CH.active);
    Ych=setdiff(1:Nch,Refch);
    
    Ndata=length(Load);
    WaitTime=Cycles*Ndata*Ts;
    disp(' '),disp(['Shaking about ' num2str(WaitTime) 's. Please wait ...'])
    
    qd=[];
    for I=1:Cycles;qd=[qd;Load(:)];end
    queueOutputData(periodic.session,qd);
    y=startForeground(periodic.session);
    y(1:Skipps*Ndata,:)=[];
    u=y(:,Refch);
    y=y(:,Ych);
    
    disp('Done.')
    disp('Estimating transfer functions. Please wait ...')
    
    %                                                           Do calibration
    active = [periodic.MHEADER.SeqNo];
    refch = 1;
    cal = 1./[periodic.MHEADER.SensorSensitivity];
    yind=setdiff(active,refch);uind=refch;
    y=y*diag(1./cal(yind));u=u*diag(1./cal(uind));
    
    for II=1:size(y,2)
        [FRF(II,1,:),f] = ...
            tfestimate(u,y(:,II),ones(Ndata,1),0,Ndata,Fs);
    end
    ind=find(f>=min(Fspan) & f<=max(Fspan));FRF=FRF(:,:,ind);f=f(ind);
    
    % Make IDFRD data object
    frdsys=frd(FRF,2*pi*f,'FrequencyUnit','rad/s');
    frdsys=idfrd(frdsys);
        
        
        
        
        
        
        
        %   Clean-up
        periodic.session.release();
        delete(periodic.session);
        
        %   Clear DAQ
        daq.reset;
        
        set(handles.statusStr, 'String', 'READY!  DAQ data available at workbench.');
        drawnow();
        
        % TA (start mod)
        Nt=DATAcontainer.nt;
        DAQdata2WS(1,DATAcontainer.t(1:Nt),DATAcontainer.data(1:Nt,:),CHdata);
        % TA (end)
        
    end
    
    
elseif handles.steppedSine.Value == 1 % if impactTest
elseif handles.multisine.Value == 1 % if impactTest
end