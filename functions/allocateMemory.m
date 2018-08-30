function allocateMemory(handles)
% ALLOCATEMEMORY - allocate memory for acquired data
%
% Syntax:  allocateMemory(handles)
%
% Inputs:
%    input - handles
%
% Outputs:
%    output - none
%
% Example: 
%    allocateMemory(handles)
%
% Other m-files required: folders in parent and subfolders
% Subfunctions: none
% MAT-files required: none
%
% See also: NONE

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global dataObject

% Update the status bar
set(handles.statusStr, 'String', 'Allocating memory ...');
drawnow();

% Allocate the memory for dataObject
Chdata = get(handles.channelsTable, 'data');
Chact = sum([Chdata{:, 1}]);
if Chact==0,error('Seems that no channels are active');end
[uv,sv]=memory;
memmax=sv.PhysicalMemory.Available;

% Don't use more that half of available memory, only half of that for now
ntmax=round(memmax/4/Chact/2/2);
dataObject.nt=0;
dataObject.t=0;
dataObject.data=0;
dataObject.ntmax=0;

% % Do real allocation
% if get(handles.dataLogg,'Value') == 1 || get(handles.monitor,'Value') == 1
%     dataObject.nt=0;
%     dataObject.t=zeros(ntmax,1);
%     dataObject.data=zeros(ntmax,Chact);
%     dataObject.ntmax=ntmax;
% end
