function [t,u]=nidaq_sin(t1)
%NIDAQ_CHIRP Generates a chirp signal
%Inputs: f0   - Start instantaneous frequency of chirp
%        t1   - Time instant for f1
%        f1   - Instantaneous frecuency at time t1
%Output: t    - Discrete times for u
%        u    - Chirp signal
%Call:   [t,u]=nidaq_chirp(f0,t1,f1)

%Created: 2011-03-02. Thomas Abrahamsson

Fs=51200;Ts=1/Fs;

t=0:Ts:t1;
u=sin(t);
