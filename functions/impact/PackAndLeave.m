function PackAndLeave
% global Y refch fcut SetAct Leave TS FRD
global Impact Y SetAct

Impact.Leave=true;
% close(Impact.hd);
closereq;% Close figure window

% while 1
%   try 
% %     close(Impact.hd);
%     closereq;
%     break;
%   catch
%   end
% end

%%
fcut=Impact.fcut;
refch=Impact.refch;
t=Y{1}(end,:);t=t-t(1);dt=t(2)-t(1);
[ny,nt]=size(Y{1}(1:end-1,:));
    
%% Align hits
Mx=max(abs(Y{1}(refch,:))); PWidth=sum(abs(Y{1}(refch,:)>.1*Mx));
for I=1:length(Y)
  [~,mxind]=max(abs(Y{I}(refch,:)));
  Y{I}=circshift(Y{I}',-mxind+PWidth)';
end  

J=0;ytot=zeros(ny,nt);ylong=[];
for I=1:length(Y)
  if SetAct(I)
    J=J+1;
    yts{J}=timeseries(Y{I}(1:(end-1),:),t,'Name',['Y' int2str(J)]);
    ytot=ytot+Y{I}(1:(end-1),:);
    ylong=[ylong Y{I}(1:(end-1),:)];
  end  
end

%% Eliminate negative contribution to impact force
uhit=ytot(refch,:); uhit=uhit-median(uhit);
maxu=max(uhit); minu=min(uhit);
if maxu<abs(minu);%% Negative impact pulse
  uhit(uhit>0)=0;
else% Positive impact pulse
  uhit(uhit<0)=0;
end    
ytot(refch,:)=uhit;

TS=timeseries(ytot,t,'Name','Y');
UserDataTS.refch=refch;
UserDataTS.Y=yts;
TS.UserData=UserDataTS;

respch=setdiff(1:ny,refch);


%% Window
W=(cos(pi*[0:nt-1]/(nt-1))+1)/2;
for I=1:ny
  ytot(I,:)=W.*ytot(I,:);
end   

%% Fix calibration, mladen 2018-04-01
respcal = Impact.ChCal(respch);
refcal = Impact.ChCal(refch);
ytot_resp = ytot(respch,:)'*diag(respcal);
ytot_ref = ytot(refch,:)'*diag(refcal);
%% END

if ~isempty(ytot)
  %[F,f] = tfestimate(ytot(refch,:)',ytot(respch,:)',nt,0,nt,1/dt);
  [F,f] = tfestimate(ytot_ref, ytot_resp,nt,0,nt,1/dt); % Mladen 2018-04-01
  indf=find(f<=fcut);
  FRF(:,1,:)=F(indf,:).';
  FRD=frd(FRF,2*pi*f(indf));
  Cxy = mscohere(ylong(refch,:)',ylong(respch,:)',nt,0,nt,1/dt);
  %UserDataFRD.Coherence(:,1,:) = Cxy(indf,:)'; % Mladen 2018-04-01
  %FRD.UserData=UserDataFRD; % Mladen 2018-04-01
  FRD.UserData.Coherence(:,1,:) = Cxy(indf,:)'; % Mladen 2018-04-01
end  

FRD.InputUnit=Impact.Metadata.Sensor.Unit(refch);
FRD.OutputUnit=Impact.Metadata.Sensor.Unit(respch);

switch Impact.Metadata.Sensor.Dof{refch}
  case 'X+'
    FRD.InputName=[Impact.Metadata.Sensor.Dir{refch} '.1'];
  case 'X-'
    FRD.InputName=['-' Impact.Metadata.Sensor.Dir{refch} '.1'];
  case 'Y+'
    FRD.InputName=[Impact.Metadata.Sensor.Dir{refch} '.2'];
  case 'Y-'
    FRD.InputName=['-' Impact.Metadata.Sensor.Dir{refch} '.2'];
  case 'Z+'
    FRD.InputName=[Impact.Metadata.Sensor.Dir{refch} '.3'];
  case 'Z-'
    FRD.InputName=['-' Impact.Metadata.Sensor.Dir{refch} '.3'];
  otherwise
    FRD.InputName=Impact.Metadata.Sensor.Label(refch);      
end

for I=1:length(respch)
  switch Impact.Metadata.Sensor.Dof{respch(I)}
    case 'X+'
      FRD.OutputName{I}=[Impact.Metadata.Sensor.Dir{respch(I)} '.1'];
    case 'X-'
      FRD.OutputName{I}=['-' Impact.Metadata.Sensor.Dir{respch(I)} '.1'];
    case 'Y+'
      FRD.OutputName{I}=[Impact.Metadata.Sensor.Dir{respch(I)} '.2'];
    case 'Y-'
      FRD.OutputName{I}=['-' Impact.Metadata.Sensor.Dir{respch(I)} '.2'];
    case 'Z+'
      FRD.OutputName{I}=[Impact.Metadata.Sensor.Dir{respch(I)} '.3'];
    case 'Z-'
      FRD.OutputName{I}=['-' Impact.Metadata.Sensor.Dir{respch(I)} '.3'];
    otherwise
      FRD.OutputName{I}=char(Impact.Metadata.Sensor.Label(respch(I)));      
  end
end    
    
Impact.FRD=FRD;
Impact.TS=TS;

% Impact.Leave=true;
% closereq;
end