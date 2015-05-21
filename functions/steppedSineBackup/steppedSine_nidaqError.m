function steppedSine_nidaqError(so,event)
%nidaqError 

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global DAQ

disp(event.Error.getReport())
DAQ.ErrorState=1;



