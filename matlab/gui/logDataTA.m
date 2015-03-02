function logDataTA(src, evt)
% Add the time stamp and the data values to data.

global DATAcontainer

% data = [evt.TimeStamps, evt.Data]' ;
% fwrite(fid,data,'double');

nt=length(evt.TimeStamps);
Nt=DATAcontainer.nt;

if nt+Nt<DATAcontainer.ntmax
  DATAcontainer.t(Nt+1:Nt+nt,1)=evt.TimeStamps(:);
  DATAcontainer.data(Nt+1:Nt+nt,:)=evt.Data;
  DATAcontainer.nt=Nt+nt;
else
  fprintf('Memory overflow. Skipping data ...\n');  
end    
    