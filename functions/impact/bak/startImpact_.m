function dataOut = startImpact(hObject, eventdata, handles)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015


global Impact
% global ImpactDataRead MMFhit

%%
Impact.DataRead=0;

% Initialaise the test setup
set(handles.startButton, 'String', 'Working!','BackGround',[1 0 0]);
impact = startInitialisation(hObject, eventdata, handles);
Impact.session=impact.session;

Impact.startButton=handles.startButton;
Impact.statusStr=handles.statusStr;

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');

ACT=cell2mat(CHdata(:,1));ACTind=find(ACT);ny=length(ACTind);
REF=cell2mat(CHdata(:,2));REFind=find(REF);
try
  refch=find(ACTind==REFind);
catch
  error('No reference channel specified')
end  
ChNames=CHdata(:,4);
ChNames=ChNames(find(ACT));
RefName=ChNames(refch);
ChCal=cell2mat(impact.Metadata.Sensor.Sensitivity);
ChCal=[ChCal 1];% Unity scaling for time

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
nt=get(impact.session,'NotifyWhenDataAvailableExceeds');
Nblocks=floor(1e8/(nt*(ny+1)))-1;
Impact.MMF1=PassDoubleThruFile(1,[Nblocks ny+1 nt 1]);

% Check if any channels was added to the session
if ~isempty(impact.session.Channels) && ~isempty(impact.channelInfo.reference)
    
%%      Actual impact test                                Initiate and test
    impact.session.IsContinuous = true;
    lh = impact.session.addlistener('DataAvailable', @GetImpact);
    startBackground(impact.session);
    
    FCutStr=[impact.Metadata.TestSettings{4,2} '       '];
    if strcmpi(FCutStr(1:7),'default')
      fcut=1000;  
    else    
      fcut=str2double(impact.Metadata.TestSettings{4,2});
    end
    FadeStr=[impact.Metadata.TestSettings{2,2} '       '];
    if strcmpi(FadeStr(1:7),'default')
      FadeTime=20;  
    else    
      FadeTime=str2double(impact.Metadata.TestSettings{2,2});
    end  
    RefLabel=impact.Metadata.TestSettings{5,2};
    [frdsys,tssys]=ImpactTest(ChNames,ChCal,refch,RefLabel,fcut,FadeTime);
    dataOut{1} = data2WS(2,frdsys,impact);
    dataOut{2} = data2WS(3,tssys,impact);
    
    
 %%           Clean-up
    impact.session.stop;
    delete(lh);    
    impact.session.release();
    delete(impact.session);
    
    % Clear DAQ
    daq.reset;
    
%     set(handles.statusStr, 'String', 'READY!  IDFRD and DAQ data available at workbench.');
    handles.statusStr.String='READY!  IDFRD and DAQ data available at workbench.';
    handles.startButton.String='Start measurement';
    handles.startButton.BackgroundColor=[0 1 0];
    handles.startButton.UserData=0;
    drawnow();
    
else
    errordlg('No channels or no reference.')
    set(handles.statusStr, 'String', 'Measurement aborted.');
    drawnow();
end