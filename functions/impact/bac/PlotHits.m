function vargout=PlotHits(vargin)

% dbstop error

global Y refch plotch dt fcut SetAct ChNames hp Leave TSC hfig

%% Initiate
if nargin>0 opt.Term=true;else opt.Term=false;end
hfig=figure;
SetAct=ones(12,1);
plotch=1;

% if opt.Term
%     opt.Lite=true;
%     PlotHitsLite;
%     opt.Lite=false;
% else
    opt.Lite=false;
% end

%%                                         Load data passed from ImpactTest
load('Data4PlotHits.mat','refch','fcut','ChNames');

%%                                                    Initiate data channel
[MMF,Iret]=GetDoubleFromFile(2);

Leave=false;
NBlocksRead=0;
cl0=clock;
% J=0;
while 1,
%   J=J+1;
  load('Data4PlotHits.mat','Kill');
  if Kill,quit,end
  if Leave,close(hfig),break;end
  try
    if etime(clock,cl0)>2;% Check every 2s
      [NBlocks,~,Size,Iret]=GetDoubleFromFile(MMF);
      for I=NBlocksRead+1:NBlocks
        D=GetDoubleFromFile(MMF,I);
        Y{I}=reshape(D,Size(2),Size(3));
        dt=diff(Y{1}(end,1:2));
      end
%       if (NBlocks>NBlocksRead) && ~opt.Term
      if NBlocks>NBlocksRead
        hax=PlotHitsGUI(Y,opt);
%       elseif J==1 && opt.Term
%         hax=PlotHitsGUI(Y,opt);
      end
      NBlocksRead=NBlocks;
%       if ~(J>1 && opt.Term)
        try
          for I=1:length(Y)
            nt=length(Y{I}(1,:));
            BDFcn=get(hax(I),'ButtonDownFcn');
            plot(hax(I),Y{I}(plotch,:));
            set(hax(I),'XTickLabel',[],'YTickLabel',[],'XLim',[1 nt],'ButtonDownFcn',BDFcn);
%           SetAct(I)=get(get(hax(I),'Parent'),'UserData');
          end
        catch
        end
%       end
      cl0=clock;
    else
      drawnow
      pause(.1)
    end
  catch 
    pause(1)
  end
  try
    apa=get(hfig);% If figure window is deleted, this will cause error
  catch
    quit
  end  
end  

%%                                                     Pack data and return
vargout{1}=TSC;



function hax=PlotHitsGUI(Y,opt)
% close all
global SetAct hp hfig

delete(hfig.Children);

NY=length(Y);
NWcols=2;NWrows=2;
if NY>12
  NWcols=5;NWrows=4;
elseif NY>9
  NWcols=4;NWrows=3;
elseif NY>4
  NWcols=3;NWrows=3;
end  

%%                                                       Open figure window
MonPos=get(0,'MonitorPositions');MonPos=MonPos(1,:);
FigPos=[590 MonPos(4)-500 560 420];
hfig=figure(hfig);
set(hfig,'Position',FigPos);
set(hfig,'Menu','none','Name','impactGUI - Hit Collector','NumberTitle','off',...
       'SizeChangedFcn',@sc);
%%                                                                     Menu     
hm(1)=uimenu('Label','FRF','CallBack',@EstFRF);
hm(2)=uimenu('Label','Help');
  if opt.Lite
      hsm(1)=uimenu(hm(2),'Label','Full Menu','Callback','global hfig;set(hfig,''Menu'',''figure'')');
      hsm(2)=uimenu(hm(2),'Label','About');
  else
      hsm(1)=uimenu(hm(2),'Label','About');
  end    
if opt.Term
  hm(3)=uimenu('Label','Terminate','CallBack',@PackandLeave);
end  

%%                                                                   Panels
IW=0;
for I=1:NWrows
  for J=1:NWcols
    IW=IW+1;
    if IW<=NY
      hp(IW)=uipanel(hfig);
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
    end
  end
end

%%
function ChList(source,callbackdata)
global ChNames hp
hui=uicontrol('Parent',hp(1),'Style','listbox','String',ChNames,...
  'Position',[1 1 155 60],'BackgroundColor',[1 1 1],...
  'ForegroundColor',[0 0 0],'CallBack',@ChSelect);

function ChSelect(source,callbackdata)
global plotch
plotch=get(source,'Value');
delete(source);


%%
function ToggleActive(source,callbackdata)
% hp=get(source,'Parent');
global SetAct
hp=source;
% st=get(hp,'UserData');% Get state
No=get(hp,'UserData');
st=SetAct(No);
if st
  set(hp,'Back',[1 .4 .4]);
%   set(hp,'UserData',false);
  SetAct(No)=0;
else
  set(hp,'Back',[.5 1 .5]);
%   set(hp,'UserData',true);
  SetAct(No)=1;
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
global Y refch plotch dt fcut SetAct
NY=length(Y);
ind=find(SetAct(1:NY));
if ~isempty(ind)
  Ytot=Y{ind(1)};
  for I=2:length(ind);
    Ytot=Ytot+Y{ind(I)};
  end

  [ny,nt]=size(Ytot);
  [FRF,f] = tfestimate(Ytot(refch,:),Ytot(plotch,:),nt,0,nt,1/dt);
  FRD=frd(FRF,2*pi*f);

  figure
  opt.grid=true;
  if fcut<f(2),fcut=f(end);end
  magphase([1 1;0 fcut],FRD,opt); 
end  

%%
function PackandLeave(source,callbackdata)
global Y SetAct Leave TSC

t=Y{1}(end,:);t=t-t(1);
J=0;
for I=1:length(Y)
  if SetAct(I)
    J=J+1;
    TSC{J}=timeseries(Y{I}(1:(end-1),:),t,'Name',['Y' int2str(J)]);
  end  
end
Leave=true;


