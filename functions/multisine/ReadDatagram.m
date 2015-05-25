function ReadDatagram(u)
% ReadDatagram - Reads the Datagrams passed by the PassDatagram function
% Inputs: u  - The UDP object
% The datagram (data) is assumed to be sent by the PassDatagram function
% that passes a (double) matrix along with its name into the caller's
% workspace

%Written: 2015-03-17, Thomas Abrahamsson, Chalmers University of Technology

NByteAvail=get(u,'BytesAvailable');
if NByteAvail==0;% Do nothing if nothing new is available
  warning('Nothing to read')
  return
end

%%                                                         Read matrix name
notdone=true;
while notdone
  try
    Name=fscanf(u);
    Name=Name(1:end-1);
    notdone=false;
  catch
  end
end

%%                                                   Read dimension of data
notdone=true;
while notdone
  try
    nSzD=fread(u,1,'double');
    notdone=false;
  catch
  end
end

%%                                                         Read matrix size
notdone=true;
while notdone
  try
    sD=fread(u,nSzD,'double');
    notdone=false;
  catch
  end
end

%%                                                         Read matrix data
notdone=true;
while notdone
  try
    D=fread(u,prod(sD),'double');
    notdone=false;
  catch
  end
end

%%                                       Assign matrix in Callers workspace
D=reshape(D,sD(:)');
assignin('caller',Name,D);
