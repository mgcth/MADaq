function ao=dtolaosetup(XLSetFile)
%DTOLAOSETUP: Sets up the Analog Output of the DataTranslation unit (dtol)

% See also: DEMOAO_INTRO


%%                                   Do settings either by table or default
try;                                                          % Excel table
  [num,txt,raw]=xlsread(XLSetFile,'Settings');
  OutputRate=raw{4,3};        % Sample Rate is in (3,3) cell of spreadsheet
catch;                                                        % Default
  OutputRate=51200;
end

%%                 For stability: Stop any running data acquisition objects
try,stop(daqfind);catch,end

%%                    Create an analog output object, add an output channel
ws=warning;warning('Off');                  % Shut off warnings for a while
ao = analogoutput('dtol');
warning(ws);
addchannel(ao,0);

%%                                    Configure the analog output data rate
set(ao,'SampleRate',OutputRate);

%%                                    Set Buffer to hold 1 minute of output
%                                     as default
set(ao,'BufferingConfig',[60*OutputRate 2])

%%                         Set trigger type such that it starts immediately 
%                          after a START command as default
set(ao,'TriggerType','Immediate');

