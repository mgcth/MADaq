function dataOut = startMultisine(hObject, eventdata, handles)

global dataObject HFRFGUI CH UDP plotK% Xsave Xsave_ Zsave
plotK = 0;
Xsave = [];
Xsave_ = [];
% Initialaise the test setup
multisine = startInitialisation(hObject, eventdata, handles);
% 2*0.03
% Get info about channnels
CHdata = get(handles.channelsTable, 'data');
Chact = 0; for i=1:size(CHdata,1),if CHdata{i,1},Chact=Chact+1; end, end
CH = multisine.channelInfo;

% Get frequencies and loads etc...
%[Freqs, wd, Tsd] = eval(get(handles.fun2,'String')); % should be in Hz!
Freqs = eval(get(handles.fun2,'String')); % should be in Hz!
Tsd = 0.001;

nf = length(Freqs);
loads = eval(get(handles.fun3,'String'));
blockSize = 10000;

% Get the sampling rate and Ts
Fs = multisine.session.Rate;
Ts = 1/Fs;

% Data that should be given or provided by multisine
%refch = CH.reference;
refch = find(CH.active==CH.reference);
nu = length(CH.reference); % number of inputs
ny = length(CH.active); % number of outputs
yind = 1:ny; yind(refch) = [];
%Ct = 0.997;
Ct = 0.99;


% Start up parallel Matlab process that has GUI
%startstr=['cmd /c start /min matlab -nosplash -nodesktop -minimize ' ...
%    '-r "simo_multisine_GUI"'];dos(startstr);
%UDP.ready = false;

% Pass data to GUI process
%instrreset;
%uh=startUDP('Host');
%while ~UDP.ready
%    pause(1);
%end
%PassDatagram(uh,'f',Freqs); % Pass frequency list
%PassDatagram(uh,'ny',ny); % Pass ny

% Some (yet) hardcoded numbers
Ncyc=10;% Number of lowest frequency sinusoidal that data block should cover
Nstat=20;% Number of block evaluations for statistics

% Initiate
frdsys=frd(NaN*zeros(length(CH.active)-length(CH.reference),length(CH.reference),nf),Freqs,'FrequencyUnit','Hz');

% Obtain good number of frequencies K that can be used simulaneously
Nblock=ceil(Ncyc/Ts/min(Freqs));
K=floor(nf/10);% Start guess for number of frequency sets (not too few)
while 1,
    ind=1:K:nf;
    [~,~,~,A]=harmcoeff(randn(nu+ny,Nblock),Ts,Freqs(ind));
    if rank(A)==min(size(A)),break;end
    K=K+1;
end
%K=nf; % For stepped sine

