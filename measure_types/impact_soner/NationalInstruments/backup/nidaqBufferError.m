function nidaqBufferError(so,event);
%nidaqBufferError 

global DAQ

disp(event.Error.getReport())
DAQ.BufferReady=true;
DAQ.BufferError=true;


