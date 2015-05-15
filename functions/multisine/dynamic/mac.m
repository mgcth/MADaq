function MAC=mac(Z1,Z2,opt,depthZ2)
%MAC: Computes the MAC-matrix using the mode matrices Z1 and Z2
%Inputs:   Z1     - First modal matrix containing modes as column vectors
%          Z2     - Second modal matrix containing modes as column vectors. If
%                   depthZ2 > 1 the groups of modes are stoved on top of each
%                   other
%          opt    - 1 gives standard MAC calculation (default if depthZ2=1)
%                   2 gives cosines of subspace angles
%Output:   MAC    - MAC-matrix
%Call:     MAC=mac(Z1,Z2,opt,depthZ2)

% Copyleft: Thomas Abrahamsson, Linkping, Sweden
% Written:  Oct    4, 1993
% Modified: April 16, 1994 /TA
% Modified: June  14, 1995
% Modified: June  19, 1995
% Modified: Nov   11, 2001 (real added to ensure that MAC is real also for
%                           complex vectors)
% Modified: Dec   12, 2013 Removed bottleneck for set opt and depthZ2 
%                          and made MAC computations more efficient /TA
% Modified: Jan    2, 2015, More efficient code /TA

% ------------------------------------------------------------------------------
%                                                             Initiate and check
%                                                             ------------------
tol=1.e6*eps;
if nargin<2,
  error('Too few input arguments to MAC')
elseif nargin<3
  opt=1;depthZ2=1;
elseif nargin<4
  depthZ2=1;
end

[n1,m1]=size(Z1);[n2,m2]=size(Z2);n2=n2/depthZ2;
if n1~=n2,
  error('The row dimension of the two mode matrices must be the same')
end
if (depthZ2~=1 && opt==1),
  error('Error in MAC: opt=1 is not allowed when depthZ2>1')
end

if opt==1,
% -------------------------------------------------------------------------
%                                                              Standard MAC
%                                                              ------------
MAC=(abs(Z2'*Z1).^2)./(sum(conj(Z2).*Z2)'*sum(conj(Z1).*Z1));
% Code according to Claudius Lein (in e-mail 2014-11-20)
% vTmp1 = diag(Z1'*Z1);
% vTmp2 = diag(Z2'*Z2);
% MAC   = ((Z1'*Z2).^2)./ ...
%         (repmat(vTmp1,1,length(vTmp2)).*repmat(vTmp2',length(vTmp1),1));

% Old, less efficient code
%    for I=1:m1,
%     for II=1:m2,
%       MAC(II,I)=real((Z1(:,I)'*Z2(:,II))*conj(Z1(:,I)'*Z2(:,II)))/ ...
%                norm(Z1(:,I))^2/norm(Z2(:,II))^2;
%     end
%    end

else
% ------------------------------------------------------------------------------
%                                                  MAC using square of cosine of
%                                                  subspace angle
%                                                  -----------------------------
  for I=1:m1,
    for II=1:m2,
      MAC(II,I)=(cos(subspac2(Z1(:,I),reshape(Z2(:,II),n2,depthZ2),tol)))^2;
    end
  end
end

function theta = subspac2(A,B,tol)
%SUBSPAC2 Angle between two subspaces.
%  SUBSPAC2(A,B,tol) finds the angle between two subspaces specified by the
%  columns of A and B.  If A and B are vectors of unit length, this is the
%  same as ACOS(A'*B). 
%  If the angle is small, the two spaces are nearly linearly dependent. The 
%  rank of A and B will be checked using: rank(A,tol) and rank(B,tol).  Rank 
%  deficient matrices will be substituted will lower column order matrices 
%  of full rank.
%Inputs: A,B   - Subspace matrices
%        tol   - Tolerance parameter for rank determination
%Output: theta - Angle between subspaces  
%Call:   theta=subspac2(A,B,tol)
%See also: SUBSPACE     

%Copyright: Thomas Abrahamsson, Saab Military Aircraft, Linkoping, Sweden
%Written:  June  19, 1995
%Modified: June  27, 1995

% -------------------------------------------------------------------------------
%                                                              Initiate and check
%                                                              ------------------
if nargin<3,tol=eps;elseif isempty(tol),tol=eps;end
[na,ma]=size(A);[nb,mb]=size(B);
if na ~= nb
   error('Row dimensions of A and B must be the same.')
end

% -------------------------------------------------------------------------------
%                           Calculate rank and create non-rank-deficient matrices
%                           -----------------------------------------------------
[U,S,V] = svd(A);U=U(:,1:ma);S=S(1:ma,1:ma);
if na ~= 1, s = diag(S); else, s = S(1,1); end
r = sum(s > tol);
A = U(:,1:r);

[U,S,V] = svd(B);U=U(:,1:mb);S=S(1:mb,1:mb);
if nb ~= 1, s = diag(S); else, s = S(1,1); end
r = sum(s > tol);
B = U(:,1:r);

[na,ma]=size(A);[nb,mb]=size(B);

% -------------------------------------------------------------------------------
%                                         Compute the angle between the subspaces
%                                         ---------------------------------------
[QA,ignore] = qr(A);QA=QA(:,1:ma);
[QB,ignore] = qr(B);QB=QB(:,1:mb);
s = svd(QA'*QB);
% The max singular value is the correct one to choose
% but should have magnitude no more than 1.
theta = acos(min(min(s),1));
