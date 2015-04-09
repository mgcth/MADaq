function dataOut = data2WS(opt,varargin)
% data2WS Put data in the Matlab workspace

% Written: 2015-02-28, Thomas Abrahamsson, Chalmers University of Technology

if opt==1,
  t=varargin{1};
  data=varargin{2};
  ts=timeseries(data,t);
  %dataOut.Data = ts;
  %dataOut.Metadata = varargin{3}.Metadata;
  ts.UserData = varargin{3}.Metadata;
  dataOut = ts;
  assignin('base','DAQts',dataOut);
elseif opt==2
  frddata=varargin{1};
  %dataOut.Data = frddata;
  %dataOut.Metadata = varargin{2}.Metadata;
  frddata.UserData = varargin{2}.Metadata;
  dataOut = frddata;
  assignin('base','FRDsys',dataOut);
else
  error('Unknown opt')
end