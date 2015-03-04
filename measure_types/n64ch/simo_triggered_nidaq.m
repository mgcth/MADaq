function [um,y]=simo_triggered_nidaq(so,Ndata,u,tu)
%SIMO_TRIGGERED_NIDAQ: 
% Inputs: so        - DAQ object
%         Ndata     - Number of time samples to take
%         u         - Source signal
%         tu        - Times associated with u
% Output: um        - Measured input
%         y         - Output matrix
% Call:   [um,y]=simo_triggered_nidaq(so,Ndata,u)

%%                                                                  Globals
global CH DAQ

%%                                                        Initiate and test
Refch=find(CH.active==CH.refch);
Nch=length(CH.active);
Ych=setdiff(1:Nch,Refch);
Fs=so.Rate;Ts=1/Fs;
DAQ.ErrorState=0;

%%                                                         Set up listeners
LReqrd=so.addlistener('DataRequired',@nidaqPutTriggeredData);
LAvail=so.addlistener('DataAvailable',@nidaqGetTriggeredData);
LErr = so.addlistener('ErrorOccurred',@nidaqError);

%%                                     Set up for continuous running of DAQ
so.IsContinuous=true;  

%%                                             Fill output buffer and start
if ~isempty(u),
    if tu(end)<(Ndata-1)*Ts;tu=[tu(:);(Ndata-1)*Ts];u=[u(:);0];end
    u=interp1(tu,u,[0:Ndata-1]*Ts);
    so.queueOutputData(u(:));
else
    so.queueOutputData(zeros(Ndata,1));
end    
so.NotifyWhenDataAvailableExceeds=Ndata;
so.startBackground;

%% Wait until data become available
while 1,
    try 
        DAQ.y;
        if ~isempty(DAQ.y)
           break
        else
           pause(0.01);
        end   
    catch
        pause(0.01);
    end
end

y=DAQ.y(:,Ych);
um=DAQ.y(:,Refch);

DAQ.y=[];

%%                                                           Do calibration
yind=setdiff(CH.active,CH.refch);
uind=CH.refch;
y=y*diag(1./DAQ.cal(yind));
um=um*diag(1./DAQ.cal(uind));
 
%%                              Stop Analog Output/Input and delete handles
if so.IsRunning,so.stop();end
delete(LReqrd);delete(LAvail);delete(LErr);

