function [CLL,Draw]=xls2cell(xlsname,col)
% Makes non-NaN data in column=col into a cell, Draw are the associated

% Author: Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

% raw table
[~,~,Draw]=xlsread(xlsname);
D=Draw(:,col);
J=0;Ikill=[];
for I=1:length(D)
  if ischar(D{I})
    J=J+1;
    cll{J}=D{I};
  else
    if ~isnan(D{I})
    J=J+1;
    cll{J}=num2str(D{I});
    else
      Ikill=[Ikill I];     
    end
  end
end
Draw(Ikill,:)=[];
CLL{1}=cll;
        
 