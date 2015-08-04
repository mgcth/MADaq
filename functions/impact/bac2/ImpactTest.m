function [FRD,TStot]=ImpactTest(ChNames,ChCal,refch,RefName,fcut)
%IMPACTTEST
if length(ChCal)==length(ChCal(:)), ChCal=diag(ChCal);end

%%                                                         Initial settings
indTrainHit=[];TrainHitFound=false;hdh=[];rmsnoise=-1;
FileName=[tempdir 'DataContainer1.mat'];

%%                                                          Hard-coded data
fps=10;Tdelay=1.0;FadeTime=30.;PreTime=0.02;WindowTime=0.2;
Twindow=2.0;CFm=1;CrestFactor=20;

%% Save data for PlotHits
plotch=1;
Kill=false;save('Data4PlotHits','refch','plotch','fcut','ChNames','Kill');

%%                                                         Get data for GUI
[hp,hax,hplt,hui,hf]=impactGUI(ChNames,RefName);% Get handles for the plot areas

%%                           Get the handle to the memmapfile and some data
while ~exist(FileName,'file') pause(0.1),end
pause(1);% Let some time pass so that the memmapfile can be set up nicely
[MMF{1},Iret]=GetDoubleFromFile(1);
BlocksRead=0;
while BlocksRead==0
  [BlocksAvail,Clock0,SizeData]=GetDoubleFromFile(MMF{1});
  BlocksRead=BlocksAvail;MaxNoBlocks=SizeData(1);
end  
[Dread,Iret]=GetDoubleFromFile(MMF{1},1:BlocksAvail);
dt=diff(Dread(end,1:2,1));
%fs=1/dt;
PreSamples=floor(PreTime/dt);
PostSamples=PreSamples;
FadeSamples=floor(FadeTime/dt);
WindowSamples=ceil(WindowTime/dt);

%%                                                       Make room for data
mData=SizeData(2);
BlockNt=SizeData(3);
Data=zeros(mData,BlockNt,SizeData(1));
Data(:,:,1:BlocksRead)=Dread;

%%                                  Call to procedure that collects impacts
MMF{2}=PassDoubleThruFile(2,[12 mData (FadeSamples+PreSamples) 1]);
strt='cmd /c start /min matlab -nosplash -nodesktop -minimize -r "PlotHitsPre;"';
dos(strt);

%%                                                          Countdown timer
WB=waitbar(1,'Countdown Timer');
WBpos=get(WB,'Position');WBpos(1:2)=[50 50];set(WB,'Position',WBpos);

%%                                                    Start collecting data
Ylim=[inf -inf];NewHitDetected=false;HitNo=0;HitCrestFactor=CrestFactor;
while 1
  if (BlocksRead>=MaxNoBlocks) || get(hui(1),'Value'),break;end
  
%%                           Load all data that is available at this moment 
  BlocksAvail=GetDoubleFromFile(MMF{1});
  if BlocksAvail>BlocksRead
    [Data(:,:,(BlocksRead+1):BlocksAvail),Iret] = ...
                      GetDoubleFromFile(MMF{1},(BlocksRead+1):BlocksAvail);
    for I=BlocksRead+1:BlocksAvail
      Data(:,:,I)=ChCal*Data(:,:,I);
    end    
    BlocksRead=BlocksAvail;
  end
  waitbar(1-BlocksRead/MaxNoBlocks,WB);
  
%%                                                 Look for training impact 
  if TrainHitFound,set(hui(2),'Value',0);end
  TrainImpactClock=get(hui(2),'Userdata');
  if ~isempty(TrainImpactClock)
    if isempty(indTrainHit)
      y=Data(refch,:,:);y=y(:);
      ind1=floor(etime(TrainImpactClock,Clock0)/dt);
      ind1=max([ind1 1]);ind2=floor(etime(clock,Clock0)/dt);
      if rmsnoise<0; % Get noise rms from times before training impact
        rmsnoise=rms(y(1:ind1));
      end
      y(1:ind1)=0;
      if any(abs(y(ind1:ind2))>CrestFactor*rmsnoise)
        [HitCrestFactor,indmx]=max(abs(y(1:ind2))/rmsnoise);
      else indmx=[];
      end
      if ~isempty(indmx)
        TrainHitFound=true;
        indTrainHit=indmx(1);indLastHit=indTrainHit;
        FeedbackString=get(hui(5),'String');
        FeedbackString{end+1}=sprintf('Training impact detected.');
        set(hui(5),'String',FeedbackString);
        set(hui(2),'Value',0);% Deactivate training clock
        set(hui(2),'Userdata',[]);% Deactivate training clock
      end  
    end
  end  

%%                                    Don't collect before training is made  
  if get(hui(3),'Value') && (HitCrestFactor==CrestFactor)
    FeedbackString=get(hui(5),'String');
    FeedbackString{end+1}=sprintf('No training done yet!');
    set(hui(5),'String',FeedbackString);set(hui(3),'Value',false);
  end
      
