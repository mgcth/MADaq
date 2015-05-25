function celleditcallback(varargin)

% Author: Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

Table=varargin{1};
CellEditData=varargin{2};
rawCells=varargin{3};

ind=CellEditData.Indices;row=ind(1);col=ind(2);
if col~=10,return;end

was=CellEditData.PreviousData;
isnow=CellEditData.NewData;
if ~ischar(isnow),isnow=num2str(isnow);end

DTA=get(gco,'Data');

% Find which one that is picked (from 5th column)
ind=0;
for I=1:size(rawCells,1)
    dta=rawCells{I,5};
    if ~ischar(dta),dta=num2str(dta);end
    if strcmp(dta,isnow),ind=I;end
end

if ind == 0
    Model='NaN';
    Make=char([]);
    Unit=char([]);
    Coupling=char([]);
    Type=char([]);
    Calib='NaN';
    
    DTA{row,5}=Coupling;
    DTA{row,6}=Type;
    DTA{row,7}='NaN';% 10 V
    DTA{row,8}=Make;
    DTA{row,9}=Model;
    DTA{row,11}=Calib;
    DTA{row,12}=Unit;
else
%     Model=rawCells{ind,4};
%     Make=rawCells{ind,6};
%     Unit=rawCells{ind,7};
%     Coupling=rawCells{ind,8};
%     Calib=rawCells{ind,10};
    Model=rawCells{ind,4};
    Make=rawCells{ind,6};
    Unit=rawCells{ind,7};
    %Coupling=rawCells{ind,8};
    Type=rawCells{ind,8};
    Calib=rawCells{ind,10};
    
    %DTA{row,5}=Coupling;
    DTA{row,6}=Type;
    DTA{row,7}=10;% 10 V
    DTA{row,8}=Make;
    DTA{row,9}=Model;
    DTA{row,11}=Calib;
    DTA{row,12}=Unit;
end

set(gco,'Data',DTA);


