function FRD2=SandvikPhasewrap(FRD)
% Compensates for phase shift between PXI modules



%%
f=FRD.Frequency;
FRF=FRD.ResponseData;FRF0=FRF;
ref=7;% Phase master channel
phch1=15;%Phase slave channels
phch2=17;

nf=size(FRF,3);

for I=1:nf
    ph=FRF(ref,1,I)/FRF(phch1,1,I);ph=ph/abs(ph);
    FRF(8:15,1,I)=ph*FRF(8:15,1,I);
    ph=FRF(ref,1,I)/FRF(phch2,1,I);ph=ph/abs(ph);
    FRF(16:17,1,I)=ph*FRF(16:17,1,I);
end

FRD2=frd(FRD);
FRD2.ResponseData=FRF([1 2 3 4 5 6 8 9 10 11 12 13 14 16],:,:);

    