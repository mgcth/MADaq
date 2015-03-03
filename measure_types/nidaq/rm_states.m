function varargout=rm_states(A,B,C,D,rm)
%------------------------------- rm_states --------------------------------
%RM_STATES: Function which removes unwanted states from a state-space model
%on real diagonal form (c.f. function "REALDIAGFORM"), such that the output
%model has those states removed.
%
%Input:     SS / A,B,C,D - State space object / matrices
%               rm       - list of which states to remove (OBS! numbered as
%                           eigenmodes, that is one represents first two
%                           columns of the state matrix, etc.)
%Output:    SS / A,B,C,D - Reduced state space object / matrices

%--------------------------------------------------------------------------
%                                                          Tests
%                                                          ----------------
if nargin==2
    rm=B;
    SS=A;clear A;A=SS.A;B=SS.B;C=SS.C;D=SS.D;
elseif nargin~=5
    error('bad number of inputs');
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%                                                           Code
%                                                           ---------------
for a=1:length(rm)
    DelRC((2*a-1):(2*a))=[2*rm(a)-1 2*rm(a)];
end
A(DelRC,:)=[];
A(:,DelRC)=[];
B(DelRC,:)=[];
C(:,DelRC)=[];

if nargout==1
    varargout{1}=idss(ss(A,B,C,D));
elseif nargout==4
    varargout{1}=A;
    varargout{2}=B;
    varargout{3}=C;
    varargout{4}=D;
end
%------------------------- end of function --------------------------------