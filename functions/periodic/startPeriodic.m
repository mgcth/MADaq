function dataOut = startPeriodic(hObject, eventdata, handles)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global dataObject

% Initialaise the test setup
set(handles.startButton, 'String', 'Working!','BackGround',[1 0 0]);
periodic = startInitialisation(hObject, eventdata, handles);

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');

% Check if any channels was added to the session
if ~isempty(periodic.session.Channels) && ~isempty(periodic.channelInfo.reference)
    % Add listener
    %periodic.eventListener = addlistener(periodic.session, 'DataAvailable', @(src, event) logData(src, event));
    tic
    
    % Actual periodic test                                Initiate and test
    Fs=periodic.session.Rate;Ts=1/Fs;
    
    Fspan=eval(get(handles.fun7,'String'));
    if length(Fspan)<2,errordlg('Frequency range must be given with lower and upper limits');end
    CyclesStr=[get(handles.fun4,'String') '       '];
    if strcmpi(CyclesStr(1:7),'default')
      Cycles=10;  
    else    
      Cycles=str2double(get(handles.fun4,'String'));
    end
    SkippsStr=[get(handles.fun5,'String') '       '];
    if strcmpi(SkippsStr(1:7),'default')
      Skipps=1;
    else    
      Skipps=str2double(get(handles.fun5,'String'));
    end
    TendStr=[get(handles.fun2,'String') '       '];
    if strcmpi(TendStr(1:7),'default')
      Tend=20;  
    else
      Tend=str2double(get(handles.fun2,'String'));
    end
    
    try
      [t,Load]=eval(char(get(handles.fun3,'String')));
    catch
      [t,Load]=abradaq_noise(Fspan(1),Fspan(2),Ts,Tend);
      warndlg('No peridic function definition given. Using a random signal. See e.g.: abradaq_chirp or abradaq_noise.','Periodic Excitation');
    end  
    MaxAmpl=eval(get(handles.fun6,'String'));
    MaxLoad=max(abs(Load));

    
    dt=t(2)-t(1);
    if Tend<t(end)
        ind=find(t<Tend);
        t=t(ind);t(end+1)=t(end)+dt;
        Load=Load(ind);Load(end+1)=0;
    elseif Tend>t(end)
        t(end+1)=Tend;
        Load(end+1)=0;
    end    
%     t(end+1)=t(end)+dt;t(end+1)=Tend;
%     if any(~diff(t)),inddiff=find(diff(t)==0),t(inddiff+1)=t(inddiff+1)+10*eps;end
%     Load(end+1)=0;Load(end+1)=0;
    
    Ts=1/Fs;
    Load=interp1(t,(MaxAmpl/MaxLoad)*Load,t(1):Ts:t(end));
    
    Refch=find(periodic.channelInfo.active == periodic.channelInfo.reference);
    Nch=length(periodic.channelInfo.active);
    Ych=setdiff(1:Nch,Refch);

%                                                      Get calibration data
    active = periodic.channelInfo.active;
    refch = periodic.channelInfo.reference;
    tmpTable = get(handles.channelsTable,'Data');
    yind=setdiff(active,refch);uind=refch;
    
    ycal=diag(cell2mat({tmpTable{yind,11}}));
    ucal=diag(cell2mat({tmpTable{uind,11}}));

%%                               Give one period of data to find load level    
    qd=0.01*Load(:)/norm(Load(:),'inf');
    queueOutputData(periodic.session,qd);
    [y,times,Trigt]=periodic.session.startForeground();
    u=y(:,Refch)*ucal;
    LoadFactor=0.01*MaxAmpl/norm(u,'inf')/norm(Load(:),'inf');

    
    Ndata=length(Load);
    WaitTime=(Cycles+Skipps)*Ndata*Ts;
    set(handles.statusStr, 'String', sprintf('Shaking about %5.2f s. Please wait ...', WaitTime));
    drawnow();
    
    qd=[];
    for I=1:Cycles;qd=[qd;LoadFactor*Load(:)];end
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
    
    
%                                                            Do calibration
    y=y*ycal;u=u*ucal;
    
    for II=1:size(y,2)
        [FRF(II,1,:),f] = ...
            tfestimate(u,y(:,II),ones(Ndata,1),0,Ndata,Fs);
    end
    ind=find(f>=min(Fspan) & f<=max(Fspan));FRF=FRF(:,:,ind);f=f(ind);
    
    timeElapsed = toc;
    periodic.Metadata.TimeElapsed = timeElapsed;
    periodic.Metadata.TestDateEnd = datestr(now,'mm-dd-yyyy HH:MM:SS');
    
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
    
    % NAME THE OUTPUTS AND INPUTS, NOTE THAT IT WORKS ONLY FOR ONE INPUT...
    frdsys.InputName=periodic.Metadata.Sensor.Label(1);
    frdsys.OutputName=periodic.Metadata.Sensor.Label(2:end);
    dataOut = data2WS(2,frdsys,periodic);

    set(handles.startButton, 'String', 'Start measurement','BackGround',[0 1 0]);
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