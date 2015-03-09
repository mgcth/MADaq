function startImpact(hObject, eventdata, handles)

global DATAcontainer

% Initialaise the test setup
impact = startInitialisation(hObject, eventdata, handles);

impact.session.Rate = eval(get(handles.fun1, 'String')) * 1000;

% Get info about channnels
CHdata = get(handles.channelsTable, 'data');

% Check if any channels was added to the session
if ~isempty(impact.session.Channels) && ~isempty(impact.channelInfo.reference)
    %     % Add listener
    %     impact.eventListener = addlistener(impact.session, 'DataAvailable', @(src, event) logDataTA(src, event));
    %
    %     % Start impact
    %     impact.session.startForeground();
    
    % Actual impact test                                Initiate and test
    Fs=impact.session.Rate;Ts=1/Fs;
    
    nRefPoints = eval(handles.fun3.String);
    impactsOnRef = eval(handles.fun4.String);
    recordTime = eval(handles.fun2.String);
    triggerLevel = eval(handles.fun5.String);
    
    %
    if strcmp(lower(impact.session.Channels(1).ID(1:2)),'ao')
        impact.session.removeChannel(1);
    end
    
    %
    nCh = length(impact.channelInfo.active);
    %impact.session.Rate = 51200; %HÅDKODAD!!! Är 51200.0001 från excel
    %Fs = impact.session.Rate;
    nScans = recordTime*Fs;
    
    %
    iRef = 1;
    iImpacts = 1;
    
    %%
    impact.session.IsContinuous = true;
    lh = impact.session.addlistener('DataAvailable', @GetImpact);
    impact.session.startBackground();
    while (iRef <= nRefPoints)
        fprintf('Reference point #%u \n',iRef)
        while iImpacts <= impactsOnRef
            fprintf('Impact #%u \n',iImpacts)
            %close all;
            % Delete old temporary log
            if(exist('tempLogImpact.mat') == 2)
                delete('tempLogImpact.mat');
            end
            pause(recordTime)
            
            fprintf('Data aquisition started... ')
            % Wait until the temporary log is created in @GetImpact
            while 1
                if isequal(exist('tempLogImpact.mat'),2)
                    break
                else
                    pause(0.01);
                end
            end
            
            collectedData = load('tempLogImpact.mat');
            impactData = ImpactFinder(collectedData.data,triggerLevel,nScans);
            
            for iCh = 2 : nCh
                [FRF,f] = tfestimate(collectedData.data(iCh,:),-collectedData.data(1,:),[],[],[],Fs);
                frdsys{1}.REF{iRef}.CH{iCh}(:,iImpacts) = FRF;
                subplot(nCh,1,iCh-1);
                plot(f,log10(abs(frdsys{1}.REF{iRef}.CH{iCh}(:,iImpacts))));
                xlabel('Hz');ylabel('log|Y|');title('FRF estimate Impact hammer')
                subplot(nCh,1,nCh);
                plot(linspace(0,recordTime,size(impactData(1,:),2)),impactData(1,:),'k');
            end
            %         dblHitSearch(loadCellData,hitCriteria,toleranceInt);
            continueCriteria = input('Redo current node test? (y/n) ');
            if (continueCriteria == 'y'); end
            if (continueCriteria == 'n'); iImpacts = iImpacts + 1; end
        end
        iRef = iRef + 1;
        iImpacts = 1;
    end
    impact.session.stop;
    delete(lh);
    
    frdsys{2}.FREQ= f;
    frdsys{3}.IMPULSE= collectedData.data(1,:);
    
    
    % Make IDFRD data object
    frdsys=frd(FRF,2*pi*f,'FrequencyUnit','rad/s');
    frdsys=idfrd(frdsys);
    frdsys.UserData.MeasurementDate = datestr(now,'mm-dd-yyyy HH:MM:SS');
    
    % Clean-up
    impact.session.release();
    delete(impact.session);
    
    % Clear DAQ
    daq.reset;
    
    % Save data
    Nt=DATAcontainer.nt;
    DAQdata2WS(1,DATAcontainer.t(1:Nt),DATAcontainer.data(1:Nt,:),CHdata);
    assignin('base','frdsys',frdsys);
    clear('DATAcontainer');
    
    set(handles.statusStr, 'String', 'READY!  IDFRD and DAQ data available at workbench.');
    drawnow();
    
else
    errordlg('No channels or no reference.')
    set(handles.statusStr, 'String', 'Measurement aborted.');
    drawnow();
end