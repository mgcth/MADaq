function dataOut = data2WS(opt,varargin)
% data2WS Put data in the Matlab workspace

% Written: 2015-02-28, Thomas Abrahamsson, Chalmers University of Technology

if opt==1,
  t=varargin{1};
  data=varargin{2};
  ts=timeseries(data,t);
  assignin('base','DAQts',ts);
  dataOut.Data{1} = ts;
  dataOut.Metadata = varargin{3}.Metadata;
elseif opt==2
  frddata=varargin{3};
  assignin('base','FRDsys',frddata);
  dataOut.Data{1} = frddata;
  dataOut.Metadata = varargin{4}.Metadata;
elseif opt==3
  t=varargin{1};
  data=varargin{2};
  frddata=varargin{3};
  ts=timeseries(data,t);
  assignin('base','DAQts',ts);
  assignin('base','FRDsys',frddata);
  dataOut.Data{1} = ts;
  dataOut.Data{2} = frddata;
  dataOut.Metadata = varargin{4}.Metadata;
else
  error('Unknown opt')
end