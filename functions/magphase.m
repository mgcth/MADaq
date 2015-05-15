function [m,p]=magphase(f,frf,opt)
%MAGPHASE: Plot and calculate magnitude and phase of frf
% If called by no output arguments only a plot will be made
% No plot will be produced if output arguments are given
%
%Alternative use 1:
%Inputs:   f    - Frequencies (in Hz) associated to frf
%          frf  - Frequency response function (Complex)
%          opt.linlog Set to true creates a linlog plot (else loglog)
%          opt.hold   If true, sets figure status to "hold on"
%          opt.grid   Set to true plots a grid
%          opt.ls     LineStyle (Default is Matlab's plot default)
%          opt.magn   If true, only plot magnitude
%Output:   m    - Magnitude of frf
%          p    - Phase of frf (in degrees)
%          opt  - See above
%Call:     [m,p]=magphase(f,frf,opt)
%Alternative use 2:
%Inputs:   [In Out;  - Identifier for input channel # (In) and output 
%                      channel # (Out)
%           flo fhi] - Lower and upper frequency for plotting
%          FRD       - FRD object
%          opt       - See alternative 1 above
%Output:   m    - Magnitude of frf
%          p    - Phase of frf (in degrees)
%Call:     [m,p]=magphase([In Out;flo fhi],FRD,opt)

%Modified: Nov 11, 2001 (real and imag was switched in atan2)
%Modified: April 16, 2013 changed to use angle and added opt /TA
%Modified: March 8, 2014 modified to also handle FRD objects /TA
%Modified: April 28, 2014 avoid phase flip-flops /TA


if nargin<3,opt.linlog=true;opt.hold=false;end
if ~isfield(opt,'linlog'),opt.linlog=true;end
if ~isfield(opt,'hold'),opt.hold=false;end
if ~isfield(opt,'grid'),opt.grid=false;end
if ~isfield(opt,'ls'),opt.ls='';end
if ~isfield(opt,'magn'),opt.magn=false;end
if strcmpi(class(frf),'frd') || strcmpi(class(frf),'idfrd')
  if min(size(f))==1
    f=f(:)';
    f(2,1)=0;f(2,2)=Inf;% Default for lower and upper frequency
  end  
end

%%                                                 Get data from FRD object
if strcmpi(class(frf),'frd') || strcmpi(class(frf),'idfrd')
  if strcmpi(get(frf,'FrequencyUnit'),'rad/s')
    f0=frf.Frequency/2/pi;
  elseif strcmpi(get(frf,'FrequencyUnit'),'Hz')  
    f0=frf.Frequency;
  elseif strcmpi(get(frf,'FrequencyUnit'),'rad/TimeUnit') & strcmpi(get(frf,'TimeUnit'),'seconds')
    f0=frf.Frequency/2/pi;
  else    
    error('Unknown frequency unit. Only rad/s and Hz allowed.')
  end
  ind=find(f0>=f(2,1) & f0<=f(2,2));
  frf=squeeze(frf.ResponseData(f(1,2),f(1,1),ind));
  f=f0(ind);  
end    

m=abs(frf);
p=angle(frf)*180/pi;

%%                          Make an attempt to make phase do less flip-flop
if size(p,2)~=length(f),p=p';end
if size(p,2)~=length(f),error('Size of transfer function does not match length of frequency vector');end
for I=2:length(f)
  for J=1:size(p,1)
    if abs(abs(p(J,I))-180)<20;% Within 10 degrees of +-180 degrees?
      if abs(abs(p(J,I-1))-180)<20
        if abs(p(J,I)-p(J,I-1))>40
          if p(J,I)<0
             p(J,I)=p(J,I)+360;
          else
             p(J,I)=p(J,I)-360; 
          end      
        end      
      end
    end    
  end
end  

%%                                                                 Do plots
if nargout==0,
  if ~opt.magn, subplot(211);end
  if opt.linlog
    semilogy(f,m,opt.ls)
  else
    loglog(f,m,opt.ls)
  end    
  title('Magnitude')
  xlabel('f [Hz]')
  if opt.grid, grid on,end
  if opt.hold, hold on,end    
  
  if ~opt.magn
    subplot(212)
    if opt.linlog
      plot(f,p,opt.ls)
    else
      semilogx(f,p,opt.ls)
    end  
    v=axis;
    axis([v(1) v(2) -200 200]);
    title('Phase')
    xlabel('f [Hz]')
    if opt.grid, grid on,end
    if opt.hold, hold on,end 
  end
end

