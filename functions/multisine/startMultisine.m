function dataOut = startMultisine(hObject, eventdata, handles)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

% Initialaise the test setup
set(handles.startButton, 'String', 'Working!','BackGround',[1 0 0]);
multisine = startInitialisation(hObject, eventdata, handles);

% File is deleted at the end
channelLabels = multisine.Metadata.Sensor.Label;
Container0=[tempdir,'DataContainer00'];
save(Container0,'channelLabels');

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');
Chact = 0; for i=1:size(CHdata,1),if CHdata{i,1},Chact=Chact+1; end, end
CH = multisine.channelInfo;

% Get the sampling rate and Ts
Fs = multisine.session.Rate;
Ts = 1/Fs;

% Get frequencies and loads etc...
% [Freqs, wd, Tsd] = eval(get(handles.fun2,'String')); % should be in Hz!
Freqs = eval(get(handles.fun2,'String')); % should be in Hz!
Freqs=sort(Freqs);
loads = eval(get(handles.fun3,'String'));

% Correlation, between 0 and 1
CtStr=[get(handles.fun5,'String') '       '];
if strcmpi(CtStr(1:7),'default')
    Ct=.99;
else
    Ct = eval(get(handles.fun5,'String')); % 0.997 a good value
    if Ct>.99999,Ct=.9999;end
    if Ct<.8,Ct=.8;end
end

CtMeanStr=[get(handles.fun6,'String') '       '];
if strcmpi(CtMeanStr(1:7),'default')
    CtMeanInput=.95;
else
    CtMeanInput = eval(get(handles.fun6,'String')); % 0.95 a good value
    if CtMeanInput>.99,CtMeanInput=.99;end
    if CtMeanInput<.8,CtMeanInput=.8;end
end

% Number of lowest frequency sinusoidal that data block should cover
SimFreqStr=[get(handles.fun4,'String') '       '];
if strcmpi(SimFreqStr(1:7),'default')
    SimFreq = 10;
else
    SimFreq = floor(eval(get(handles.fun4,'String')));
end
% Number of block evaluations for statistics
NStatStr=[get(handles.fun7,'String') '       '];
if strcmpi(NStatStr(1:7),'default')
    Nstat=20;
else
    Nstat = eval(get(handles.fun7,'String')); % 20 a good value
end

% Data that should be given or provided by multisine
refch = find(CH.active == CH.reference);
nu = length(CH.reference); % number of inputs
ny = length(CH.active); % number of outputs
yind = 1:ny; yind(refch) = [];
nf = length(Freqs);
blockSize = Fs;%1500; % 1500 was good, sample rate in Hz a good value?

%if handles.steppedSine.Value == 1
%  K = nf; SimFreq=1; % For stepped sine
%else
  K = ceil(nf/SimFreq); % now TRUE!, not true before when only SimFreq
%end

FreqAdd=[];% Add freqs to get nf/SimFreq integer
dfMin=min(diff(Freqs)); 
for I=1:K*SimFreq-nf, FreqAdd(I)=Freqs(end-I)-1e-3*dfMin; end  
Freqs=sort([Freqs(:);FreqAdd(:)]);
nf=length(Freqs); nfdK=round(nf/K);
Ncyc = 10;



% readPass = 0;
% MMF{1} = GetDoubleFromFile(1);
% while readPass == 0
%     pause(1)
%     readPass = GetDoubleFromFile(MMF{1},1);
% end

% Initiate
frdsys = frd(NaN*zeros(ny-nu,length(CH.reference),nf),2*pi*Freqs,'FrequencyUnit','rad/s');
coherence = zeros(length(yind),length(refch),nf); % preallocate
coherenceAmplitude = zeros(nf,1);


% Pass data initially
% MMF{2}=PassDoubleThruFile(2,[1 nf 1 1]); % initialise Freqs
% MMF{3}=PassDoubleThruFile(3,[1 1 1 1]); % initialise ny

