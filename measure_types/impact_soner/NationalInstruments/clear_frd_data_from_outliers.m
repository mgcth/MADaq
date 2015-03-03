function data_mod=clear_frd_data_from_outliers(data,Flow,Fhigh,sens)
%clear_frd_data_from_outliers
%--------------------------------------------------------------------------
%Function which clears out outliers from measured frd data objects (as
%measured by the nidaq measurment system).
%
%input: data  - frd data object with outlier problems
%       Flow  - lower limit of frequency band with outlier problems (Hz)
%       Fhigh - upper limit of frequency band with outlier problems (Hz)
%       sens  - sensitivity parameter. (error in freq. response larger than 
%                                       10^sens will be removed.)
%output: data_mod - modified data model without outliers.
%
%call: data_mod=clear_frd_data_from_outliers(data,Flow,Fhigh);





H=data.Responsedata;
w=data.Frequency;
dY=zeros(size(H,1),size(H,2),length(w)-1);
for a=1:length(w)-1
dY(a)=norm(abs(H(:,:,a+1))-abs(H(:,:,a)));
end

dYfrd=frd(dY,w(1:end-1));
dYfrd=idfrd(dYfrd);

I=find(abs(dY)>10^(sens));
Ir=I(dYfrd.Frequency(I)>Flow*2*pi);
Irr=Ir(dYfrd.Frequency(Ir)<Fhigh*2*pi);
Irrr=Irr % Irrr=Irr(2:2:end)

H(:,:,Irrr)=[];w(Irrr)=[];

data_mod=idfrd(frd(H,w));