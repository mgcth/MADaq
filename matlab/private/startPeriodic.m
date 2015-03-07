function startPeriodic(hObject, eventdata, handles)
% TA (start mod)
% global DATAcontainer
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

set(handles.statusStr, 'String', 'Setting up logging ...');
drawnow();

dateString = datestr(now,'mm-dd-yyyy_HH-MM-SS');

%   Setup session
periodic.session = daq.createSession('ni');

items = get(handles.fun1, 'String');
f = str2double(get(handles.fun1, 'String')); %freqConverter(items{get(handles.fun1, 'Value')});
periodic.session.Rate = f;

periodic.session.DurationInSeconds = str2double(get(handles.fun2, 'String'));

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
            periodic.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'IEPE');
        else
            analogChan = periodic.session.addAnalogInputChannel(chan{1}{1, 1}, chan{1}{1, 2}, 'Voltage');
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
        periodic.MHEADER(j).SeqNo = j;
        periodic.MHEADER(j).RespId = channelData.channel;
        periodic.MHEADER(j).Date = datestr(now,'mm-dd-yyyy HH:MM:SS');
        periodic.MHEADER(j).Title = get(handles.title1, 'String');
        periodic.MHEADER(j).Title2 = get(handles.title2, 'String');
        periodic.MHEADER(j).Title3 = get(handles.title3, 'String');
        periodic.MHEADER(j).Title4 = get(handles.title4, 'String');
        periodic.MHEADER(j).Label = data{i, 3};
        %   Added by Kent 17-02-2014
        periodic.MHEADER(j).SensorManufacturer = data{i, 6};
        periodic.MHEADER(j).SensorModel = data{i, 7};
        periodic.MHEADER(j).SensorSerialNumber = data{i, 8};
        periodic.MHEADER(j).SensorSensitivity = data{i, 9};
        %   %   %   %   %   %   %   %   %
        periodic.MHEADER(j).Unit = data{i, 10};
        periodic.MHEADER(j).Dof = data{i, 11};
        periodic.MHEADER(j).Dir = data{i, 12};
        %   periodic.MHEADER(j).Sensitivity = data{i,11}; % Esben 28-11-2013 Does not comply with specifications, another is added above this
        periodic.MHEADER(j).FunctionType = 1;
        
        %   Increment channels counter
        j = j + 1;
    end
end

%   Check if any channels was added to the session
if (isempty(periodic.session.Channels))
    msgbox('No channels in session, might be because no channels have been activated yet.','No channels in session');
    periodic.session.release();
    delete(periodic.session);
    
    set(handles.statusStr, 'String', 'Logging failed ...');
    drawnow();
    
    %   Else start periodic data
else
    set(handles.statusStr, 'String', 'Logging data from sensors ...');
    drawnow();
    
    %   Sync and reject alias if low freqency
    try periodic.session.AutoSyncDSA = true; catch, end
    
    try
        lowFreq = f < 1000;
        for i = 1:length(periodic.session.Channels)
            periodic.session.Channels(i).EnhancedAliasRejectionEnable = lowFreq;
        end
    catch
        lowFreq = 0;
    end
    
    disp(['SyncDSA: ', num2str(periodic.session.AutoSyncDSA), ' - Aliasrejection: ', num2str(lowFreq)]);
    
    
    %   Add listener
    % TA (start mod)
    %         periodic.eventListener = addlistener(periodic.session, 'DataAvailable', @(src, event) logData(src, event, periodic.files));
    periodic.eventListener = addlistener(periodic.session, 'DataAvailable', @(src, event) logDataTA(src, event));
    % TA (end mod)
    
    %   Start periodic
    periodic.session.startForeground();
    
    %   Get actual rate
    actualFs = periodic.session.Rate;
    
    %   Will remain here until data periodic is finished ...
    
    
    
    
    
    
    %                                                        Initiate and test
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
    
    
    
    
    
    Refch=1; %%DUMMY for now!  find(CH.active==CH.refch);
    Nch=Chact;%length(CH.active);
    Ych=setdiff(1:Nch,Refch);
    
    Ndata=length(Load);
    WaitTime=Cycles*Ndata*Ts;
    disp(' '),disp(['Shaking about ' num2str(WaitTime) 's. Please wait ...'])
    
    qd=[];
    for I=1:Cycles;qd=[qd;Load(:)];end
    queueOutputData(periodic.session,qd);
    y=startForeground(periodic.session);
    y(1:Skipps*Ndata,:)=[];
    u=y(:,Refch);
    y=y(:,Ych);
    
    disp('Done.')
    disp('Estimating transfer functions. Please wait ...')
    
    %                                                           Do calibration
    active = [periodic.MHEADER.SeqNo];
    refch = 1;
    cal = 1./[periodic.MHEADER.SensorSensitivity];
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
    
    
    
    
    
    
    
    %   Clean-up
    periodic.session.release();
    delete(periodic.session);
    
    %   Clear DAQ
    daq.reset;
    
    set(handles.statusStr, 'String', 'READY!  DAQ data available at workbench.');
    drawnow();
    
    % TA (start mod)
    Nt=DATAcontainer.nt;
    DAQdata2WS(1,DATAcontainer.t(1:Nt),DATAcontainer.data(1:Nt,:),CHdata);
    % TA (end)
    
end