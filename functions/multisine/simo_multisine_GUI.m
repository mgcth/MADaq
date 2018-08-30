function simo_multisine_GUI
%SIMO_MULTISINE_GUI
%Inputs:
%Output:
%Call:

%Copyleft: 2014-12-15, Thomas Abrahamsson, Chalmers University of Technology

dbstop error
% keyboard
% Speed
set(0, 'DefaultFigureRenderer', 'OpenGL'); % breaks EPS save


% Initialise
% MMF{2} = GetDoubleFromFile(2); % Freqs
% MMF{3} = GetDoubleFromFile(3); % ny
% MMF{4} = GetDoubleFromFile(4); % indf
% MMF{5} = GetDoubleFromFile(5); % H real
% MMF{6} = GetDoubleFromFile(6); % H imag
% MMF{7} = GetDoubleFromFile(7); % C
MMF2=GetDoubleFromFile(2);% For re(H), im(H), indf and C
MMF2.Writable=true;
PassDoubleThruFile(MMF2,uint8(0));% Set MMF into normal state
MMF2.Writable=false;


%%                                                    Get data from main process
Container0=[tempdir,'DataContainer00'];
Data = load(Container0,'channelLabels'); channelLabels = Data.channelLabels;
% f = GetDoubleFromFile(MMF{2},1);
% ny = GetDoubleFromFile(MMF{3},1);
Data = load(Container0,'Freqs'); f=Data.Freqs;
Data = load(Container0,'ny'); ny=Data.ny;
% indf = GetDoubleFromFile(MMF{4},1);
indfMat=GetDoubleFromFile(MMF2,3); indf=squeeze(indfMat(1,1,:));

% MMF1=PassDoubleThruFile(1,[1 1 1 1]); % initialise
% readPass = 1; % pass true
% PassDoubleThruFile(MMF1,readPass,1); % pass data
% pause(5) % wait so that first data is sent!

% firstPass = 1; indfOld = 1;

%%                        Create a FRD object that will be filled in the process
nf = length(f);
H = NaN * zeros(ny-1,1,nf);
FRD = frd(H,2*pi*f);

%%                                                                    Set up GUI
global statGUIg
statGUIg.workdone=false;
try
    figure(statGUIg.fh);
    statGUIg.yseth=figure('Visible','off');
    statGUIg.ax=[];
catch
    statGUIg.fh=figure;
    statGUIg.Pos=get(gcf,'Pos');statGUIg.Pos(1:2)=0;
    set(statGUIg.fh,'SizeChangedFcn', ...
      'global statGUIg;Pos=get(statGUIg.fh,''Pos'');minpos=max([Pos;statGUIg.Pos]);set(statGUIg.fh,''Pos'',minpos);')
    statGUIg.hui{1}=uicontrol(statGUIg.fh,'Pos',[1 1 15 15],'Back',[1 0 0]);
    statGUIg.hui{2}=uicontrol(statGUIg.fh,'Pos',[17 0 20 17], ...
                              'Stri','y?','Call','yset;');
    statGUIg.hui{3}=uicontrol(statGUIg.fh,'Style','Check', ...
                              'Pos',[37 0 60 17],'Stri','I''m done');
    statGUIg.yseth=figure('Visible','off');
    statGUIg.ax=[];
    statGUIg.ny=ny;
    statGUIg.channelLabels = channelLabels;
end
while 1
    %keyboard
    %% Get indf, H and C from main process
    if exist('StopTheGUI','var'),quit,end
        pause(0.01)
        try
%             indf = GetDoubleFromFile(MMF{4},1);
%             Hreal = GetDoubleFromFile(MMF{5},1);
%             Himag = GetDoubleFromFile(MMF{6},1);
            
            Hreal=GetDoubleFromFile(MMF2,1);
            Himag=GetDoubleFromFile(MMF2,2);
            indfMat=GetDoubleFromFile(MMF2,3); indf=indfMat(1,:);
            
            H = Hreal + 1i*Himag;
%             C = GetDoubleFromFile(MMF{7},1);
            CMat=GetDoubleFromFile(MMF2,4); C=CMat(1,1);
            FRD.ResponseData(:,1,indf) = H;
%             indfOld = indf;
            statGUI(f,indf,FRD,C);drawnow
        catch
            disp('Waiting for data');
        end
    while 1,if strcmpi(get(statGUIg.yseth,'Visible'),'off'),break;else,pause(0.1);end,end
end
end

%% ========================================================================
function statGUI(f,indf,FRD,C)
global statGUIg
figure(statGUIg.fh);cla;
uid=1;
try, yid=get(statGUIg.hpop,'Value');catch, yid=1;end
opt.hold=false;opt.linlog=false;opt.ls='k';opt.grid=true;
if isempty(statGUIg.ax), opt.ax=[];end
magphase([uid yid;f(1) f(end)],FRD,opt);
subplot(211);
set(gca,'Xlim',[f(1) f(end)]);
line(f(indf),abs(FRD.ResponseData(yid,uid,indf)),'Color','red','Marker','o')
subplot(212);
set(gca,'Xlim',[f(1) f(end)]);
line(f(indf),180*phase(FRD.ResponseData(yid,uid,indf))/pi,'Color','red','Marker','o')


if C>0.999
    set(statGUIg.hui{1},'Back',[0 .7 0]);
elseif C>.98
    set(statGUIg.hui{1},'Back',[1 .7 0]);
else
    set(statGUIg.hui{1},'Back',[.9 0 0]);
end
end

