function [wc,wd,Ts]=freqdesign(flo,fup,nf)
% inputs:
%     flo: lower frequency range (Hz)
%     fup: upper frequency range (Hz)
%     nf: number of frequencies
% outputs:
%     wc : frequncy lines in countinous-time system (Hz) .. old(rad/s)
%     wd : frequncy lines in discrete-time system (Hz) .. old(rad/s)
%     Ts : sampling Time
% 

%Copyleft: 2015-04-25, Thomas Abrahamsson, Chalmers University of Technology

Ts=1/pi/sqrt(flo*fup);     % optimized sampling time for wider frequency 
                           % range in discrete-time system
wdlo=2*atan(flo*pi*Ts);    % lower frequency in discrete system
wdup=2*atan(fup*pi*Ts);    % upper frequency in discrete system
wd=linspace(wdlo,wdup,nf); 
wc=tan(wd/2)*2/Ts;

% rad/s to Hz
wc = wc/2/pi;
wd = wd/2/pi;