function abraDAQterm(TSsys,FRDsys)
[hf,hui]=terminalGUI(TSsys,FRDsys);
while 1
  if get(hui(31),'Value'),break,end
  pause(.1)
end

%%                                                   Plot time series data?
if get(hui(11),'Value')
  htsf=figure;
  set(htsf,'NumberTitle','off','Name','abraDAQ - Timeseries Plot');
  try plot(TSsys),catch, close(htsf);end
end  

%%                                                  Plot FRF with bodeplot?
if get(hui(12),'Value')
  w=FRDsys.Frequency;f0=w(1)/2/pi;f1=w(end)/2/pi;
  BO=bodeoptions;
  BO.FreqUnits='Hz';
  BO.FreqScale='linear';
  BO.PhaseVisible='off';
  BO.XLim=[f0 f1];
  hbf=figure;set(hbf,'NumberTitle','off','Name','abraDAQ - Bode Plot');
  try bodeplot(FRDsys,BO),catch, end
  if isfield(FRDsys.UserData,'Coherence')
    helpdlg(['This FRD object contains estimation coherence data. For ' ...
              'visualization: try plotting these with the magphase function.'])
  end  
end

%%                                                  Plot FRF with magphase?
if get(hui(13),'Value')
  w=FRDsys.Frequency;f0=w(1)/2/pi;f1=w(end)/2/pi;
  hmpf=figure;set(hmpf,'NumberTitle','off','Name','abraDAQ - Magnitude/phase Plot');
  try magphase([1 1;f0 f1],FRDsys),catch, end
end  

%%                                                     Convert to mobility?
if get(hui(21),'Value')
  w=FRDsys.Frequency;
  Hacc=FRDsys.ResponseData;
  for I=1:length(w)
    Hmob(:,:,I)=Hacc(:,:,I)/(1i*w(I));
    Hrec(:,:,I)=Hmob(:,:,I)/(1i*w(I));
  end
  FRDmob=frd(Hmob,w);
  FRDrec=frd(Hrec,w);
  assignin('base','FRDmob',FRDmob);
  assignin('base','FRDrec',FRDrec);  
  disp('Mobility and receptance data now available as FRDmob and FRDrec')
end

%%                                                     Write UFF?
if get(hui(22),'Value')
  disp('Sorry. Not implemeneted yet!')
end

%%                                                     Generate report?
if get(hui(23),'Value')
  disp('Sorry. Not implemeneted yet!')
end

%%                                                     Start ident?
if get(hui(24),'Value')
  updateSID(FRDsys);
  systemIdentification('abraDaq.sid');
  helpdlg(['Click on the FRD object to activate and see its Frequency function.'])
end

close(hf)


function [hf,hui]=terminalGUI(TS,FRD)
MonPos=get(0,'MonitorPositions');
FigPos=[10 MonPos(1,4)-500 320 280];
hf=figure('Position',FigPos);
set(hf,'Menu','none','Name','abraDAQ - Terminal GUI','NumberTitle','off',...
       'SizeChangedFcn',@sc);
%%                                                                     Menu     
hm=uimenu('Label','Help');
uimenu(hm,'Label','About');
hp(1)=uipanel(hf);set(hp(1),'Position',[0 .65 1 .35],'Title','Visualization')
hui(11)=uicontrol('Parent',hp(1),'Style','Check','String','Plot time series data',...
  'Position',[8 57 300 20],'BackgroundColor',[.9 .9 .9]);
if isempty(TS),set(hui(11),'enable','off');end
hui(12)=uicontrol('Parent',hp(1),'Style','Check','String','Plot frequency response data using bodeplot',...
  'Position',[8 35 300 20],'BackgroundColor',[.9 .9 .9]);
if isempty(FRD),set(hui(12),'enable','off');end
hui(13)=uicontrol('Parent',hp(1),'Style','Check','String','Plot frequency response data using magphase',...
  'Position',[8 13 300 20],'BackgroundColor',[.9 .9 .9]);
if isempty(FRD),set(hui(13),'enable','off');end

hp(2)=uipanel(hf);set(hp(2),'Position',[0 .20 1 .45],'Title','Data Processing')
hui(21)=uicontrol('Parent',hp(2),'Style','Check','String','Convert to mobility and receptance',...
  'Position',[8 82 300 20],'BackgroundColor',[.9 .9 .9]);
hui(22)=uicontrol('Parent',hp(2),'Style','Check','String','Write Universal file (UFF)',...
  'Position',[8 60 300 20],'BackgroundColor',[.9 .9 .9]);
if ~exist('writeuff','file'),set(hui(22),'enable','off');end
hui(23)=uicontrol('Parent',hp(2),'Style','Check','String','Autogenerate report',...
  'Position',[8 38 300 20],'BackgroundColor',[.9 .9 .9]);
if ~exist('rptconvert','file'),set(hui(23),'enable','off');end
set(hui(23),'enable','off');
hui(24)=uicontrol('Parent',hp(2),'Style','Check','String','Start ident TB',...
  'Position',[8 16 300 20],'BackgroundColor',[.9 .9 .9]);
if ~exist('ident','file'),set(hui(24),'enable','off');end

hp(3)=uipanel(hf);set(hp(3),'Position',[0 .0 1 .20],'Title','Terminate')
hui(31)=uicontrol('Parent',hp(3),'Style','Radio','String','Leave abraDAQ',...
  'Position',[8 15 300 20],'BackgroundColor',[.9 .9 .9]);


%% ========================================================================
function sc(source,callbackdata)
sz=get(source,'Position');
set(source,'Position',[sz(1) sz(2) 320 420]);

%% ========================================================================
function updateSID(FRD)
load('abraDAQ.sid','-mat');
FRD=idfrd(FRD);
FRD.Utility.axinfo=[1 0.0389 0.7594 0.0973 0.0984 0 0 1];
Data{1}=FRD;
save abraDAQ.sid -mat