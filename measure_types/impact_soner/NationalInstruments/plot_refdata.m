function [DATA_filt_red]=plot_refdata(data)

t=(0:(length(data.y(:,1))-1))*data.Ts;
data_filt=idfilt(data,2*pi*[50 400]);


f1=figure;hold on;plot(t,data.y(:,1),'k',t,data.u,'r');
figure(f1);hold on;plot(t,data_filt.y(:,1),'c:',t,data_filt.u,'g:');

DATA=fft(data);
DATA_filt=fft(data_filt);

f2=figure;hold on; plot(DATA_filt.Frequency./2./pi,log(abs(DATA_filt.y(:,1))),'m--');

DATA_filt_red=DATA_filt(DATA_filt.Frequency<2*pi*400);
DATA_filt_red=DATA_filt_red(DATA_filt_red.Frequency>2*pi*50);