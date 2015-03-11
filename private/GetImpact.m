function GetImpact(src,event)
persistent tempData 
global data nScans triggerLevel scanData
if(isempty(tempData))
    tempData = [];
end

tempData = [tempData event.Data];

data = [data tempData'];
tempData = [];

if (size(data,2) == nScans)
    scanData = [scanData data];
    data = [];
    if (size(scanData,2) == 3*nScans)
        scanData(:,1:nScans) = [];
    end
    if (any(abs(scanData(1,1:nScans)) >= triggerLevel))
        data = scanData;
        save tempLogImpact.mat data
        fprintf('Data saved\n')
        data = [];
        scanData = [];
    end
end

end