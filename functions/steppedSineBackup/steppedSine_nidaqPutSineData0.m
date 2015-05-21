function steppedSine_nidaqPutSineData0(so,data);
%nidaqPutSineData30 - Prepare for buffer fill

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

% disp('In nidaqPutSineData0')

global DAQ
DAQ.BufferReady=true;