% MMF{4}=PassDoubleThruFile(4,[1 nf/K 1 1]); % initialise indf
% MMF{5}=PassDoubleThruFile(5,[1 ny-1 1 nf/K]); % initialise H real
% MMF{6}=PassDoubleThruFile(6,[1 ny-1 1 nf/K]); % initialise H imag
% MMF{7}=PassDoubleThruFile(7,[1 1 1 1]); % initialise C

MMF2=PassDoubleThruFile(2,[4 ny-1 nfdK 1]);%For passing Re(H), Im(H), indf and C

% Pass once
% PassDoubleThruFile(MMF{2},Freqs,1); % pass Freqs data
% PassDoubleThruFile(MMF{3},ny,1); % pass ny data
% PassDoubleThruFile(MMF{4},zeros(nf/K,1),1); % pass indf data
save(Container0,'Freqs','-append');
save(Container0,'ny','-append');

% PassDoubleThruFile(MMF{5},zeros(ny-1,1,nf/K),1); % pass H data
% PassDoubleThruFile(MMF{6},zeros(ny-1,1,nf/K),1); % pass H data
% PassDoubleThruFile(MMF{7},0,1); % pass C data
Zer=zeros(ny-1,nfdK); indfMat=Zer; CMat=Zer;
for I=1:4
  PassDoubleThruFile(MMF2,Zer,I);
end  

% Start up parallel Matlab companion process that has GUI
PassDoubleThruFile(MMF2,uint8(3));% Set MMF into "wait" state and let companion process release it
startstr = ['cmd /c start /min matlab -nosplash -nodesktop -minimize ' ...
    '-r "run(''',handles.homePath,'\functions\multisine\','simo_multisine_GUI'')"'];
dos(startstr);

Iret=-3;
while Iret~=0; % Wait until companion process has released "flush" state
  [~,Iret]=GetDoubleFromFile(MMF2,1);
  pause(0.1)
end  

% Check if any channels were added to the session
if ~isempty(multisine.session.Channels) &&  ~isempty(multisine.channelInfo.reference)
    tmpTable = get(handles.channelsTable,'Data');
    ical = {tmpTable{:,11}};
    ical = cell2mat(ical(CH.active))';
    
    %%                        Give chirp sweep(s) to find appropriate load level
    if 0
      ucal = diag(cell2mat({tmpTable{CH.reference,11}}));
      [t,Load] = abradaq_chirp(min(Freqs),10,max(Freqs),Ts); nt=length(t);
      qd = 0.01*Load(:)/norm(Load(:),'inf');
      queueOutputData(multisine.session,qd);
      prepare(multisine.session);
      [y,times]=startForeground(multisine.session);
      u = y(ceil(nt/2):end,refch)*ucal;
      MaxAmpl = max(loads);
      LoadFactor = 0.01*MaxAmpl/norm(u,'inf')/norm(Load(:),'inf');
    else
      Irecon=0; ReconDone=false;
      yrecon{1}=1e16; yrecon{2}=1e8;
      [t,ReconLoad] = abradaq_chirp(min(Freqs),3,max(Freqs),Ts); nt=length(t);
      ReconLoad=0.01*ReconLoad;
      LAvail = addlistener(multisine.session, 'DataAvailable', @nidaqMultisineGetReconDataInline);
      LReqrd = addlistener(multisine.session, 'DataRequired', @nidaqMultisinePutReconDataInline);
    % Set up for continuous running of DAQ
      multisine.session.IsContinuous = true;
      multisine.session.NotifyWhenDataAvailableExceeds=ceil(nt);
