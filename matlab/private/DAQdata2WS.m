function DAQdata2WS(opt,varargin)
% DAQdata2WS Put DAQ data in the Matlab workspace

% Written: 2015-02-28, Thomas Abrahamsson, Chalmers University of Technology

if opt==1,
  t=varargin{1};
  data=varargin{2};
  %CHdata=varargin{3};
  ts=timeseries(data,t);
  ts.UserData.MeasurementDate = datestr(now,'mm-dd-yyyy HH:MM:SS');
  assignin('base','DAQts',ts);
else
  error('Unknown opt')
end  