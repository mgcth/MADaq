function dataOut = startMonitor(hObject, eventdata, handles)

global dataOutTmp handles_

handles_ = handles;

dataOut = dataOutTmp;

%   Get state of session if existing
preview = getappdata(0, 'previewStruct');

try     running = ~isempty(preview) && preview.session.IsRunning;
catch,  running = false;
end

if (~running)

    % Initialaise the test setup
	preview = startInitialisation(hObject, eventdata, handles);
    
    %   Check if any channels was added to the session
    if (~isempty(preview.session.Channels))
        
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
%         preview.adHocLog = uicontrol(preview.figure,    'Style', 'pushbutton', ...
%             'Position', [120 10 150 25], ...
%             'String', 'Start free logging', ...
%             'Callback', @previewAdHocLog);
%         
        %   Duration Log Button
        %             preview.normLog = uicontrol(preview.figure, 'Style', 'pushbutton', ...
        %                                                         'Position', [280 10 150 25], ...
        %                                                         'String', 'Start timed logging', ...
        %                                                         'Callback', @previewNormLog);
        %
        %   Add listener
        preview.eventListener = addlistener(preview.session, 'DataAvailable', @plotPreview);
        
        %   Start monitoring
        set(handles.startButton, 'String', 'Stop monitor','BackGround',[1 0 0]);
        
        %             try preview.session.AutoSyncDSA = true; catch, end
        %             disp(['DSA enabled: ', num2str(preview.session.AutoSyncDSA)]);
        
        preview.session.startBackground();
    end
    
    %   Save state of preview
    setappdata(0, 'previewStruct', preview);
    
else
    closePreview (hObject, eventdata, handles);
    set(handles.startButton, 'String', 'Start measurement','BackGround',[0 1 0]);
end