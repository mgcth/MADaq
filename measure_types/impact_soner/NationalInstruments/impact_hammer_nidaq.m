function frdsys = impact_hammer_nidaq(so,nRefPoints,impactsOnRef,recordTime,triggerLevel)


%%                                                                  Globals
global CH data nScans triggerLevel scanData
%%
if strcmp(lower(so.Channels(1).ID(1:2)),'ao')
    so.removeChannel(1);
end

%%
nCh = length(CH.active);
so.Rate = 51200; %HÅDKODAD!!! Är 51200.0001 från excel
Fs = so.Rate;
nScans = recordTime*Fs;
%%
iRef = 1;
iImpacts = 1;

%%
so.IsContinuous = true;
lh = so.addlistener('DataAvailable', @GetImpact);
so.startBackground();
while (iRef <= nRefPoints)
    fprintf('Reference point #%u \n',iRef)
    while iImpacts <= impactsOnRef
        fprintf('Impact #%u \n',iImpacts)
        close all;
        % Delete old temporary log
        if(exist('tempLog.mat') == 2)
            delete('tempLog.mat');
        end
        pause(recordTime)
        
        fprintf('Data aquisition started... ')
        % Wait until the temporary log is created in @GetImpact
        while 1
            if isequal(exist('tempLog.mat'),2)
                break
            else
                pause(0.01);
            end
        end
        
        collectedData = load('tempLog.mat');
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
so.stop;
delete(lh);

frdsys{2}.FREQ= f;
frdsys{3}.IMPULSE= collectedData.data(1,:);
end
% % plot(Data{2},log10(abs(Data{1})),'k');xlabel('Hz');ylabel('log|Y|');title('FRF estimate Impact hammer')
