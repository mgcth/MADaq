function data=fakenidaq(in)
%Fakeing the nidaq measurement system
%as of yet not working properly.

%                               Open Settings and Calibrations spreadsheet
Dir0=pwd;
Dir=which('nidaq');ind=find(Dir=='\');Dir=[Dir(1:ind(end)) 'xls'];
if strcmp(lower(in),'go')
  XLSetFile=[Dir '\ni_active.xls'];
else
  cd(Dir);
  [Name,Dir]=uigetfile('*.xl*');
  XLSetFile=[Dir Name];
  Stat=dos(['excel "' XLSetFile '"']);if Stat, errormsg(1);end
  copyfile(XLSetFile,[Dir '\ni_active.xls']);
  cd(Dir0);
end




Ts=1/51200;
[num,txt,raw]=xlsread(XLSetFile,'Triggered');
TrigMeth=raw{3,5};
TrigFun=raw{4,5};
TrigT=raw{5,5};Ndata=ceil(TrigT/Ts);
SourceLim=abs(raw{6,5});
TrigOpt.Repeat=true;
disp('Waiting for external trigger')
while TrigOpt.Repeat    
  TrigOpt.Go=false;
  while ~TrigOpt.Go
    try TrigOpt=eval(TrigFun);catch errormsg(3);end
  end      
  try TrigOpt.Repeat; catch TrigOpt.Repeat=false;end
  try
      u=TrigOpt.u;
      u(1,find(u(1,:)>SourceLim))=SourceLim;% Clip large source signals
      u(1,find(u(1,:)<-SourceLim))=-SourceLim;
      tu=TrigOpt.tu;
  catch
      u=[];tu=[];
  end
  [um,y]=fake_simo_triggered_nidaq(u,tu);
          
  IdData = iddata(y,um,Ts);
  try
    save(TrigOpt.File,'IdData')
    varargout{1}=IdData;
  catch
    varargout{1}=IdData;
  end
end
end

function [um,y]=fake_simo_triggered_nidaq(u,tu)
%SIMO_TRIGGERED_NIDAQ: 
% Inputs: so        - DAQ object
%         Ndata     - Number of time samples to take
%         u         - Source signal
%         tu        - Times associated with u
% Output: um        - Measured input
%         y         - Output matrix
% Call:   [um,y]=simo_triggered_nidaq(so,Ndata,u)
load('TWRinputdata.mat','sys'); %(ref) sys

Sys=c2d(sys,tu(2)-tu(1));
um=u(:,1);

end

function errormsg(opt)
if opt==1
    disp(' ')
    disp('The batch file excel.bat is not present in any directories in')
    disp('the Windows path. It is suggested that you revise the content')
    disp('of excel.bat in the DataTranslation directory and put that in')
    disp('the /bin directory of your Matlab installation')
    disp(' ')
elseif opt==2
    disp(' ')
    disp('Check the name of the random data function given in the ')
    disp('Excel sheet. Also check that the function can be found')
    disp('in the path.')
    disp(' ')
elseif opt==3
    disp(' ')
    disp('Impossible to interpret the Trigger Evaluation function')
    disp(' ')
elseif opt==4
    disp(' ')
    disp('Unknown data acqusition type.')
    disp(' ')
end   
end

