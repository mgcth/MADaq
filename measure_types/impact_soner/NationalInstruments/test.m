% while(~isequal(exist('log.mat'),2))
% if(isequal(exist('log.mat'),2))
    collectedData = load('tempLog.mat');
    impactData = ImpactFinder(collectedData.data,triggerLevel,nScans);
    [FRF,f] = tfestimate(impactData(2,:),-impactData(1,:),[],[],[],Ts);
    plot(f,log10(abs(FRF)))
%     break
% end

% end