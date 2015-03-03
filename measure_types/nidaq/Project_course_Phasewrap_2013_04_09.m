function FRD2=Project_course_Phasewrap_2013_04_09(FRD,opt)
% Compensates for phase shift between PXI modules
% Structure of FRD input object assumed to be following:
%       1-6:    Accelerometers 1-6.                 Card #1
%       7:      Phase reference ch. 1 (reference)   Card #1
%       8-12:   Accelerometers 7-11.                Card #2
%       13:     Phase reference ch. 2               Card #2
%
%       Inputs: FRD     -   FRD object to be phase compensated.
%       Output: FRD2    -   Phase compensated FRD object with Phase ref.
%                           channels removed.
%
%       Call:   FRD2=Project_course_Phasewrap_2013_04_09(FRD)

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
phch1=13;%Phase slave channel

nf=size(FRF,3);

for I=1:nf
    ph=FRF(ref,1,I)/FRF(phch1,1,I);ph=ph/abs(ph);
    FRF(8:12,1,I)=ph*FRF(8:12,1,I);
 
end

FRD2=frd(FRD);
FRD2.ResponseData=FRF([1 2 3 4 5 6 8 9 10 11 12],:,:);

%%
if opt==1
    for I=1:nf
        ph1=FRF(ref,1,I)/FRF(phch1,1,I);ph1=ph1/abs(ph1);
    end
    f=f./2./pi;
    plot(f,angle(ph1),'k');
end