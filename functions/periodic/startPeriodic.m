function dataOut = startPeriodic(hObject, eventdata, handles)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global dataObject

% Initialaise the test setup
periodic = startInitialisation(hObject, eventdata, handles);

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');

% Check if any channels was added to the session
if ~isempty(periodic.session.Channels) && ~isempty(periodic.channelInfo.reference)
    % Add listener
    %periodic.eventListener = addlistener(periodic.session, 'DataAvailable', @(src, event) logData(src, event));
    
    % Actual periodic test                                Initiate and test
    Fs=periodic.session.Rate;Ts=1/Fs;
    
    [t,Load]=eval(char(get(handles.fun3,'String')));
    MaxAmpl=eval(get(handles.fun6,'String'));
    MaxLoad=max(abs(Load));Fspan=eval(get(handles.fun7,'String'));
    Cycles=str2double(get(handles.fun4,'String'));Skipps=str2double(get(handles.fun5,'String'));
    Tend=str2double(get(handles.fun2,'String'));
    dt=t(2)-t(1);
    t(end+1)=t(end)+dt;t(end+1)=Tend;
    Load(end+1)=0;Load(end+1)=0;
    Ts=1/Fs;
    Load=interp1(t,(MaxAmpl/MaxLoad)*Load,t(1):Ts:t(end));
    
    Refch=find(periodic.channelInfo.active == periodic.channelInfo.reference);
    Nch=length(periodic.channelInfo.active);
    Ych=setdiff(1:Nch,Refch);
    
    Ndata=length(Load);
    WaitTime=Cycles*Ndata*Ts;
    set(handles.statusStr, 'String', sprintf('Shaking about %5.2f s. Please wait ...', WaitTime));
    drawnow();
    
    qd=[];
    for I=1:Cycles;qd=[qd;Load(:)];end
    %y = [];
    %periodic.eventListener = addlistener(periodic.session, 'DataAvailable', @(src, event) tempPeriodic(src, event));
    
    queueOutputData(periodic.session,qd);
    [y,times,Trigt]=periodic.session.startForeground();
    %periodic.session.startBackground();
    %wait(periodic.session)
    y(1:Skipps*Ndata,:)=[];
    u=y(:,Refch);
    y=y(:,Ych);
    
    set(handles.statusStr, 'String', 'Estimating transfer functions. Please wait ...');
    drawnow();
    
    %                                                        Do calibration
    active = periodic.channelInfo.active;
    refch = periodic.channelInfo.reference;
    tmpTable = get(handles.channelsTable,'Data');
%     cal = 1./[tmpTable{:,11}];
    yind=setdiff(active,refch);uind=refch;
    
    ycal=diag(cell2mat({tmpTable{yind,11}}));
    ucal=diag(cell2mat({tmpTable{uind,11}}));
    
%     y=y*diag(1./cal(yind));u=u*diag(1./cal(uind));
    y=y*ycal;u=u*ucal;
    
    for II=1:size(y,2)
        [FRF(II,1,:),f] = ...
            tfestimate(u,y(:,II),ones(Ndata,1),0,Ndata,Fs);
    end
    ind=find(f>=min(Fspan) & f<=max(Fspan));FRF=FRF(:,:,ind);f=f(ind);
    
    % Make IDFRD data object
    frdsys=frd(FRF,2*pi*f,'FrequencyUnit','rad/s');
    frdsys=idfrd(frdsys);
    
    % Clean-up
    periodic.session.release();
    delete(periodic.session);
    
    % Clear DAQ
    daq.reset;
    
    % Save data
    %Nt=dataObject.nt;
    dataOut = data2WS(2,frdsys,periodic);
    
    set(handles.statusStr, 'String', 'READY!  IDFRD and DAQ data available at workbench.');
    drawnow();
else
    errordlg('No channels or no reference.')
    set(handles.statusStr, 'String', 'Measurement aborted.');
    drawnow();
end

clear -global dataObject

    function tempPeriodic(src, event)
        
        q = event.Data;
        y = [q; y];
        %times = event.TimeStamps;
    end
end