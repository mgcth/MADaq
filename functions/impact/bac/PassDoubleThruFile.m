function varargout=PassDoubleThruFile(varargin)
%% PassDoubleThruFile
%Inputs: Function needs to be called 1st for initiation and then repeatedly
%        for passing data in double precision data blocks
% At initiation:
%        Proc   - Number of process
%        Size   - Vector with size info
%                 Size(1) = Number of blocks to pass
%                 Size(2) = Row dimension of block
%                 Size(3) = Column dimension of block
%                 Size(4) = Layer dimension of block
% To pass data:
%        MMF     - The MEMMAPFILE object
%        D       - The data to be passed
%        BlockNo - The block number to be passed
% To set clock:
%        MMF    - The MEMMAPFILE object (and no more input arguments)
%Output:
% At initiation:
%        MMF    - The memmapfile object
%        Iret   - Return code (=0 if everything went well)

%Written: 2015-06-19, Thomas Abrahamsson, Chalmers University of Technology

%%                                                                 Initiate
Proc=varargin{1};

%%                                                               Do the job
if strcmpi(class(Proc),'double');%          Initiate the data transfer file
  if prod(varargin{2})>1e8
    error(['Too large data set to handle. Requires:' int2str(prod(varargin{2})) ' Available is 100,000,000'])
  end     
  FileName=[tempdir 'DataContainer' int2str(Proc) '.mat'];
  if exist(FileName,'file')
    delete(FileName);
    if exist(FileName,'file'),error('File is locked. It may be associated with a memmapfile object. Try to clear that.');end
  end
  try
    [f, msg] = fopen(FileName,'wb');
    D=varargin{2};
    nD=prod(D);
    fwrite(f,[zeros(nD,1);clock';D(:);0],'double');% Room for data+clock+size+No blocks passed
    varargout{2}=0;
  catch
    lasterr
    varargout{1}=[];
    varargout{2}=-1;
    return
  end  
  fclose(f);
  varargout{1}=memmapfile(FileName, 'Writable', true, 'Format', 'double');
elseif strcmpi(class(Proc),'memmapfile') && nargin==3;%          Write data
  try
    MMF=varargin{1};
    D=varargin{2};
    BlockNo=varargin{3};
    Nrows=MMF.Data(end-3);
    Ncols=MMF.Data(end-2);
    Nlays=MMF.Data(end-1);
    NdataInBlock=Nrows*Ncols*Nlays;
    ind=(BlockNo-1)*NdataInBlock+[1:NdataInBlock];
    if length(ind)~=length(D(:)),error('Size mis-match');end
    MMF.Data(ind)=D(:);
    MMF.Data(end)=MMF.Data(end)+1;
    varargout{1}=varargin{1};
    varargout{2}=0;
  catch
    lasterr
    varargout{1}=[];
    varargout{2}=-2;
    return
  end  
elseif strcmpi(class(Proc),'memmapfile') && nargin==1
  Proc.Data(end-[10:-1:5])=clock;
  varargout{1}=Proc;
  varargout{2}=0;
else
  error(' ');
end
