function so=nidaqsetup(so,XLSetFile)
%NIDAQSETUP: Sets up the National Instruments unit (ni)

global DAQ

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
    Ch.SNos=XLScal(4:56,5);
    Ch.cals=XLScal(4:56,7);
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

%%                                                    Add an output channel
ws=warning;warning off;
so.addAnalogOutputChannel('PXI1Slot6', 0, 'Voltage');

%%                                                       Add input channels
NOutCh=length(so.Channels);
NInCh=0;
for I=0:7; % Channels of PXI1Slot2
  NInCh=NInCh+1;Type='Voltage';
  if strcmp(lower(Ch.On(NInCh)),'yes')
    if strcmp(lower(Ch.Type(NInCh)),'iepe');Type='Accelerometer';end
    so.addAnalogInputChannel('PXI1Slot2',I,Type);
    so.Channels(length(so.Channels)).Coupling=char(upper(Ch.Coupl(NInCh)));
    if strcmp(lower(Ch.Type(NInCh)),'iepe')
      so.Channels(length(so.Channels)).Sensitivity=1;% Dummy value
    end
    try
      so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
    catch
      so.Channels(length(so.Channels)).Name=' ';
    end
  end
end
for I=0:7; % Channels of PXI1Slot3
  NInCh=NInCh+1;Type='Voltage';
  if strcmp(lower(Ch.On(NInCh)),'yes')
    if strcmp(lower(Ch.Type(NInCh)),'iepe');Type='Accelerometer';end
    so.addAnalogInputChannel('PXI1Slot3',I,Type);
    so.Channels(length(so.Channels)).Coupling=char(upper(Ch.Coupl(NInCh)));
    if strcmp(lower(Ch.Type(NInCh)),'iepe')
      so.Channels(length(so.Channels)).Sensitivity=1;% Dummy value
    end  
    try
      so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
    catch
      so.Channels(length(so.Channels)).Name=' ';
    end
  end
end
for I=0:7; % Channels of PXI1Slot4
  NInCh=NInCh+1;Type='Voltage';
  if strcmp(lower(Ch.On(NInCh)),'yes')
    if strcmp(lower(Ch.Type(NInCh)),'iepe');Type='Accelerometer';end
    so.addAnalogInputChannel('PXI1Slot4',I,Type);
    so.Channels(length(so.Channels)).Coupling=char(upper(Ch.Coupl(NInCh)));
    if strcmp(lower(Ch.Type(NInCh)),'iepe')
      so.Channels(length(so.Channels)).Sensitivity=1;% Dummy value
    end  
    try
      so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
    catch
      so.Channels(length(so.Channels)).Name=' ';
    end
  end
end
for I=0:7; % Channels of PXI1Slot5
  NInCh=NInCh+1;Type='Voltage';
  if strcmp(lower(Ch.On(NInCh)),'yes')
    if strcmp(lower(Ch.Type(NInCh)),'iepe');Type='Accelerometer';end
    so.addAnalogInputChannel('PXI1Slot5',I,Type);
    so.Channels(length(so.Channels)).Coupling=char(upper(Ch.Coupl(NInCh)));
    if strcmp(lower(Ch.Type(NInCh)),'iepe')
      so.Channels(length(so.Channels)).Sensitivity=1;% Dummy value
    end  
    try
      so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
    catch
      so.Channels(length(so.Channels)).Name=' ';
    end
  end
end
for I=0:1; % Channels of PXI1Slot6
  NInCh=NInCh+1;Type='Voltage';
  if strcmp(lower(Ch.On(NInCh)),'yes')
    if strcmp(lower(Ch.Type(NInCh)),'iepe');Type='Accelerometer';end
    so.addAnalogInputChannel('PXI1Slot6',I,Type);
    so.Channels(length(so.Channels)).Coupling=char(upper(Ch.Coupl(NInCh)));
    if strcmp(lower(Ch.Type(NInCh)),'iepe')
      so.Channels(length(so.Channels)).Sensitivity=1;% Dummy value
    end  
    try
      so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
    catch
      so.Channels(length(so.Channels)).Name=' ';
    end
  end
end

%%                                                    Make the modules sync
if ~verLessThan('matlab','7.14.0')
  try,so.addTriggerConnection('PXI1Slot6/PXI_Trig0','PXI1Slot2/PXI_Trig0',...
              'StartTrigger');catch, end
  try,so.addTriggerConnection('PXI1Slot6/PXI_Trig0','PXI1Slot3/PXI_Trig0',...
      'StartTrigger');catch, end
  try,so.addTriggerConnection('PXI1Slot6/PXI_Trig0','PXI1Slot4/PXI_Trig0',...
      'StartTrigger');catch, end
  try,so.addTriggerConnection('PXI1Slot6/PXI_Trig0','PXI1Slot5/PXI_Trig0',...
      'StartTrigger');catch, end
end

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
       if all(Ch.SNos{II}==Ch.SN{I})
           DAQ.cal(I)=Ch.cals{II};
       end    
   end
 end

 
