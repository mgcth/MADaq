function [c,C,rn,rh,rs,pw,cstd]=harmonics_w_stats(y,Ts,f0,refch,order,skipcycles)
% HARMONICS_W_STATS: Obtain harmonical components in data
%Inputs:  y          - The discrete-time signal
%         Ts         - The sampling rate
%         f0         - The fundamental frequency (Hz) of the data
%         refch      - Reference for phase wrap calculation
%         order      - The maximum order of harmonics to calculate
%         skipcycles - Number of cycles to skip at start of time sequence
%                      (in wait for pseudo-stationarity)
%Output:  c    - Complex amplitude of harmonic function. Mean of C
%         C    - Complex amplitude of harmonic function
%         rn   - Normalized (noise) residual
%         rh   - Normalized harmonic distorsion
%         rs   - Stationarity indicator
%         pw   - Phase wrap during block
%         cstd - Standard deviation of c
%Call:    [c,C,rn,rh,rs,pw,cstd]=harmonics(y,Ts,f0,refch,order,skipcycles)

%Created: 2014-03-13, TA


%%                                                       Initiate and check
if nargin<4,error('HARMONICS_W_STATS needs at least 4 input arguments');end
if nargin<5,order=[];end, if isempty(order),order=0;end
if nargin<6,skipcycles=0;end
if size(y,1)<size(y,2), y=y'; end,       % Assume more samples than signals
N=floor(1/Ts/f0);                               % Samples per period
if skipcycles>0,y(1:skipcycles*N,:)=[];end
[Nt,Ny]=size(y);tt=0:Ts:(Nt-1)*Ts;
Ncyc=floor(Nt/N);                        % Number of full cycles in data
w0=2*pi*f0;

%%                                                   Make regression matrix
A=[];t=0:Ts:(N-1)*Ts;
for I=0:order
  A=[A cos((I+1)*w0*t(:)) sin((I+1)*w0*t(:))];
end
[~,mah]=size(A);
A=[A ones(size(t(:))) t(:)]; % For linear trends in data
Ai=pinv(A);

%%                                      Make regressions and calculate some
Nshifts=20;
Ishift=1:round((Nt-N)/Nshifts):Nt-N;tshift=tt(Ishift);
for I=1:Nshifts
  yii=y(Ishift(I)+(0:N-1),refch);
  x=Ai*yii;C(refch,I)=(x(1)-1i*x(2))*exp(-1i*w0*tshift(I));
end    
for I=1:Nshifts
  for II=1:Ny
    yii=y(Ishift(I)+(0:N-1),II);
    x=Ai*yii;C(II,I)=(x(1)-1i*x(2))*exp(-1i*w0*tshift(I));
%     for III=2:order+1
%       c{III}(I)=x(2*III-1,II)-x(2*III,II)*1i;
%     end

    y0=A(:,1:2)*x(1:2);                  % Only zeroth order harmonics
    yh=A(:,1:mah)*x(1:mah);              % All harmonics
    yf=A*x;                              % Full regression        
    rh(II,I)=norm(y0-yh)/norm(y0);
    rn(II,I)=norm(yii-yf)/norm(yii);      
  end
end
for I=1:Nshifts
  for II=1:Ny
    rs(II,I)=max(abs(abs(C(II,:))-mean(abs(C(II,:)))))/mean(abs(C(II,:)));
    pw(II,I)=std(phase(C(II,:)./C(refch,:)));
  end
end


%%                                                     Calculate statistics
c=mean(C,2);cstd=std(C,0,2);
rh=mean(rh,2);
rn=mean(rn,2);
rs=mean(rs,2);
pw=mean(pw,2);
