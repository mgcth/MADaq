function [t,y]=logging_daq(ao,ai,Logp)
%SIMO_FRF_DAQ: 
% Inputs: ao        - Analog output object
%         ai        - Analog input object
%         Logp      - Parameter(s)
% Output: t         - Time data vector
%         y         - Output matrix of responses. Size ny x na
% Call:   [t,y]=logging_daq(ao,ai,Logp)


%%                                                        Initiate and test
Duration=Logp(1);

ai.LogFileName = tempname();
ai.LogToDiskMode = 'overwrite';
ai.LoggingMode = 'Disk';
ai.TriggerType = 'Manual';
ai.SamplesPerTrigger=Inf;

%%                                                             Collect data
start(ai);
input('Hit Enter key to start logging!');
trigger(ai);
disp(' ')
disp('The DAQ is now logging to disk')
disp(' ')

%%                                                           Pause and stop
pause(Duration);
stop(ai);  

[y,t] = daqread(ai.LogFileName);

