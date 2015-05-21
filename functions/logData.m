function logData(src, evt)
% Add the time stamp and the data values to data.

global dataObject

nt=length(evt.TimeStamps);
Nt=dataObject.nt;

if nt+Nt<dataObject.ntmax
  dataObject.t(Nt+1:Nt+nt,1)=evt.TimeStamps(:);
  dataObject.data(Nt+1:Nt+nt,:)=evt.Data;
  dataObject.nt=Nt+nt;
else
  fprintf('Memory overflow. Skipping data ...\n');  
end    
    