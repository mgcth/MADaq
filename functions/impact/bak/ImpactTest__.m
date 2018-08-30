function [FRD,TS]=ImpactTest(ChNames,ChCal,refch,RefName,fcut,FadeTime)
%IMPACTTEST
global Impact

if length(ChCal)==length(ChCal(:)), ChCal=diag(ChCal);end

%%                                                         Initial settings
indTrainHit=[]; TrainHitFound=false; hdh=[]; rmsnoise=-1; biaslvl=[];
FileName=[tempdir 'DataContainer1.mat'];

%%                                                          Hard-coded data
fps=10; Tdelay=1.0; PreTime=0.02; WindowTime=0.2;
Twindow=2.0; CFm=0.5; CrestFactor=10;

%% Save data for PlotHits
plotch=1;
Kill=false; save('Data4PlotHits','refch','plotch','fcut','ChNames','Kill');

%%                           Get the handle to the memmapfile and some data
I=0;
while Impact.DataRead<2
  pause(0.1); I=I+1; if I>50, break, end
end  
if Impact.DataRead<2
  disp('Could not get data from DAQ. Waited 5s. Gave up!')
  error('Could not get data from DAQ. Waited 5s. Gave up!')
end  
[BlocksAvail,Clock0,SizeData]=GetDoubleFromFile(Impact.MMF1);
MaxNoBlocks=SizeData(1);
Rate=Impact.session.Rate; dt=1/Rate;
PreSamples=floor(PreTime/dt);
FadeSamples=floor(FadeTime/dt);
PostSamples=FadeSamples;
WindowSamples=ceil(WindowTime/dt);

%%                                                       Make room for data
mData=SizeData(2);
BlockNt=SizeData(3);
NoFadeBlocks=ceil(FadeTime*Rate/BlockNt);
NBlocksIn1s=ceil(Rate/BlockNt);

%%                                  Call to procedure that collects impacts
Impact.MMF2=PassDoubleThruFile(2,[20 mData (NoFadeBlocks+1)*BlockNt 1]);
strt='cmd /c start /min matlab -nosplash -nodesktop -minimize -r "PlotHitsPre;"';
dos(strt);

%%                                                          Countdown timer
BlockInds=[MaxNoBlocks:-1:1]'; 
NDataInFilmWindow=length(Impact.hplt(1).YData);
NewHitDetected=false; HitNo=0; HitCrestFactor=CrestFactor;
Train=false; TrainDone=false; Collect=false; TrainFade=false;

while 1,
%%                                                       Read data from DAQ
  if HitNo>20,break,end;% Not more than 20 hits allowed
  LastBlockFed=Impact.DataRead;
  Blocks=circshift(BlockInds,LastBlockFed,1); 
  Blocks=Blocks(1:NBlocksIn1s); Blocks=flipud(Blocks(:));
  [DataRead,Iret] = GetDoubleFromFile(Impact.MMF1,Blocks);
  y=DataRead(refch,:,:); y=y(:); 
  Impact.hplt(1).YData=y(1:NDataInFilmWindow);
  pause(.0001)
%%                                                Get state from checkboxes
  Stop=Impact.hui(1).Value;
  Train=Impact.hui(2).Value; %Impact.hui(2).Value=0; 
  Collect=Impact.hui(3).Value;
  if Stop, break, end
  if ~TrainDone && Collect
    Impact.hui(3).Value=0; 
    Collect=0;
  end
  if Train 
    if TrainDone
      Train=0;
      Impact.hui(2).Value=0; 
      Impact.hui(2).Enable='on'; 
    else
      Impact.hui(2).Enable='off'; 
      ym=y-median(y);
      if (norm(ym,'inf')/rms(ym))>CrestFactor; % Training hit found!
        HitCrestFactor=norm(ym,'inf')/rms(ym);  
        TrainFade=true;
        TrainClock=clock;
        TrainDone=true;
        FeedbackString=get(Impact.hui(5),'String');
        FeedbackString{end+1}=sprintf('Training impact detected. Wait for response to fade.');
        set(Impact.hui(5),'String',FeedbackString);
        set(Impact.hui(2),'String','Re-Train');
        set(Impact.hp(1),'Back',[1 0 0],'Title','DON''T HIT AGAIN RIGHT NOW!');
      end    
    end
  elseif TrainFade
      if etime(clock,TrainClock)>FadeTime
         TrainFade=false;
         set(Impact.hp(1),'Back',[.5 1 .5],'Title','Data Film');
      end    
  elseif Collect
      if NewHitDetected
        if LastBlockFed>HitBlock+NoFadeBlocks,% Terminate this hit collection
          Blocks=circshift(BlockInds,HitBlock+NoFadeBlocks,1); 
          Blocks=Blocks(1:NoFadeBlocks+1); Blocks=flipud(Blocks(:));
          [Y,Iret] = GetDoubleFromFile(Impact.MMF1,Blocks);
          PassDoubleThruFile(Impact.MMF2,Y(:),HitNo);
          NewHitDetected=false;
          set(Impact.hp(1),'Back',[.5 1 .5],'Title','Data Film');
        end    
      else    
        ym=y-median(y);
        if (norm(ym,'inf')/rms(ym))> CFm*HitCrestFactor
           NewHitDetected=true;
           HitNo=HitNo+1;
           [~,indmx]=max(abs(ym));
           NBlocksRead=length(Blocks);
           HitBlock=LastBlockFed-NBlocksRead+ceil(indmx/BlockNt);
           FeedbackString=get(Impact.hui(5),'String');
           Nstrings=length(FeedbackString);
           FeedbackString{Nstrings+1}=sprintf(['Hit ' int2str(HitNo) ' detected.']);
           set(Impact.hui(5),'String',FeedbackString,'Value',Nstrings+1);
           set(Impact.hp(1),'Back',[1 0 0],'Title','DON''T HIT AGAIN RIGHT NOW!');
        end
      end  
  end    
end   

close(Impact.hf);
%%                                             Get the selected impact data
HD=helpdlg(['Wait until impactGUI window appears. Then select/unselect data ' ...
         'by left-click in colored fields. You ' ...
         'may also watch the data from various channels by left-click ' ...
         'on the data axes. When that is done, close the impactGUI window.']);
HDpos=get(HD,'Position');set(HD,'Position',[50 50 HDpos(3:4)]); 

Impact.hd=HD;
Kill=true;save('Data4PlotHits','Kill','-append');
[FRD,TS]=PlotHitsPost;
end

function Y=WindowY(Y,refch,PreSamples,WindowSamples);
[ny,my]=size(Y);
W=zeros(1,my);
W(1:(PreSamples+WindowSamples))=1;
W((PreSamples+WindowSamples):(PreSamples+2*WindowSamples-1))=...
    (1+cos(pi*(1:WindowSamples)/WindowSamples))/2;
Y(refch,:)=W.*Y(refch,:);
end