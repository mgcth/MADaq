function varargout=nidaq(in)
%NIDAQ: Data acquisition with National Instruments system

%Written: 2011-02-10 by Thomas Abrahamsson

%% ------------------------------------------------------------------------
%                                                                    Global
%                                                                    ------
clear global
global CH

%%                                                                 Initiate
if nargin<1,in=[];end

%%                               Open Settings and Calibrations spreadsheet
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

%%           The fix provided by Mathwork's Wael Hemdan to get NI PXI units
%            to work with the DAQ TB
daq.reset;
% daqreset;
% daq.HardwareInfo.getInstance('CompactDAQOnly',false);

%%                                                Create the session object
so=daq.createSession('ni');

%%                                         Get some channel characteristics
[num,txt,raw]=xlsread(XLSetFile,'Settings');
TestType=raw{3,3};            % Test type is in (3,3) cell of spreadsheet
NCh=raw{4,7};                 % Number of channels is in (4,7)
RefInd=raw(6:5+NCh,8);CH.refch=[];
ActInd=raw(6:5+NCh,7);CH.active=[];
for I=1:NCh
  if strcmp(lower(RefInd(I)),'yes'), CH.refch=[CH.refch I];end  
  if strcmp(lower(ActInd(I)),'yes'), CH.active=[CH.active I];end
end
if length(CH.refch)~=1,error('There needs to be ONE reference channel'),end

%%                                            Setup Analog Output and Input
chinfo=[];
so=nidaqsetup(so,XLSetFile);
% so=niaosetup(XLSetFile,so);
% so=niaisetup(XLSetFile,so);

%%                                                       Do the measurement
if strcmp(lower(TestType),'stepped sine')
  [num,txt,raw]=xlsread(XLSetFile,'Stepped-Sine');
  Freqs=eval(raw{3,4});
  Loads=eval(raw{4,4});
  Convp=raw(8:11,5);
  try,CH.eval=eval(raw{7,5});catch, CH.eval=raw{7,5};end
%  SSarray.chplot=cheval(1);
%  SSarray.refno=refch(1);
  [sysfrd,stdY]=simo_frf_nidaq(so,Freqs,Loads);
  varargout{1}=sysfrd;
elseif strcmp(lower(TestType),'periodic')
  [num,txt,raw]=xlsread(XLSetFile,'Periodic');
  PeriodicDataFile=raw(3,5);
  try
    [t,Load]=eval(char(PeriodicDataFile));
  catch
    errormsg(2);
  end
  MaxAmpl=raw{3,8};MaxLoad=max(abs(Load));Fspan=raw{5,8};
  Cycles=raw{4,5};Skipps=raw{5,5};
  Tend=raw{4,8};
  dt=t(2)-t(1);
  t(end+1)=t(end)+dt;t(end+1)=Tend;
  Load(end+1)=0;Load(end+1)=0;
  Ts=1/so.Rate;
  Load=interp1(t,(MaxAmpl/MaxLoad)*Load,t(1):Ts:t(end));
  sysfrd=simo_periodic_nidaq(so,Load,Cycles,Skipps,Fspan);
  varargout{1}=sysfrd;
elseif strcmp(lower(TestType),'triggered')
  
  Ts=1/so.Rate;
  [num,txt,raw]=xlsread(XLSetFile,'Triggered');
  TrigMeth=raw{3,5};
  TrigFun=raw{4,5};
  TrigT=raw{5,5};Ndata=ceil(TrigT/Ts);
  SourceLim=abs(raw{6,5});
  
  switch lower(TrigMeth)
    case 'signal driven'
      error('Method (Signal Driven) not implemented yet')
      IdData = iddata(y,u,Ts);
      varargout{1}=IdData;
    case 'external trigger'
      TrigOpt.Repeat=true;
      disp('Waiting for external trigger')
      while TrigOpt.Repeat    
        TrigOpt.Go=false;
        while ~TrigOpt.Go
          try TrigOpt=eval(TrigFun);catch errormsg(3);end
        end      
        try TrigOpt.Repeat; catch TrigOpt.Repeat=false;end
        try
            u=TrigOpt.u(:);
            u(find(u>SourceLim))=SourceLim;% Clip large source signals
            u(find(u<-SourceLim))=-SourceLim;
            tu=TrigOpt.tu;
        catch
            u=[];tu=[];
        end
        [um,y]=simo_triggered_nidaq(so,Ndata,u,tu);
            
        IdData = iddata(y,um,Ts);
        try
          save(TrigOpt.File,'IdData')
          varargout{1}=IdData;
        catch
          varargout{1}=IdData;
        end
      end
    otherwise
      disp('Unknown method')    
  end    
      
  
elseif strcmp(lower(TestType),'logging')
  [num,txt,raw]=xlsread(XLSetFile,'Logging');
  Logp=raw{3,5};
  [t,y]=logging_daq(ao,ai,Logp);    
  varargout{1}=t;
  varargout{2}=y;
  
  
elseif strcmp(lower(TestType),'impact hammer')
   [num,txt,raw]=xlsread(XLSetFile,'Impact Hammer');
   nRefPoints = raw{3,5};
   impactsOnRef = raw{4,5};
   recordTime = raw{5,5};
   triggerLevel = raw{6,5};
   frdsys_impact = impact_hammer_nidaq(so,nRefPoints,impactsOnRef,recordTime,triggerLevel);
   varargout{1} = frdsys_impact;
   % Plot
   impact_hammer_plot(frdsys_impact)
else
  errormsg(4)  
end

%%                                                             Stop the DAQ
%so.stop();

%%                                         Pack the results in data objects




%%                                                           Error messages
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


