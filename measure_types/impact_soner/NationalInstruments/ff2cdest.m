function [C,D]=ff2cdest(w,H,A,B)
%FF2CDEST: Compute estimations of state-space realization's C and D matrices from 
%          transfer function H. This matrix should be consistent with associated 
%          (given) A and B matrices
%Inputs: w     - Frequencies [rad/s] at which H is given
%        H     - Transfer function matrix with column blocks associated
%                to the frequencies given by w
%        A,B   - State space realization matrices A and B pertinent to H
%Output: C,D   - State space realization matrices C and D consistent with A, B and H
%Call:   [C,D]=ff2cdest(w,H,A,B)

%Copyleft: Thomas Abrahamsson, Applied Mechanics, Chalmers University 
%          of Technology, Sweden
%Written:  April 28, 2003
%Modified: April 29, 2003 /TA  (Speeding up)
%Modified: Aug   13, 2009 /TA  (allowing for complex A and B)
%Modified: Dec   21, 2009 /TA  (3D storage of H)

% -------------------------------------------------------------------------
%                                                         Initiate and test
%                                                         -----------------
if nargin<4, error('FF2CDEST needs 4 arguments');end
nw=length(w);
[n,m]=size(A);if n~=m,error('A must be square');end
[nb,nu]=size(B);if nb~=n,error('Size of B is not consistent with A');end
[ny,mh,nf]=size(H);if mh~=nu,error('Sizes of B and H are not consistent');end
if nf~=nw,error('Sizes of w and H are not consistent');end

% -------------------------------------------------------------------------
%                                                           Set up equation
%                                                           ---------------
% G=[];
% for I=1:nw
%     G=[G H(:,:,I)];
% end    
% G=[G conj(G)];
G=reshape(H(:),size(H,1),size(H,2)*size(H,3));
G=[G conj(G)];

p=myltifr(A,B,i*w);
P=reshape(p(:),n,nw*nu);
for I=1:nw,% rearrange
   P((n+1):(n+nu),(I-1)*nu+[1:nu])=eye(nu);
end
P=[P conj(P)];

warning('');
%if rank(P)==size(P,1)
  CD=G/P;
if ~isempty(lastwarn)    
%  disp('FF2CDEST warning: Data matrix rank deficient. Trying to estimate C with D=0')
  P((n+1):(n+nu),:)=[];
  CD=[G/P zeros(ny,nu)];
end  
        
C=CD(:,1:n);D=CD(:,n+1:n+nu);
if isreal(A) & isreal(B)
    C=real(C);D=real(D);
end    


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
