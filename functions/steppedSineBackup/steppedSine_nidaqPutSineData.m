function steppedSine_nidaqPutSineData(so,data);
%nidaqPutSineData - Fill data buffer of Analog Output

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global DAQ

% disp('In nidaqPutSineData')

Ts=1/so.Rate;om=2*pi*DAQ.freq;
u=DAQ.load * sin(om*[Ts:Ts:DAQ.AOBufferSize*Ts]+DAQ.fi0);
DAQ.fi0=om*DAQ.AOBufferSize*Ts+DAQ.fi0;

so.queueOutputData(u(:));


