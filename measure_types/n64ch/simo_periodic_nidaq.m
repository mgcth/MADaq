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

Refch=find(CH.active==CH.refch);
Nch=length(CH.active);
Ych=setdiff(1:Nch,Refch);

Ndata=length(Loads);
WaitTime=Cycles*Ndata*Ts;
disp(' '),disp(['Shaking about ' num2str(WaitTime) 's. Please wait ...'])

qd=[];
for I=1:Cycles;qd=[qd;Loads(:)];end
queueOutputData(so,qd);
y=startForeground(so);
y(1:Skipps*Ndata,:)=[];
u=y(:,Refch);
y=y(:,Ych);

disp('Done.')
disp('Estimating transfer functions. Please wait ...')

%%                                                           Do calibration
yind=setdiff(CH.active,CH.refch);uind=CH.refch;
y=y*diag(1./DAQ.cal(yind));u=u*diag(1./DAQ.cal(uind));

for II=1:size(y,2)
  [FRF(II,1,:),f] = ...
              tfestimate(u,y(:,II),ones(Ndata,1),0,Ndata,Fs);
end
ind=find(f>=min(Fspan) & f<=max(Fspan));FRF=FRF(:,:,ind);f=f(ind);
    
%% Make IDFRD data object
frdsys=frd(FRF,2*pi*f,'FrequencyUnit','rad/s');
frdsys=idfrd(frdsys);


