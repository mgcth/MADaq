function [FRD,TS]=ImpactTest(ChNames,ChCal,refch,RefName,fcut,FadeTime)
%IMPACTTEST
global Impact
Impact.refch=refch;
Impact.fcut=fcut;
Impact.ChCal = ChCal; % Mladen 2018-04-01

%%                                                         Initial settings
if isfield(Impact,'Trained')
  Trained=true; HitCrestFactor=Impact.HitCrestFactor;
else, Trained=false; end  

%%                                                          Hard-coded data
CFm=0.5; CrestFactor=10;

%% Save data for PlotHits
plotch=1;
Kill=false; save('Data4PlotHits','refch','plotch','fcut','ChNames','Kill');

%%                           Get the handle to the memmapfile and some data
I=0;
while Impact.DataRead<2, pause(0.1); I=I+1; if I>50, break, end, end  
if Impact.DataRead<2
  disp('Could not get data from DAQ. Waited 5s. Gave up!')
  error('Could not get data from DAQ. Waited 5s. Gave up!')
end  
[BlocksAvail,Clock0,SizeData]=GetDoubleFromFile(Impact.MMF1);
MaxNoBlocks=SizeData(1);
Rate=Impact.session.Rate;

%%                                                       Make room for data
mData=SizeData(2); BlockNt=SizeData(3);
NoFadeBlocks=ceil(FadeTime*Rate/BlockNt); NBlocksIn1s=ceil(Rate/BlockNt);
NoFadeBlocks=NoFadeBlocks+1;% Add one extra block

%%                                  Call to procedure that collects impacts
% Impact.MMF2=PassDoubleThruFile(2,[20 mData (NoFadeBlocks+1)*BlockNt 1]);
% strt='cmd /c start /min matlab -nosplash -nodesktop -minimize -r "PlotHitsPre;"';
% dos(strt);

%%                                                          Countdown timer
BlockInds=[MaxNoBlocks:-1:1]'; 
NDataInFilmWindow=length(Impact.hplt(1).YData);
NewHitDetected=false; HitNo=0; HitCrestFactor=CrestFactor;

while 1
%%                                                Get state from checkboxes
  if ~Trained, Impact.hui(3).Enable='off'; end
  Stop=Impact.hui(1).Value; 
  Train=Impact.hui(2).Value;
  Collect=Impact.hui(3).Value;
  if Stop
    break
  elseif Train
    Collect=0;
    Impact.hui(3).Value=0;
    Impact.hui(1).Enable='off'; Impact.hui(2).Enable='off'; Impact.hui(3).Enable='off';
  end    
    
%%                                                       Read data from DAQ
  if HitNo>20,break,end;% Not more than 20 hits allowed
  LastBlockFed=Impact.DataRead;
  Blocks=circshift(BlockInds,LastBlockFed,1); 
  Blocks=Blocks(1:NBlocksIn1s); Blocks=flipud(Blocks(:));
  [DataRead,Iret] = GetDoubleFromFile(Impact.MMF1,Blocks);
  y=DataRead(refch,:,:); y=y(1:NDataInFilmWindow);
  y=y(:)-mean(y); y=y/max(abs(y)); 
  Impact.hplt(1).YData=y;
  y2ch=Impact.hui(4).Value;
  y2=DataRead(y2ch,:,:); y2=y2(1:NDataInFilmWindow); 
  y2=y2(:)-mean(y2); y2=y2/max(abs(y2)); 
  Impact.hplt(2).YData=y2;
  pause(.001)
  
  if Train 
    ym=y-median(y);
    if (norm(ym,'inf')/rms(ym))>CrestFactor; % Training hit found!
      HitCrestFactor=norm(ym,'inf')/rms(ym);  
      FeedbackString=get(Impact.hui(5),'String');
      FeedbackString{end+1}=sprintf('Training impact detected.');
      set(Impact.hui(5),'String',FeedbackString);
      set(Impact.hui(2),'String','Re-Train');
      Impact.hui(1).Enable='on'; Impact.hui(2).Enable='on'; Impact.hui(3).Enable='on';
      Trained=true;
      Impact.hui(2).Value=0; Impact.Trained=true;
      Impact.HitCrestFactor=HitCrestFactor;
      mx=norm(ym,'inf'); Nbig=sum(abs(ym)>.5*mx);
      if Nbig<4, warndlg(['Very few (' int2str(Nbig) ...
          ') samples to represent hit. Try increasing sampling rate']); end
      set(Impact.hp(1),'Back',[.5 1 .5],'Title','Data Film');
      pause(0.1)
    end
  elseif Collect
    if NewHitDetected
      if LastBlockFed>HitBlock+NoFadeBlocks,% Terminate this hit collection
        Blocks=circshift(BlockInds,HitBlock+NoFadeBlocks,1); 
        Blocks=Blocks(1:NoFadeBlocks+1); Blocks=flipud(Blocks(:));
        [Y,Iret] = GetDoubleFromFile(Impact.MMF1,Blocks);
%         PassDoubleThruFile(Impact.MMF2,Y(:),HitNo);
        YY{HitNo}=reshape(Y,size(Y,1),[]);
        phh=PlotHits(YY,refch,y2ch);
        NewHitDetected=false;
        Impact.hui(1).Enable='on'; Impact.hui(2).Enable='on'; Impact.hui(3).Enable='on';
        set(Impact.hp(1),'Back',[.5 1 .5],'Title','Data Film');
      end    
    else    
      ym=y-median(y);
      if (norm(ym,'inf')/rms(ym))> CFm*HitCrestFactor
        NewHitDetected=true; HitNo=HitNo+1;
        [~,indmx]=max(abs(ym));
        NBlocksRead=length(Blocks);
        HitBlock=LastBlockFed-NBlocksRead+ceil(indmx/BlockNt);
        FeedbackString=get(Impact.hui(5),'String');
        Nstrings=length(FeedbackString);
        FeedbackString{Nstrings+1}=sprintf(['Hit ' int2str(HitNo) ' detected.']);
        set(Impact.hui(5),'String',FeedbackString,'Value',Nstrings+1);
        set(Impact.hp(1),'Back',[1 0 0],'Title','DON''T HIT AGAIN RIGHT NOW!');
        Impact.hui(1).Enable='off'; Impact.hui(2).Enable='off'; Impact.hui(3).Enable='off';
      end
    end  
  end    
end   

close(Impact.hf);
close(phh);
% Kill=true;save('Data4PlotHits','Kill','-append');

%%                                             Get the selected impact data
HD=helpdlg(['Select/unselect data ' ...
         'by left-click in colored fields. You ' ...
         'may also watch the data from various channels by left-click ' ...
         'on the data axes. When that is done, close the impactGUI window.']);
HDpos=get(HD,'Position');set(HD,'Position',[50 50 HDpos(3:4)]); 
Impact.hd=HD;
[FRD,TS]=PlotHitsPost(YY,refch,y2ch);
end


