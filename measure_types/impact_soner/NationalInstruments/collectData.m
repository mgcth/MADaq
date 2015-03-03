function collectData(s,triggerLevel)
global data nScans triggerLevel scanData
% % triggerLevel = 0.3;
% % s = daq.createSession('ni');
% % 
% % s.Rate = 51200;
% % nScans = 2*s.Rate;
% % Ts = s.Rate;
% % s.IsContinuous = true;
% % s.addAnalogInputChannel('PXI1Slot2','ai0', 'IEPE');
% % s.addAnalogInputChannel('PXI1Slot2','ai1', 'IEPE');

lh_avail = s.addlistener('DataAvailable', @GetImpact);
fprintf('Data aquisition started... ')
s.startBackground();
end

