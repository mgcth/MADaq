function FRD2=Blade_Phasewrap(FRD,opt)
% Compensates for phase shift between PXI modules
% Structure of FRD input object assumed to be following:
%       1-6:    Accelerometers 1-6.                 Card #1
%       7:      Phase reference ch. 1 (reference)   Card #1
%       8-14:   Accelerometers 7-13.                Card #2
%       15:     Phase reference ch. 2               Card #2
%       16-22:  Accelerometers 14-20.               Card #3
%       23:     Phase reference ch. 3               Card #3
%       24:     Accelerometer 21.                   Card #4
%       25:     Phase reference ch. 4               Card #4
%
%       Inputs: FRD     -   FRD object to be phase compensated.
%               opt     -   plot option parameter. set 1 for validation
%                           plot.
%       Output: FRD2    -   Phase compensated FRD object with Phase ref.
%                           channels removed.
%
%       Call:   FRD2=Blade_Phasewrap(FRD,opt)

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
phch3=25;

nf=size(FRF,3);

for I=1:nf
    ph=FRF(ref,1,I)/FRF(phch1,1,I);ph=ph/abs(ph);
    FRF(8:15,1,I)=ph*FRF(8:15,1,I);
    ph=FRF(ref,1,I)/FRF(phch2,1,I);ph=ph/abs(ph);
    FRF(16:23,1,I)=ph*FRF(16:23,1,I);
    ph=FRF(ref,1,I)/FRF(phch3,1,I);ph=ph/abs(ph);
    FRF(24:25,1,I)=ph*FRF(24:25,1,I);   
end

FRD2=frd(FRD);
FRD2.ResponseData=FRF([1 2 3 4 5 6 8 9 10 11 12 13 14 16 17 18 19 ...
    20 21 22 24],:,:);

%%
if opt==1
    for I=1:nf
        ph1=FRF(ref,1,I)/FRF(phch1,1,I);ph1=ph1/abs(ph1);
        ph2=FRF(ref,1,I)/FRF(phch2,1,I);ph2=ph2/abs(ph2);
        ph3=FRF(ref,1,I)/FRF(phch3,1,I);ph3=ph3/abs(ph3);
    end
    f=f./2./pi;
    plot(f,angle(ph1),'k',f,angle(ph2),'--r',f,angle(ph3),':g');
end