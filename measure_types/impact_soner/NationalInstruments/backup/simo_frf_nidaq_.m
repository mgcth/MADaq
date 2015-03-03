function [Freqs,Y,stdY]=simo_frf_nidaq(so,Freqs,Loads,Convp)
%SIMO_FRF_NIDAQ: 
% Inputs: so        -     object
%         Freqs     - Frequencies of excitation
%         Loads     - Amplitudes of excitation
%         Convp     - Convergence parameters
% Output: Y         - Output matrix of complex amplitudes. Size ny x na
%                     (na, ny - number of averages and number of outputs)
%         stdY      - Standard deviation of estimate of Y
% Call:   [f,Y,stdY]=simo_frf_nidaq(so,Freqs,Loads,Convp)


%%                                                                  Globals
global CH DAQ

%%                                                        Initiate and test
%Nch=length(ai.Channel);
Ncycles=10;%                             Number of periods to collect
%Tbuff=10;%                              Set time for output buffer (10s)
%                                       to diminish risk of output
%                                       underflow
Fs=so.Rate; Ts=1/Fs;
%Nbuff=Tbuff*Fs;
RHlim=Convp{1};RSlim=Convp{2};RNlim=Convp{3};Itermax=Convp{4};
DAQ.Maxscans=Itermax+1;
cal=DAQ.cal;
blocksizemin=(Fs/20)+1;%     Warning message issued if blocks are generated
%                            at a faster rate than 20 per second
DAQ.BufferError=false;

%%                                                             Initiate GUI
frf_gui;

%%                                                         Set up listeners
LReqrd=so.addlistener('DataRequired',@nidaqPutSineData);
LAvail=so.addlistener('DataAvailable',@nidaqGetData);
LErr = so.addlistener('ErrorOccurred',@nidaqBufferError);
%LErr = so.addlistener('ErrorOccurred',@(src,event) disp(event.Error.getReport()));

%%                                     Set up for continuous running of DAQ
so.IsContinuous=true;  

%%                                                     Do initial frequency
DAQ.Nscans=0;DAQ.data=[];DAQ.t=[];%               Reset at each frequency

%%                                            Get actual frequency and load
freq=Freqs(1);try load=Loads(1);catch, load=Loads;end
DAQ.freq=freq;DAQ.load=load;

%%                                            Set blocksize of Analog Input
blocksize=frfsetblocksize(freq,Fs,Ncycles);
CurrentBS=blocksize;
DAQ.Nbuff=(Itermax+3)*blocksize;
DAQ.BufferCountAccumulated=0;DAQ.MarkStartOfBuffer=true;
DAQ.k0=0;DAQ.fi0=0;
so.NotifyWhenDataAvailableExceeds=blocksize;  
% so.NotifyWhenScansQueuedBelow=ceil(DAQ.Nbuff/4);
nidaqPutSineData(so,[]);
so.startBackground();




for I=1:length(Freqs)
    
%% Initiate
  RHmax=inf;RNmax=inf;RSmax=inf;
  Iter=1;%             Meaning: Skip first batch of data when DAQ is set up

%%                                            Get actual frequency and load
  freq=Freqs(I);try load=Loads(I);catch, load=Loads;end
  
%%                                      Repeat until criteria are fulfilled
  while Iter<=Itermax && (RSmax>RSlim || RNmax>RNlim || RHmax>RHlim)
%%                                                             Collect data
    if Iter<DAQ.Nscans
      if Iter==1,yfull=DAQ.data(:,:,DAQ.Maxscans);end;%    First batch 
      y=DAQ.data(:,:,DAQ.Maxscans-Iter);%   Data put in DAQ by nidaqGetData
      yfull=[yfull;y];
          
%%                                               Obtain harmonic properties
%         c  - complex amplitudes of harmonics
%         RN - Residual noise (normalized with respect to signal)
%         RH - Harmonic distorsion (normalized with respect to signal)
%         RS - Stationarity deviation
%         C  - Cycle-per-cycle amplitude of 0:th order harmonics 
      order=2;
      [c,RN(:,I),RH(:,I),RS(:,I),C]=harmonics(y,Ts,freq,order);
    
%%                        Get channel max (noise, distorsion, stationarity)
      RNmax=max(RN(CH.eval,I));
      RHmax=max(RH(CH.eval,I));
      RSmax=max(RS(CH.eval,I));
    
      Iter=Iter+1;
    elseif DAQ.BufferError
        break
    else
         pause(0.001)
    end
    
  end
  
%%                                              Get next frequency and load
  try nextfreq=Freqs(I+1);catch nextfreq=Freqs(end);end
  try nextload=Loads(I);catch nextload=Loads(end);end
  DAQ.freq=nextfreq;DAQ.load=nextload;

%%                                            Set blocksize of Analog Input
  blocksize=frfsetblocksize(nextfreq,Fs,Ncycles);
  DAQ.Nbuff=(Itermax+1)*blocksize;
  
  if blocksize~=CurrentBS || DAQ.BufferError
%%                                                    (Re)set and start DAQ
    so.stop();
    CurrentBS=blocksize;
    so.NotifyWhenDataAvailableExceeds=blocksize;  
    DAQ.BufferCountAccumulated=0;DAQ.MarkStartOfBuffer=true;
    DAQ.k0=0;DAQ.fi0=0;
    nidaqPutSineData(so,[]);
    so.startBackground();
    pause(0.01)
  else
%                                            Fill new data in output buffer
    DAQ.MarkStartOfBuffer=true;
    DAQ.k0=0;%DAQ.fi0=0;
    nidaqPutSineData(so,[]);
  end
  DAQ.Nscans=0;DAQ.data=[];DAQ.t=[];%               Reset at each frequency
  

%%                                               Establish (calibrated) FRF  
  if DAQ.BufferError
    DAQ.BufferError=false;
  else  
    Yc=diag(cal)*C./repmat(cal(CH.refch)*C(CH.refch,:),size(C,1),1);
    Y(:,I)=mean(Yc,2);
    stdY(:,I)=std(Yc,0,2);
  
    t.t=0:Ts:Ts*(size(yfull,1)-1);t.blocktic=0:Ts*size(y,1):t.t(end);
    frf_gui(t,yfull*diag(cal),Freqs,Y,stdY,RN,RH,RS);
  end
end

%%                              Stop Analog Output/Input and delete handles
so.stop();
delete(LReqrd);delete(LAvail);delete(LErr);
