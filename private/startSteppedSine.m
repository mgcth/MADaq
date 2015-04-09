function dataOut = startSteppedSine_foreground(hObject, eventdata, handles)

global DAQ dataObject HFRFGUI CH

% Initialaise the test setup
steppedSine = startInitialisation(hObject, eventdata, handles);

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');
Chact=0;for i=1:size(CHdata,1),if CHdata{i,1},Chact=Chact+1;end,end
CH = steppedSine.channelInfo;

Freqs = eval(get(handles.fun2,'String'));
Loads = eval(get(handles.fun3,'String'));

% Check if any channels was added to the session
if ~isempty(steppedSine.session.Channels) &&  ~isempty(steppedSine.channelInfo.reference)
    % Add listener
    %steppedSine.eventListener = addlistener(steppedSine.session, 'DataAvailable', @(src, event) logDataTA(src, event));
    
    tic
    %                                                     Initiate and test
    NCyclesInBlock=8*2;%                    Minimum number of periods in AI block
    NBlocks=4*2;%                           Number of blocks in AO buffer
    HarmOrder=2;
    Ny=length(CH.active);Nf=length(Freqs);
    
    %   Warning message issued if blocks are generated at a faster rate than 20
    %   per second. Use some margin for AIBSmin. Here margin=2
    Fs=steppedSine.session.Rate;Ts=1/Fs;AIBSmin=ceil(Fs/10);
    
    DAQ.ErrorState=0;DAQ.BufferReady=true;
    AICurrentBS=0;
    
    DAQ.AcceptedOutputDelay=1.00*Fs;
    
    DAQ.BlocksCollected=0;
    DAQ.BlocksSaved=0;
    DAQ.y=[];
    
    %                                                          Initiate GUI
    frf_gui;
    tmpTable = get(handles.channelsTable,'Data');
    DAQ.ical = [tmpTable{:,10}];
    ical = DAQ.ical(CH.active);Refch=find(CH.active==CH.reference);
    %names=DAQ.name(CH.active);
    names = {tmpTable{CH.active,4}}; %CH.active;
    
    
    
    % Preallocate
    nActive = length(CH.active);
    
    RN = zeros(nActive,Nf);
    RH = RN;
    RS = RN;
    PW = RN;
    %Yc = zeros(nActive,20); % 20 harcoded in harmonics.m
    meanY = zeros(nActive,Nf);
    covY = zeros(nActive*2,nActive*2,Nf);
    stdY = zeros(nActive,Nf);
    
    
    ItoBuffer=1;Imax=Nf;Iprocessed=0;
    %                                         Loop over the frequency steps
    while ItoBuffer<=Imax
        %                          Wait until output buffer can accept data
        clk=clock;
        while ~DAQ.BufferReady
            if etime(clock,clk)<2% Wait max 2s
                pause(0.0001);
            else
                DAQ.BufferError=true;
                break
            end
        end
        DAQ.BufferReady=false;
        
        %                                     Set blocksize of Analog Input
        %                                         and size of output buffer
        DAQ.freq=Freqs(ItoBuffer);
        AIBlockSize=max(frfsetblocksize(DAQ.freq,Fs,NCyclesInBlock),AIBSmin);
        %   disp(['ItoBuffer=' int2str(ItoBuffer) ' f=' num2str(DAQ.freq) ', AIBlockSize=' int2str(AIBlockSize) ', AICurrentBS=' int2str(AICurrentBS)])
        
        
        % if ItoBuffer==50*floor(ItoBuffer/50), DAQ.ErrorState=50;disp('Enforcing reset'),end; %Force reset after 50 steps to get sync
        
        if AIBlockSize~=AICurrentBS || DAQ.ErrorState;%       Those require RESET
            
            if ItoBuffer>1
                nidaqPutSineData(steppedSine.session,[]);
            end
            
            
            %                                    Wait some time if DAQ is still running
            clk=clock;
            while steppedSine.session.IsRunning
                if etime(clock,clk)>3*NBlocks*AIBlockSize/Fs,break,end
                pause(0.01);
            end
            if steppedSine.session.IsRunning,steppedSine.session.stop();end
            
            %                      Do a full start-over if settings need to be changed
            %                       I tried softer se-sets with no success /TA
            if ItoBuffer>1
                daq.reset;
                if ~verLessThan('matlab','7.14.0')
                    daqreset;
                    daq.HardwareInfo.getInstance('CompactDAQOnly',false);
                end
                %steppedSine.session=daq.createSession('ni');
                %steppedSine.session=nidaqsetup(steppedSine.session);
                steppedSine = startInitialisation(hObject, eventdata, handles);
            end
            
            %                                                         Set up listeners
            LReqrd=steppedSine.session.addlistener('DataRequired',@nidaqPutSineData0);
            LAvail=steppedSine.session.addlistener('DataAvailable',@nidaqGetData);
            LErr = steppedSine.session.addlistener('ErrorOccurred',@nidaqError);
            
            %                                     Set up for continuous running of DAQ
            steppedSine.session.IsContinuous=true;
            
            DAQ.ErrorState=0;DAQ.BufferReady=true;DAQ.fi0=0;
            DAQ.NextBlockEndAddress=[];NextBlockEndAddress=0;
            
            try IthIsDone=length(DAQ.y);catch, IthIsDone=0;end
            ItoBuffer=IthIsDone+1;
            DAQ.freq=Freqs(ItoBuffer);
            
            AIBlockSize=max(frfsetblocksize(DAQ.freq,Fs,NCyclesInBlock),AIBSmin);
            steppedSine.session.NotifyWhenDataAvailableExceeds=AIBlockSize;
            steppedSine.session.NotifyWhenScansQueuedBelow=floor((NBlocks-.5)*AIBlockSize);
            
            Reset=true;
            
        else  %                                                          GO AHEAD
            Reset=false;
        end
        
        %                                                   Set up for buffer fill
        try DAQ.load=Loads(ItoBuffer);catch, DAQ.load=Loads;end
        AICurrentBS=AIBlockSize;
        DAQ.AOBufferSize=NBlocks*AIBlockSize;
        
        DAQ.NextBlockEndAddress(end+1,1)=NextBlockEndAddress+DAQ.AOBufferSize;
        DAQ.NextBlockEndAddress(end,2)=DAQ.freq;
        NextBlockEndAddress=DAQ.NextBlockEndAddress(end,1);
        
        
        nidaqPutSineData(steppedSine.session,[]);
        if Reset,steppedSine.session.startBackground;end
        
        
        
        %          At this time the I:th frequency/load was added to buffer,
        %           the (I-1) should be running and the (I-2):th data available to
        %           harvest (I>2)
        
        %try IthIsDone=length(DAQ.y);catch IthIsDone=0;end
        
        %   disp(['I=' int2str(ItoBuffer) ' ,  Irecorded=' int2str(IthIsDone)])
        
        try DAQ.y;doplot=true;catch, doplot=false;end
        doplot=false;
        if doplot
            I=length(DAQ.y);
            plot(DAQ.t{end}-min(DAQ.t{end}),DAQ.y{end}(:,1))
            title(['f = ' num2str(Freqs(I))])
        end
        
        try
            Irecorded=length(DAQ.y);
            for I=Iprocessed+1:Irecorded
                [c,RN(:,I),RH(:,I),RS(:,I),C,PW(:,I)] = ...
                    harmonics(DAQ.y{I},Ts,Freqs(I),HarmOrder,Refch);
                Yc=diag(ical)*C./repmat(ical(Refch)*C(Refch,:),size(C,1),1);
                meanY(:,I)=mean(Yc,2);
                if any(isnan(meanY)),keyboard,end
                covY(:,:,I)=cov([real(Yc.') imag(Yc.')]);
                stdY(:,I)=sqrt(diag(covY(1:Ny,1:Ny)).^2+ ...
                    diag(covY(Ny+1:2*Ny,Ny+1:2*Ny)).^2);
                %       stdY(:,I)=sqrt(diag(covY(:,:,I)));
                %      stdY(:,I)=std(Yc,0,2);
                Iprocessed=Iprocessed+1;
            end
            t=DAQ.t{I}-min(DAQ.t{I});ycal=DAQ.y{I}*diag(ical);
            DAQ.y{I}=[];% When read, clear to gain memory
            %     frf_gui(t,ycal,I,Freqs,meanY,stdY,RN,RH,RS,PW,names);
        catch
            disp('No data available, or problem processing data')
        end
        
        try
            if Iprocessed>1
                frf_gui(t,ycal,I,Freqs,meanY,stdY,RN,RH,RS,PW,names);
            end
        catch,end
        
        %   disp(['ItoBuffer=',int2str(ItoBuffer),' Irecorded=',int2str(Irecorded),' Iprocessed=',int2str(Iprocessed)])
        
        ItoBuffer=ItoBuffer+1;
        
        
    end
    
    
    %    Keep on pumping out more source data until last input block available
    while length(DAQ.y)<Nf
        DAQ.NextBlockEndAddress(end+1,1)=NextBlockEndAddress+DAQ.AOBufferSize;
        DAQ.NextBlockEndAddress(end,2)=Freqs(end);
        NextBlockEndAddress=DAQ.NextBlockEndAddress(end,1);
        nidaqPutSineData(steppedSine.session,[]);
        pause(0.9*DAQ.AOBufferSize/Fs);
    end
    
    %                              Stop Analog Output/Input and delete handles
    % clk=clock;
    % while steppedSine.session.IsRunning
    %   if etime(clock,clk)>3*NBlocks*AIBlockSize/Fs,break,end
    %     pause(0.01);
    % end
    % if steppedSine.session.IsRunning,steppedSine.session.stop();end
    steppedSine.session.stop();
    delete(LReqrd);delete(LAvail);delete(LErr);
    
    
    %                                                             Finish FRF
    % Irecorded=length(DAQ.y);
    % disp('Ending ...')
    for I=Iprocessed+1:Nf
        [c,RN(:,I),RH(:,I),RS(:,I),C,PW(:,I)] = ...
            harmonics(DAQ.y{I},Ts,Freqs(I),HarmOrder,Refch);
        Yc=diag(ical)*C./repmat(ical(Refch)*C(Refch,:),size(C,1),1);
        %  Y(:,I)=mean(Yc,2);
        meanY(:,I)=mean(Yc,2);
        %      covY(:,:,I)=cov(Yc.');
        covY(:,:,I)=cov([real(Yc.') imag(Yc.')]);
        stdY(:,I)=sqrt(diag(covY(1:Ny,1:Ny)).^2+ ...
            diag(covY(Ny+1:2*Ny,Ny+1:2*Ny)).^2);
        %      stdY(:,I)=sqrt(diag(covY(:,:,I)));
        %  stdY(:,I)=std(Yc,0,2);
        
        %    Iprocessed=Iprocessed+1;
        %    disp(['ItoBuffer=',int2str(ItoBuffer),' Irecorded=',int2str(Irecorded),' Iprocessed=',int2str(Iprocessed)])
    end
    t=DAQ.t{I}-min(DAQ.t{I});ycal=DAQ.y{I}*diag(ical);
    frf_gui(t,ycal,I,Freqs,meanY,stdY,RN,RH,RS,PW,names);
    
    
    
    
    toc
    % temporary
    close(HFRFGUI.hFigtd, HFRFGUI.hFigdd, HFRFGUI.hFigfd, HFRFGUI.Fig);
    
    % Make IDFRD data object
    for I=1:Ny
        for J=1:Nf
            idCovY(I,1,J,1:2,1:2)=[covY(I,I,J) covY(I,I+Ny,J);covY(I+Ny,I,J) covY(I+Ny,I+Ny,J)];
        end
    end
    % ind=find(CH.active~=CH.reference);%
    % meanY=meanY(ind,:);idCovY=idCovY(ind,:,:,:,:)% Exclude reference
    ind=find(CH.active==CH.reference);
    meanY(ind,:)=[];idCovY(ind,:,:,:,:)=[];% Exclude reference
    
    Ts=0;
    frdsys=frd(reshape(meanY,size(meanY,1),1,size(meanY,2)),2*pi*Freqs,'FrequencyUnit','rad/s');
    frdsys=idfrd(frdsys);
    frdsys.CovarianceData=idCovY;
    % frdsys=idfrd(frdsys,'CovarianceData',idCovY);
    
    % Clean-up
    steppedSine.session.release();
    delete(steppedSine.session);
    
    % Clear DAQ
    daq.reset;
    
    % Save data
    %Nt=dataObject.nt;
    dataOut = data2WS(2,frdsys,steppedSine);
    
    set(handles.statusStr, 'String', 'READY!  IDFRD and DAQ data available at workbench.');
    drawnow();
else
    errordlg('No channels or no reference.')
    set(handles.statusStr, 'String', 'Measurement aborted.');
    drawnow();
end

clear -global dataObject

end

function bs=frfsetblocksize(freq,Fs,Ncycles)
%% FRFSETBLOCKSIZE. Choose blocksize from set of allowed sizes
%Inputs: freq    - Frequency of sinusiodal signal
%        Fs      - Sampling frequency
%        Ncycles - (Minimum) number of cycles to fit in block
%Output: blocksize
%Call:   blocksize=frfsetblocksize(freq,Fs,Ncycles)


if freq<2,        Freq =   1;
elseif freq<5.001,    Freq =   2;
elseif freq<10.001,   Freq =   5;
elseif freq<15.001,   Freq =  10;
elseif freq<20.001,   Freq =  15;
elseif freq<25.001,   Freq =  20;
elseif freq<30.001,   Freq =  25;
elseif freq<40.001,   Freq =  30;
elseif freq<50.001,   Freq =  40;
elseif freq<60.001,   Freq =  50;
elseif freq<70.001,   Freq =  60;
elseif freq<80.001,   Freq =  70;
elseif freq<90.001,   Freq =  80;
elseif freq<100.001,  Freq =  90;
elseif freq<150.001,  Freq = 100;
elseif freq<200.001,  Freq = 150;
elseif freq<500.001,  Freq = 200;
elseif freq<1000.001,  Freq = 500;
elseif freq<5000.001, Freq = 500;
else
    error('Cannot handle excitation frequencies above 5kHz')
end

blocksizemin=ceil(Fs/20)+1;%           Warning message issued if blocks are
%                                      generated at a faster rate than 20
%                                      per second

bs=max([ceil(Ncycles*Fs/Freq) blocksizemin]);%       Allow at least Ncycles
end


