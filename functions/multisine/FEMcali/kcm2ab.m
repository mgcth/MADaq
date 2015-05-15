function [A,B,Z]=kcm2ab(K,C,M,m)
%KCM2AB: Converts coefficient matrices of second order form to first order
%        form with possible model reduction
%
%        That is from:
%         ..    .
%        Mx  + Cx + Kx = u 
%        
%        To:
%        .
%        x = Ax + Bu   (where x is displacement over velocity)
%
% For reduced system the state vector x is x=Zq where q is the reduced
% state vector associated to the reduced size A.
%
%Input:   K  -  Stiffness matrix
%         C  -  Damping matrix (default zero)
%         M  -  Mass matrix
%         m  -  The number of retained states (optional). Truncation
%               is according to frequency magnitude of undamped eigenfrequencies
%Output:  A  -  Coefficient matrix
%         B  -         -"-
%         Z  - State transformation matrix
%Call:    [A,B,Z]=kcm2ab(K,C,M,m)

% Copyleft: Thomas Abrahamsson, Chalmers University of Technology, Sweden
% Written: 1994
% Modified: 2007-11-21 /TA, Made more efficient and with reduction possibility
% Modified: 2011-10-28 /TA, Minor modification

% -----------------------------------------------------------------------------
%                                                                         Tests
%                                                                         -----
if isempty(C),C=zeros(size(K));end
[ n,mK]=size(K);if  n~=mK,error('KCM2AB: K matrix not square'),end
[nC,mC]=size(C);if nC~=mC,error('KCM2AB: C matrix not square'),end
[nM,mM]=size(M);if nM~=mM,error('KCM2AB: M matrix not square'),end
if nM~=n,error('KCM2AB: M and K matrix dimensions do not agree'),end
if nC~=n,error('KCM2AB: C and K matrix dimensions do not agree'),end

if nargin<4,m=n;end
if m>n,error('Number of retained states cannot be more than order of system'),end


% -------------------------------------------------------------------------
if m==n, % No reduction
  I=speye(n);O=sparse(zeros(n));
  iM=M\[-K -C I];
  A=[O I;iM(:,1:2*n)];
  B=[O;iM(:,2*n+1:end)];
%   iM=inv(M);
%   A=[O I;iM*[-K -C]];
%   B=[O;iM];
  Z=[I O;O I];
else, % Do reduction  
  [v,d]=eig(full(K),full(M));
  [d,ind]=sort(diag(d));v=v(:,ind);
  v=v(:,1:m);d=d(1:m);% Reduce
  for I=1:m,v(:,I)=v(:,I)/sqrt(v(:,I)'*M*v(:,I));end, %Mass orthonormalize
  I=speye(m);O=sparse(zeros(m));Ov=sparse(zeros(size(v)));
  A=sparse([O I;-diag(d) -v'*C*v]);
  B=sparse([Ov';v']);
  Z=[v Ov;Ov v];
end  
  


