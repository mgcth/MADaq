function nidaqGetData(so,data)
%nidaqGetData

global DAQ

%     DAQ.BlocksCollected=DAQ.BlocksCollected+1;
%     bc=DAQ.BlocksCollected;
% 
%     DAQ.allt{bc}=data.TimeStamps;
%     DAQ.ally{bc}=data.Data;
%     DAQ.BlockFreq{bc}=DAQ.NextBlockEndAddress(1,2);
%     DAQ.NextBlockAddress{bc}=DAQ.NextBlockEndAddress(1,2);
%     DAQ.ScansOutByHardware{bc}=so.ScansOutputByHardware;
%     DAQ.ScansAcquired{bc}=so.ScansAcquired;
% 
if so.ScansAcquired>so.ScansOutputByHardware+DAQ.AcceptedOutputDelay
  DAQ.ErrorState=2;
elseif isempty(DAQ.NextBlockEndAddress)
  DAQ.ErrorState=3;
elseif so.ScansAcquired==DAQ.NextBlockEndAddress(1,1)
  DAQ.BlocksSaved=DAQ.BlocksSaved+1;
  bs=DAQ.BlocksSaved;

%   disp(['In nidaqGetData. Block= ', int2str(bs)]);
  DAQ.t{bs}=data.TimeStamps;
  DAQ.y{bs}=data.Data;
  DAQ.tt{bs}=data.TriggerTime;
  DAQ.BlockFreq{bs}=DAQ.NextBlockEndAddress(1,2);
  DAQ.NextBlockEndAddress(1,:)=[];
end  

