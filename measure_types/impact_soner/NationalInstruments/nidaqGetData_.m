function nidaqGetData(so,data)
%nidaqGetData

global DAQ


  try
    DAQ.allt{end+1}=data.TimeStamps;
    DAQ.ally{end+1}=data.Data;
    DAQ.BlockFreq{end+1}=DAQ.NextBlockEndAddress(1,2);
    DAQ.NextBlockAddress{end+1}=DAQ.NextBlockEndAddress(1,2);
    DAQ.ScansOutByHardware{end+1}=so.ScansOutputByHardware;
    DAQ.ScansAcquired{end+1}=so.ScansAcquired;
  catch
    DAQ.allt{1}=data.TimeStamps;
    DAQ.ally{1}=data.Data;
    DAQ.BlockFreq{1}=DAQ.NextBlockEndAddress(1,2);
    DAQ.NextBlockAddress{1}=DAQ.NextBlockEndAddress(1,2);
    DAQ.ScansOutByHardware{1}=so.ScansOutputByHardware;
    DAQ.ScansAcquired{1}=so.ScansAcquired;
  end


if so.ScansAcquired>so.ScansOutputByHardware+DAQ.AcceptedOutputDelay
   DAQ.ErrorState=2;
elseif isempty(DAQ.NextBlockEndAddress)
   DAQ.ErrorState=3;
elseif so.ScansAcquired==DAQ.NextBlockEndAddress(1,1)
  try
    DAQ.t{end+1}=data.TimeStamps;
    DAQ.y{end+1}=data.Data;
    DAQ.tt{end+1}=data.TriggerTime;
  catch
    DAQ.t{1}=data.TimeStamps;
    DAQ.y{1}=data.Data;
    DAQ.tt{1}=data.TriggerTime;
  end
  DAQ.NextBlockEndAddress(1,:)=[];
end  

pause(0.0001)