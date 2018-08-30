function ScopeFeedl = startOscilloscope(hObject, eventdata, handles)

global ScopeFeed
dataOut=[];

%%
handles.startButton.String='Stop oscilloscope';
handles.startButton.BackgroundColor=[1 0 0];
handles.startButton.UserData=6;% Tells that oscilloscope is running
handles.startButton.Value=0;
ScopeFeed.startButton=handles.startButton;
ScopeFeed.statusStr=handles.statusStr;

%%                                                       Initiate the test setup
oscillo = startInitialisation(hObject, eventdata, handles);
ScopeFeed.oscillo=oscillo;
CH = oscillo.channelInfo;
ical = {handles.channelsTable.Data{:,11}}; 
ScopeFeed.ical = diag(cell2mat(ical(CH.active))');
Fs = oscillo.session.Rate;
if oscillo.channelInfo.ao
  tid=[1:Fs]/Fs; AOdata=0*tid; AOcount=1; Sinusoidal=false;
  Hao=Stimulus; HaoStruct=guidata(Hao);
  Hao.Visible='off';
  SC=get(0,'ScreenSize');
  Pos=Hao.Position; Cww=Pos(3); Cwh=Pos(4);
  Hao.Position=[25 SC(4)-Cwh-600 Cww Cwh];
  ScopeFeed.Hao=Hao;
end    
    
%%                                              Initiate data transfer file
FileName=[tempdir 'DataContainer1.mat'];
if exist(FileName,'file')
  delete(FileName);
  NoAttempts=100;Attempts=0;
  while exist(FileName,'file') && Attempts<NoAttempts
    Attempts=Attempts+1;
    pause(0.1);
  end  
  if Attempts>=NoAttempts
    error('Could not continue because of file lockup. Try a "clear all" at the command prompt >> and try again', ...
            'Impact test file lockup')
  end  
end
% pause(5)

ChLabels=oscillo.Metadata.Sensor.Label;
save(fullfile(tempdir,'abraScope'),'ChLabels');

%%                                           Do if there are channels in session
if (~isempty(oscillo.session.Channels))        
  oscillo.eventListener = addlistener(oscillo.session, 'DataAvailable', @oscilloscopeFeed);
  oscillo.errListener = addlistener(oscillo.session,'ErrorOccurred',@(src,event) disp(getReport(event.Error)));
  if oscillo.channelInfo.ao
    oscillo.session.queueOutputData(AOdata(:));
    oscillo.dataReqListener = addlistener(oscillo.session, 'DataRequired', @oscilloscopeAO);
  end    
  ScopeFeed.startButton=handles.startButton;
  Rate=oscillo.session.Rate;
  Nch=length(oscillo.session.Channels)-oscillo.channelInfo.ao;
  Nscans=oscillo.session.NotifyWhenDataAvailableExceeds;
  Nblocks=ceil(30*Rate/Nscans);% Allow for 30s data in MMF file
  Size=[Nblocks Nch Nscans 1];
  ScopeFeed.MMF=PassDoubleThruFile(1,Size);% Initiate MMF
  ScopeFeed.I=1;

%%                                  Start obtaining data from DAQ
  prepare(oscillo.session);
  startBackground(oscillo.session);
  
%%                                  Start oscilloscope in another Matlab process
  strt=['cmd /c start /min matlab -nosplash -nodesktop -minimize -r "abraSCOPE(' num2str(Rate) ',1)"'];
  dos(strt);
 
  pause(10)   
  Hao.Visible='on';
  
else
  handles.startButton.String='Start measurement';
  handles.startButton.BackgroundColor=[0 1 0];
  handles.startButton.UserData=0;
  return
end
    
ScopeFeedl=ScopeFeed;

function oscilloscopeAO(src, event)
  persistent Amp Freq 
  
  if HaoStruct.Activate.UserData
    HaoStruct.Activate.UserData=0;
    if HaoStruct.Quiet.Value
      AOdata=0*AOdata;
      Sinusoidal=false;
    elseif HaoStruct.Sinusoidal.Value
      Amp=0.05;
      Freq=str2double(HaoStruct.Frequency.String);
      Sinusoidal=true;
    elseif HaoStruct.Periodic.Value
      Amp=0.05;
      T=str2double(HaoStruct.PeriodT.String);
      t=[1:Fs*T]/Fs;
      AOdata=eval(HaoStruct.PeriodicFcn.String);
      AOdata=Amp*AOdata/norm(AOdata,'inf');
      Sinusoidal=false;
    end    
  end
  if Sinusoidal
    t=tid+AOcount;
    AOdata=Amp*sin(2*pi*Freq*t);
  end    
  src.queueOutputData(AOdata(:));
  AOcount=AOcount+1;
end

end
