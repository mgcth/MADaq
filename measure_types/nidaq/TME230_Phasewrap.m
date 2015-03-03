function FRD2=TME230_Phasewrap2(FRD,opt)
% Compensates for phase shift between PXI modules
% Structure of FRD input object assumed to be following:
%       1-6:    Accelerometers 1-6.                 Card #1
%       7:      Phase reference ch. 1 (reference)   Card #1
%       8-14:   Accelerometers 7-13.                Card #2
%       15:     Phase reference ch. 2               Card #2
%       16-22:  Accelerometers 14-20.               Card #3
%       23:     Phase reference ch. 3               Card #3
%
%       Inputs: FRD     -   FRD object to be phase compensated.
%               opt     -   plot option parameter. set 1 for validation
%                           plot.
%       Output: FRD2    -   Phase compensated FRD object with Phase ref.
%                           channels removed.
%
%       Call:   FRD2=TME230_Phasewrap(FRD,opt)

%Written by Anders Johansson 2012 following template by Thomas Abrahamsson.
%Chalmers University of Technology.

%%
if nargin<2
    opt=0;
end

%%
f=FRD.Frequency;
FRF=FRD.ResponseData;FRF0=FRF;
ref=7;% Phase master channel
phch1=15;%Phase slave channels
phch2=23;

nf=size(FRF,3);

for I=1:nf
    ph=FRF(ref,1,I)/FRF(phch1,1,I);ph=ph/abs(ph);
    FRF(8:15,1,I)=ph*FRF(8:15,1,I);
    ph=FRF(ref,1,I)/FRF(phch2,1,I);ph=ph/abs(ph);
    FRF(16:23,1,I)=ph*FRF(16:23,1,I);
end

FRD2=frd(FRD);
FRD2.ResponseData=FRF([1:6 8:14 16:22],:,:);

%%
if opt==1
    for I=1:nf
        ph1=FRF(ref,1,I)/FRF(phch1,1,I);ph1=ph1/abs(ph1);
        ph2=FRF(ref,1,I)/FRF(phch2,1,I);ph2=ph2/abs(ph2);
    end
    f=f./2./pi;
    plot(f,angle(ph1),'k',f,angle(ph2),'--r');
end