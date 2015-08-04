function [FRDout,TSout]=PlotHitsPost
% dbstop error
global Y refch plotch fcut SetAct ChNames hp Leave TS FRD
global GCA
WS=warning;warning('off');
TS=[];

%% Initiate
hf=figure('CloseRequestFcn',@PackAndLeave);
% set(zoom(hf),'ActionPostCallback','disp(''hej'')');
set(zoom(hf),'ActionPostCallback','global GCA,GCA=gca;');
GCA=[];

SetAct=ones(12,1);

%%                                         Load data passed from ImpactTest
load('Data4PlotHits.mat','refch','plotch','fcut','ChNames');

%%                                                    Initiate data channel
[MMF,Iret]=GetDoubleFromFile(2);

%%                                             Plot and wait for Leave=true
DoPostPlot(hf,MMF);
Leave=false;
while 1,
  pause(1)
  if Leave
%     close(hf),
    break
  end
  if ~isempty(GCA),RefreshPlot2(GCA);GCA=[];tic,end
  if strcmpi(get(zoom(hf),'Enable'),'off'), RefreshPlot;end
end

FRDout=FRD;
TSout=TS;
warning(WS);


%% ========================================================================
function DoPostPlot(hf,MMF)
global Y refch plotch hpyy hax
[NBlocks,~,Size,Iret]=GetDoubleFromFile(MMF);
for I=1:NBlocks
  D=GetDoubleFromFile(MMF,I);
  Y{I}=reshape(D,Size(2),Size(3));
end  
[hf,hax]=PostPlotHitsGUI(Y,hf);
try
  for I=1:length(Y)  
    hpyy{I}=plotyy(hax(I),Y{I}(end,:)-Y{I}(end,1),Y{I}(plotch,:),Y{I}(end,:)-Y{I}(end,1),Y{I}(refch,:));
    set(hpyy{I},'XLim',[0 Y{I}(end,end)-Y{I}(end,1)]);
    set(hpyy{I},'ButtonDownFcn',@ChList);
  end
catch
end

%% ========================================================================
function RefreshPlot
global Y refch plotch hpyy hax
for I=1:length(Y)  
  hpyy{I}=plotyy(hax(I),Y{I}(end,:)-Y{I}(end,1),Y{I}(plotch,:),Y{I}(end,:)-Y{I}(end,1),Y{I}(refch,:));
  set(hpyy{I},'XLim',[0 Y{I}(end,end)-Y{I}(end,1)]);
  set(hpyy{I},'ButtonDownFcn',@ChList);
end

%% ========================================================================
function RefreshPlot2(GCA)
global Y refch plotch hpyy hax
XLim=get(GCA,'XLim');YLim=get(GCA,'YLim');
for I=1:length(Y)  
  hpyy{I}=plot(hax(I),Y{I}(end,:)-Y{I}(end,1),Y{I}(plotch,:));
  set(hax(I),'XLim',XLim,'YLim',YLim);
  set(hpyy{I},'ButtonDownFcn',@ChList);
end


%% ========================================================================
function [hf,hax]=PostPlotHitsGUI(Y,hf)
global SetAct hp
NY=length(Y);NWcols=2;NWrows=2;
if NY>12, NWcols=5;NWrows=4;elseif NY>9, NWcols=4;NWrows=3;
elseif NY>6, NWcols=3;NWrows=3;elseif NY>4, NWcols=3;NWrows=2;end  

%%                                                       Open figure window
MonPos=get(0,'MonitorPositions');MonPos=MonPos(1,:);
FigPos=[590 MonPos(4)-500 560 420];
hf=figure(hf);
set(hf,'Position',FigPos);
set(hf,'Name','impactGUI - Hit Selector','NumberTitle','off',...
       'SizeChangedFcn',@sc);
%%                                                                     Menu     
hm(1)=uimenu('Label','Estimate FRF','CallBack',@EstFRF);

