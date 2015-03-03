function nidaqPutPeriodicData(so,data);
%nidaqPutPeriodicData - Fill data buffer of Analog Output

global DAQ

so.queueOutputData(DAQ.Loads(:));


