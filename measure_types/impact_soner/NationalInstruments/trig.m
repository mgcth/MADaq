function [um,y,Ts] = trig(t,u)
%TRIG
%Inputs: t    - Source sampling times  
%        u    - Source signal
%Output: y    - Measured response
%        um   - Measured source
%        Ts   - Sampling rate
%Call:   [um,y,Ts] = trig(t,u)

TrigOpt.u=u;
TrigOpt.tu=t;

TrigOpt.Go=true;
TrigOpt.Repeat=true;
TrigOpt.File='DataTransferFile.mat';


save triggerdata TrigOpt

while ~exist('DataTransferFile.mat','file')
    pause(0.01);
end

load DataTransferFile

Ts=get(IdData,'Ts');
um=get(IdData,'u');
y=get(IdData,'y');

delete('DataTransferFile.mat')