%%                                                             Collect hits  
  if TrainHitFound && ~NewHitDetected && get(hui(3),'Value')
    yref=Data(refch,:,1:BlocksRead);yref=yref(:);
    yref(1:(indLastHit+PostSamples))=0;
    indHits=find(abs(yref)>CFm*HitCrestFactor*rmsnoise);
    if ~isempty(indHits)
      NewHitDetected=true;indHits=indHits(1);
    end
  end  
    
  if NewHitDetected;%  If collecting impacts
    t=Data(end,:,1:BlocksRead);t=t(:);
    yref=Data(refch,:,1:BlocksRead);yref=yref(:);
    pltch=max([1 get(hui(4),'Value')-1]);
    yplt=Data(pltch,:,1:BlocksRead);yplt=yplt(:);
                                                    
    if BlocksRead*BlockNt<indHits+FadeSamples
      HitEndSample=BlocksRead*BlockNt;
      set(hp(1),'Back',[1 0 0],'Title','DON''T HIT AGAIN RIGHT NOW!');
      set(hui(6),'Back',[1 0 0]);
    else
      HitNo=HitNo+1;HitEndSample=indHits+FadeSamples;
      indLastHit=HitEndSample;
      NewHitDetected=false;
      delete(hdh);hdh=[];
      Ytmp=reshape(Data(:,:,1:BlocksRead),mData,BlockNt*BlocksRead);
      Ytmp=Ytmp(:,(indHits-PreSamples+1):(indHits+FadeSamples));
      Ytmp=WindowY(Ytmp,refch,PreSamples,WindowSamples);
      PassDoubleThruFile(MMF{2},Ytmp(:),HitNo);      
      FeedbackString=get(hui(5),'String');
      Nstrings=length(FeedbackString);
      FeedbackString{Nstrings+1}=sprintf(['Hit ' int2str(HitNo) ' detected.']);
      set(hui(5),'String',FeedbackString,'Value',Nstrings+1);
      set(hp(1),'Back',[.5 1 .5],'Title','Data Film');
      set(hui(6),'Back',[.5 1 .5]);
    end
    ind=(indHits-PreSamples):HitEndSample;
    hplt(2).XData=t(ind);hplt(2).YData=yref(ind);
    hax(2).XLim=[t(ind(1)) t(ind(end))];
    htit=get(hax(2),'Title');
    htit.String=ChNames(refch);htit.FontName='Times';htit.FontWeight='normal';
    htit.Position=[mean(hax(2).XLim) hax(2).YLim(1)];
    hax(2).XGrid='on';hax(2).YGrid='on';
        
    hplt(3).XData=t(ind);hplt(3).YData=yplt(ind);
    hax(3).XLim=hax(2).XLim;
    htit=get(hax(3),'Title');htit.FontName='Times';htit.FontWeight='normal';
    htit.String=ChNames(pltch);
    htit.Position=[mean(hax(3).XLim) hax(3).YLim(1)];
    hax(3).XGrid='on';hax(3).YGrid='on';
  end
      
%%                                  Plot data up to point of accepted delay  
  Tnow=etime(clock,Clock0);Tavail=BlocksRead*BlockNt*dt;
  ind=ceil((Tnow-Tdelay-Twindow)/dt):floor(Tavail/dt);
  y=Data(refch,:,:);y=y(:);t=Data(  end,:,:);t=t(:);
  if isempty(ind)
    disp('No more blocks to read. Returning.'),break
  elseif ind(end)>length(t)
    disp('No more blocks to read. Returning.'),break
  end  
  try
    Ylim=fpsplot(hax(1),t(ind),y(ind),Ylim,fps,Twindow);
  catch
  end  
  
   
end  

close(hf);
delete(WB);

%%                                             Get the selected impact data
HD=helpdlg(['Select/unselect data by left-click in colored fields. You ' ...
         'may also watch the data from various channels by left-click ' ...
         'on the data axes. When that is done, select Terminate from'...
         ' the menu bar.'],...
         'Data Selection');
HDpos=get(HD,'Position');set(HD,'Position',[50 50 HDpos(3:4)]);       
Kill=true;save('Data4PlotHits','Kill','-append');pause(5)
Kill=false;save('Data4PlotHits','Kill','-append');
TSCc=PlotHitsPost;
% TSC=TSCc{1};
TSC=TSCc;

%%                                          Estimate the transfer functions
TStot=TSC{1};
for I=2:length(TSC), TStot=TStot+TSC{I};end
t=TStot.Time;dt=t(2)-t(1);
Y=squeeze(TStot.Data);
[nY nt]=size(Y);indy=setdiff([1:nY],refch);
u=Y(refch,:);Y=Y(indy,:);
for I=1:length(indy)
  [FRF(I,1,:),f] = tfestimate(u,Y(I,:),nt,0,nt,1/dt);  
end
indf=find(f<=fcut);
FRD=frd(FRF(:,:,indf),2*pi*f(indf));

function Y=WindowY(Y,refch,PreSamples,WindowSamples);
[ny,my]=size(Y);
W=zeros(1,my);
W(1:(PreSamples+WindowSamples))=1;
W((PreSamples+WindowSamples):(PreSamples+2*WindowSamples-1))=...
    (1+cos(pi*(1:WindowSamples)/WindowSamples))/2;
Y(refch,:)=W.*Y(refch,:);
