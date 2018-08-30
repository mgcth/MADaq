function abraSCOPE(Rate,QuitState)
%abraSCOPE
%Inputs: Rate      - Sampling rate
%        QuitState - 0 just terminates abraSCOPE
%                    1 also quit the Matlab session

global abraScope abraScopeData
% dbstop at 9 in abraSCOPE
abraScopeData.fs=Rate;
% keyboard
if nargin<2, QuitState=0; end

%%                                                             Open the GUI
H=abraSCOPEgui;
SC=get(0,'ScreenSize');
Pos=abraScope.FH.Position; Cww=Pos(3); Cwh=Pos(4);
abraScope.FH.Position=[20 SC(4)-Cwh-40 Cww Cwh];
Pos=abraScope.fht.Position; Fww=Pos(3); Fwh=Pos(4); 
abraScope.fht.Position=[40+Cww SC(4)-Fwh-40 Fww Fwh];
abraScope.fhl.Position=abraScope.fht.Position;
abraScope.fhp.Position=abraScope.fht.Position;

%%                                          Get settings from abraScopeData 
fs=abraScopeData.fs;

%%                                          Make initial search in MMF file
MMF=GetDoubleFromFile(1);% Initiate
Nblock=0;
while Nblock<1
  [Nblock,~,Size]=GetDoubleFromFile(MMF);
  pause(0.1)
end  
Nblocks=Size(1); Nch=Size(2); Nscans=Size(3); T=Nscans/fs;
BlockInd=Nblocks:-1:1;

load(fullfile(tempdir,'abraScope'),'ChLabels');
for I=1:Nch
  try
    if isempty(deblank(ChLabels{I}))
      ChLabels{I}=['Ch# ' int2str(I)];
    end
  catch
    ChLabels{I}=['Ch# ' int2str(I)];
  end    
end      
abraScope.hCh1.String=ChLabels;
abraScope.hCh2.String=ChLabels;

%%                                                             Get GUI data
Spans=[1 0.5 .1 0.050 0.010 0.005]; Tlabels={'0.1s' '50ms' '10ms' '5 ms' '1ms' '0.5ms'};
Span=Spans(abraScope.hTspan.Value);% Get span
NBlocksInSpan=ceil(Span/T);
tind=1:floor(Span*fs); tind=tind+NBlocksInSpan*Nscans-tind(end);
Ch1=abraScope.hCh1.Value; Ch2=abraScope.hCh2.Value;

%%                                                         Initiate figures
% Time window
NewSpan(Span,'time');
NewSpan(Span,'lissajous');
abraScope.fhl.Visible='off';
NewSpan(Span,'poincare');
abraScope.fhp.Visible='off';

%%
QuitScope=false;

while ~QuitScope
% Get settings from GUI
  Ch1=abraScope.hCh1.Value; Ch2=abraScope.hCh2.Value;
  NEWSpan=Spans(abraScope.hTspan.Value);% Get span
  if NEWSpan~=Span, Span=NEWSpan; NewSpan(Span,abraScope.Type); end          
  NBlocksInSpan=ceil(Span/T);
%   tind=1:NBlocksInSpan*Nscans;
  tind=1:floor(Span*fs); tind=tind+NBlocksInSpan*Nscans-tind(end); 
  
% Read data from MMF
  Nblock=GetDoubleFromFile(MMF);% Read last block no id
  LastBlocks=circshift(BlockInd(:),[Nblock,0]); LastBlocks=LastBlocks(:); 
  LastBlocks=flipud(LastBlocks(1:NBlocksInSpan));% Block ID in chronological order
  
%%                                                             Datalogging?  
  if abraScope.LogData
    MMF.Writable=true;
    PassDoubleThruFile(MMF,true);% Set in flush mode
    MMF.Writable=false;
    AllBlocks=circshift(BlockInd,[Nblock,0]);
    AllBlocks=fliplr(AllBlocks(1:Nblock));% Block ID in chronological order
    Y=GetDoubleFromFile(MMF,AllBlocks);
    abraScope.LogData=false;
    PassDoubleThruFile(MMF,false);% Set in normal mode    
    [logfile, logpath] = uiputfile('*.mat','Save time series log file');
    [n,m,k]=size(Y);
    Y=squeeze(reshape(Y,n,m*k,1));
    tid=[0:m*k-1]/fs;
    ts=timeseries(Y,tid);
    save([logpath logfile],'ts');
  end  

