function bs=frfsetblocksize(freq,Fs,Ncycles)
%% FRFSETBLOCKSIZE. Choose blocksize from set of allowed sizes 
%Inputs: freq    - Frequency of sinusiodal signal
%        Fs      - Sampling frequency
%        Ncycles - (Minimum) number of cycles to fit in block
%Output: blocksize
%Call:   blocksize=frfsetblocksize(freq,Fs,Ncycles)


if freq<2,        Freq =   1;
% elseif freq<5,    Freq =   2;
% elseif freq<10,   Freq =   5;
% elseif freq<20,   Freq =  10;
% elseif freq<50,   Freq =  20;
% elseif freq<100,  Freq =  50;
% elseif freq<200,  Freq = 100;
% elseif freq<500,  Freq = 200;
% elseif freq<1000, Freq = 500;
% elseif freq<2000, Freq =1000;
% elseif freq<5000, Freq =2000;
elseif freq<5,    Freq =   2;
elseif freq<10,   Freq =   5;
elseif freq<20,   Freq =  10;
elseif freq<30,   Freq =  20;
elseif freq<40,   Freq =  30;
elseif freq<50,   Freq =  40;
elseif freq<60,   Freq =  50;
elseif freq<70,   Freq =  60;
elseif freq<80,   Freq =  70;
elseif freq<90,   Freq =  80;
elseif freq<100,  Freq =  90;
elseif freq<5000, Freq = 100;
else 
    error('Cannot handle excitation frequencies above 5kHz')
end    

blocksizemin=ceil(Fs/20)+1;%           Warning message issued if blocks are
%                                      generated at a faster rate than 20 
%                                      per second

bs=max([ceil(Ncycles*Fs/Freq) blocksizemin]);%       Allow at least Ncycles
