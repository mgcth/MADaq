function GetImpact(src,event)

% Author: Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

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