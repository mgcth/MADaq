function GetChannelData(src,event)
persistent tempData
global channelData 
if(isempty(tempData))
    tempData = [];
end
tempData = [tempData;event.Data(:,2:end)];
channelData = tempData;
end