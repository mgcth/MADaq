function [cc,yr,yc,yl,A,ind]=harmcoeff2(y,Ts,f,opt)
%%HARMCOEFF Calculates the harmonic coefficients in signals of y
%Inputs:  y      - Signals sampled at rate Ts, ny-by-nt in size
%         Ts     - Sampling rate
%         f      - Vector of frequencies for which coefficients sought for
%         opt.A  - Optional regression matrix
%         opt.o  - If true, single frequency regression is made
%Output:  cc     - Complex valued coefficients
%         yr     - Reconstructued y time-signal
%         yc     - Regression component time-signals, in order of f
%         yl     - Leftovers after successive single-harmonic regressions (i.e. yl=y-yr) in descending order of contribution
%         A      - Regression matrix
%         ind    - Frequency-index in descending order of total magnitude contribution
%Call:    [cc,yr,yrc,yl,ylc,A,ind]=harmcoeff2(y,Ts,f)

%Copyleft: 2014-12-14, Thomas Abrahamsson, Chalmers University of Technology
%Modified to output yc, yl and ind @2016-01-28: Niclas Andersson, Volvo Car Corporation
%Modified: 2016-10-19, Added linear drift to regression model


% -- Initiate
if nargin<4,opt=[];end
if ~isfield(opt,'o'),opt.o=false;end
if isfield(opt,'A');
    A=opt.A;
else
    t=0:Ts:Ts*(size(y,2)-1);
    w=2*pi*f;
    for I=length(f):-1:1
        A(:,2*I-1)=cos(w(I)*t);
        A(:,2*I)  =sin(w(I)*t);
    end
    A(:,end+1)=1;
    A(:,end+1)=t;
end

% -- Do regression and reconstruction
c=A\y';
cc=c(1:2:end-2,:)-1i*c(2:2:end-2,:);
[~,ind]=sort(sum(abs(cc),2),'descend');
if opt.o
    error('Sorry. Single frequency regression code not updated')
    yr=0*y;
    for I=1:length(ind)
        a=A(:,2*ind(I)-1+[0 1]);  % Extracts all rows and 2 cols, i.e. A(:,[ind(I)+0 ind(I)+1])
        c2=a\y';
        cc(ind(I),:)=c2(1,:)-1i*c2(2,:);
        yc(:,:,ind(I))=(a*c2)';
        % yc(:,:,I)=(a*c2)';
        yr=yr+(a*c2)';
        yl(:,:,I)=y-(a*c2)';
        y=y-(a*c2)';
    end
    %yl=y;
else
    yc=[];
    yr=(A*c)';
    yl=y-yr;
end