%       multisine.session.NotifyWhenScansQueuedBelow=ceil(nt/2);
      multisine.session.IsNotifyWhenScansQueuedBelowAuto=true;
      nidaqMultisinePutReconDataInline(multisine.session, []);
     
      startBackground(multisine.session);
      pause(4)
      HaveStartedRecon=false; Itries=0;
      while ~HaveStartedRecon; %Try max 5 restarts if 1st start fails
        stop(multisine.session);
        nidaqMultisinePutReconDataInline(multisine.session, []);
        startBackground(multisine.session);
        pause(4)
        Itries=Itries+1;
        if Itries>5, 
          disp('Could not start data collection in background')
          error('Could not start data collection in background')
        end
      end  
      if Itries>0
        disp(['Started at try no.: ' int2str(Itries)])
      end 
      
      if 0
      while (norm(yrecon{1}-yrecon{2}))/norm(yrecon{1})>1/2; % Wait for "stationary" signals
        pause(1)
      end
      else
         disp('Skip stationarity check in startmultisine')
         pause(10);% Temporary until stable stationarity check can be found
      end
      
      stop(multisine.session);
      ReconDone=true;
      ucal = diag(cell2mat({tmpTable{CH.reference,11}}));
      Yrecon=yrecon{mod(Irecon,2)+1};% Last read data
      u = Yrecon(refch,ceil(nt/2):end)*ucal; 
%       MaxAmpl = max(loads);
%       LoadFactor = 0.01*MaxAmpl/norm(u,'inf')/norm(ReconLoad(:),'inf');
      LoadFactor = norm(ReconLoad(:),'inf')/norm(u,'inf');
    end  
        
    if LoadFactor > 1
        choiceText = sprintf('Load factor high = %6.2f. You risk damage. Continue? Y/N [N]',LoadFactor);
        choice = input(choiceText,'s');
        
        if isempty(choice)
            error('Amplitude too high.');
        elseif strmpci(choice,'N')
            error('Amplitude too high.');
        else
            % go on
        end
    end
    loads = LoadFactor*loads;
    loadsDefault = loads;
    loads = loadsDefault*ones(1,SimFreq);
    
    % Add listener
    LAvail = addlistener(multisine.session, 'DataAvailable', @nidaqMultisineGetDataInline);
    LReqrd = addlistener(multisine.session, 'DataRequired', @nidaqMultisinePutSineDataInline);
    LErr = addlistener(multisine.session, 'ErrorOccurred', @nidaqMultisineErrorInline);
    % Set up for continuous running of DAQ
    multisine.session.IsContinuous = true;
    multisine.session.NotifyWhenDataAvailableExceeds=ceil(blockSize/10);%ceil(blockSize/2); if blockSize is sample rate this is 1/10th of a second
%     multisine.session.NotifyWhenScansQueuedBelow=ceil(blockSize/2);%ceil(blockSize/2);
    multisine.session.IsNotifyWhenScansQueuedBelowAuto=true;

    firstRun = true;
    
    %covH = zeros(2,2,nf);
    
    tic
    % ------------------------------------- Loop over number of frequency sets
    for I = 1:K

      fprintf('____ FREQUENCY STEP %u of %u ____\n', I, K)
        
        C = 0;
        y = [];
        ynotused = [];
        iret = -1;
        opt = [];
        H0 = [];
        %H = zeros(ny-nu,1);
        
        haveData = false;
        haveReadData = true;
        haveDataContinous = false;
        firstTime = true;
        
        % Set up load
        indf = I:K:nf;
        tStart = Ts;
        blockSizeInPutData = blockSize;
        w = Freqs(indf);
        om = 2 * pi * w;
        nw = length(w);
        fi = 2*pi*rand(nw,1);
        
        % Pass data
%         PassDoubleThruFile(MMF{4},indf,1); % pass indf data
% keyboard
        indfMat(1,:)=indf;
        PassDoubleThruFile(MMF2,indfMat,3);% Pass indf data
        
        % Collect data until after stationarity obtained
        if firstRun == true
            firstRun = false;
            nidaqMultisinePutSineDataInline(multisine.session, [])
            startBackground(multisine.session);
            pause(0.1);
        end
        
        O = 0;
        while iret == -1
            O = O + 1;
            pause(0.0001);
            % Estimate transfer functions
            if haveData == true
                ynotused = [ynotused y]; haveReadData = true; haveData = false;
            end
            
            if haveDataContinous == true
                if firstTime == true
                    [iret,H,ynotused,C,opt]=simostationarityengine(ynotused,Ts,w,refch,Ncyc,Ct);
                    H0=H;
                    if ~isempty(opt)
                        firstTime = false;
                    end
                else
                    [iret,H,ynotused,C]=simostationarityengine(ynotused,Ts,w,refch,Ncyc,Ct,H0,opt);
                    H0=H;
                end
                
                % Pass data
                %PassDoubleThruFile(MMF{4},indf,1); % pass indf data
