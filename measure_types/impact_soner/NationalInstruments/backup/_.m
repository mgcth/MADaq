function nidaqPutSineData(so,data);
%nidaqPutSineData - Fill data buffer of Analog Output

global DAQ

Ts=1/so.Rate;
om=2*pi*DAQ.freq;
%u=DAQ.load * sin(om*[DAQ.k0*Ts:Ts:(DAQ.k0+DAQ.Nbuff)*Ts]); 
u=DAQ.load * sin(om*[0:Ts:(DAQ.Nbuff-1)*Ts]+DAQ.fi0); 
so.queueOutputData(u(:));

DAQ.k0=DAQ.k0+DAQ.Nbuff;
DAQ.fi0=DAQ.fi0+om*DAQ.Nbuff*Ts;


if DAQ.MarkStartOfBuffer
    DAQ.StartOfBuffer=DAQ.BufferCountAccumulated+1;
    DAQ.MarkStartofBuffer=false;
end
DAQ.BufferCountAccumulated=DAQ.BufferCountAccumulated+DAQ.Nbuff;

end

