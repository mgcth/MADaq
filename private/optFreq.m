function [wc,wd,Ts]=optFreq(flo,fup,nf)
% inputs:
%     flo: lower frequency range (Hz)
%     fup: upper frequency range (Hz)
%     nf: number of frequencies
% outputs:
%     wc : frequncy lines in countinous-time system (rad/s)
%     wd : frequncy lines in discrete-time system (rad/s)
%     Ts : sampling Time
% Copyright Majid Khorsand Vakilzadeh and Vahid Yaghoubi Nasrabadi (??)

Ts=1/pi/sqrt(flo*fup);     % optimized sampling time for wider frequency 
                           % range in discrete-time system
wdlo=2*atan(flo*pi*Ts);    % lower frequency in discrete system
wdup=2*atan(fup*pi*Ts);    % upper frequency in discrete system

Nn = ceil(2*pi*(nf-1)/(wdup-wdlo));   % number of frequency grid between [0,2*pi]
k1 = round(Nn*wdlo/2/pi); % number of closest frequency grid to wdlo
k2 = k1+nf-1;
wd=(k1:k2)*2*pi/Nn; 
wc=tan(wd/2)*2/Ts;

% My change
% Output in Hz
wc = wc/2/pi;
wd = wd/2/pi;

%%%%% 
% wdlo = 2*pi*k1/N
% wdup = 2*pi*k2/N, k2=k1+nf ==> wdup=wdlo+2*pi*nf/N
%  ==> N = 2*pi*nf/(wdup-wdlo) 