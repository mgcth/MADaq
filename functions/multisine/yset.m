%% ========================================================================
function yset
global statGUIg
Pos=get(statGUIg.fh,'Pos');
Pos=[Pos(1)+Pos(3)+20 Pos(2) 150 70];
statGUIg.yseth=figure('Pos',Pos);
set(statGUIg.yseth,'MenuBar','none','NumberTitle','off');
set(statGUIg.yseth,'CloseRequestFcn','global statGUIg,set(statGUIg.yseth,''Visible'',''off'');');

for I=1:statGUIg.ny-1,S{I}=[statGUIg.channelLabels{I+1}];end
ht=uicontrol(statGUIg.yseth,'Pos',[20 35 120 30],'Style','Text','String','Select Output Channel');
statGUIg.hpop=uicontrol(statGUIg.yseth,'Pos',[30 10 100 30]);
set(statGUIg.hpop,'Style','popup','String',S);
set(statGUIg.hpop,'Call','global statGUIg; statGUIg.ax=[];set(statGUIg.yseth,''Visible'',''off'');if statGUIg.workdone,plotFRD;end');

