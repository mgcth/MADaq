function [t,u]=abradaq_chirp(f0,t1,f1,Ts)
%ABRADAQ_CHIRP Generates a chirp signal
%Inputs: f0   - Start instantaneous frequency of chirp
%        t1   - Time instant for f1
%        f1   - Instantaneous frecuency at time t1
%        Ts   - Sample rate
%Output: t    - Discrete times for u
%        u    - Chirp signal
%Call:   [t,u]=abradaq_chirp(f0,t1,f1,Ts)

%Created: 2011-03-02. Thomas Abrahamsson

% if nargin<4
%   Fs=51200;Ts=1/Fs;
% end
%
% t = 0:Ts:t1;
% u = chirp(t,f0,t1,f1);

%if nargin<4
%  Fs=51200;Ts=1/Fs;
%end

%N = t1/Ts;
%t = (0:N-1)*Ts;
%u = chirp(t,f0,t1,f1);

N = t1/Ts;
t = (0:N-1)*Ts;
u = chirp(t,f0,t1,f1,'logarithmic',270);
