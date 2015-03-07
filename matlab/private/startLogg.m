function startLogg(hObject, eventdata, handles)
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