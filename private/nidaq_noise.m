function [t,u]=nidaq_noise(f0,f1,Ts,T)
%NIDAQ_NOISE Generates a random noise signal
%Inputs: f0   - Cut-on frequency of noise
%        f1   - Cut-off frequency of noise
%        Ts   - Discrete time steps
%        T    - Duration of noise signal
%Output: t    - Discrete times for u
%        u    - Noise signal
%Call:   [t,u]=nidaq_noise(f0,f1,Ts,T)

%Created: 2011-03-03. Thomas Abrahamsson

Fs=1/Ts;
t=0:Ts:T;
u=randn(size(t));

u=iddata(u(:),[],Ts);
u=idfilt(u,2*pi*[f0 f1]);
u=u.OutputData;