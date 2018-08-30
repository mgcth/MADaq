function phh=PlotHits(Y,ch1,ch2)
persistent HitW
if isempty(HitW)
  [HitW.hf,HitW.hax]=PlotHitsGUI;
end    
for I=1:length(Y)
    y1=Y{I}(ch1,:);y1=y1/norm(y1,'inf');
    y2=Y{I}(ch2,:);y2=y2/norm(y2,'inf');
    t=0:length(y1)-1;
    hp=plot(HitW.hax(I),t,y1,t,y2);
    set(HitW.hax(I),'XLim',[0 t(end)]);
    set(HitW.hax(I),'XTickLabel',[],'YTickLabel',[]);
end
phh=HitW.hf;
end

function [hf,hax]=PlotHitsGUI
%%                                                       Open figure window
MonPos=get(0,'MonitorPositions');MonPos=MonPos(1,:);
FigPos=[590 MonPos(4)-500 560 420];
hf=figure;
set(hf,'Position',FigPos);
set(hf,'Menu','none','Name','Hit Collector','NumberTitle','off');

%%                                                                   Panels
IW=0;
NWcols=5;NWrows=4;
for I=1:NWrows
  for J=1:NWcols
    IW=IW+1;
%     if IW<=NY
      hp(IW)=uipanel(hf);
      set(hp(IW),'UserData',true,'Position',...
    [(J-1)/NWcols (NWrows-I)/NWrows 1/NWcols 1/NWrows],'Title',int2str(IW));
      hax(IW)=axes('Parent',hp(IW),'Position',[.1 .1 .85 .85],...
           'XtickLabel','','YtickLabel','');
%     end
  end
end
end
