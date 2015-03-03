function SSrb=rbmodes_paperD

load OptimizedMatrices.mat %Gives matrices KX MX VX (and a few more)

%Ta reda på vilka frihetsgrader det handlar
%om! 1: mätnod 6.        386 Reverse direction.  (5:e mätta kanalen)
%    2: mätnod 5.        383 Reverse direction.  (1:a mätta kanalen)
%    3: mätnod 15.       389                     (2:a mätta kanalen)
%    4: Front plate PC.      Reverse direction.  (3:e mätta kanalen)
%    5. Back plate PC.                           (4:e mätta kanalen)
PseudoNodeNo=[22 19 25 80 169];
DOFin=3*(PseudoNodeNo-1)+3;                  %All in z-direction.          
DOFout=DOFin;                                %Checked with "JimBeamFRF".
                                             %They seem OK.
%----------------
[PhiFULL,D]=eig(full(KX),full(MX));
[omn2,I]=sort(diag(D));
I=I(1:6);                                     
omn2=[0.4 0.8 1 2 4 5]*2*pi;                  %Modify frequencies based on
omn2=omn2.*omn2;                              %"engineering knowledge".
Phi=PhiFULL(:,I);
mn=zeros(size(omn2));zn=mn;
for ss=1:length(omn2)
    mn(ss)=Phi(:,ss)'*MX*Phi(:,ss);
    zn(ss)=Phi(:,ss)'*VX*Phi(:,ss)./(2*mn(ss)*sqrt(omn2(ss)));
end
SS=modal2ss(omn2,mn,zn,Phi,DOFin,DOFout);
SS.C=SS.C./1000;                              %mm ->m!
SS.B(:,[1 2 4])=-SS.B(:,[1 2 4]);             %Change directions of the 
SS.C([1 2 4],:)=-SS.C([1 2 4],:);             %Appropriate channels.

% SS.C=-SS.C;                                 %Why do I need this? No clue. 
% % EDIT: IT IS OFF BECAUSE THE INPUT FORCE IS%But the phase is off by 180,
% % BLOODY WELL REVERSE FROM ITS DIRECT OUTPUT%and this is what fixes it.

SSrb=SS;