function [m,p]=magphase(f,frf,opt)
%MAGPHASE: Plot and calculate magnitude and phase of frf
% If called by no output arguments only a plot will be made
% No plot will be produced if output arguments are given
%
% Alternative 1:
%Inputs:   f    - Frequencies (in Hz) associated to frf
%          frf  - Frequency response function (Complex)
%          opt.linlog Set to true creates a linlog plot (else loglog)
%          opt.hold   If true, sets figure status to "hold on" before
%                     plotting
%          opt.grid   Set to true plots a grid
%          opt.ls     LineStyle (Default is Matlab's plot default)
%          opt.magn   If true, only plot magnitude
%          opt.ax     Axis setting for magnitude plot
%Output:   m    - Magnitude of frf
%          p    - Phase of frf (in degrees)
%          opt  - See above
%Call:     [m,p]=magphase(f,frf,opt)
%
%Alternative 2:
%Inputs:   [In Out;  - Identifier for input channel # (In) and output 
%                      channel # (Out)
%           flo fhi] - Lower and upper frequency for plotting
%          FRDorSS   - FRD or SS object
%          opt       - See alternative 1 above
%Output:   m    - Magnitude of frf
%          p    - Phase of frf (in degrees)
%Call:     [m,p]=magphase([In Out;flo fhi],FRDorSS,opt)

%Modified: Nov 11, 2001 (real and imag was switched in atan2)
%Modified: April 16, 2013 changed to use angle and added opt /TA
%Modified: March 8, 2014 modified to also handle FRD objects /TA
%Modified: April 28, 2014 avoid phase flip-flops /TA
%Modified: June 29, 2015 to also treat SS objects
%Modified: July  7, 2015 to include plot title



if nargin<3,opt.linlog=true;opt.hold=false;end
if ~isfield(opt,'linlog'),opt.linlog=true;end
if ~isfield(opt,'hold'),opt.hold=false;end
if ~isfield(opt,'grid'),opt.grid=false;end
if ~isfield(opt,'ls'),opt.ls='';end
if ~isfield(opt,'magn'),opt.magn=false;end
if ~isfield(opt,'ax'),opt.ax=[];end
if ~isfield(opt,'title'),opt.title=[];end
if strcmpi(class(frf),'frd') || strcmpi(class(frf),'idfrd')
  if min(size(f))==1
    f=f(:)';
    f(2,1)=0;f(2,2)=Inf;% Default for lower and upper frequency
  end  
end
if strcmpi(class(frf),'ss') || strcmpi(class(frf),'idss')
  if get(frf,'Ts')>0,error('Cannot treat discrete-time state-space models');end
  [Wn,zeta] = damp(frf);zetamin=min(zeta);
  if min(size(f))==1
    f=f(:)';
    f(2,1)=0.8*Wn(1)/2/pi;f(2,2)=1.2*Wn(end)/2/pi;% Default for lower and upper frequency
  end  
end

range=false;

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
  try
    mrange=frf.UserData.mrange;
    mrange=squeeze(mrange(f(1,2),f(1,1),ind,:));
    range=true;
  catch
    range=false;
  end    
  frf=squeeze(frf.ResponseData(f(1,2),f(1,1),ind));
  f=f0(ind); 
end    

%%                                                  Get data from SS object
if strcmpi(class(frf),'ss') || strcmpi(class(frf),'idss')
  w=wlogspace(0.8*Wn(1),1.2*Wn(end),5,zetamin);
  while length(w)>1600, w=w(1:2:end);end  
  FRD=frd(frf,w);
  frf=squeeze(FRD.ResponseData(f(1,2),f(1,1),:));
  f=w/2/pi;
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
%   if ~opt.hold,axis('auto');end
  if ~opt.magn, subplot(211);end
  if opt.hold, hold on,else, hold off,end 
  if ~opt.hold,axis('auto');end
  
%   if ~opt.hold,cla;end
  if opt.linlog
    if range
      fr=[f(:) f(:) f(:)]';fr=fr(:);
      mrange=[mrange NaN*zeros(size(mrange,1),1)]';
      mrange=mrange(:);
      hl=semilogy(fr,mrange,f,m,opt.ls);
      set(hl(1),'Color',[.6 1 .6],'LineWidth',.01);
      set(hl(2),'MarkerSize',4);
      try set(hl(2),'Color',opt.color);catch,end
    else
      hl=semilogy(f,m,opt.ls);
      try set(hl(1),'Color',opt.color);catch,end
    end
    axis tight
    ax=axis;
%     expo=10^floor(log10(f(end)));
%     axis([round(f(1),1,'significant') (round(f(end),1,'significant')/expo+1)*expo ax(3) ax(4)]);
%     ax=axis;
  else
    if range
      fr=[f(:) f(:) f(:)]';fr=fr(:);
      mrange=[mrange NaN*zeros(size(mrange,1),1)]';
      mrange=mrange(:);
      hl=loglog(fr,mrange,f,m,opt.ls);,
      set(hl(1),'Color',[.6 1 .6],'LineWidth',.01);
      set(hl(2),'MarkerSize',4);
      try set(hl(2),'Color',opt.color);catch,end
    else    
      hl=loglog(f,m,opt.ls);
      try set(hl(1),'Color',opt.color);catch,end
    end  
%     expo=10^floor(log10(f(end)));
    axis tight
    ax=axis;
%     axis([round(f(1),2,'significant') (round(f(end),2,'significant')/expo+1)*expo ax(3) ax(4)]);
    axis([round(f(1)-.49,2,'significant') round(f(end)+.49,2,'significant') ax(3) ax(4)]);
    ax=axis;
  end
  if ~isempty(opt.ax),axis(opt.ax);end
  if ~isempty(opt.title), title(opt.title),else, title('Magnitude'),end
  xlabel('f [Hz]')
  if opt.grid, grid on,end
%   if opt.hold, hold on,end    
  
  if ~opt.magn
    subplot(212)
    if opt.hold, hold on,else hold off,end 
    if ~opt.hold,cla;end
    if opt.linlog
      hl=plot(f,p,opt.ls);
      set(hl(1),'MarkerSize',4);
      try set(hl(1),'Color',opt.color);catch,end
    else
      hl=semilogx(f,p,opt.ls);
      set(hl(1),'MarkerSize',4);
      try set(hl(1),'Color',opt.color);catch,end      
      ax0=axis;
      axis([ax(1) ax(2) ax0(3) ax0(4)]);
    end  
%     v=axis;
%     axis([v(1) v(2) -200 200]);
    axis([ax(1) ax(2) -200 200]);
    title('Phase')
    xlabel('f [Hz]')
    if opt.grid, grid on,end
    if opt.hold, hold on,end 
  end
end

