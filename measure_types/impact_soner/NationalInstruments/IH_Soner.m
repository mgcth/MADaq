clear all
clc

global data nScans triggerLevel scanData
triggerLevel = 0.3;
if(exist('tempLog.mat') == 2)
    delete('tempLog.mat');
    disp('old log deleted')
end
s = daq.createSession('ni');

s.Rate = 51200;
nScans = 2*s.Rate;
Ts = s.Rate;
s.IsContinuous = true;
s.addAnalogInputChannel('PXI1Slot2','ai0', 'IEPE');
s.addAnalogInputChannel('PXI1Slot2','ai1', 'IEPE');

lh_avail = s.addlistener('DataAvailable', @GetImpact);
fprintf('Data aquisition started')
s.startBackground();

% collectData(s,triggerLevel);

% % if(exist('log.mat') == 2)
% %     load('log.mat')
% %     impactData = ImpactFinder(data,triggerLevel,nScans);
% %     [FRF,f] = tfestimate(impactData(2,:),-impactData(1,:),[],[],[],Ts);
% %     plot(f,log10(abs(FRF)))
% %     break
% % end