%%                                                                   Panels
IW=0;
for I=1:NWrows
  for J=1:NWcols
    IW=IW+1;
    if IW<=NY
      hp(IW)=uipanel(hf);
      set(hp(IW),'UserData',true,'Position',...
    [(J-1)/NWcols (NWrows-I)/NWrows 1/NWcols 1/NWrows],'Title',int2str(IW), ...
    'ButtonDownFcn',@ToggleActive);
      set(hp(IW),'UserData',IW);
      if SetAct(IW)
        set(hp(IW),'Back',[.5 1 .5]);
      else
        set(hp(IW),'Back',[1 .4 .4]);
      end  
      hax(IW)=axes('Parent',hp(IW),'Position',[.1 .1 .85 .85],...
           'XtickLabel','','YtickLabel','','ButtonDownFcn',@ChList);
%       set(zoom(hax(IW)),'ActionPostCallback',@(x,y) myCBF(ax));
    end
  end
end

function myCBF(varargin)
N=nargin

%%
function ChList(source,callbackdata)
global ChNames hp
hui=uicontrol('Parent',hp(1),'Style','listbox','String',ChNames,...
  'Position',[1 1 155 60],'BackgroundColor',[1 1 1],...
  'ForegroundColor',[0 0 0],'CallBack',@ChSelect);

function ChSelect(source,callbackdata)
global plotch
plotch=get(source,'Value');
RefreshPlot;
delete(source);


%%
function ToggleActive(source,callbackdata)
global SetAct
hp=source;
No=get(hp,'UserData');
st=SetAct(No);
if st
  SetAct(No)=0;set(hp,'Back',[1 .4 .4]);
else
  SetAct(No)=1;set(hp,'Back',[.5 1 .5]);
end

%%
function sc(source,callbackdata)
sz=get(source,'Position');
if (sz(3)<560 | sz(4)<480)
  sz(3:4)=[560 480];
  set(source,'Position',sz);
end

%%
function EstFRF(source,callbackdata)
global Y refch plotch fcut SetAct ChNames
NY=length(Y);
dt=diff(Y{1}(end,1:2));
ind=find(SetAct(1:NY));
if ~isempty(ind)
  Ytot=Y{ind(1)};
  for I=2:length(ind);
    Ytot=Ytot+Y{ind(I)};
  end

  [ny,nt]=size(Ytot);
  [FRF,f] = tfestimate(Ytot(refch,:),Ytot(plotch,:),nt,0,nt,1/dt);
  FRD=frd(FRF,2*pi*f);

  hffrf=figure;
  set(hffrf,'NumberTitle','off','Name','impactGUI - FRF plot');
  opt.grid=true;
  opt.title=[ChNames{plotch} ' / ' ChNames{refch}];
  if fcut<f(2),fcut=f(end);end
  magphase([1 1;0 fcut],FRD,opt); 
end  

%%
function PackAndLeave(source,callbackdata)
global Y refch fcut SetAct Leave TS FRD

t=Y{1}(end,:);t=t-t(1);dt=t(2)-t(1);
[ny,nt]=size(Y{1}(1:end-1,:));

J=0;ytot=zeros(ny,nt);ylong=[];
for I=1:length(Y)
  if SetAct(I)
    J=J+1;
    yts{J}=timeseries(Y{I}(1:(end-1),:),t,'Name',['Y' int2str(J)]);
    ytot=ytot+Y{I}(1:(end-1),:);
    ylong=[ylong Y{I}(1:(end-1),:)];
  end  
end
TS=timeseries(ytot,t,'Name','Y');
UserDataTS.refch=refch;
UserDataTS.Y=yts;
TS.UserData=UserDataTS;

respch=setdiff(1:ny,refch);

if ~isempty(ytot)
  [F,f] = tfestimate(ytot(refch,:)',ytot(respch,:)',nt,0,nt,1/dt);
  indf=find(f<=fcut);
  FRF(:,1,:)=F(indf,:).';
  FRD=frd(FRF,2*pi*f(indf));
  Cxy = mscohere(ylong(refch,:)',ylong(respch,:)',nt,0,nt,1/dt);
  UserDataFRD.Coherence(:,1,:) = Cxy(indf,:)';
  FRD.UserData=UserDataFRD;
end  

Leave=true;
closereq;
