function [Freqs,Y,stdY]=simo_frf_nidaq2(so,Freqs,Loads,Convp)
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
NCyclesInBlock=8;%                            Number of periods in AI block
NBlocks=5;%                                   Number of blocks in AO buffer
Fs=so.Rate; Ts=1/Fs;
AIBSmin=ceil(Fs/12);%        Warning message issued if blocks are generated
%                            at a faster rate than 20 per second. Use some 
%                            margin
DAQ.BufferError=false;DAQ.BufferReady=true;
DAQ.SetNo=0;
DAQ.NBlocks=NBlocks;DAQ.NBlocksRead=0;DAQ.NBlocksSaved=0;
AICurrentBS=0;

%%                                                         Set up listeners
LReqrd=so.addlistener('DataRequired',@nidaqPutSineData20);
LAvail=so.addlistener('DataAvailable',@nidaqGetData2);
LErr = so.addlistener('ErrorOccurred',@nidaqBufferError);

%%                                     Set up for continuous running of DAQ
so.IsContinuous=true;  

I=0;Imax=length(Freqs);IthIsPostProcessed=0;
while I<Imax
  I=I+1;
    
%%                                 Wait until output buffer can accept data
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

  DAQ.freq=Freqs(I);
  try DAQ.load=Loads(I);catch, DAQ.load=Loads;end

%%                                            Set blocksize of Analog Input
%                                             and size of output buffer
  AIBlockSize=max(frfsetblocksize(DAQ.freq,Fs,NCyclesInBlock),AIBSmin);
  DAQ.AOBufferSize=NBlocks*AIBlockSize;
  
  if DAQ.BufferError;%              Do previous frequency again after reset
    so.stop();
    DAQ.BufferError=false;DAQ.BufferReady=true;

%%                                    Stop, and remove spurious data if any
%     if ~so.IsDone
%        so.stop();
%        DAQ.y=DAQ.y(1:I-2);DAQ.t=DAQ.t(1:I-2);
%     end
  
%%                  If too much data: remove. If too little data: step back 
    if length(DAQ.y)>=I
       DAQ.y=DAQ.y(1:I-1);DAQ.t=DAQ.t(1:I-1);
    elseif length(DAQ.y)<(I-1)
       I=length(DAQ.y)+1;
    end   

    DAQ.freq=Freqs(I);
    try DAQ.load=Loads(I);catch, DAQ.load=Loads;end
    AIBlockSize=max(frfsetblocksize(DAQ.freq,Fs,NCyclesInBlock),AIBSmin);
    DAQ.AOBufferSize=NBlocks*AIBlockSize;
    
    
    AICurrentBS=AIBlockSize;

    so.NotifyWhenDataAvailableExceeds=AIBlockSize;
    so.NotifyWhenScansQueuedBelow=floor((NBlocks-.5)*AIBlockSize);
    DAQ.fi0=0;
    
    nidaqPutSineData2(so,[]);
    DAQ.NBlocksRead=0;% Reset before new start
    disp(['Buffer error. f = ' num2str(DAQ.freq) ' BS= ' int2str(AICurrentBS)]) 
    so.startBackground();
    
  elseif AIBlockSize~=AICurrentBS
%%                                                    (Re)set and start DAQ
    clk=clock;
    while so.IsRunning;% && etime(clock,clk)<5 
        disp([int2str(so.ScansOutputByHardware) ' ' int2str(so.ScansAcquired)])
        pause(0.05);;% Wait max 5s until buffer flushed
    end
    disp([int2str(so.ScansOutputByHardware) ' ' int2str(so.ScansAcquired)])
    so.stop(0);
    %DAQ.BufferError=false;DAQ.BufferReady=true;
    AICurrentBS=AIBlockSize;

%%                                              Handle lack of data problem
    if I>1
     if ~(I==length(DAQ.y)+1)
      I=length(DAQ.y)+1;
      DAQ.freq=Freqs(I);
      try DAQ.load=Loads(I);catch, DAQ.load=Loads;end
      AIBlockSize=max(frfsetblocksize(DAQ.freq,Fs,NCyclesInBlock),AIBSmin);
      DAQ.AOBufferSize=NBlocks*AIBlockSize;
     end
    end
    AICurrentBS=AIBlockSize;
    
    so.NotifyWhenDataAvailableExceeds=AIBlockSize;
    so.NotifyWhenScansQueuedBelow=floor((NBlocks-.5)*AIBlockSize);
    DAQ.fi0=0;
    nidaqPutSineData2(so,[]);
    DAQ.NBlocksRead=0;% Reset before new start
    disp(['Resetting. f = ' num2str(DAQ.freq) ' BS= ' int2str(AICurrentBS)]) 
    so.startBackground();

  else
%                                            Fill new data in output buffer
    AICurrentBS=AIBlockSize;
    nidaqPutSineData2(so,[]);
    disp(['Go ahead. f = ' num2str(DAQ.freq) ' BS= ' int2str(AICurrentBS)]) 
  end

%%          At this time the I:th frequency/load should be added to buffer,
%           the (I-1) should be running and the (I-2):th data available to 
%           harvest (I>2)

  try IthIsDone=length(DAQ.y);catch IthIsDone=0;end
  
  if IthIsDone>=I,keyboard,end
  
  if I>2
    disp(['I=' int2str(I) ' ,  Idone=' int2str(IthIsDone)])
  end
  
  try,plot(DAQ.t{end},DAQ.y{end}(:,1)),catch, end
  

end

 disp(['Idone=' int2str(length(DAQ.y))]) 
 pause(5)
 disp(['Idone=' int2str(length(DAQ.y))])

%%                              Stop Analog Output/Input and delete handles
so.stop();
delete(LReqrd);delete(LAvail);delete(LErr);
