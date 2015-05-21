function [y,xend]=simo_multisine_testsys(u,x0)

%Copyleft: 2015-04-24,Thomas Abrahamsson, Chalmers University of Technology

%True model: P=[3600 1725 1200 2200 1320 1330 1500 5250 3600 850 1 1.4 1.2 2.2 2.5 0.9]
P=[3600 1725 1200 2200 1320 1330 1500 5250 3600 850 1 1.4 1.2 2.2 2.5 0.9];
%%                                                          Create matrices
k1=P(1);k2=P(2);k3=P(3);k4=P(4);k5=P(5);k6=P(6);k7=P(7);k8=P(8);k9=P(9);k10=P(10);
K=[k1+k2+k3+k4 -k2  -k3   0    0        -k4;
       0      k2+k5  0    0    0        -k5;
       0        0  k3+k6  0    0        -k6;
       0        0    0  k7+k9  0        -k7;
       0        0    0    0  k8+k10     -k8;
       0        0    0    0    0   k4+k5+k6+k7+k8];
K=K+K'-diag(diag(K));
m1=P(11);m2=P(12);m3=P(13);m4=P(14);m5=P(15);m6=P(16);
M=diag([m1 m2 m3 m4 m5 m6]);
V=modaldamp(K,M,0.01);
[A,B]=kcm2ab(K,V,M);B=B(:,6);
Cv=[zeros(6) eye(6)];
Ca=Cv*A;D=Cv*B;

SS=ss(full(A),full(B),Ca,D);
Ts=0.0005;
SSd=c2d(SS,Ts,'foh');


x=ltitr(SSd.A,SSd.B,u',x0);
y=SSd.C*x'+SSd.D*u;

xend=x(end,:)';
