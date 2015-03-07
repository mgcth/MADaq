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