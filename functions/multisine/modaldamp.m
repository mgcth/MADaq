function C=modaldamp(K,M,z,zind,z0)
%MODALDAMP   Establish the viscous damping matrix from given modal dampings
%Inputs: K,M  - Stiffness and mass matrices
%        z    - Relative modal dampings, either as scalar (meaning same
%               damping for all modes) or as vector
%        zind - (optional) index vector for damping values of z
%               z(zind(I)) specifies I:th modes damping value
%        z0   - Damping of modes not specified in zind (default: 0.01);
%Output: C    - Viscous damping matrix
%Call:   C=modaldamp(K,M,z[,zind,z0])

%Written: 2012-09-04, Thomas Abrahamsson
%Modified: 2012-09-27, Addded default damping /TA
%Corrected: 2013-03-30, Corrected for damping spec. /TA

%Reference: Craig & Curdila, Fundamentals of Structural Dynamics, p305

%%                                                        Initiate and test
zdef=0.01;
N=size(K,1);
if length(z)==1,z=z*ones(N,1);zind=1:N;end
if nargin<4,zind=1:length(z);end
if ~isempty(zind)
  if length(z)~=length(zind)
    error('z and zind need to be of same length');
  end
end

%%                                        Solve eigenvalue problem and sort
[V,D]=eig(full(K),full(M));
[Ds,inds]=sort(diag(D));Ds(Ds<0)=0;
V=V(:,inds);

%%                                             Prepare damping value vector
% if length(z)==1
%   z=z*ones(N,1);
% else
  zs=z;
  try
    z=z0*ones(N,1); 
  catch
    z=zdef*ones(N,1);
  end
  z(zind)=zs;
% end

%%                                                   Compute damping matrix
Md=diag(V'*M*V);iMd=diag(1./Md);
Cd=diag(2*z.*sqrt(Ds).*Md);
C=M*V*iMd*Cd*iMd*V.'*M;