function pumpDataProto

format compact

%% Initiate memmapfile
Nch=64; Nscans=2000; nl=1; fs=20000; T=Nscans/fs;
Nblocks=ceil(30/T);% Allow for 30s data 
MMF=PassDoubleThruFile(1,[Nblocks Nch Nscans nl]);

t=[0:Nscans-1]*T/Nscans; t=repmat(t,Nch,1);
t=diag([1:64])*t;

%% Create and pump data
cl0=clock;
I=0;
while 1
  Now=clock; Now=Now(end-1)*60+Now(end);
  D=sin(t+Now);
  I=I+1;
  while etime(clock,cl0)<I*T, pause(0.01); end
  PassDoubleThruFile(MMF,D,mod(I,Nblocks)+1);
end
    
