function frdsys=simo_periodic_nidaq(so,Loads,Cycles,Skipps,Fspan)
%SIMO_PERIODIC_NIDAQ: 
% Inputs: so        - DAQ object
%         Loads     - Discrete time loads
%         Cycles    - Number of duty cycles
%         Skipps    - Number of skipped cycles
%         Fspan     - Frequency span of FRF
% Output: frdsys    - Frequency domain sys object
%         stdY      - Standard deviation of estimate of Y
% Call:   frdsys=simo_periodic_nidaq(so,Loads,Cycles,Skipps,Fspan)


%%                                                                  Globals
global CH DAQ

%%                                                        Initiate and test
Fs=so.Rate;Ts=1/Fs;
DAQ.Loads=Loads;NCycleLength=length(DAQ.Loads);
DAQ.ErrorState=0;
Hwb=waitbar(0,'Periodic cycle progress');
set(Hwb,'Name','Periodic NIDAQ Waitbar')

%%                                                             Initiate GUI
%frf_gui;
Refch=find(CH.active==CH.refch);
Nch=length(CH.active);
Ych=setdiff(1:Nch,Refch);

%%                                                         Set up listeners
LReqrd=so.addlistener('DataRequired',@nidaqPutPeriodicData);
LAvail=so.addlistener('DataAvailable',@nidaqGetPeriodicData);
LErr = so.addlistener('ErrorOccurred',@nidaqError);

%%                                     Set up for continuous running of DAQ
so.IsContinuous=true;  

%%                                               Fill first batch and start
nidaqPutPeriodicData(so,[]);
so.NotifyWhenDataAvailableExceeds=NCycleLength;
so.NotifyWhenScansQueuedBelow=floor(0.9*NCycleLength);
so.startBackground;

%% Wait until data become available
while 1,
    try 
        DAQ.y;
        break
    catch
        pause(0.1);
    end
end

%%                                            Loop over the frequency steps
for I=1:Cycles

  
%%                                   Pause until I:th data set is available

  while length(DAQ.y)<I
    pause(0.01)
  end
  
  Hwb=waitbar(I/Cycles,Hwb);
  
  if I<=Skipps
    y=[];u=[];
  else
    y=[y;DAQ.y{I}(:,Ych)];u=[u;DAQ.y{I}(:,Refch)];
  end
 
%   disp(['Doing ' int2str(I) ' of ' int2str(Cycles)])
%   plot(DAQ.t{I},DAQ.y{I}(:,1))
end

%%                                                           Do calibration
yind=setdiff(CH.active,CH.refch);uind=CH.refch;
y=y*diag(1./DAQ.cal(yind));u=u*diag(1./DAQ.cal(uind));

for II=1:size(y,2)
  [FRF(II,1,:),f] = ...
              tfestimate(u,y(:,II),ones(NCycleLength,1),0,NCycleLength,Fs);
end
ind=find(f<=Fspan);FRF=FRF(:,:,ind);f=f(ind);
    
 
%%                              Stop Analog Output/Input and delete handles
if so.IsRunning,so.stop();end
delete(LReqrd);delete(LAvail);delete(LErr);


%% Make IDFRD data object
frdsys=frd(FRF,2*pi*f,'FrequencyUnit','rad/s');
frdsys=idfrd(frdsys);

close(Hwb);


