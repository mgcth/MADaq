function nidaqGetTriggeredData(so,data)
%nidaqGetTriggeredData

global DAQ

DAQ.t=data.TimeStamps;
DAQ.y=data.Data;
  