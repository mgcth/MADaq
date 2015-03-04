function [frdsys,stdY]=simo_frf_nidaq(so,Freqs,Loads)
%SIMO_FRF_NIDAQ: 
% Inputs: so        - DAQ object
%         Freqs     - Frequencies of excitation
%         Loads     - Amplitudes of excitation
% Output: Y         - Output matrix of complex amplitudes. Size ny x na
%                     (na, ny - number of averages and number of outputs)
%         stdY      - Standard deviation of estimate of Y
% Call:   [frdsys,stdY]=simo_frf_nidaq(so,Freqs,Loads,Convp)


%%                                                                  Globals
%                        DAQ is important. It is link to Listener Functions
global CH DAQ

%%                                                        Initiate and test
% NCyclesInBlock=8;%                    Minimum number of periods in AI block
% NBlocks=4;%                           Number of blocks in AO buffer
HarmOrder=2;
Ny=length(CH.active);Nf=length(Freqs);


if length(Loads==1),Loads=Loads*ones(size(Freqs));end

rampcycles=5;
skipcycles=50;
takecycles=20;
% Naverages=20;
tmargin=0.2;%Margin to compensate for the modules trigger att different times

% Fs=so.Rate;Ts=1/Fs;
% AIBSmin=ceil(Fs/10);

%%                                                             Initiate GUI
frf_gui;
ical=1./DAQ.cal(CH.active);Refch=find(CH.active==CH.refch);
names=DAQ.name(CH.active);

h=figure;

for I=1:Nf
  f=Freqs(I);
  
  Rate=50*f;if Rate<1000,Rate=1000;end
  if Rate>51200;Rate=51200;end
  so.Rate=Rate;
  Fs=Rate;Ts=1/Fs;
  Nramp=rampcycles/f/Ts;
  w=(1-cos(pi*[0:Nramp-1]/Nramp))/2;
  t=0:Ts:(skipcycles+takecycles)/f+tmargin;
  
  Nskip=length(0:Ts:skipcycles/f);
  Nskipandtake=length(0:Ts:(skipcycles+takecycles)/f);
  
  W=ones(length(t),1);W(1:length(w))=w;
  Sine=Loads(I)*W.*sin(2*pi*f*t(:));
  queueOutputData(so,Sine);
  [Data,times,Trigt]=startForeground(so);
  stop(so);% This terminates activities that may interfere

  figure(h);
  plot(times,Data(:,3-1));
  
  tuse=times(Nskip+1:Nskipandtake);
  Datause=Data(Nskip+1:Nskipandtake,:);
  
  [c,RN(:,I),RH(:,I),RS(:,I),C,PW(:,I)] = ...
              harmonics(Datause,Ts,f,HarmOrder,Refch);
                
  Yc=diag(ical)*C./repmat(ical(Refch)*C(Refch,:),size(C,1),1);
  meanY(:,I)=mean(Yc,2);
  if any(isnan(meanY)),keyboard,end
  covY(:,:,I)=cov([real(Yc.') imag(Yc.')]);
  stdY(:,I)=sqrt(diag(covY(1:Ny,1:Ny)).^2+ ...
                                       diag(covY(Ny+1:2*Ny,Ny+1:2*Ny)).^2);
%
  ycal=Datause*diag(ical);
  frf_gui(tuse-tuse(1),ycal,I,Freqs,meanY,stdY,RN,RH,RS,PW,names);
 
end

%% Make IDFRD data object
for I=1:Ny
    for J=1:Nf
        idCovY(I,1,J,1:2,1:2)=[covY(I,I,J) covY(I,I+Ny,J);covY(I+Ny,I,J) covY(I+Ny,I+Ny,J)];
    end
end    
ind=find(CH.active==CH.refch);
meanY(ind,:)=[];idCovY(ind,:,:,:,:)=[];% Exclude reference

frdsys=frd(reshape(meanY,size(meanY,1),1,size(meanY,2)),2*pi*Freqs,'FrequencyUnit','rad/s');
frdsys=idfrd(frdsys);
frdsys.CovarianceData=idCovY;
