function startMonitor(hObject, eventdata, handles)

% Define conversion between Hz and kHz;
kHz2Hz = 1000;
Hz2kHz = 0.001;

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
    
    preview.session.Rate = str2double(get(handles.fun1, 'String')) * kHz2Hz;
    
    %   Get overall info
    preview.logging.impact = get(handles.impactTest, 'Value');
    
    %   Add channels
    data = get(handles.channelsTable, 'data');
    [m, n] = size(data);
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