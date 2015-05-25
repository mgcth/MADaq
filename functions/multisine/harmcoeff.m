function [cc,yr,yl,A]=harmcoeff(y,Ts,f,opt)
%%HARMCOEFF Calculates the harmonic coefficients in signals of y
%Inputs:  y      - Signals sampled at rate Ts, ny-by-nt in size
%         Ts     - Sampling rate
%         f      - Vector of frequencies for which coefficients sought for
%         opt.A  - Optional regression matrix
%         opt.o  - If true, single frequency regression is made
%Output:  cc     - Complex valued coefficients
%         yr     - Reconstructued y
%         yl     - The leftovers of y, i.e. yl=y-yr
%         A      - Regression matrix
%Call:    [cc,yr,yl,A]=harmcoeff(y,Ts,f)

%Copyleft: 2014-12-14, Thomas Abrahamsson, Chalmers University of Technology

%%                                                                 Initiate
if nargin<4,opt=[];end
if ~isfield(opt,'o'),opt.o=false;end
if isfield(opt,'A');
  A=opt.A;
else  
  t=0:Ts:Ts*(size(y,2)-1);
  w=2*pi*f;
  for I=length(f):-1:1
    A(:,2*I-1)=cos(w(I)*t);
    A(:,2*I)  =sin(w(I)*t);
  end
end

%%                                         Do regression and reconstruction
c=A\y';
cc=c(1:2:end,:)-1i*c(2:2:end,:);  
if opt.o
%   cc2=cc;
  yr=0*y;
  [~,ind]=sort(sum(abs(cc),2),'descend');
  for I=1:length(ind)
    a=A(:,2*ind(I)-1+[0 1]);
    c2=a\y';
    cc(ind(I),:)=c2(1,:)-1*i*c2(2,:);
    yr=yr+(a*c2)';
    y=y-(a*c2)';
  end
  yl=y;
else  
  yr=(A*c)';
  yl=y-yr;
end
