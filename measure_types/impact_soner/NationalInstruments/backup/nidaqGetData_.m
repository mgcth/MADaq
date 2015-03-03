function nidaqGetData(so,data);
%nidaqPutSineData Summary of this function goes here
%                 Detailed explanation goes here
global DAQ

%disp('In nidaqGetData')

Ts=1/so.Rate;
DAQ.t=data.TimeStamps;
if DAQ.t(1)>=(DAQ.StartOfBuffer-1)*Ts
  if DAQ.Nscans<DAQ.Maxscans
    DAQ.data(:,:,DAQ.Maxscans-DAQ.Nscans)=data.Data;
    DAQ.Nscans=DAQ.Nscans+1;
  end
end


