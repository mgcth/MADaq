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
% To set state:
%        MMF       - The MEMMAPFILE object
%        Flag      - uint8 integer value set to:
%                    0 (uint8(0)) is normal state (default)
%                    1 is flush state (data is flushed)
%                    2 is terminate state (of data receiving process)
%                    3 is halt state (of dta retreiving process)
% To set clock:
%        MMF    - The MEMMAPFILE object (and no more input arguments)
%Output:
% At initiation:
%        MMF    - The memmapfile object
%        Iret   - Return code (=0 if everything went well)
%                 = -2 if error occurred
% At passing data:
%        []     - Empty first output argument
%        Iret   - Return code (=0 if everything went well)
%                 = -1 if in flush state

%Written: 2015-06-19, Thomas Abrahamsson, Chalmers University of Technology
%Modified: 2017-08-23: Added state functionality /TA


%%                                                                 Initiate
Proc=varargin{1};

%%                                                               Do the job
if strcmpi(class(Proc),'double');%          Initiate the data transfer file
  if prod(varargin{2})>5e8
    error(['Too large data set to handle. Requires:' int2str(prod(varargin{2})) ' Available is 100,000,000'])
  end     
  FileName=[tempdir 'DataContainer' int2str(Proc) '.mat'];
  if exist(FileName,'file')
    delete(FileName);
    if exist(FileName,'file'),error('File is locked. It may be associated with a memmapfile object. Try to clear that.');end
  end
  try
    [fh, msg] = fopen(FileName,'wb');
    D=varargin{2};
    nD=prod(D);
    fwrite(fh,[zeros(nD,1);clock';D(:);0;0],'double');% Room for data+clock+size+FlushFlag+No blocks passed
    varargout{2}=0;
  catch
    lasterr
    varargout{1}=[];
    varargout{2}=-2;
    return
  end  
  fclose(fh);
  varargout{1}=memmapfile(FileName, 'Writable', true, 'Format', 'double');
elseif strcmpi(class(Proc),'memmapfile') && nargin==3;%          Write data
  try
    MMF=varargin{1};
    D=varargin{2};
    BlockNo=varargin{3};
    Nblocks=MMF.Data(end-5);
    BlockUse=mod(BlockNo,Nblocks); if BlockUse==0, BlockUse=Nblocks; end
    Nrows=MMF.Data(end-4);
    Ncols=MMF.Data(end-3);
    Nlays=MMF.Data(end-2);
    Flush=MMF.Data(end-1);
    if ~Flush
      NdataInBlock=Nrows*Ncols*Nlays;
      ind=(BlockUse-1)*NdataInBlock+[1:NdataInBlock];
      if length(ind)~=length(D(:)),error('Size mis-match');end
      MMF.Data(ind)=D(:);
%       MMF.Data(end)=MMF.Data(end)+1;
      MMF.Data(end)=BlockNo;
      varargout{2}=0;
    else
      varargout{2}=-1;
    end    
    varargout{1}=varargin{1};
  catch
    lasterr
    varargout{1}=[];
    varargout{2}=-2;
    return
  end  
elseif strcmpi(class(Proc),'memmapfile') && nargin==2;%                Set state  
  MMF=varargin{1};
  Flag=varargin{2};
  varargout{1}=[];
  if strcmpi(class(Flag),'uint8')
    if Flag==1
      MMF.Data(end-1)=1;
    elseif Flag==2
      MMF.Data(end-1)=2;
    elseif Flag==3
      MMF.Data(end-1)=3;
    else
      MMF.Data(end-1)=0;
    end
    varargout{2}=0;
  else  
    varargout{2}=-2;
  end  
elseif strcmpi(class(Proc),'memmapfile') && nargin==1
  Proc.Data(end-[11:-1:6])=clock;
  varargout{1}=Proc;
  varargout{2}=0;
else
  error(' ');
end