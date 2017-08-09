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
    Fs = periodic.session.Rate;
    Ts = 1/Fs;
    
    Refch = find(periodic.channelInfo.active == periodic.channelInfo.reference);
    Nch = length(periodic.channelInfo.active);
    Ych = setdiff(1:Nch,Refch);
    
    %                                                      Get calibration data
    active = periodic.channelInfo.active;
    refch = periodic.channelInfo.reference;
    tmpTable = get(handles.channelsTable,'Data');
    yind = setdiff(active,refch);
    uind = refch;
    
    ycal = diag(cell2mat({tmpTable{yind,11}}));
    ucal = diag(cell2mat({tmpTable{uind,11}}));
    
    % very ugly coding here, but I dont want to do any more MATLAB GUI,
    % going to transfer it over anyway. Implementing just for functionality
    if ~strcmpi(char(get(handles.fun3,'String')),'multisine')
        % do this if not multisine, e.g. any other periodic function
        
        Fspan = eval(get(handles.fun7,'String'));
        if length(Fspan)<2,errordlg('Frequency range must be given with lower and upper limits');end
        CyclesStr = [get(handles.fun4,'String') '       '];
        if strcmpi(CyclesStr(1:7),'default')
            M = 10;
        else
            M=str2double(get(handles.fun4,'String'));
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
        [y,times,Trigt]=periodic.session.startForeground();%% One 1st extra for electronics to warm up
        u=y(:,Refch)*ucal;
        LoadFactor=0.01*MaxAmpl/norm(u,'inf')/norm(Load(:),'inf');
        
        
        Ndata=length(Load);
        WaitTime=(M+Skipps)*Ndata*Ts;
        set(handles.statusStr, 'String', sprintf('Shaking about %5.2f s. Please wait ...', WaitTime));
        drawnow();
        
        qd=[];
        for I=1:(M+Skipps)
            qd=[qd;LoadFactor*Load(:)];
        end
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
        
        % for coherence
        yre = reshape(y',size(y',1),Ndata,M);
        yre = permute(yre,[2 1 3]);
        ure = reshape(u',size(u',1),Ndata,M);
        ure = permute(ure,[2 1 3]);
        
        Y = fft(yre); Y = permute(Y,[2 1 3]);
        U = fft(ure); U = permute(U,[2 1 3]);
        
        %     Ump = YUp(refch,:,:)./exp(1i*angle(Ur.'));
        %     Ymp = YUp(Ych,:,:)./exp(1i*angle(Ur.'));
        
        f2 = (0:Ndata-1)/Ndata*Fs;
        ind2 = find(f2>=min(Fspan) & f2<=max(Fspan));
        FRF = [];
        GBLA = [];
        coherence = [];
        for II=1:size(y,2)
            [FRF(II,1,:),f] = ...
                tfestimate(u,y(:,II),ones(Ndata,1),0,Ndata,Fs);
            
            GBLA(II,1,:) = mean(Y(II,ind2,:),3)./mean(U(1,ind2,:),3); % another way to calculate the frf
            coherence(II,1,:) = sqrt(abs(mean(Y(II,ind2,:).*conj(U(1,ind2,:)),3)).^2 ./ ...
                (mean(abs(U(1,ind2,:)).^2,3) .* mean(abs(Y(II,ind2,:)).^2,3)));
        end
        ind = find(f>=min(Fspan) & f<=max(Fspan));
        FRF = FRF(:,:,ind);f=f(ind);
        
        periodic.Metadata.Coherence = coherence;
        periodic.Metadata.GBLA = GBLA;
        
        timeElapsed = toc
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
        % do this if multisine
        % NOTE: only sample rate is read from the GUI here, everything else
        % is set below in this file!
        
        % SET BY USER
        N = 20000;
        fmin = 40; % Hz
        fmax = 500; % Hz
        nf = 200;
        
        % input signal amplitude
        amp = 50; %50 tested
        
        % realisations
        M = 10;
        
        % periods
        P = 10;
        
        % transient periods
        Pr = 3;
        
        % frequency resolution
        fLeaveOut = 1; % 1 for no leave out
        
        fs = Fs;
        % END SET BY USER
        
        Fspan = [fmin fmax];
        
        % sample time
        %fs = Fs;
        %Ts = 1/fs;
        fr = fs/N;
        
        % generate frequency vector in Hz
        f = (0:N-1)/N*fs;
        t = (0:N-1)*Ts;
        
        % generate samples
        %[wc,wd,Tsd,wq,bins,eqdf]=freqdesign_quasi(fmin,fmax,nf,fr);
        %deviation = sum((wc-wq).^2);
        %fprintf("Deviation between approximant and true frequency design is %6.2f \n",deviation);
        %w0=wq*2*pi;
        bins = round(fmin/fr)+1:fLeaveOut:round(fmax/fr);
        binsLength = length(bins);
        %nonExc = bins((2:2:binsLength)+1); % remove even lines
        %exc = setdiff(bins,nonExc); % odd multisine
        
        
        WaitTime=(M*(P+Pr)+1)*N*Ts;
        set(handles.statusStr, 'String', sprintf('Shaking about %5.2f s (and then some). Please wait ...', WaitTime));
        drawnow();
        
        
        Um = zeros(length(Refch),N,M);
        Ym = zeros(length(Ych),N,M);
        Cum = zeros(length(Refch),length(Refch),N,M);
        Cym = zeros(length(Ych),length(Ych),N,M);
        Cyum = zeros(length(Ych),length(Refch),N,M);

        ytr = [];
        ytrRMS = [];
        loadFactor = 0;
        for j = 1:M
            % create input signal
            Ur = zeros(N,1);
            
            % random phase multisine
            Ur(bins+1) = amp * exp(1i * rand(binsLength,1)*2*pi);
            u = 2*real(ifft(Ur));
            maxAmp = max(abs(u));
            u = amp/maxAmp * u;
            %u = amp * u / (std(u));
            
            % find load levels, should suffice once for approximate level
            if j == 1
                % Give X period of data to find load level
                qd = 0.01*u(:)/norm(u(:),'inf');
                queueOutputData(periodic.session,qd);
                [yMeas,times,Trigt] = periodic.session.startForeground();%% One 1st extra for electronics to warm up
                uMeas = yMeas(:,Refch)*ucal;
                loadFactor = 0.01*maxAmp/norm(uMeas,'inf')/norm(u(:),'inf');
            end
            
            % number of periods
            qd = repmat(loadFactor*u,P+Pr,1);
            
            queueOutputData(periodic.session,qd);
            [yMeas,times,Trigt] = periodic.session.startForeground();
            %periodic.session.startBackground();
            %wait(periodic.session)
            %y(1:Skipps*Ndata,:) = [];
            u = yMeas(:,Refch);
            y = yMeas(:,Ych);
            u = (u*ucal)';
            y = (y*ycal)';
            
            % check stationarity
            for tr = 1:Pr+P-1
                ytr(:,(tr-1)*N+1:tr*N) = y(:,(tr+1-1)*N+1:(tr+1)*N) - y(:,(tr-1)*N+1:tr*N);
                ytrRMS(:,tr) = rms(ytr(:,(tr-1)*N+1:tr*N)');
            end
            
            % remove transient
            u(:,1:N*Pr) = [];
            y(:,1:N*Pr) = [];
            
            yp = reshape(y,size(y,1),N,P);
            yp = permute(yp,[2 1 3]);
            up = reshape(u,size(u,1),N,P);
            up = permute(up,[2 1 3]);
            
            Ymp = permute(fft(yp),[2 1 3]);
            Ump = permute(fft(up),[2 1 3]);
            for wk = 1:N % do without for loop for efficieny
                Ymp(:,wk,:) = Ymp(:,wk,:)./exp(1i*angle(Ur(wk)));
                Ump(:,wk,:) = Ump(:,wk,:)./exp(1i*angle(Ur(wk)));
            end
            
            % fft
            %[FRFmp,f1] = tfestimate(yu(refch,:)',yu(2:end,:)',ones(N,1),0,bins*fr,fs);
            %FRFmp=FRFmp';
            %yup = reshape(yu,size(yu,1),N,P); yup=permute(yup,[2 1 3]);
            %YUp = fft(yup); YUp = permute(YUp,[2 1 3]);
            %Ump = YUp(Refch,:,:)./exp(1i*angle(Ur.'));
            %Ymp = YUp(Ych,:,:)./exp(1i*angle(Ur.'));
            
            % estimation and average over periods
            % robust method for multisine
            Um(:,:,j) = mean(Ump,3);
            Ym(:,:,j) = mean(Ymp,3);
            
            for wk = 1:N
                Cum(:,:,wk,j) = 1/P * cov(squeeze(Ump(:,wk,:)).');
                Cym(:,:,wk,j) = 1/P * cov(squeeze(Ymp(:,wk,:)).');
                Cyum(:,:,wk,j) = 1/P * xcovMat(squeeze(Ymp(:,wk,:)), squeeze(Ump(:,wk,:)).'); % transpose special case of one input
                
            end
            
            fprintf('Realisation %i \n',j)
            %figure
            %subplot(M,1,j)
            %plot(bins*fr,db(Ym(1,bins+1,1)./Um(1,bins+1,j)))
            %hold on
            %plot(bins*fr,db(sig2um(1,bins+1,j)))
            %plot(bins*fr,db(sig2ym(1,bins+1,j)))
            %plot(bins*fr,db(squeeze(sig2yum(1,1,bins+1,j))))
            %xlabel('Hz')
            %ylabel('dB')
        end
        
        %% average realisations
        
        set(handles.statusStr, 'String', 'Estimating transfer functions. Please wait ...');
        drawnow();
        
        U = mean(Um,3);
        Y = mean(Ym,3);
        
        Cu = zeros(length(Refch),length(Refch),N);
        Cy = zeros(length(Ych),length(Ych),N);
        Cyu = zeros(length(Ych),length(Refch),N);
        for wk = 1:N
            Cu(:,:,wk) = 1/M * cov(squeeze(Um(:,wk,:)).');
            Cy(:,:,wk) = 1/M * cov(squeeze(Ym(:,wk,:)).');
            Cyu(:,:,wk) = 1/M * xcovMat(squeeze(Ym(:,wk,:)), squeeze(Um(:,wk,:)).'); % transpose special case of one input
        end
        
        % improved estimate of input/output noise
        Cun = 1/M * mean(Cum,4);
        Cyn = 1/M * mean(Cym,4);
        Cyun = 1/M * mean(Cyum,4);
        
        % final estimate
        GBLA = zeros(length(Ych),length(Refch),N);
        coherence = zeros(length(Ych),length(Refch),N);
        for i = 1:length(Ych)
            for j = 1:length(Refch)
                GBLA(i,j,:) = Y(i,:)./U(j,:);
                
                coherence(i,j,:) = sqrt(abs(mean(Ym(i,:,:).*conj(Um(j,:,:)),3)).^2 ./ ...
                    (mean(abs(Um(j,:,:)).^2,3) .* mean(abs(Ym(i,:,:)).^2,3)));
            end
        end
        coherence2 = coherence(:,:,bins+1);
        
        CBLA = zeros(length(Ych),length(Ych),N);
        CBLAn = zeros(length(Ych),length(Ych),N);
        for wk = 1:N
            V = [eye(length(Ych)) -GBLA(:,:,wk)];
            Cz = [Cy(:,:,wk) Cyu(:,:,wk); Cyu(:,:,wk)' Cu(:,:,wk)];
            Czn = [Cyn(:,:,wk) Cyun(:,:,wk); Cyun(:,:,wk)' Cun(:,:,wk)];
            
            %         CBLA(:,:,wk) = 1/conj(U(refch,wk)*U(refch,wk).') * V*Cz*V.';
            %         CBLAn(:,:,wk) = 1/conj(U(refch,wk)*U(refch,wk).') * V*Czn*V.';
            CBLA(:,:,wk) = 1/conj(U(Refch,wk)*U(Refch,wk)') * V*Cz*V';
            CBLAn(:,:,wk) = 1/conj(U(Refch,wk)*U(Refch,wk)') * V*Czn*V';
        end
        
        %     varNu = M*P*abs(Ur').^2.*sig2un;
        %     varNy = M*P*abs(Ur').^2.*sig2yn;
        %     covarNyu = M*P*abs(Ur').^2.*sig2yun;
        %     varYs = M*abs(Ur').^2.*(sig2y-sig2yn);
        %     varNg = M*P*sig2BLAn;
        %     varGs = M*(sig2BLA-sig2BLAn);
        %
        %     % covariance data for idfrd, is this even correct?
        %     for ny = 1:size(GBLA,1)
        %         for nu = 1:size(GBLA,2)
        %             Gmcov(ny,nu,:,:) = Ym(ny,:,:)./Um(nu,:,:);
        %             for kf = 1:size(GBLA,3)
        %                 Gcov(ny,nu,kf,:,:) = cov([real(squeeze(Gmcov(ny,nu,kf,:))) imag(squeeze(Gmcov(ny,nu,kf,:)))]);
        %             end
        %         end
        %     end
        
        %FRDe = idfrd(GBLA(:,:,bins+1),bins*fr*2*pi);%,'CovarianceData',Gcov(:,:,bins+1,:,:));
        %sig2e = frd(sig2(2:end,:),bins(2:end)*fr*2*pi);
        %sig2en = frd(sig2n(2:end,:),bins(2:end)*fr*2*pi);
        

        
        
        
        
        

%         f2 = (0:Ndata-1)/Ndata*Fs;
%         ind2 = find(f2>=min(Fspan) & f2<=max(Fspan));
%         FRF = [];
%         GBLA = [];
%         coherence = [];
%         for II=1:size(y,2)
%             [FRF(II,1,:),f] = ...
%                 tfestimate(u,y(:,II),ones(Ndata,1),0,Ndata,Fs);
%             
%             GBLA(II,1,:) = mean(Y(II,ind2,:),3)./mean(U(1,ind2,:),3); % another way to calculate the frf
%             coherence(II,1,:) = sqrt(abs(mean(Y(II,ind2,:).*conj(U(1,ind2,:)),3)).^2 ./ ...
%                 (mean(abs(U(1,ind2,:)).^2,3) .* mean(abs(Y(II,ind2,:)).^2,3)));
%         end
%         ind = find(f>=min(Fspan) & f<=max(Fspan));
%         FRF = FRF(:,:,ind);f=f(ind);
        
        periodic.Metadata.Coherence = coherence2;
        periodic.Metadata.CBLA = CBLA(:,:,bins+1);
        periodic.Metadata.CBLAn = CBLAn(:,:,bins+1);
        periodic.Metadata.Cu = Cu(:,:,bins+1);
        periodic.Metadata.Cy = Cy(:,:,bins+1);
        periodic.Metadata.Cyu = Cyu(:,:,bins+1);
        periodic.Metadata.Cun = Cun(:,:,bins+1);
        periodic.Metadata.Cyn = Cyn(:,:,bins+1);
        periodic.Metadata.Cyun = Cyun(:,:,bins+1);
        periodic.Metadata.bins = bins;
        
        timeElapsed = toc
        periodic.Metadata.TimeElapsed = timeElapsed;
        periodic.Metadata.TestDateEnd = datestr(now,'mm-dd-yyyy HH:MM:SS');
        
        % Make IDFRD data object
        frdsys = frd(GBLA(:,:,bins+1),bins*fr*2*pi,'FrequencyUnit','rad/s');
        frdsys = idfrd(frdsys);
        
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
        
    end
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