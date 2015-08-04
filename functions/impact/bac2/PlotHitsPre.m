function PlotHitsPre
% dbstop at 16 in PlotHitsPre
global Y refch plotch ChNames hp 

%% Initiate
hf=figure;
% plotch=1;
% SetAct=ones(12,1);

%%                                         Load data passed from ImpactTest
load('Data4PlotHits.mat','refch','plotch','fcut','ChNames');

%%                                                    Initiate data channel
[MMF,Iret]=GetDoubleFromFile(2);

NBlocksRead=0;
cl0=clock;
while 1,
  load('Data4PlotHits.mat','Kill');
  if Kill,quit,end
  try
    if etime(clock,cl0)>2;% Check every 2s
      load('Data4PlotHits.mat','plotch');
      NBlocksRead=DoThePlot(hf,MMF,NBlocksRead);
      cl0=clock;
    else drawnow,pause(.5),end
  catch, pause(1),end
  try
    apa=get(hf);% If figure window is deleted, this will cause error
  catch, quit,end  
end  

%% ========================================================================
function NBlocksRead=DoThePlot(hf,MMF,NBlocksRead)
% dbstop at 37 in DoThePlot
global Y refch plotch
[NBlocks,~,Size,Iret]=GetDoubleFromFile(MMF);
for I=NBlocksRead+1:NBlocks
  D=GetDoubleFromFile(MMF,I);
  Y{I}=reshape(D,Size(2),Size(3));
end  
if NBlocks>NBlocksRead
  [hf,hax]=PlotHitsGUI(Y,hf);
end
NBlocksRead=NBlocks;            
for I=1:length(Y)
  try
%     nt=length(Y{I}(1,:));
    hpyy=plotyy(hax(I),Y{I}(end,:)-Y{I}(end,1),Y{I}(plotch,:),Y{I}(end,:)-Y{I}(end,1),Y{I}(refch,:));
    set(hpyy,'XLim',[0 Y{I}(end,end)-Y{I}(end,1)]);
    set(hpyy,'XTickLabel',[],'YTickLabel',[]);
  catch
  end
end




function [hf,hax]=PlotHitsGUI(Y,hf)
global SetAct hp
delete(hf.Children);
NY=length(Y);NWcols=2;NWrows=2;
if NY>12, NWcols=5;NWrows=4;elseif NY>9, NWcols=4;NWrows=3;
elseif NY>4, NWcols=3;NWrows=3;end  

%%                                                       Open figure window
MonPos=get(0,'MonitorPositions');MonPos=MonPos(1,:);
FigPos=[590 MonPos(4)-500 560 420];
hf=figure(hf);
set(hf,'Position',FigPos);
set(hf,'Menu','none','Name','impactGUI - Hit Collector','NumberTitle','off',...
       'SizeChangedFcn',@sc);
%%                                                                     Menu     
% hm(1)=uimenu('Label','FRF','CallBack',@EstFRF);
hm(1)=uimenu('Label','Help');
      uimenu(hm(1),'Label','About');
% if opt.Term
%   hm(3)=uimenu('Label','Terminate','CallBack',@PackandLeave);
% end  

%%                                                                   Panels
IW=0;
for I=1:NWrows
  for J=1:NWcols
    IW=IW+1;
    if IW<=NY
      hp(IW)=uipanel(hf);
      set(hp(IW),'UserData',true,'Position',...
    [(J-1)/NWcols (NWrows-I)/NWrows 1/NWcols 1/NWrows],'Title',int2str(IW));
%   , ...
%     'ButtonDownFcn',@ToggleActive);
%       set(hp(IW),'UserData',IW);
%       if SetAct(IW)
%         set(hp(IW),'Back',[.5 1 .5]);
%       else
%         set(hp(IW),'Back',[1 .4 .4]);
%       end  
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
% function ToggleActive(source,callbackdata)
% global SetAct
% hp=source;
% No=get(hp,'UserData');
% st=SetAct(No);
% if st
%   SetAct(No)=0;set(hp,'Back',[1 .4 .4]);
% else
%   SetAct(No)=1;set(hp,'Back',[.5 1 .5]);
% end

%%
function sc(source,callbackdata)
sz=get(source,'Position');
if (sz(3)<560 | sz(4)<480)
  sz(3:4)=[560 480];
  set(source,'Position',sz);
end
