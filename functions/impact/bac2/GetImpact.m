function GetImpact(src,event)

% Author: Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Revision: 21-May-2015
%           Last revision: 29-June-2015


global ImpactDataRead MMFhit

ImpactDataRead=ImpactDataRead+1;

t=event.TimeStamps;
Y=[event.Data';t'];[ny,my,ly]=size(Y);
if ImpactDataRead==1
  PassDoubleThruFile(MMFhit);
end    
if ImpactDataRead*ny*my*ly<1e8
  PassDoubleThruFile(MMFhit,Y(:),ImpactDataRead);
end  
