function celleditcallback(varargin)
Table=varargin{1};
CellEditData=varargin{2};
rawCells=varargin{3};

ind=CellEditData.Indices;row=ind(1);col=ind(2);
if col~=8,return;end

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
    Calib='NaN';
    
    DTA{row,4}=Coupling;
    DTA{row,5}='NaN';% 10 V
    DTA{row,6}=Make;
    DTA{row,7}=Model;
    DTA{row,9}=Calib;
    DTA{row,10}=Unit;
else
    Model=rawCells{ind,4};
    Make=rawCells{ind,6};
    Unit=rawCells{ind,7};
    Coupling=rawCells{ind,8};
    Calib=rawCells{ind,10};
    
    DTA{row,4}=Coupling;
    DTA{row,5}=10;% 10 V
    DTA{row,6}=Make;
    DTA{row,7}=Model;
    DTA{row,9}=Calib;
    DTA{row,10}=Unit;
end

set(gco,'Data',DTA);