%                 PassDoubleThruFile(MMF{5},real(H),1); % pass H data
%                 PassDoubleThruFile(MMF{6},imag(H),1); % pass H data
%                 PassDoubleThruFile(MMF{7},C,1); % pass C data

                PassDoubleThruFile(MMF2,real(H),1); % pass re(H) data
                PassDoubleThruFile(MMF2,imag(H),2); % pass im(H) data
                CMat(1,1)=C;
                PassDoubleThruFile(MMF2,CMat,4); % pass C data
                
                pause(0.0001);
            end
            
            % Reset
            if multisine.session.IsRunning == 0
                haveDataContinous = false;
                haveData = false;
                multisine.session.stop();
                nidaqMultisinePutSineDataInline(multisine.session, [])
                disp('was 0 in stationary')
                startBackground(multisine.session);
                pause(0.1);
            end
            
        end
        
        % Obtain statistics
        %coherenceValue = zeros();
        %while coherenceValue < 0.9 %%% EXPERIMENTAL FEATURE
        coherenceValue = 0;
        minCoherenceValue = 0;% good value around 0.5 - 0.6
        stepLoadFactor = 1.55;%1.5; % small increments take longer time (1.25 good)
        maxFactorIncrease = 2.5;%2.3; % dont want to damadge the shaker (2 good)
        timesIncrease = log(maxFactorIncrease)/log(stepLoadFactor);
        loads = loadsDefault*ones(1,SimFreq); % reset for every new frequency step
        firstStatRun = true;
        Ctmean = CtMeanInput;
        CtmeanChanged = false;
        while any(find(coherenceValue < minCoherenceValue)) || firstStatRun == true
            firstStatRun = false;
            Hs = zeros(size(H,1),size(H,2),size(H,3),Nstat);
            YU = zeros(size(H,3),ny,Nstat);
            
            for JJ=1:Nstat
                haveReadData = true;
                ynotused = [];
                haveData = false;
                haveDataContinous = false;
                
                iret = -1;
                OO = 0;
                while iret == -1
                    OO = OO + 1;
                    
                    pause(0.0001)
                    
                    % Estimate transfer functions
                    if haveData == true
                        ynotused = [ynotused y];
                        haveReadData = true;
                        haveData = false;
                    end
                    
                    if haveDataContinous == true
                        [iret,H,ynotused,C,~,yuc]=simostationarityengine(ynotused,Ts,w,refch,Ncyc,Ctmean,H0,opt);
                        H0=H;
                        
                        if CtmeanChanged == true && C >= Ct && iret == 0
                            %fprintf('Ctmean = %u, C = %u \n',Ctmean,C)
                            Ctmean = CtMeanInput;
                            CtmeanChanged = false;
                        end
                    end
                    
                    % Reset
                    if multisine.session.IsRunning == 0
                        haveDataContinous = false;
                        haveData = false;
                        multisine.session.stop();
                        nidaqMultisinePutSineDataInline(multisine.session, [])
                        disp('System reset in statistics. Waiting for stationarity again.')
                        startBackground(multisine.session);
                        pause(0.1);
                        Ctmean = Ct;
                        CtmeanChanged = true;
                    end
                    
                end
                fprintf('\b Saved to statistics. \n')
                
                Hs(:,:,:,JJ) = H;
                YU(:,:,JJ) = yuc;
                
                % Pass data
