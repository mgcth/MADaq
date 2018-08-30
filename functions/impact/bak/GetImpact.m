function GetImpact(src,event)

% Author: Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Revision: 21-May-2015
%           Last revision: 29-June-2015


global Impact

if ~Impact.DataRead;% Set clock at 1st time called
  PassDoubleThruFile(Impact.MMF1);
end  
  
Impact.DataRead=Impact.DataRead+1;

t=event.TimeStamps; 
Y=[event.Data';t'];

[~,Iret]=PassDoubleThruFile(Impact.MMF1,Y(:),Impact.DataRead);
