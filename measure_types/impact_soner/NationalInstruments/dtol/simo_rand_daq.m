function [f,Y]=simo_rand_daq(ao,ai,Load,refch,Randp)
%SIMO_FRF_DAQ: 
% Inputs: ao        - Analog output object
%         ai        - Analog input object
%         Loads     - Random load sequence
%         refch     - Channel that records the load
%         Randp     - Parameters
% Output: Y         - Output matrix of complex amplitudes. Size ny x na
%                     (na, ny - number of averages and number of outputs)
%         stdY      - Standard deviation of estimate of Y
% Call:   [f,Y,stdY]=simo_rand_daq(ao,ai,Load,refch,Randp)


%%                                                        Initiate and test
Nch=length(ai.Channel);
Fs=ai.SampleRate;
Repeats=Randp{1};Skips=Randp{2};
Ndata=length(Load);

%%                                    Set Buffer to hold 1 minute of output
%                                     as default
set(ao,'BufferingConfig',[Ndata Repeats]);
set(ao,'TriggerType','Manual');
set(ai,'TriggerType','Manual');
set(ao,'RepeatOutput',Repeats-1);          % Repeat random sequence
putdata(ao,Load(:));

%%                                            Set blocksize of Analog Input
blocksize=Repeats*Ndata;               % Allow all data in block
set(ai,'SamplesPerTrigger',blocksize);

%%                                                             Collect data
start([ao ai]);
trigger([ai ao]);
while isrunning(ai), pause(0.001);end
[y,t] = getdata(ai);
  

%%                              Skip first part (unstationary) part of data
y(1:Skips*Ndata,:)=[];t(1:Skips*Ndata)=[];

close all,plot(t,y(:,1))

%%                                           Estimate the transfer function
ch=1:Nch;ch=setdiff(ch,refch);
for I=1:length(ch)
  [Y(:,ch(I)),f]=tfestimate(y(:,refch),y(:,ch(I)),Ndata,0,[],Fs);
end
Y(:,refch)=ones(size(Y,1),1);

%%                                                                 Stop DAQ
stop([ao ai]);