%                 PassDoubleThruFile(MMF{5},real(H),1); % pass H data
%                 PassDoubleThruFile(MMF{6},imag(H),1); % pass H data
%                 PassDoubleThruFile(MMF{7},C,1); % pass C data

                PassDoubleThruFile(MMF2,real(H),1); % pass re(H) data
                PassDoubleThruFile(MMF2,imag(H),2); % pass im(H) data
                CMat(1,1)=C;
                PassDoubleThruFile(MMF2,CMat,4); % pass C data
                
                %for MM = 1:K
                %    covH(:,:,indf(MM)) = cov([real(H(:,:,MM)) imag(H(:,:,MM))]);
                %end
            end
            
            % coherence?
            for cii = 1:length(yind)
                for cjj = 1:length(refch)
                    Ym = YU(:,yind(cii),:);
                    Um = YU(:,refch(cjj),:);
                    coherence(cii,cjj,indf) = sqrt(abs(mean(Ym.*conj(Um),3)).^2 ./ ...
                        (mean(abs(Um).^2,3) .* mean(abs(Ym).^2,3)));
                end
            end
            
            % loop over all frequencies in this freq step
            anyAmpChange = 0;
            for indii = 1:length(indf)
                ampChanged = 0;
                coherenceValue(indii) = min(squeeze(coherence(:,:,indf(indii)))); % assume only one input
                
                if coherenceValue(:,indii) < minCoherenceValue
                    %fprintf('Increased load for freq %6.4f from %6.4f ',Freqs(indf(indii)),loads(indii))
                    
                    % only increase a bit, otherwise unbuonded amplitude levels possible
                    if stepLoadFactor*loads(indii) < stepLoadFactor^timesIncrease*loadsDefault
                        ampChanged = 1;
                        loads(indii) = loads(indii)*stepLoadFactor;
                    else
                        coherenceValue(:,indii) = minCoherenceValue;
                    end
                    %fprintf('to %6.2f. \n',loads(indii))
%                 else % values with good coherence, put amplitude a bit lower
%                     % only decrease a bit here, too
%                     if loads(indii) > (2-stepLoadFactor)^timesIncrease*loadsDefault
%                         ampChanged = 2;
%                         loads(indii) = loads(indii)*(2-stepLoadFactor);
%                     else
%                         % do nothing, should just pass through
%                         %coherenceValue(:,indii) = minCoherenceValue;
%                     end
                end
                
                if ampChanged == 1
                    fprintf('Min coh. for freq %0.2f is %0.2f, and amplitude %0.4f (default %0.4f)',Freqs(indf(indii)),coherenceValue(indii),loads(indii),loadsDefault)
                    fprintf(' amp INCREASED.\n')
                    anyAmpChange = 1;
                elseif ampChanged == 2
                    fprintf(' amp decreased.\n')
                    anyAmpChange = 1;
                else
                    %fprintf('.\n')
                end
                
                coherenceAmplitude(indf(indii)) = coherenceValue(indii);
            end
            
            % if amplitude changed
            % reset the correlation value as we will have new transient
            if anyAmpChange == 1
                Ctmean = Ct;
                CtmeanChanged = true;
                fprintf('Waiting 1 second to load new input data. \n')
                pause(1) % this should suffice to put in new load as the queued data is 1 second at a time
            end
            
        end
        
        Hm = mean(Hs,4);
                
        % is this noise estimate correct?
        for nny = 1:size(Hs,1)
            for nnu = 1:size(Hs,2)
                for kf = 1:size(Hs,3)
                    Hcov(nny,nnu,indf(kf),:,:) = cov([real(squeeze(Hs(nny,nnu,kf,:,:))) imag(squeeze(Hs(nny,nnu,kf,:,:)))]);
                end
            end
        end
        
        % Pass data
        %PassDoubleThruFile(MMF{4},indf,1); % pass indf data
