function previewAdHocLog (hObject, eventData, handles)

global dataObject dataOutTmp

preview = getappdata(0, 'previewStruct');

try     running = ~isempty(preview) && preview.adHocLogging;
catch,  running = false;
end

if (~running)
    preview.adHocLogging = true;
    %disp('Starting ad hoc logging ...');
    
%     for j = 1:length(preview.channelData)
%         preview.logging.MHEADER(j).SeqNo = j;
%         preview.logging.MHEADER(j).RespId = preview.channelData(j).channel;
%         preview.logging.MHEADER(j).Date = datestr(now,'mm-dd-yyyy HH:MM:SS');
%         preview.logging.MHEADER(j).Title = preview.channelData(j).title1;
%         preview.logging.MHEADER(j).Title2 = preview.channelData(j).title2;
%         preview.logging.MHEADER(j).Title3 = preview.channelData(j).title3;
%         preview.logging.MHEADER(j).Title4 = preview.channelData(j).title4;
%         preview.logging.MHEADER(j).Label = preview.channelData(j).label;
%         preview.logging.MHEADER(j).SensorManufacturer = preview.channelData(j).manufacturer;
%         preview.logging.MHEADER(j).SensorModel = preview.channelData(j).model;
%         preview.logging.MHEADER(j).SensorSerialNumber = preview.channelData(j).serialNumber;
%         preview.logging.MHEADER(j).SensorSensitivity = preview.channelData(j).sensitivity;
%         preview.logging.MHEADER(j).Unit = preview.channelData(j).units;
%         preview.logging.MHEADER(j).Dof = preview.channelData(j).dof;
%         preview.logging.MHEADER(j).Dir = preview.channelData(j).direction;
%         preview.logging.MHEADER(j).FunctionType = 1;
%         
%     end
    

    
    %setappdata(0, 'previewStruct', preview);
    
    % Add listener
    preview.freeLogEventListener = addlistener(preview.session, 'DataAvailable', @(src, event) logData(src, event));
    
    set(preview.adHocLog, 'String', 'Stop free logging');
    drawnow;
    
    % % TA (start mod)
    %        global dataObject
    %        ts=timeseries(dataObject.data,dataObject.t);
    %        assignin('base','logdata',ts);
    % % TA (end)
    
else
    preview.adHocLogging = false;
    %disp('Stopping ad hoc logging ...');
    
    delete(preview.freeLogEventListener);
    
    set(preview.adHocLog, 'String', 'Start free logging');
    drawnow;
    % TA (start mod)
    % Save data
    Nt=dataObject.nt;
    dataOutTmp = data2WS(1,dataObject.t(1:Nt),dataObject.data(1:Nt,:),preview);
    %clear -global dataObject
    % TA (end)
end

%     set(preview.adHocLog, 'String', 'Start free logging');
%     drawnow;

setappdata(0, 'previewStruct', preview);