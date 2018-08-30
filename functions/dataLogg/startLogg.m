function dataOut = startLogg(hObject, eventdata, handles)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global dataObject

% Initialaise the test setup
set(handles.startButton, 'String', 'Logging!','BackGround',[1 0 0]);
logging = startInitialisation(hObject, eventdata, handles);

set(handles.statusStr, 'String', 'Measurement in progress NOW!...');
drawnow();
pause(1)

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');
Chact=0;for i=1:size(CHdata,1),if CHdata{i,1},Chact=Chact+1;end,end

% calibration info
CH = logging.channelInfo;
tmpTable = get(handles.channelsTable,'Data');
ical = {tmpTable{:,11}};
ical = diag(cell2mat(ical(CH.active))');

%   Check if any channels were added to the session
if (~isempty(logging.session.Channels))
    % Add listener
    logging.eventListener = addlistener(logging.session, 'DataAvailable', @(src, event) logData(src, event));
    
    % Start logging
    logging.session.startForeground();
    
    % Clean-up
    logging.session.release();
    delete(logging.session);
    
    % Clear DAQ
    daq.reset;
    
    % Save data
    Nt=dataObject.nt;
    dataOut = data2WS(1,dataObject.t(1:Nt),dataObject.data(1:Nt,:) * ical,logging);
    
    set(handles.statusStr, 'String', 'READY!  DAQ data available at workbench.');
    set(handles.startButton, 'String', 'Start measurement','BackGround',[0 1 0]);
    drawnow();
end

clear -global dataObject