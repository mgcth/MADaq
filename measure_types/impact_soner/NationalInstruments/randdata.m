function [t,u]=randdata

u=0.5*randn(1024,1);
u(513:1024)=0;a(1:10)=0;

dt=0.001;
t=0:dt:1023*dt;