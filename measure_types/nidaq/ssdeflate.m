function [A,B,C,D]=ssdeflate(w,H,A,B,C,D,order,options)
%SSDEFLATE: Deflate a given state space model to a specific order by
%           deflating the states that give little contribution to the 
%           transfer function differences
%Inputs: w       - Frequencies [rad/s] at which H is given
%        H       - MIMO Transfer function matrix. Of H(i,j,k), ith row is 
%                  for ith output, jth column for jth input and kth layer 
%                  is for kth frequency 
%        A,B,C,D - State space realization matrices.
%        order   - Order of deflated system (or frequency range free from 
%                  poles, see options.range below)
%        options - Function options (not needed)
%                  options.plot>=1 give plot (options.plot=0 is default)
%                  options.method specifies method (see function)
%                  options.range=1 specifies that frequency range given
%                  by order should be free from poles, i.e. if order=[wl wu]
%                  then no poles with oscillating frequency between wl and
%                  wu remains in the deflated model
%Output: A,B,C,D - State space realization matrices of deflated size
%Call:   [A,B,C,D]=ssdeflate(w,H,A,B,C,D,order,options)

%Copyleft: Thomas Abrahamsson, Applied Mechanics, Chalmers University 
%          of Technology, Sweden
%Written:  Aug   14, 2009 /TA
%Modified: Feb   27, 2010 /TA (to MIMO)
%Modified: Apr    7, 2010 /TA (remove poles from range)

% -------------------------------------------------------------------------
%                                                         Initiate and test
%                                                         -----------------
if nargin<7, error('SSDEFLATE needs at least 7 arguments');end
nw=length(w);
if ndims(H)==2,H(:,1,:)=H;end;% Assume SIMO if H is 2D
[n,m]=size(A);if n~=m,error('A must be square');end
[nb,mb]=size(B);if nb~=n,error('Size of B is not consistent with A');end
try options.plot;catch options.plot=0;end
try options.method;catch options.method='difflogmag';end
try options.range;catch options.range=0;end


% -------------------------------------------------------------------------
%                                               Recursively increase states
%                                               ---------------------------
Order=0;
[V,D]=eig(A);D=diag(D);[Ds,ind]=sort(abs(imag(D)));D=diag(D(ind));V=V(:,ind);
[V,A0]=cdf2rdf(V,D);
B0=V\B;
if options.range==0
  A=[];B=[];Atry=A;Btry=B;
  while Order<order
    fits=[];Orderleft=size(A0,1);
    N=size(A,1);
    for I=1:2:Orderleft
      Atry(N+1:N+2,N+1:N+2)=A0(I:I+1,I:I+1);
      Btry(N+1:N+2,:)=B0(I:I+1,:);
      Ntry=size(Atry,1);
%     H3d(:,1,:)=H;
      [Cr,Dr]=ff2cdest(w,H,Atry,Btry);
%    Y=Cr*myltifr(Atry,Btry,i*w);
      X=myltifr(Atry,Btry,i*w);
      for J=1:mb
        Y(:,J,:)=Cr*X((J-1)*Ntry+[1:Ntry],:);
      end    
%    for I=1:nw,Y(:,:,I)=Y(:,:,I)+Dr;end
      if strcmp(options.method,'logmagdiff')
        fits=[fits norm(log(abs(H(:)-Y(:))))];
      elseif strcmp(options.method,'difflogmag')
        fits=[fits norm(log(abs(H(:))-log(abs(Y(:)))))];
      elseif strcmp(options.method,'diff')
        fits=[fits norm(H(:)-Y(:))];
      else
        error(['Unrecognized method in SSDEFLATE: ' options.method])
      end
      if options.plot>2,plotfrf(w,H,Atry,Btry,Cr,0*Dr);end
%    fits
%       1;
    end    
    [mfit,I]=min(fits);I=I(1);
    A(N+1:N+2,N+1:N+2)=A0(2*I-1:2*I,2*I-1:2*I);   
    B(N+1:N+2,:)=B0(2*I-1:2*I,:);
    [C,D]=ff2cdest(w,H,A,B);
    [B,D]=ff2bdest(w,H,A,C);
    Atry=A;
    Btry=B;
  
    A0(2*I-1:2*I,:)=[];A0(:,2*I-1:2*I)=[];
    B0(2*I-1:2*I,:)=[];
    Order=Order+2
    if options.plot>1,plotfrf(w,H,A,B,C,D);end
  
  end
