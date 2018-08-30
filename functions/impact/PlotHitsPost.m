function [FRDout,TSout]=PlotHitsPost(YY,refch,y2ch)
% % dbstop error
% global Y refch plotch fcut SetAct ChNames hp Leave TS FRD
global Impact SetAct GCA Y
Impact.y2ch=y2ch;
% global ImpactTestData
WS=warning;warning('off');
% TS=[]; 

%% Initiate
Impact.hd=figure('MenuBar','none','CloseRequestFcn','PackAndLeave;');
uimenu(Impact.hd,'Label','Done','CallBack','PackAndLeave;')
set(zoom(Impact.hd),'ActionPostCallback','global GCA,GCA=gca;');
GCA=[];
Y=YY;

SetAct=ones(20,1);

%%     ,                                       Plot and wait for Leave=true
hax=DoPostPlot(Impact.hd,YY,refch,y2ch);
Impact.Leave=false;
while 1,
  pause(.5)
  if Impact.Leave
    break
  end
  if ~isempty(GCA),RefreshPlot2(GCA,hax,YY,refch,Impact.y2ch);GCA=[];tic,end
  if strcmpi(get(zoom(Impact.hd),'Enable'),'off'), RefreshPlot(hax,YY,refch,Impact.y2ch);end
end

FRDout=Impact.FRD;
TSout=Impact.TS;
warning(WS);
end

%% ========================================================================
function hax=DoPostPlot(hf,YY,refch,y2ch)
% global Y refch plotch hpyy hax

[~,hax]=PostPlotHitsGUI(YY,hf);
try
  for I=1:length(YY)
    t=YY{I}(end,:)-YY{I}(end,1);
    yp=detrend(YY{I}(y2ch,:)); 
    yp=yp-median(yp); yp=yp/norm(yp,inf);
    yr=YY{I}(refch,:); yr=yr-median(yr); yr=yr/norm(yr,inf);
    plot(hax(I),t,yp,t,yr);
    set(gca,'XLim',[0 t(end)-t(1)]);
    set(gca,'ButtonDownFcn',@ChList);
%     hpyy{I}=plotyy(hax(I),t,yp,t,yr);
%     set(hpyy{I},'XLim',[0 t(end)-t(1)]);
%     set(hpyy{I},'ButtonDownFcn',@ChList);
  end
catch
end
end

%% ========================================================================
function RefreshPlot(hax,Y,refch,plotch)
for I=1:length(Y)
  t=Y{I}(end,:)-Y{I}(end,1);
  yp=detrend(Y{I}(plotch,:)); 
  yp=yp-median(yp); yp=yp/norm(yp,inf);
  yr=Y{I}(refch,:); yr=yr-median(yr); yr=yr/norm(yr,inf);
  plot(hax(I),t,yp,t,yr);
  set(hax(I),'XLim',[0 t(end)-t(1)]);
  set(hax(I),'ButtonDownFcn',@ChList);
%   hpyy{I}=plotyy(hax(I),t,yp,t,yr);
%   set(hpyy{I},'XLim',[0 Y{I}(end,end)-Y{I}(end,1)]);
%   set(hpyy{I},'ButtonDownFcn',@ChList);
end
end

%% ========================================================================
function RefreshPlot2(GCA,hax,Y,refch,plotch)
XLim=get(GCA,'XLim');YLim=get(GCA,'YLim');
for I=1:length(Y)  
  t=Y{I}(end,:)-Y{I}(end,1);
  yp=detrend(Y{I}(plotch,:));
  yp=yp-median(yp); yp=yp/norm(yp,inf);
  yr=Y{I}(refch,:); yr=yr-median(yr); yr=yr/norm(yr,inf);
  plot(hax(I),t,yp,t,yr);
  set(hax(I),'XLim',XLim,'YLim',YLim);
  set(hax(I),'ButtonDownFcn',@ChList);
%     hpyy{I}=plotyy(hax(I),t,yp,t,yr);
%   set(hax(I),'XLim',XLim,'YLim',YLim);
%   set(hpyy{I},'ButtonDownFcn',@ChList);
end
end

%% ========================================================================
function [hf,hax]=PostPlotHitsGUI(Y,hf)
global SetAct hp
NY=length(Y);NWcols=2;NWrows=2;
if NY>16, NWcols=5;NWrows=4;
elseif NY>12, NWcols=4;NWrows=4;
elseif NY>9, NWcols=4;NWrows=3;
elseif NY>6, NWcols=3;NWrows=3;
elseif NY>4, NWcols=3;NWrows=2;end  

