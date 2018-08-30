function oscilloscopeFeed(src, event)
% Feed oscilloscope with data
global ScopeFeed

%% Find possible stop state and size info
[~,~,Size,Iret]=GetDoubleFromFile(ScopeFeed.MMF);

%% Make cyclic use of memory file
MaxBlocks=Size(1);
BlockNo=mod(ScopeFeed.I,MaxBlocks); 
if BlockNo==0, BlockNo=MaxBlocks; end

%% Pass data
d=(ScopeFeed.ical*event.Data');
[~,Iret]=PassDoubleThruFile(ScopeFeed.MMF,d,BlockNo);
ScopeFeed.I=ScopeFeed.I+1;


