ts = bounce1;
i = 3;

Ts = diff(ts.Time); Ts=Ts(1);
fs = 1/Ts;
n = 9624:25970;
N = length(n);%ts.Length;
f = fs*(0:N-1)/N;

Y = fft(squeeze(ts.Data(n,i)));

figure
plot(f,abs(Y));
