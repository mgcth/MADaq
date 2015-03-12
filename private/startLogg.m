function dataOut = startLogg(hObject, eventdata, handles)

global dataObject

% Initialaise the test setup
logging = startInitialisation(hObject, eventdata, handles);

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');
Chact=0;for i=1:size(CHdata,1),if CHdata{i,1},Chact=Chact+1;end,end

%   Check if any channels was added to the session
if (~isempty(logging.session.Channels))
    % Add listener
    logging.eventListener = addlistener(logging.session, 'DataAvailable', @(src, event) logDataTA(src, event));
    
    % Start logging
    logging.session.startForeground();
    
    % Clean-up
    logging.session.release();
    delete(logging.session);
    
    % Clear DAQ
    daq.reset;
    
    % Save data
    Nt=dataObject.nt;
    dataOut = data2WS(1,dataObject.t(1:Nt),dataObject.data(1:Nt,:),logging);
    
    set(handles.statusStr, 'String', 'READY!  DAQ data available at workbench.');
    drawnow();
end

clear -global dataObject