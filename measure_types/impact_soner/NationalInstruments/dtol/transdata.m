function [t,u]=transdata

u=0.5*randn(1024,1);
u(1:10)=0;u(end-1:end)=0

dt=0.001;
t=0:dt:1023*dt;