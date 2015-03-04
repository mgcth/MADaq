function w = wlogspace(wlo,whi,nfhb,dmp,wextra,ord)
%WLOGSPACE: Calculates a frequency vector with equal logarithmic spacing
%Inputs: wlo     - Lowest frequency [rad/s]
%        whi     - Highest frequency
%        nfhb    - Number of frequencies per half-bandwidth
%        dmp     - Damping (in fraction of critical)
%        wextra  - Extra frequencies
%        ord     - Sorting order. 'ascending' or 'descending'
%Output: w       - Resulting frequency vector
%Call:   w = wlogspace(wlo,whi,nfhb,dmp[,wextra,ord])

%% Copyleft: 2013-06-04, Thomas Abrahamsson, Chalmers Univ. of Technology

%% Initiate
if nargin<5,wextra=[];end
if nargin<6, ord='a';end
    
df=dmp*wlo/nfhb/pi;
N=ceil((log10(whi/2/pi)-log10(wlo/2/pi))/(log10(wlo/2/pi+df)-log10(wlo/2/pi))+1);
w=2*pi*logspace(log10(wlo/2/pi),log10(whi/2/pi),N);
  
%%                                    Plug in the extra frequencies, if any  
try
  w=[w(:);wextra(:)];
catch
end      

switch ord(1)
    case 'a'
      w=sort(w,1,'ascend');
    case 'd'
      w=sort(w,1,'descend');
end

end

