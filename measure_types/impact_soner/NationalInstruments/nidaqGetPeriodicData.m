function nidaqGetPeriodicData(so,data)
%nidaqGetPeriodicData

global DAQ

try
  DAQ.t{end+1}=data.TimeStamps;
  DAQ.y{end+1}=data.Data;
catch
  DAQ.t{1}=data.TimeStamps;
  DAQ.y{1}=data.Data;
end
  