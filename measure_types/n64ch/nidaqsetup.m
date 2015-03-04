function so=nidaqsetup(so,XLSetFile)
%NIDAQSETUP: Sets up the National Instruments unit (ni)

global DAQ

disp(' '),disp('Setting up DAQ system. Please wait.')
%%                                                              Do settings
if nargin>1
  try;                                                          % Excel table
    [num,txt,XLSset]=xlsread(XLSetFile,'Settings');
    SampleRate=XLSset{4,3};     % Sample Rate is in (4,3) cell of spreadsheet
    NCh=XLSset{4,7};            % Number of channels is in (4,7)
    Ch.Type=XLSset(6:5+NCh,4);
    Ch.Coupl=XLSset(6:5+NCh,5);
    Ch.SN=XLSset(6:5+NCh,3);
    Ch.On=XLSset(6:5+NCh,7);
    Ch.Name=XLSset(6:5+NCh,11);
    [num,txt,XLScal]=xlsread(XLSetFile,'Calibration');
    Ch.SNos=XLScal(4:43,5);
    Ch.cals=XLScal(4:43,7);
    DAQ.XLScal=XLScal;
    DAQ.XLSset=XLSset;
  catch;                                                        
    error('Error setting up input channels')
  end
else
  SampleRate=DAQ.XLSset{4,3};
  NCh=DAQ.XLSset{4,7};        
  Ch.Type=DAQ.XLSset(6:5+NCh,4);
  Ch.Coupl=DAQ.XLSset(6:5+NCh,5);
  Ch.SN=DAQ.XLSset(6:5+NCh,3);
  Ch.On=DAQ.XLSset(6:5+NCh,7);
  Ch.Name=DAQ.XLSset(6:5+NCh,11);
  Ch.SNos=DAQ.XLScal(4:33,5);
  Ch.cals=DAQ.XLScal(4:33,7);
end

%%                                                        Set sampling rate
so.Rate=SampleRate;

ws=warning;warning off;
%%                                                    Add an output channel
%so.addAnalogOutputChannel('PXI1Slot2', 0, 'Voltage');

for I=1:length(Ch.Type),if strcmp(Ch.Type{I},'Volt'), Ch.Type{I}='Voltage';end,end
    
%%                                                       Add input channels
NOutCh=length(so.Channels);
NInCh=0;

for I=0:15; % Channels of PXI2Slot8
  NInCh=NInCh+1;
  if strcmpi(Ch.On(NInCh),'yes')
    so.addAnalogInputChannel('PXI1Slot8',I,Ch.Type(NInCh));
    so.Channels(end).Coupling=char(upper(Ch.Coupl(NInCh)));
    try
      so.Channels(end).Name=Ch.Name(NInCh);
    catch
      so.Channels(end).Name=' ';
    end
  end
end

for I=0:15; % Channels of PXI2Slot9
  NInCh=NInCh+1;
  if strcmpi(Ch.On(NInCh),'yes')
    so.addAnalogInputChannel('PXI1Slot9',I,Ch.Type(NInCh));
    so.Channels(end).Coupling=char(upper(Ch.Coupl(NInCh)));
    try
      so.Channels(end).Name=Ch.Name(NInCh);
    catch
      so.Channels(end).Name=' ';
    end
  end
end

for I=0:15; % Channels of PXI2Slot10
  NInCh=NInCh+1;
  if strcmpi(Ch.On(NInCh),'yes')
    so.addAnalogInputChannel('PXI1Slot10',I,Ch.Type(NInCh));
    so.Channels(end).Coupling=char(upper(Ch.Coupl(NInCh)));
    try
      so.Channels(end).Name=Ch.Name(NInCh);
    catch
      so.Channels(end).Name=' ';
    end
  end
end

for I=0:15; % Channels of PXI2Slot11
  NInCh=NInCh+1;
  if strcmpi(Ch.On(NInCh),'yes')
    so.addAnalogInputChannel('PXI1Slot11',I,Ch.Type(NInCh));
    so.Channels(end).Coupling=char(upper(Ch.Coupl(NInCh)));
    try
      so.Channels(end).Name=Ch.Name(NInCh);
    catch
      so.Channels(end).Name=' ';
    end
  end
end

for I=0:1; % Channels of PXI1Slot2
  NInCh=NInCh+1;
  if strcmpi(Ch.On(NInCh),'yes')
    so.addAnalogInputChannel('PXI1Slot2',I,Ch.Type(NInCh));
    so.Channels(end).Coupling=char(upper(Ch.Coupl(NInCh)));
    try
      so.Channels(end).Name=Ch.Name(NInCh);
    catch
      so.Channels(end).Name=' ';
    end
  end  
end

so.AutoSyncDSA=true;

%%                                                    Add an output channel
so.addAnalogOutputChannel('PXI1Slot2', 0, 'Voltage');

warning(ws);

%%                                  Set up the channel calibration
%                                   Set to dummy value (value required) in 
%                                   object so. Calibration taken care of 
%                                   in DAQ.cal
 for I=1:NCh
   if isnan(Ch.Name{I})
       DAQ.name{I}=' ';
   else
       DAQ.name{I}=[Ch.Name{I} ' '];
   end
   Navail=length(Ch.SNos);
   for II=1:Navail
       if length(Ch.SNos{II})==length(Ch.SN{I}) && all(Ch.SNos{II}==Ch.SN{I})
           DAQ.cal(I)=Ch.cals{II};
       end    
   end
 end

disp('Done.'),disp(' ')

 
