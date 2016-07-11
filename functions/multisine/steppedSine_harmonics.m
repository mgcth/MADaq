function [c,rn,rh,rs,C,pw,yf]=steppedSine_harmonics(y,Ts,f0,order,refch)
% HARMONICS: Obtain harmonical components in data
%Inputs:  y      - The discrete-time signal
%         Ts     - The sampling rate
%         f0     - The fundamental frequency (Hz) of the data
%         order  - The maximum order of harmonics to calculate
%         refch  - Reference for phase wrap calculation
%Output:  c   - Complex amplitude of harmonic function
%         rn  - Normalized (noise) residual
%         rh  - Normalized harmonic distorsion
%         rs  - Stationarity indicator
%         C   - Cycle per cycle complex amplitudes
%         pw  - Phase wrap during block
%         yf  - Full regression reconstruction
%Call:    [c,rn,rh,rs,C,pw,yf]=harmonics(y,Ts,f0,order,refch)

%Created: 2010-08-14, TA


%%                                                       Initiate and check
if nargin<3,error('HARMONICS needs at least 3 input arguments');end
if nargin<4;order=[];end, if isempty(order),order=0;end
if size(y,1)<size(y,2), y=y'; end,       % Assume more samples than signals
[Nt,Ny]=size(y);
N=floor(1/Ts/f0);                               % Samples per period
Ncyc=floor(Nt/N);                        % Number of full cycles in data
w0=2*pi*f0;

%%                                                   Make regression matrix
A=[];t=0:Ts:(Nt-1)*Ts;
for I=0:order
    A=[A cos((I+1)*w0*t(:)) sin((I+1)*w0*t(:))];
end
[~,mah]=size(A);
A=[A ones(size(t(:))) t(:)]; % For linear trends in data
Acyc=A(1:N,1:2);          % Cycle per cycle regression matrix. Zeroth order
Ainv=pinv(A);
Acycinv=pinv(Acyc);

c(Ny,order+1)=0;
for I=1:Ny
%%                                                          Make regression
  x(:,I)=Ainv*y(:,I);

%%                                        Calc complex Fourier coefficients
  for II=1:order+1
    c(I,II)=x(2*II-1,I)-x(2*II,I)*1i;
  end
end
   
%%                                                      Reconstruct signals
y0=zeros(size(y));yh=y0;yf=y0;
for I=1:Ny
  y0(:,I)=A(:,1:2)*x(1:2,I);                  % Only zeroth order harmonics
  yh(:,I)=A(:,1:mah)*x(1:mah,I);              % All harmonics
  yf(:,I)=A*x(:,I);                           % Full regression        
end

% figure(5),plot(y(:,4)-mean(y(:,4))),hold on,plot(y0(:,4)-mean(y0(:,4)),'r'),hold off

%%                                                Calc distorsion and noise 
rh=zeros(Ny,1);rn=rh;
for I=1:Ny
    rh(I)=norm(y0(:,I)-yh(:,I))/norm(y0(:,I));
    rn(I)=norm( y(:,I)-yf(:,I))/norm( y(:,I));
end

%%                                             Calc stationarity properties
Nshifts=20;C=zeros(Ny,Nshifts);
Ishift=1:round((Nt-N)/Nshifts):Nt-N;tshift=t(Ishift);

try
if nargout>3
  for I=1:Nshifts
    for II=1:Ny
      ycyc=y(Ishift(I)+(0:N-1),II);
      xx=Acycinv*ycyc;
      C(II,I)=(xx(1)-1i*xx(2))*exp(-1i*w0*tshift(I));
    end
  end
  rs=zeros(Ny,1);
  for I=1:Ny
    rs(I)=max(abs(abs(C(I,:))-mean(abs(C(I,:)))))/mean(abs(C(I,:)));
    pw(I)=std(phase(C(I,:)./C(refch,:)));
  end    
end
catch
  C=NaN;rs=NaN;pw=NaN;
end  