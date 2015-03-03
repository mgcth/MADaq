function [t,y]=simo_trans_daq(ao,ai,Load,refch,Transp)
%SIMO_FRF_DAQ: 
% Inputs: ao        - Analog output object
%         ai        - Analog input object
%         Loads     - Transient load sequence
%         refch     - Channel that records the load
%         Transp    - Parameter(s)
% Output: t         - Time data vector
%         y         - Output matrix of responses. Size ny x na
% Call:   [t,y]=simo_rand_daq(ao,ai,Load,refch,Transp)


%%                                                        Initiate and test
Nch=length(ai.Channel);
Ts=1/ai.SampleRate;
Nldata=length(Load);
Duration=Transp(1);
t=0:Ts:Duration;
Ndata=length(t);

%%                                                Set Buffer to hold output
set(ao,'BufferingConfig',[Nldata 2]);
set(ao,'TriggerType','Manual');
set(ai,'TriggerType','Manual');
set(ao,'RepeatOutput',0);
putdata(ao,Load(:));

%%                                            Set blocksize of Analog Input
blocksize=Ndata;               % Allow all data in block
set(ai,'SamplesPerTrigger',blocksize);

%%                                                             Collect data
start([ao ai]);
trigger([ai ao]);
while isrunning(ai), pause(0.001);end
[y,t] = getdata(ai);
  
close all,plot(t,y(:,1))

%%                                                                 Stop DAQ
stop([ao ai]);