% Check if any channels were added to the session
if ~isempty(multisine.session.Channels) &&  ~isempty(multisine.channelInfo.reference)
    tmpTable = get(handles.channelsTable,'Data');
    ical = {tmpTable{:,10}};
    ical = cell2mat(ical(CH.active))';
    
    % Add listener
    LAvail=addlistener(multisine.session, 'DataAvailable', @nidaqMultisineGetDataInline);
    LReqrd=addlistener(multisine.session, 'DataRequired', @nidaqMultisinePutSineDataInline);
    LErr = addlistener(multisine.session, 'ErrorOccurred', @nidaqMultisineErrorInline);
    
    % Set up for continuous running of DAQ
    multisine.session.IsContinuous = true;
    multisine.session.NotifyWhenDataAvailableExceeds=blockSize;
    multisine.session.NotifyWhenScansQueuedBelow=ceil(blockSize/2);
    
    firstRun = 0;

    Zsave = [];
    tic
    % ------------------------------------- Loop over number of frequency sets
    for I=1:K
        I
        y = [];
        ynotused = [];
        C = 0;
        iret = -1;
        opt = [];
        H0 = [];
        H = [];
        ySave = [];
        
        haveData = false;
        haveReadData = true;
        haveDataContinous = false;
        firstTime = true;
        
        % Set up load
        indf=I:K:nf;
        tStart = Ts;
        blockSizeInPutData = blockSize;
        w=Freqs(indf);
        om = 2 * pi * w;
        nw=length(w);
        fi=2*pi*rand(nw,1);
        
        % Collect data until after stationarity obtained
        if firstRun == 0
            firstRun = firstRun + 1;
            nidaqMultisinePutSineDataInline(multisine.session, [])
            startBackground(multisine.session);
            pause(0.1);
        end
        
        O = 0;
        while iret == -1% && OO < 100
            O = O + 1;
            %nidaqMultisinePutSineDataInline(multisine.session, [])
            %tic
            %pause(100*Ts-toc);
            pause(0.0001);
            
            % Estimate transfer functions
            if haveData == true
                ynotused = [ynotused y];
                haveReadData = true;
                haveData = false;
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
            end
            
            %disp(['I = ', num2str(I), ', O = ' num2str(O), ', C = ', num2str(C), ', K = ', num2str(KK), ', queue = ', num2str(multisine.session.ScansQueued)])
            %multisine.session.ScansQueued
            
            if multisine.session.IsRunning == 0%multisine.session.ScansQueued == 0
                haveDataContinous = false;
                haveData = false;
                multisine.session.stop();
                nidaqMultisinePutSineDataInline(multisine.session, [])
                disp('was 0 in stationary')
                %get(multisine.session)
                startBackground(multisine.session);
                pause(0.1);
            end
            
            %if O == 30
            %    assignin('base','YY',YY);
            %    keyboard
            %end
            
            %             %
            %             % Pass data to GUI process
            %             %     flushoutput(uh);
            %             PassDatagram(uh,'indf',indf);
            %             PassDatagram(uh,'Hr',real(H));
            %             PassDatagram(uh,'Hi',imag(H));
            %             PassDatagram(uh,'C',C);
            
        end
        %get(multisine.session)
        
        % Obtain statistics
        Hs=[];
        Ctmean_input = 0.9;
        Ctmean = Ctmean_input;
        CtmeanChanged = false;
        
        for JJ=1:Nstat
            haveReadData = true;
            ynotused = [];
            haveData = false;
            haveDataContinous = false;
            
            %JJ
            iret=-1;
            OO = 0;
            while iret==-1% && OO < 100
                OO = OO + 1;
                
                %tic
                %pause(100*Ts-toc);
                pause(0.0001)

                % Estimate transfer functions
                if haveData == true
                    ynotused = [ynotused y];
                    haveReadData = true;
                    haveData = false;
                end
                
                if haveDataContinous == true
                    [iret,H,ynotused,C]=simostationarityengine(ynotused,Ts,w,refch,Ncyc,Ctmean,H0,opt);
                    H0=H;
                    
                    if CtmeanChanged == true
                        Ctmean = Ctmean_input;
                        CtmeanChanged = false;
                    end
                end
                
                if multisine.session.IsRunning == 0%multisine.session.ScansQueued == 0
                    haveDataContinous = false;
                    haveData = false;
                    multisine.session.stop();
                    nidaqMultisinePutSineDataInline(multisine.session, [])
                    disp('was 0 in statistics')
                    %get(multisine.session)
                    startBackground(multisine.session);
                    pause(0.1);
                    Ctmean = Ct;
                    CtmeanChanged = true;
                end
                
                %disp(['I = ', num2str(I), ', JJ = ' , num2str(JJ), ', OO = ' num2str(OO), ', C = ', num2str(C), ', K = ', num2str(KK), ', queue = ', num2str(multisine.session.ScansQueued)])
                %multisine.session.ScansQueued
                
            end
            Hs(:,:,:,JJ)=H;
        end
        Hm=mean(Hs,4);
        %         PassDatagram(uh,'indf',indf);
        %         PassDatagram(uh,'Hr',real(Hm));
        %         PassDatagram(uh,'Hi',imag(Hm));
        %         PassDatagram(uh,'C',C);
        frdsys.ResponseData(:,:,indf)=Hm;
        
        
        
    end
    %     PassDatagram(uh,'StopTheGUI',1);
    multisine.session.stop();
    delete(LAvail);
    delete(LReqrd);
    delete(LErr);
    set(frdsys,'Frequency',Freqs,'Ts',Tsd);
    % Clean-up
    multisine.session.release();
    delete(multisine.session);
    toc
    assignin('base','Zsave',Zsave);
    
    % Clear DAQ
    daq.reset;
    
    % Calibration
    for I = 1:length(frdsys.Frequency)
        for J = 1:length(refch)
            frdsys.ResponseData(:,J,I) = diag(ical(yind)./ical(refch(J))) * frdsys.ResponseData(:,J,I);
        end
    end
    % Save data
    %Nt=dataObject.nt;
    dataOut = data2WS(2,frdsys,multisine);
    
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
        for II = 1:nw, u = u + loads.* sin(om(II) * tArg + fi(II)); end
        src.queueOutputData(u(:));
        blockSizeInPutData = blockSizeInPutData + blockSize;
        tStart = tArg(end) + Ts;
    end

    function nidaqMultisineGetDataInline(src, event)
        %t=event.TimeStamps;
        if haveReadData == true
            y=event.Data.';
        else
            y = [y event.Data'];
        end
        
        haveData = true;
        haveReadData = false;
        
        haveDataContinous = true;
        
        %Zsave = [Zsave event.Data'];
    end

end