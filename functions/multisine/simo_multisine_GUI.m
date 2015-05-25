function simo_multisine_GUI
%SIMO_MULTISINE_GUI
%Inputs:
%Output:
%Call:

%Copyleft: 2014-12-15, Thomas Abrahamsson, Chalmers University of Technology

dbstop error

% Speed
set(0, 'DefaultFigureRenderer', 'OpenGL'); % breaks EPS save

%%                                               Get data from main process
instrreset;
u=startUDP('Client');
PassDatagram(u,'ans',1);% Send data to host to show that this client is OK
pause(3);%       Get ready to receive data
ReadDatagram(u);%Now f should be in this function's workspace
ReadDatagram(u);%Now ny should be in this function's workspace

%%                   Create a FRD object that will be filled in the process
nf = length(f);
%H = NaN*zeros(ny,1,nf);
H = NaN * zeros(ny-1,1,nf);
FRD = frd(H,2*pi*f);

%%                                                               Set up GUI
global statGUIg
statGUIg.workdone=false;
try
  figure(statGUIg.fh);
  statGUIg.yseth=figure('Visible','off');
  statGUIg.ax=[];
catch
  statGUIg.fh=figure;
  statGUIg.Pos=get(gcf,'Pos');statGUIg.Pos(1:2)=0;
  set(statGUIg.fh,'SizeChangedFcn','global statGUIg;Pos=get(statGUIg.fh,''Pos'');minpos=max([Pos;statGUIg.Pos]);set(statGUIg.fh,''Pos'',minpos);')
  statGUIg.hui{1}=uicontrol(statGUIg.fh,'Pos',[1 1 15 15],'Back',[1 0 0]);
  statGUIg.hui{2}=uicontrol(statGUIg.fh,'Pos',[17 0 20 17],'Stri','y?','Call','yset;');
  statGUIg.hui{3}=uicontrol(statGUIg.fh,'Style','Check','Pos',[37 0 60 17],'Stri','I''m done');
  statGUIg.yseth=figure('Visible','off');
  statGUIg.ax=[];
  statGUIg.ny=ny;
end
%keyboard
while 1
    %keyboard
%% Get indf, H and C from main process
  if exist('StopTheGUI','var'),quit,end
  if u.BytesAvailable>0
    pause(0.1)
    try
      ReadDatagram(u)% indf should be passed to workspace
      ReadDatagram(u)% Hr=real(H) should be passed to workspace
      ReadDatagram(u)% Hi=imag(H) should be passed to workspace
      ReadDatagram(u)% C should be passed to workspace
      H=Hr+1i*Hi;
      FRD.ResponseData(:,1,indf)=H;
    catch
    end 
    statGUI(f(indf),indf,H,FRD,C);drawnow
  end
  while 1,if strcmpi(get(statGUIg.yseth,'Visible'),'off'),break;else,pause(0.1);end,end
end

%% ========================================================================
function statGUI(f,indf,H,FRD,C)
global statGUIg
figure(statGUIg.fh);cla;
uid=1;
try, yid=get(statGUIg.hpop,'Value');catch, yid=1;end   
opt.hold=false;opt.linlog=false;opt.ls='k';opt.grid=true;
if isempty(statGUIg.ax), opt.ax=[];end
%keyboard
magphase([uid yid;f(1) f(end)],FRD,opt);
subplot(211);opt.ax=axis;statGUIg.ax=opt.ax;

if all(isnan(FRD.ResponseData(:)));opt.ax=[];end
opt.hold=true;opt.ls='r.';opt.grid=true;
%magphase(f,squeeze(H(yid,uid,:)),opt);
magphase(f,squeeze(FRD.ResponseData(yid,uid,indf)),opt);
subplot(211),title(['u1->y' int2str(yid)])

if C>0.999
  set(statGUIg.hui{1},'Back',[0 .7 0]);
elseif C>.98
  set(statGUIg.hui{1},'Back',[1 .7 0]);
else
  set(statGUIg.hui{1},'Back',[.9 0 0]);
end  
