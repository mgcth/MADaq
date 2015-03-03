function so=niaisetup(XLSetFile,so)
%NIAISETUP: Sets up the Analog Inputs of the National Instruments unit (ni)

global DAQ

%%                                                              Do settings
try;                                                          % Excel table
  [num,txt,raw]=xlsread(XLSetFile,'Settings');
  SampleRate=raw{4,3};        % Sample Rate is in (4,3) cell of spreadsheet
  NCh=raw{4,7};               % Number of channels is in (4,7)
  Ch.Type=raw(6:5+NCh,4);
  Ch.Coupl=raw(6:5+NCh,5);
  Ch.SN=raw(6:5+NCh,3);
  Ch.On=raw(6:5+NCh,7);
  Ch.Name=raw(6:5+NCh,11);
  [num,txt,raw]=xlsread(XLSetFile,'Calibration');
  Ch.SNos=raw(4:33,5);
  Ch.cals=raw(4:33,7);
catch;                                                        
  error('Error setting up input channels')
end

%%                                                        Set sampling rate
%ai.SampleRate=SampleRate;

%ai.SamplesPerTrigger=40000;

%%                                                             Add channels
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
    so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
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
    so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
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
    so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
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
    so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
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
    so.Channels(length(so.Channels)).Name=char(Ch.Name(NInCh));
  end
end

%%                                  Set up the channel calibration
%                                   Set to dummy value (value required) in 
%                                   object so. Calibration taken care of 
%                                   in DAQ.cal
 for I=1:NCh
   Navail=length(Ch.SNos);
   for II=1:Navail
       if all(Ch.SNos{II}==Ch.SN{I})
           DAQ.cal(I)=Ch.cals{II};
       end    
   end
 end

 
