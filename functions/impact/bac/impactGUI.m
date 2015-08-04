function [hp,hax,hplt,hui,hf]=impactGUI(ChNames,RefName)

for I=length(ChNames):-1:1, ChNames{I+1}=ChNames{I};end
ChNames{1}='Select channel to snapshot!';

% close all

MonPos=get(0,'MonitorPositions');MonPos=MonPos(1,:);
FigPos=[10 MonPos(4)-500 560 420];
hf=figure('Position',FigPos);
set(hf,'Menu','none','Name','impactGUI - Monitor','NumberTitle','off',...
       'SizeChangedFcn',@sc);
%%                                                                     Menu     
hm=uimenu('Label','Help');
uimenu(hm,'Label','About');

%%                                                                   Panels
hp(1)=uipanel(hf);set(hp(1),'Position',[0 .2 .5 .8],'Title','Data Film')
hp(2)=uipanel(hf);set(hp(2),'Position',[.5 .2 .5 .8],'Title','Data Snapshot')
hp(3)=uipanel(hf);set(hp(3),'Position',[0 0 .5 .2],'Title','User Commands')
hp(4)=uipanel(hf);set(hp(4),'Position',[.5 0 .5 .2],'Title','Program Feedback')

%% 
uicontrol('Parent',hp(1),'Style','Text','String',RefName,'Position',[100 5 100 15],'HorizontalAlignment','left');

%%                                                            User commands
hui(1)=uicontrol('Parent',hp(3),'Style','Check','String','Stop acquisition',...
  'Position',[8  8 100 20],'BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1]);
hui(2)=uicontrol('Parent',hp(3),'Style','Check','String','Train impact',...
  'Position',[8 28 100 20],'BackgroundColor',[1 1 0],'ForegroundColor',[0 0 0],...
  'Callback',@TrainImpact);
hui(3)=uicontrol('Parent',hp(3),'Style','Check','String','Collect impacts',...
  'Position',[8 48 100 20],'BackgroundColor',[0 1 0],'ForegroundColor',[0 0 0]);
hui(4)=uicontrol('Parent',hp(3),'Style','listbox','String',ChNames,...
  'Position',[117  8 155 60],'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0]);
hui(5)=uicontrol('Parent',hp(4),'Style','listbox','String',[],...
  'Position',[8  8 260 60],'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0]);
hui(6)=uicontrol('Parent',hp(1),'Style','Text','String',RefName,'Position',[100 5 100 15],'HorizontalAlignment','left');
% hui(7)=uicontrol('Parent',hp(1),'Style','Text','String','v','Position',[0 1 5 10]);



hax(1)=axes('Parent',hp(1),'Position',[.1 .1 .85 .85],'FontName','Times');
% g=gca;set(g,'FontName','Times');
hax(2)=axes('Parent',hp(2),'Position',[.1 .57 .85 .40],'FontName','Times');
hax(3)=axes('Parent',hp(2),'Position',[.1 .08 .85 .40],'FontName','Times');
hplt(1)=plot(hax(1),0,0);
hplt(2)=plot(hax(2),0,0);
hplt(3)=plot(hax(3),0,0);


function sc(source,callbackdata)
sz=get(source,'Position');
if (sz(3)<560 | sz(4)<480)
  sz(3:4)=[560 480];
  set(source,'Position',sz);
end

function TrainImpact(source,callbackdata)
set(source,'Userdata',clock);

