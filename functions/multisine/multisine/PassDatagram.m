function PassDatagram(u,Name,Data)
% PassDatagram Pass matrix data from server to client via UDP
% Inputs: u    - The UDP object
%         Name - The name of the matrix to be put in the caller's ws
%         Data - The matrix to be passed


%% Test for data size
OBSz=floor(get(u,'OutputDatagramPacketSize')/8);
D=Data(:);nD=length(D);
if nD>OBSz,error('Data matrix is too large');end

%%                                                         Pass matrix name
Nl=length(Name);ind2=min([Nl 24]);
fprintf(u,Name(1:ind2),'sync');
if Nl>24,disp('Name is truncated to 24 letters');end

%%                                       Pass number of data blocks to send
SzD=size(Data);nSzD=length(SzD);
notdone=true;
while notdone
  try
    fwrite(u,nSzD,'double','sync');
    notdone=false;
  catch
  end
end

%%                                                         Pass matrix size
notdone=true;
while notdone
  try
    fwrite(u,SzD,'double','sync');
    notdone=false;
  catch
  end
end

%%                                                         Pass matrix data
notdone=true;
while notdone
  try
    fwrite(u,D,'double','sync');
    notdone=false;
  catch
  end
end
