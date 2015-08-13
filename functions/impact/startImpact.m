function dataOut = startImpact(hObject, eventdata, handles)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015


global ImpactDataRead MMFhit

ImpactDataRead=0;

% Initialaise the test setup
impact = startInitialisation(hObject, eventdata, handles);

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');

ACT=cell2mat(CHdata(:,1));ACTind=find(ACT);ny=length(ACTind);
REF=cell2mat(CHdata(:,2));REFind=find(REF);
refch=find(ACTind==REFind);
ChNames=CHdata(:,4);
ChNames=ChNames(find(ACT));
RefName=ChNames(refch);
ChCal=cell2mat(impact.Metadata.Sensor.Sensitivity);
ChCal=[ChCal 1];% Unity scaling for time

%%                                              Initiate data transfer file
FileName=[tempdir 'DataContainer1.mat'];
if exist(FileName,'file')
  delete(FileName);
  if exist(FileName,'file'),error('File is locked. It may be associated with a memmapfile object. Try to clear that.');end  
end
nt=get(impact.session,'NotifyWhenDataAvailableExceeds');
Nblocks=floor(1e8/(nt*(ny+1)))-1;
MMFhit=PassDoubleThruFile(1,[Nblocks ny+1 nt 1]);

% Check if any channels was added to the session
if ~isempty(impact.session.Channels) && ~isempty(impact.channelInfo.reference)
    % Add listener
    %impact.eventListener = addlistener(impact.session, 'DataAvailable', @(src, event) logData(src, event));
    
    % Start impact
    %impact.session.startForeground();
    
    % Actual impact test                                Initiate and test
    Fs=impact.session.Rate;Ts=1/Fs;
    
%     nRefPoints = eval(get(handles.fun3,'String'));
%     impactsOnRef = eval(get(handles.fun4,'String'));
%     recordTime = eval(get(handles.fun2,'String'));
%     triggerLevel = eval(get(handles.fun5,'String'));
    
    %
    if strcmp(lower(impact.session.Channels(1).ID(1:2)),'ao')
        impact.session.removeChannel(1);
    end
    
%     %
%     nCh = length(impact.channelInfo.active);
%     %impact.session.Rate = 51200; %HÅRDKODAD!!! Är 51200.0001 från excel
%     %Fs = impact.session.Rate;
%     nScans = recordTime*Fs;
%     
%     %
%     iRef = 1;
%     iImpacts = 1;
    
    %%
    



    impact.session.IsContinuous = true;
    lh = impact.session.addlistener('DataAvailable', @GetImpact);
    impact.session.startBackground();
    
%     while (iRef <= nRefPoints)
%         fprintf('Reference point #%u \n',iRef)
%         while iImpacts <= impactsOnRef
%             fprintf('Impact #%u \n',iImpacts)
%             %close all;
%             % Delete old temporary log
%             if(exist('tempLogImpact.mat') == 2)
%                 delete('tempLogImpact.mat');
%             end
%             pause(recordTime)
%             
%             fprintf('Data aquisition started... ')
%             % Wait until the temporary log is created in @GetImpact
%             while 1
%                 if isequal(exist('tempLogImpact.mat'),2)
%                     break
%                 else
%                     pause(0.01);
%                 end
%             end
%             
%             collectedData = load('tempLogImpact.mat');
%             impactData = ImpactFinder(collectedData.data,triggerLevel,nScans);
%             
%             for iCh = 2 : nCh
%                 [FRF,f] = tfestimate(collectedData.data(iCh,:),-collectedData.data(1,:),[],[],[],Fs);
%                 frdsys{1}.REF{iRef}.CH{iCh}(:,iImpacts) = FRF;
%                 subplot(nCh,1,iCh-1);
%                 plot(f,log10(abs(frdsys{1}.REF{iRef}.CH{iCh}(:,iImpacts))));
%                 xlabel('Hz');ylabel('log|Y|');title('FRF estimate Impact hammer')
%                 subplot(nCh,1,nCh);
%                 plot(linspace(0,recordTime,size(impactData(1,:),2)),impactData(1,:),'k');
%             end
%             %         dblHitSearch(loadCellData,hitCriteria,toleranceInt);
%             continueCriteria = input('Redo current node test? (y/n) ');
%             if (continueCriteria == 'y'); end
%             if (continueCriteria == 'n'); iImpacts = iImpacts + 1; end
%         end
%         iRef = iRef + 1;
%         iImpacts = 1;
%     end

    fcut=str2num(impact.Metadata.TestSettings{4,2});
    FadeTime=str2num(impact.Metadata.TestSettings{2,2});
    RefLabel=impact.Metadata.TestSettings{5,2};
    [frdsys,tssys]=ImpactTest(ChNames,ChCal,refch,RefLabel,fcut,FadeTime);
    dataOut{1} = data2WS(2,frdsys,impact);
    dataOut{2} = data2WS(3,tssys,impact);
    
    
    impact.session.stop;
    delete(lh);    
    % Clean-up
    impact.session.release();
    delete(impact.session);
    % Clear DAQ
    daq.reset;
    
    
    set(handles.statusStr, 'String', 'READY!  IDFRD and DAQ data available at workbench.');
    drawnow();
    
else
    errordlg('No channels or no reference.')
    set(handles.statusStr, 'String', 'Measurement aborted.');
    drawnow();
end

