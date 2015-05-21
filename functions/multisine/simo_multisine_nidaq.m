function FRD=simo_multisine_nidaq
% function FRD=simo_multisine_nidaq(so,freq,amplist)
%SIMO_MULTISINE_NIDAQ

%Copyleft: 2015-04-24,Thomas Abrahamsson, Chalmers University of Technology

if 0,% Construct to let the appbuilder see these functions
    magphase;
    simo_multisine_GUI;
    UDPping;
end

% WORK-IN_PROGRESS!! /TA 2015-03-15

%%                            Start up parallel Matlab process that has GUI
startstr=['cmd /c start /min matlab -nosplash -nodesktop -minimize ' ...
    '-r "simo_multisine_GUI"'];dos(startstr);

%%
global UDP
UDP.ready=false;

%%                              Data that should be given or provided by so
refch=1;
nu=1;ny=6;
Ts=0.0005;
freq=[2 23];nf=200;
[Freqs,wd,Tsd]=freqdesign(freq(1),freq(2),nf);
Ct=0.997;

%%                                                 Pass data to GUI process
instrreset;
uh=startUDP('Host');
while ~UDP.ready
    pause(1);
end
PassDatagram(uh,'f',Freqs/2/pi);% Pass frequency list
PassDatagram(uh,'ny',ny);%     Pass ny

%%                                             Some (yet) hardcoded numbers
Ncyc=2;% Number of lowest frequency sinusoidal that data block should cover
Nstat=20;% Number of block evaluations for statistics

%%                                                                 Initiate
FRD=frd(NaN*zeros(6,1,nf),Freqs/2/pi,'FrequencyUnit','Hz');

%%       Obtain good number of frequencies K that can be used simulaneously
Nblock=ceil(Ncyc/Ts/min(Freqs/2/pi));
K=floor(nf/10);% Start guess for number of frequency sets (not too few)
while 1,
    ind=1:K:nf;
    [~,~,~,A]=harmcoeff(randn(nu+ny,Nblock),Ts,Freqs(ind)/2/pi);
    if rank(A)==min(size(A)),break;end
    K=K+1;
end

% K=nf; % For stepped sine

%% ------------------------------------- Loop over number of frequency sets
for I=1:K
    %%                                                              Set up load
    indf=I:K:nf;
    w=Freqs(indf);nw=length(w);
    fi=2*pi*rand(nw,1);
    t=0:Ts:2000;
    u=0*t;
    for I=1:nw,u=u+sin(w(I)*t+fi(I));end
    
    x0=zeros(12,1);J=0;nl=2e-2;% Temporary use
    
    %%                           Collect data until after stationarity obtained
    iret=-1;
    ynotused=[];
    %%                                                        Find stationarity
    while iret==-1
        
        %% Collect test data (for now by simulation)
        J=J+1;
        ua=u((J-1)*1000+[1:1000]);
        tic
        [y,xend]=simo_multisine_testsys(ua,x0);
        pause(1000*Ts-toc);
        x0=xend;
        ynoise=randn(size(y));ynoise=nl*norm(y)/norm(ynoise)*ynoise;
        Y=[ua;y+ynoise];
        
        %%                                              Estimate transfer functions
        Y=[ynotused Y];
        if J==1
            [iret,H,ynotused,C,opt]=simostationarityengine(Y,Ts,w/2/pi,refch,Ncyc,Ct);
            H0=H;
        else
            [iret,H,ynotused,C]=simostationarityengine(Y,Ts,w/2/pi,refch,Ncyc,Ct,H0,opt);
            H0=H;
        end
        
        %%                                                 Pass data to GUI process
        %     flushoutput(uh);
        PassDatagram(uh,'indf',indf);
        PassDatagram(uh,'Hr',real(H));
        PassDatagram(uh,'Hi',imag(H));
        PassDatagram(uh,'C',C);
        
    end
    %%                                                        Obtain statistics
    Hs=[];
    for JJ=1:Nstat
        iret=-1;
        while iret==-1
            
            %% Collect test data (for now by simulation)
            J=J+1;
            ua=u((J-1)*1000+[1:1000]);
            [y,xend]=simo_multisine_testsys(ua,x0);
            x0=xend;
            ynoise=randn(size(y));ynoise=nl*norm(y)/norm(ynoise)*ynoise;
            Y=[ua;y+ynoise];
            
            %%                                              Estimate transfer functions
            Y=[ynotused Y];
            [iret,H,ynotused,C]=simostationarityengine(Y,Ts,w/2/pi,refch,Ncyc,Ct,H0,opt);
            H0=H;
        end
        Hs(:,:,:,JJ)=H;
    end
    Hm=mean(Hs,4);
    PassDatagram(uh,'indf',indf);
    PassDatagram(uh,'Hr',real(Hm));
    PassDatagram(uh,'Hi',imag(Hm));
    PassDatagram(uh,'C',C);
    FRD.ResponseData(:,:,indf)=Hm;
end
PassDatagram(uh,'StopTheGUI',1);
set(FRD,'Frequency',wd,'Ts',Tsd);