%%                                                       Open figure window
MonPos=get(0,'MonitorPositions');MonPos=MonPos(1,:);
FigPos=[590 MonPos(4)-500 560 420];
hf=figure(hf);
set(hf,'Position',FigPos);
set(hf,'Name','Hit Selector','NumberTitle','off',...
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
end

function myCBF(varargin)
N=nargin
end

%%
function ChList(source,callbackdata)
global Impact
ChNames=Impact.Metadata.Sensor.Label;
hui=uicontrol('Parent',gcf,'Style','listbox','String',ChNames,...
  'Position',[10 10 160 80],'BackgroundColor',[1 1 1],...
  'ForegroundColor',[0 0 0],'CallBack',@ChSelect);
end

function ChSelect(source,callbackdata)
global Impact
Impact.y2ch=get(source,'Value');
% RefreshPlot;
delete(source);
end

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
end

%%
function sc(source,callbackdata)
sz=get(source,'Position');
if (sz(3)<560 | sz(4)<480)
  sz(3:4)=[560 480];
  set(source,'Position',sz);
end
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
end

% %%
% function PackAndLeave(source,callbackdata)
% % global Y refch fcut SetAct Leave TS FRD
% global Impact Y SetAct
% 
% Impact.Leave=true;
% close(Impact.hd);
% 
% % while 1
% %   try 
% % %     close(Impact.hd);
% %     closereq;
% %     break;
% %   catch
% %   end
% % end
% 
% %%
% fcut=Impact.fcut;
% refch=Impact.refch;
% t=Y{1}(end,:);t=t-t(1);dt=t(2)-t(1);
% [ny,nt]=size(Y{1}(1:end-1,:));
%     
% %% Align hits
% Mx=max(abs(Y{1}(refch,:))); PWidth=sum(abs(Y{1}(refch,:)>.1*Mx));
% for I=1:length(Y)
%   [~,mxind]=max(abs(Y{I}(refch,:)));
%   Y{I}=circshift(Y{I}',-mxind+PWidth)';
% end  
% 
% J=0;ytot=zeros(ny,nt);ylong=[];
% for I=1:length(Y)
%   if SetAct(I)
%     J=J+1;
%     yts{J}=timeseries(Y{I}(1:(end-1),:),t,'Name',['Y' int2str(J)]);
%     ytot=ytot+Y{I}(1:(end-1),:);
%     ylong=[ylong Y{I}(1:(end-1),:)];
%   end  
% end
% 
% %% Eliminate negative contribution to impact force
% uhit=ytot(refch,:); uhit=uhit-median(uhit);
% maxu=max(uhit); minu=min(uhit);
% if maxu<abs(minu);%% Negative impact pulse
%   uhit(uhit>0)=0;
% else% Positive impact pulse
%   uhit(uhit<0)=0;
% end    
% ytot(refch,:)=uhit;
% 
% TS=timeseries(ytot,t,'Name','Y');
% UserDataTS.refch=refch;
% UserDataTS.Y=yts;
% TS.UserData=UserDataTS;
% 
% respch=setdiff(1:ny,refch);
% 
% %% Window
% W=(2*cos(pi*[0:nt-1]/(nt-1))-1)/2;
% for I=1:ny
%   ytot(I,:)=W.*ytot(I,:);
% end   
% 
% if ~isempty(ytot)
%   [F,f] = tfestimate(ytot(refch,:)',ytot(respch,:)',nt,0,nt,1/dt);
%   indf=find(f<=fcut);
%   FRF(:,1,:)=F(indf,:).';
%   FRD=frd(FRF,2*pi*f(indf));
%   Cxy = mscohere(ylong(refch,:)',ylong(respch,:)',nt,0,nt,1/dt);
%   UserDataFRD.Coherence(:,1,:) = Cxy(indf,:)';
%   FRD.UserData=UserDataFRD;
% end  
% 
% FRD.InputUnit=Impact.Metadata.Sensor.Unit(refch);
% FRD.OutputUnit=Impact.Metadata.Sensor.Unit(respch);
% 
% switch Impact.Metadata.Sensor.Dof{refch}
%   case 'X+'
%     FRD.InputName=[Impact.Metadata.Sensor.Dir{refch} '.1'];
%   case 'X-'
%     FRD.InputName=['-' Impact.Metadata.Sensor.Dir{refch} '.1'];
%   case 'Y+'
%     FRD.InputName=[Impact.Metadata.Sensor.Dir{refch} '.2'];
%   case 'Y-'
%     FRD.InputName=['-' Impact.Metadata.Sensor.Dir{refch} '.2'];
%   case 'Z+'
%     FRD.InputName=[Impact.Metadata.Sensor.Dir{refch} '.3'];
%   case 'Z-'
%     FRD.InputName=['-' Impact.Metadata.Sensor.Dir{refch} '.3'];
%   otherwise
%     FRD.InputName=Impact.Metadata.Sensor.Label(refch);      
% end
% 
% for I=1:length(respch)
%   switch Impact.Metadata.Sensor.Dof{respch(I)}
%     case 'X+'
%       FRD.OutputName{I}=[Impact.Metadata.Sensor.Dir{respch(I)} '.1'];
%     case 'X-'
%       FRD.OutputName{I}=['-' Impact.Metadata.Sensor.Dir{respch(I)} '.1'];
%     case 'Y+'
%       FRD.OutputName{I}=[Impact.Metadata.Sensor.Dir{respch(I)} '.2'];
%     case 'Y-'
%       FRD.OutputName{I}=['-' Impact.Metadata.Sensor.Dir{respch(I)} '.2'];
%     case 'Z+'
%       FRD.OutputName{I}=[Impact.Metadata.Sensor.Dir{respch(I)} '.3'];
%     case 'Z-'
%       FRD.OutputName{I}=['-' Impact.Metadata.Sensor.Dir{respch(I)} '.3'];
%     otherwise
%       FRD.OutputName{I}=char(Impact.Metadata.Sensor.Label(respch(I)));      
%   end
% end    
%     
% Impact.FRD=FRD;
% Impact.TS=TS;
% 
% % Impact.Leave=true;
% % closereq;
% end