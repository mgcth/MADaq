function impactData = ImpactFinder(data,triggerLevel,nScans)
[nRow,nCol] = size(data);
maxAmp = triggerLevel;
triggerPosition = 0;
for i = 1 : nCol
    if(abs(data(1,i)) > maxAmp)
        triggerPosition = i;
    end
end
if(triggerPosition == 0); error('Trigger level not reached'); end

for j = triggerPosition : -1 : 1
    if(data(1,j) > 0)
        startPosition = j; break;
    end
end

endPosition = startPosition + nScans - 1;
impactData = data(:,startPosition:endPosition);