%%                                                                     Plot
  try
    nt=length(tind);
    Y=GetDoubleFromFile(MMF,LastBlocks);
    Y=reshape(Y,Nch,NBlocksInSpan*Nscans,1);
    ch1YData=Y(Ch1,end-nt+1:end); ch2YData=Y(Ch2,end-nt+1:end);
    switch abraScope.FT
      case 'AC'
        ch1YData=ch1YData-mean(ch1YData);
        ch2YData=ch2YData-mean(ch2YData);
    end        
    switch abraScope.Type
      case 'time'
        lh1t.YData=ch1YData; lh2t.YData=ch2YData;
        aht(1).YLabel.String=abraScope.hCh1.String{Ch1};       
        aht(2).YLabel.String=abraScope.hCh2.String{Ch2};       
        switch abraScope.Action
          case 'live'
%             drawnow
            pause(1/abraScope.fps)
          case 'freeze'
            abraScope.fht.MenuBar='figure';
            while strcmp(abraScope.Action,'freeze'), pause(0.1); end
            abraScope.fht.MenuBar='none';
        end
      case 'lissajous'
        lhl.XData=ch1YData; lhl.YData=ch2YData;
        switch abraScope.Action
          case 'live'
            pause(1/abraScope.fps)
          case 'freeze'
            abraScope.fhl.MenuBar='figure';
            while strcmp(abraScope.Action,'freeze'), pause(0.1); end
            abraScope.fhl.MenuBar='none';
        end
      case 'poincare'
        lh1p.XData=ch1YData;
        lh1p.YData=ch2YData;
    end        
   
  catch
  end
%%                                                                    Autoscale?  
  if abraScope.AutoScale
    abraScope.AutoScale=false;
    range=max([max(ch1YData) max(ch2YData)])-min([min(ch1YData) min(ch2YData)]);
    range=2^ceil(log2(range));
    aht(1).YLim=[-range range];
    aht(2).YLim=[-range range];
  end  
  
%%                                                RMS calc and presentation  
  if abraScope.IRB.UserData
    Yrms=rms(Y');
    for I=1:Nch, abraScope.IM(I).CData=Yrms(I); end
    abraScope.IRB.UserData=false;  
  end    
  
%%                                                                    Quit?  
  [~,~,~,Iret]=GetDoubleFromFile(MMF);
  if abraScope.Quit || Iret==-2
    MMF.Writable=true;
    PassDoubleThruFile(MMF,uint8(2));% Pass a quit to MMF
    if QuitState==1
      quit
    else  
      break 
    end  
  end
  
end

close(abraScope.fht)
close(abraScope.fhl)
close(abraScope.fhp)
close(abraScope.FH)

  function NewSpan(Span,Type)
  switch Type
    case 'time'
      figure(abraScope.fht);
      NBlocksInSpan=ceil(Span/T);
      tind=1:floor(Span*fs);tind=tind+NBlocksInSpan*Nscans-tind(end); 
      [aht,lh1t,lh2t]=plotyy(tind,0*tind,tind,0*tind); 
      aht(1).Color=[.9 1 .9];
      aht(1).XLabel.Color=[1 1 1]; aht(1).YLabel.Color=[.8 .8 0];
      aht(1).XLabel.String=[Tlabels{abraScope.hTspan.Value} ' / MajorTick'];
%       aht(1).YLabel.String='1 units / Tick';
      aht(1).XTickLabel=''; aht(1).YTickLabel='';
      aht(2).XGrid='on'; aht(2).YGrid='on';
      aht(2).XMinorGrid='on'; aht(2).YMinorGrid='on';
%       aht(2).YLabel.String='1 units / Tick';
      aht(2).YTickLabel='';
      lh1t.Color=[.8 .8 0];
    case 'lissajous'
      fhl=figure(abraScope.fhl);
      lhl=plot(tind,tind); ahl=gca; 
      ahl.Color=[.9 1 .9];
      ahl.XLabel.Color=[1 1 1]; ahl.YLabel.Color=[1 1 1];
      ahl.XLabel.String='Xlabel'; 
      ahl.YLabel.String='Ylabel';
      ahl.XTickLabel=''; ahl.YTickLabel='';
      ahl.XGrid='on'; ahl.YGrid='on';
      lhl.Color=[.8 .8 0];
      axis square
    case 'poincare'
      fhp=figure(abraScope.fhp);
      lhp=plot(tind,tind); 
      ahp=gca; ahp.Color=[.9 1 .9];
      ahp.XLabel.Color=[1 1 1]; ahp.YLabel.Color=[1 1 1];
      ahp.XLabel.String='Xlabel'; 
      ahp.YLabel.String='Ylabel';
      ahp.XTickLabel=''; ahp.YTickLabel='';
      ahp.XGrid='on'; ahp.YGrid='on';
      lhp.Color=[.8 .8 0];
      axis square
  end
  end    
end

    
    