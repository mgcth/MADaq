function startPeriodic(hObject, eventdata, handles)

global DATAcontainer

% Initialaise the test setup
periodic = startInitialisation(hObject, eventdata, handles);

periodic.session.Rate = eval(get(handles.fun1, 'String')) * 1000;

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');

% Check if any channels was added to the session
if ~isempty(periodic.session.Channels) && ~isempty(periodic.channelInfo.reference)
%     % Add listener
%     periodic.eventListener = addlistener(periodic.session, 'DataAvailable', @(src, event) logDataTA(src, event));
%     
%     % Start periodic
%     periodic.session.startForeground();
    
    % Actual periodic test                                Initiate and test
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
    
    Refch=find(periodic.channelInfo.active == periodic.channelInfo.reference);
    Nch=length(periodic.channelInfo.active);
    Ych=setdiff(1:Nch,Refch);
    
    Ndata=length(Load);
    WaitTime=Cycles*Ndata*Ts;
    set(handles.statusStr, 'String', sprintf('Shaking about %5.2f s. Please wait ...', WaitTime));
    drawnow();
    
    qd=[];
    for I=1:Cycles;qd=[qd;Load(:)];end
    queueOutputData(periodic.session,qd);
    [y,times_,Trigt_] = startForeground(periodic.session);
    %y=startForeground(periodic.session);
    y(1:Skipps*Ndata,:)=[];
    u=y(:,Refch);
    y=y(:,Ych);
    
    set(handles.statusStr, 'String', 'Estimating transfer functions. Please wait ...');
    
    %                                                        Do calibration
    active = periodic.channelInfo.active;
    refch = periodic.channelInfo.reference;
    cal = 1./[handles.channelsTable.Data{:,10}];
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
    frdsys.UserData.MeasurementDate = datestr(now,'mm-dd-yyyy HH:MM:SS');
    
    % Clean-up
    periodic.session.release();
    delete(periodic.session);
    
    % Clear DAQ
    daq.reset;
    
    % Save data
    Nt=DATAcontainer.nt;
    DAQdata2WS(1,DATAcontainer.t(1:Nt),DATAcontainer.data(1:Nt,:),CHdata);
    assignin('base','frdsys',frdsys);
    clear('DATAcontainer');
    
    set(handles.statusStr, 'String', 'READY!  IDFRD and DAQ data available at workbench.');
    drawnow();
else
    errordlg('No channels or no reference.')
    set(handles.statusStr, 'String', 'Measurement aborted.');
    drawnow();
end