function u=startUDP(typ,procno)
%StartUDP starts a UDP host or client
%Inputs:  type   - 'Host' or 'Client'
%         procno - Number of UDP process
%Output:  u      - The UDP object
%Call:    u=startUDP(type,procno)

%Copyleft: 2015-04-24,Thomas Abrahamsson, Chalmers University of Technology

if nargin<2,procno=1;end

typ=lower(typ);
switch typ
  case 'client'
    RemotePort=2*procno-1+9091;LocalPort=2*procno-1+9090;
  case 'host'
    RemotePort=2*procno-1+9090;LocalPort=2*procno-1+9091;
  otherwise
     error('No valid type');      
end
u = udp('127.0.0.1', 'RemotePort', RemotePort, 'LocalPort', LocalPort);
set(u,'OutputBufferSize',2^17,'InputBufferSize',2^17,'Timeout',.5);
set(u,'InputDatagramPacketSize',2^16-1,'OutputDatagramPacketSize',2^16-1);

if strcmpi(typ,'host')
  set(u,'BytesAvailableFcn','UDPping');
end  
fopen(u);

% startstr=['cmd /c start /min matlab -nosplash -nodesktop -minimize ' ...
%           '-r "addpath(''' GUI.FEMcaliPath ''');cd(''' GUI.PWD ''');FEMcaliMonitor;"'];
% dos(startstr);