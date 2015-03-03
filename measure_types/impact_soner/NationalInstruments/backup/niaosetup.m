function so=niaosetup(XLSetFile,so)
%NIAOSETUP: Sets up the Analog Output of the National Instrument unit (ni)

%%                                   Do settings either by table or default
try;                                                          % Excel table
  [num,txt,raw]=xlsread(XLSetFile,'Settings');
  OutputRate=raw{4,3}; % Sample Rate is in (4,3) cell of spreadsheet
catch;                                                       
  OutputRate=51200;    % Default
end

%%                                                    Add an output channel
so.addAnalogOutputChannel('PXI1Slot6', 0, 'Voltage');

%%                                    Configure the analog output data rate
so.Rate=OutputRate;
