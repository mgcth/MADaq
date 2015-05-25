function frd2uff(filen,FRD)
% FRD2UFF Writes FRD data to UFF file. Uses writeuff for that purpose
%Inputs: filen - File name of UFF file
%        FRD   - The FRD data object to put on file
%Output: none
%Call:   frd2uff(filen,FRD)

%%                                                            Initial tests
if ~exist('writeuff','file')
  error('Matlab function WRITEUFF required. Download from: www.mathworks.com');
end

%% The following is an example of data written: 
%                        measData: [401x1 double]
%                              d1: 'Trace title'
%                              d2: 'NONE'
%                            date: '10-NOV-93 09:14:24'
%                            ID_4: 'NONE'
%                            ID_5: 'NONE'
%                    functionType: 4
%                      loadCaseId: 0
%                      rspEntName: 'NONE      '
%                         rspNode: 1
%                          rspDir: 1
%                      refEntName: 'NONE      '
%                         refNode: 3
%                          refDir: 1
%                            xmin: 0
%                              dx: 0.0313
%                      zAxisValue: 0
%                    abscDataChar: 18
%         abscLengthUnitsExponent: 0
%          abscForceUnitsExponent: 0
%           abscTempUnitsExponent: 0
%                   abscAxisLabel: 'NONE                '
%                  abscUnitsLabel: 'NONE                             '
%                     ordDataChar: 12
%     ordinateLengthUnitsExponent: 0
%      ordinateForceUnitsExponent: 0
%       ordinateTempUnitsExponent: 0
%               ordinateAxisLabel: 'NONE                '
%           ordinateNumUnitsLabel: 'NONE                             '
%         ordinateDenumUnitsLabel: 'NONE                             '
%                     zUnitsLabel: 'NONE                             '
%                               x: [1x401 double]
%                          dsType: 58
%                          binary: 0

%% Some generic data
D1='NONE';
D2='NONE';
DATE=char(datetime);
FUNCTIONTYPE=4;% Frequency response
RSPDIR=1;
REFDIR=1;
PRECISION='single';
DSTYPE=58;
BINARY=0;

[ny,nu,nf]=size(FRD.ResponseData);
N=0;
for I=1:ny
  for J=1:nu
    N=N+1;% Data set number
    DS{N}.measData=squeeze(FRD.Responsedata(I,J,:));
    DS{N}.x=FRD.Frequency;
    DS{N}.d1=D1;
    DS{N}.d2=D2;
    DS{N}.date=DATE;
    DS{N}.functionType=FUNCTIONTYPE;
    DS{N}.rspNode=I;
    DS{N}.rspDir=RSPDIR;
    DS{N}.refNode=J;
    DS{N}.refDir=REFDIR;
    DS{N}.precision=PRECISION;
    DS{N}.dsType=DSTYPE;
    DS{N}.binary=BINARY;
  end
end  

%% Write to file
writeuff(filen,DS,'replace');