%         PassDoubleThruFile(MMF{5},real(H),1); % pass H data
%         PassDoubleThruFile(MMF{6},imag(H),1); % pass H data
%         PassDoubleThruFile(MMF{7},C,1); % pass C data

        PassDoubleThruFile(MMF2,real(H),1); % pass re(H) data
        PassDoubleThruFile(MMF2,imag(H),2); % pass im(H) data
        CMat(1,1)=C;
        PassDoubleThruFile(MMF2,CMat,4); % pass C data
        
        frdsys.ResponseData(:,:,indf) = Hm;
        
    end
    multisine.session.stop();
    delete(LAvail);
    delete(LReqrd);
    delete(LErr);
    
    % Clean-up
    multisine.session.release();
    delete(multisine.session);
    
    timeElapsed = toc
    multisine.Metadata.TimeElapsed = timeElapsed;
    multisine.Metadata.TestDateEnd = datestr(now,'mm-dd-yyyy HH:MM:SS');
    
    % save coherence
    multisine.Metadata.Coherence = coherence;
    multisine.Metadata.CoherenceAmplitude = coherenceAmplitude;
    multisine.Metadata.CoherenceMinValue = minCoherenceValue;
    multisine.Metadata.CoherenceStepLoadFactor = stepLoadFactor;
    multisine.Metadata.CoherenceMaxLoadFactor = maxFactorIncrease;
    
    % Clear DAQ
    daq.reset;
    
    % Delete the temp file
    delete([tempdir,'DataContainer00']);
    
    % Covariance data too
    frdsys = idfrd(frdsys,2*pi*Freqs,'FrequencyUnit','rad/s','CovarianceData',Hcov);
    
    % Calibration
    for I = 1:length(frdsys.Frequency)
        for J = 1:length(refch)
            frdsys.ResponseData(:,J,I) = diag(ical(yind)./ical(refch(J))) * frdsys.ResponseData(:,J,I);
            %frdsys.CovarianceData(I,1,J,1:2,1:2)=[covH(I,I,J) covH(I,I+ny,J); covH(I+ny,I,J) covH(I+ny,I+ny,J)];
        end
    end
    % Save data
    
    % NAME THE OUTPUTS AND INPUTS, NOTE THAT IT WORKS ONLY FOR ONE INPUT...
    frdsys.InputName=multisine.Metadata.Sensor.Label(1);
    frdsys.OutputName=multisine.Metadata.Sensor.Label(2:end);
    dataOut = data2WS(2,frdsys,multisine);
    
    set(handles.startButton, 'String', 'Start measurement','BackGround',[0 1 0]);
    set(handles.statusStr, 'String', 'READY!  IDFRD and DAQ data available at workbench.');
    drawnow();
else
    errordlg('No channels or no reference.')
    set(handles.statusStr, 'String', 'Measurement aborted.');
    drawnow();
end

clear -global dataObject

    function nidaqMultisinePutSineDataInline(src, event)
        tArg = tStart:Ts:blockSizeInPutData * Ts;
        u = zeros(1,size(tArg,2));
        for II = 1:nw
            u = u + loads(II).* sin(om(II) * tArg + fi(II));
        end
        src.queueOutputData(u(:));
        blockSizeInPutData = blockSizeInPutData + blockSize;
        tStart = tArg(end) + Ts;
        return
    end

    function nidaqMultisineGetDataInline(src, event)
        %t=event.TimeStamps;
        if haveReadData == true
            y = event.Data.';
        else
            y = [y event.Data'];
        end
        
        haveData = true;
        haveReadData = false;
        
        haveDataContinous = true;
        HaveStartedCollect=true;

        return
    end

    function nidaqMultisinePutReconDataInline(src, event)
      if ReconDone, return; end; % Construct so it will do nothing after recon is done      
      src.queueOutputData(ReconLoad(:));
      return
    end

    function nidaqMultisineGetReconDataInline(src, event)
      if ReconDone, return; end; % Construct so it will do nothing after recon is done
      Irecon=Irecon+1;
      yrecon{mod(Irecon,2)+1} = event.Data';
%       disp('read recon data!')
       HaveStartedRecon=true;
      return
    end

end