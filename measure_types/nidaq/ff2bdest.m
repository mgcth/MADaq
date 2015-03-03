function [B,D]=ff2bdest(w,H,A,C)
%FF2BDEST: Compute estimations of state-space realization's B and D matrices from 
%          transfer function H. This matrix should be consistent with associated 
%          (given) A and C matrices
%Inputs: w     - Frequencies [rad/s] at which H is given
%        H     - Transfer function matrix with column blocks associated
%                to the frequencies given by w
%        A,C   - State space realization matrices A and C pertinent to H
%Output: B,D   - State space realization matrices B and D consistent with A, C and H
%Call:   [B,D]=ff2bdest(w,H,A,C)

%Copyleft: Thomas Abrahamsson, Applied Mechanics, Chalmers University 
%          of Technology, Sweden
%Written:  Dec 21, 2009


% -------------------------------------------------------------------------
%                                                         Initiate and test
%                                                         -----------------
if nargin<4, error('FF2BDEST needs 4 arguments');end
nw=length(w);
[n,m]=size(A);if n~=m,error('A must be square');end
[ny,mc]=size(C);if mc~=n,error('Size of C is not consistent with A');end
[nh,nu,fh]=size(H);if nh~=ny,error('Sizes of C and H are not consistent');end
if fh~=nw,error('Sizes of w and H are not consistent');end

% -------------------------------------------------------------------------
%                                               Set up equation:
%                                               [C*inv(iw1-A) I][B]=[H(w1)]
%                                               |C*inv(iw2-A) I|[D] |H(w2)|
%                                               |C*inv(iw3-A) I|    |H(w3)|
%                                                       ...
%                                               [C*inv(iwN-A) I]    [H(wN)]
%                                               ---------------------------
G=[];
for I=1:nw, G=[G;H(:,:,I)];end   
G=[G;conj(G)];

p=myltifr(A,eye(n),i*w);
for I=nw:-1:1
    h=[];
    for II=1:n
        h=[h p([1:n]+(II-1)*n,I)];
    end
    P((I-1)*ny+[1:ny],:)=[C*h eye(ny)];
end    
P=[P;conj(P)];

BD=P\G;
        
B=BD(1:n,:);D=BD(n+1:n+ny,:);
if isreal(A) & isreal(C)
    B=real(B);D=real(D);
end    


% -------------------------------------------------------------------------
%                                          Use Tomas McKelvey's fast LTIFR
%                                          (included here to allow for that 
%                                          FF2BD may be used "stand-alone) 
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
