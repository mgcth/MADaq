function varargout=dtoldaq(in)
%DTOLDAQ: Data acquisition with Data Translations DT9837A device
%

%Written: 2010-08-11 by Thomas Abrahamsson

%% ------------------------------------------------------------------------
%                                                                    Global
%                                                                    ------
global CH

%%                                                                 Initiate
if nargin<1,in=[];end

%%                               Open Settings and Calibrations spreadsheet
Dir0=pwd;
Dir=which('dtoldaq');ind=find(Dir=='\');Dir=[Dir(1:ind(end)) 'xls'];
if strcmp(lower(in),'go')
  XLSetFile=[Dir '\dtol_active.xls'];
else
  cd(Dir);
  [Name,Dir]=uigetfile('*.xl*');
  XLSetFile=[Dir Name];
  Stat=dos(['excel "' XLSetFile '"']);if Stat, errormsg(1);end
  copyfile(XLSetFile,[Dir '\dtol_active.xls']);
  cd(Dir0);
end

%%                  For stability: Stop and delete data acquisition objects
try,stop(daqfind);catch,end
try,delete(daqfind);catch,end

%%                                         Get some channel characteristics
[num,txt,raw]=xlsread(XLSetFile,'Settings');
TestType=raw{3,3};            % Sample Rate is in (3,3) cell of spreadsheet
RefInd=raw(6:9,8);CH.refch=[];
ActInd=raw(6:9,7);CH.active=[];
for I=1:4
  if strcmp(lower(RefInd(I)),'yes'), CH.refch=[CH.refch I];end  
  if strcmp(lower(ActInd(I)),'yes'), CH.active=[CH.active I];end
end
if length(CH.refch)~=1,error('There needs to be ONE reference channel'),end

%%                                            Setup Analog Output and Input
ao=dtolaosetup(XLSetFile);
ai=dtolaisetup(XLSetFile);

%%                                                       Do the measurement
if strcmp(lower(TestType),'stepped sine')
  [num,txt,raw]=xlsread(XLSetFile,'Stepped-Sine');
  Freqs=eval(raw{3,4});
  Loads=eval(raw{4,4});
  Convp=raw(8:11,5);
  try,CH.eval=eval(raw{7,5});catch, CH.eval=raw{7,5};end
%  SSarray.chplot=cheval(1);
%  SSarray.refno=refch(1);
  [f,Y,stdY]=simo_frf_daq(ao,ai,Freqs,Loads,Convp);
  FRD=frd(Y,f,'Units','Hz');
  varargout{1}=FRD;
elseif strcmp(lower(TestType),'random')
  [num,txt,raw]=xlsread(XLSetFile,'Random');
  RandType=raw(3,5);
  try
    [t,Load]=eval(raw{4,5});
  catch
    errormsg(2);
  end
  Randp=raw(5:6,5);
  refch=raw{2,8};
  Ts=1/ai.SampleRate;
  Load=interp1(t,Load,t(1):Ts:t(end));
  [f,Y]=simo_rand_daq(ao,ai,Load,refch,Randp);
  FRD=frd(Y,f,'Units','Hz');
  varargout{1}=FRD;
elseif strcmp(lower(TestType),'transient')
  [num,txt,raw]=xlsread(XLSetFile,'Transient');
  try
    [t,Load]=eval(raw{3,5});
  catch
    errormsg(2);
  end
  Transp=raw{4,5};
  refch=raw{2,8};
  Ts=1/ai.SampleRate;
  Load=interp1(t,Load,t(1):Ts:t(end));
  [t,y]=simo_trans_daq(ao,ai,Load,refch,Transp);  
  varargout{1}=t;
  varargout{2}=y;
elseif strcmp(lower(TestType),'logging')
  [num,txt,raw]=xlsread(XLSetFile,'Logging');
  Logp=raw{3,5};
  [t,y]=logging_daq(ao,ai,Logp);    
  varargout{1}=t;
  varargout{2}=y;
else
  errormsg(3)  
end

%%                                                             Stop the DAQ
stop([ao ai])

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
    disp('Unknown data acqusition type.')
    disp(' ')
end   


