function [c,rn,rh,rs,C]=harmonics(y,Ts,f0,order)
% HARMONICS: Obtain harmonical components in data
%Inputs:  y      - The discrete-time signal
%         Ts     - The sampling rate
%         f0     - The fundamental frequency (Hz) of the data
%         order  - The maximum order of harmonics to calculate
%Output:  c   - Complex amplitude of harmonic function
%         rn  - Normalized (noise) residual
%         rh  - Normalized harmonic distorsion
%         rs  - Stationarity indicator
%         C   - Cycle per cycle complex amplitudes
%Call:    [c,rn,rh,rs,C]=harmonics(y,Ts,f0,order)

%Created: 2010-08-14, TA

%%                                                       Initiate and check
if nargin<3,error('HARMONICS needs at least 3 input arguments');end
if nargin<4;order=[];end, if isempty(order),order=0;end
if size(y,1)<size(y,2), y=y'; end,       % Assume more samples than signals
[Nt,Ny]=size(y);
N=floor(1/Ts/f0);                               % Samples per period
Ncyc=floor(Nt/N);                        % Number of full cycles in data
if nargin<5,cheval=1:Ny;end

%%                                                   Make regression matrix
A=[];t=0:Ts:(Nt-1)*Ts;
for I=0:order
    A=[A cos(2*pi*(I+1)*f0*t(:)) sin(2*pi*(I+1)*f0*t(:))];
end
[nah,mah]=size(A);
A=[A ones(size(t(:))) t(:)]; % For linear trends in data
Acyc=A(1:N,1:2);          % Cycle per cycle regression matrix. Zeroth order

for I=1:Ny
%%                                                          Make regression
  x(:,I)=A\y(:,I);

%%                                        Calc complex Fourier coefficients
  for II=1:order+1
    c(I,II)=x(2*II-1,I)-x(2*II,I)*i;
  end
end
   
%%                                                      Reconstruct signals
for I=1:Ny
  y0(:,I)=A(:,1:2)*x(1:2,I);                  % Only zeroth order harmonics
  yh(:,I)=A(:,1:mah)*x(1:mah,I);              % All harmonics
  yf(:,I)=A*x(:,I);                           % Full regression        
end

%%                                                Calc distorsion and noise 
for I=1:Ny
    rh(I)=norm(y0(:,I)-yh(:,I))/norm(y0(:,I));
    rn(I)=norm( y(:,I)-yf(:,I))/norm( y(:,I));
end

%%                                             Calc stationarity properties
if nargout>3
  for I=1:Ncyc
    for II=1:Ny
      xx=Acyc\y((I-1)*N+[1:N],II);
      C(II,I)=xx(1)-i*xx(2);
    end            
  end
  for I=1:Ny
    rs(I)=norm(C(I,:)-mean(C(I,:)))/norm(mean(C(I,:)));
  end    
end
