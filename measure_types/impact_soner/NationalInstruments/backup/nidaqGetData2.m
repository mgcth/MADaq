function nidaqGetData2(so,data);
%nidaqPutSineData Summary of this function goes here
%                 Detailed explanation goes here
global DAQ

DAQ.NBlocksRead=DAQ.NBlocksRead+1;
if ~mod(DAQ.NBlocksRead,DAQ.NBlocks)
  try
    DAQ.t{end+1}=data.TimeStamps;
    DAQ.y{end+1}=data.Data;
    DAQ.tt{end+1}=data.TriggerTime;
  catch
    DAQ.t{1}=data.TimeStamps;
    DAQ.y{1}=data.Data;
    DAQ.tt{1}=data.TriggerTime;
  end
end    