elseif options.range==1
  A=A0;B=B0;
  wl=order(1);wu=order(2);
  if length(order)<2,error('Range must be given by order');end
  indl=find(w<wl);try,indl=indl(end);catch,indl=1;end    
  indu=find(w>wu);try,indu=indu(1);catch, indu=length(w);end
  wr=w([1:indl indu:end]);
  Hr=H(:,:,[1:indl indu:end]);
  inda=[];
  for I=2:2:size(A,1)
    if abs(A(I-1,I))>wl & abs(A(I-1,I))<wu, inda=[inda I];end
  end
  inda=sort([inda (inda-1)]);
  A(inda,:)=[];A(:,inda)=[];
  B(inda,:)=[];
  [C,D]=ff2cdest(wr,Hr,A,B);
  [B,D]=ff2bdest(wr,Hr,A,C);    
end

if options.plot>0,plotfrf(w,H,A,B,C,D);end



% -------------------------------------------------------------------------
%                                                                  Plot FRF
%                                                                  --------
function plotfrf(w,H,A,B,C,D)
hfig=figure;
%Y=C*myltifr(A,B,i*w);
X=myltifr(A,B,i*w);
N=size(A,1);mb=size(B,2);
for J=1:mb
    Y(:,J,:)=C*X((J-1)*N+[1:N],:);
end    
ev=abs(imag(eig(A)));
for I=1:length(w),Y(:,:,I)=Y(:,:,I)+D;end
for I=1:size(H,1)
    for J=1:size(H,2)
      semilogy(w/2/pi,squeeze(abs(H(I,J,:))),'k',...
                                         w/2/pi,squeeze(abs(Y(I,J,:))),'r')
      hold on
      ax=axis;
      for II=1:2:length(ev);
        plot([ev(II) ev(II)]/2/pi,[ax(3) ax(4)],'k:');
        htxt=text(ev(II)/2/pi,10^(log10(ax(3))+(log10(ax(4))-log10(ax(3)))*II/length(ev)),int2str(II/2));
        set(htxt,'color',[0 0 1]);
      end    
      title(['Frequency response function #: ' int2str(I) ',' int2str(J)])
      hold off
      pause
    end   
end  
close(hfig);



% -------------------------------------------------------------------------
%                                          Use Tomas McKelvey's fast LTIFR
%                                          (included here to allow for that 
%                                          FF2CD may be used "stand-alone) 
%                                          --------------------------------
function f = myltifr(A,B,w);
% function f = myltifr(A,B,w);
%
%                                     -1       
%  f((p-1)*n+1:n*p,:) = (w(:) I - A )  B(:,p)
%
%
%  f = [(w(1)I-A)^{-1}B(:,1), (w(2)I-A)^{-1}B(:,1), ... (w(N)I-A)^{-1}B(:,1);
%       (w(1)I-A)^{-1}B(:,2), (w(2)I-A)^{-1}B(:,2), ... (w(N)I-A)^{-1}B(:,2);
%	:
%	:
%       (w(1)I-A)^{-1}B(:,m), (w(2)I-A)^{-1}B(:,m), ... (w(N)I-A)^{-1}B(:,m)]
% 
%   
% Calculates the frequency response kernel of a liner system in state
% space form. A fast version of matlabs LTIFR. 
% Note! Multi input systems is supported.
%
% If the A matrix is defective the standard MATLAB implementation is used.
%

% T. McKelvey 950203. Last Mod 950706

eval('[T,D] = eig(A);','T=[];');
[n,dum] = size(A); if n~=dum, error('A matrix must be square'); end;
[dum,m]  = size(B); if n~=dum, error('A,B matrices not compatible'); end;
N = length(w); 
if size(w,1)==N, w=w.'; end;
f = zeros(n*m,N);
%if rank(T)<n | 1 , disp('Deficient A. Using slow mode');
if rank(T)<n , disp('Deficient A. Using slow mode');
  for p=1:m,
    f((p-1)*n+1:n*p,:) = ltifr(A,B(:,p),w); 
  end;
else
  b = inv(T)*B;
  for p=1:m,
    ff = zeros(n,N);
    for k=1:n,
      ff(k,:) = b(k,p)./(w-D(k,k));
    end;
    f((p-1)*n+1:n*p,:) = T*ff;
  end;
end
