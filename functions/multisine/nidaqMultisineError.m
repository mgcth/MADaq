function nidaqMultiSineError(so,event)
%nidaqError 

global DAQ

disp(event.Error.getReport())
DAQ.ErrorState=1;



