function nidaqPutSineData(so,data);
%nidaqPutSineData - Fill data buffer of Analog Output

global DAQ

% disp('In nidaqPutSineData')

Ts=1/so.Rate;om=2*pi*DAQ.freq;
u=DAQ.load * sin(om*[Ts:Ts:DAQ.AOBufferSize*Ts]+DAQ.fi0);
DAQ.fi0=om*DAQ.AOBufferSize*Ts+DAQ.fi0;

so.queueOutputData(u(:));


