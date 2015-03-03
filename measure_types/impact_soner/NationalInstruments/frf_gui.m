function frf_gui(t,y,Ind,freq,FRF,stdFRF,RN,RH,RS,PW,names)
%FRF_GUI
%Alt 1:  
%         No input parameters will do an initialization
%Alt 2:
%Inputs:  t
%         y
%         Ind    - Index of data set
%         freq   - The frequencies stepped through
%         FRF    - The corresponding FRF data
%         stdFRF - The standard deviation of given FRF
%         RN     - Residual noise
%         RH     - Residual harmonic distorsion
%         RS     - Residual lack of stationarity
%         PW     - Phase wrap during block of data
%         names  - Name of channels
%Call:    frf_gui(freq,FRF,stdFRF,RN,RH,RS,PW,names)

%Copyright: Applied Mechanics, Chalmers University of Technology
%Written:  October 28, 2010/TA

%% ------------------------------------------------------------------------
%                                                                    Global
%                                                                    ------
global CH HFRFGUI

if nargin==0
  HFRFGUI.hFigfd=figure;clf; % FRF window
%   set(HFRFGUI.hFigfd,'Position',[-1908 369 982 680],'Number','off',...
%                       'Name','FRF window','Visible','on','MenuBar','None');
   set(HFRFGUI.hFigfd,'Position',[700 350 550 350],'Number','off',...
                                       'Name','FRF window','Visible','on');
                  
  HFRFGUI.hFigtd=figure;clf; % Time data window
  set(HFRFGUI.hFigtd,'Position',[100 350 550 350],'Number','off',...
                     'Name','Time window','Visible','on','MenuBar','None');
  HFRFGUI.TWpos=get(HFRFGUI.hFigtd,'Position');
  HFRFGUI.hFigdd=figure;clf; % Distorsion window
  set(HFRFGUI.hFigdd,'Position',[ 700 100 550 200],'Number','off',...
               'Name','Distorsion window','Visible','on','MenuBar','None');
  HFRFGUI.DWpos=get(HFRFGUI.hFigdd,'Position');

 
%%                                                                Start GUI
%sssGUI(setdiff(CH.active,CH.refch));
sssGUI(CH.active);
     
else
%%                                                    Create current legend
  ind=get(HFRFGUI.LB(1:3),'Value');
  chplot=[];
  for I=1:3
    if ind{I}>1
        str=get(HFRFGUI.LB(I),'String');        
        chplot=[chplot;find(CH.active==str2num(str{ind{I}}))];
    end
  end    
  Legend=[];
  for I=1:length(chplot)
      Legend{I}=['ch# ' int2str(chplot(I))];
  end
   
%%                                                   Create plot quantities
alpha=norminv(.95,0,1);% 90% confidence interval
FRFplus=(abs(FRF)+alpha*stdFRF).*FRF./abs(FRF);
FRFminus=(abs(FRF)-alpha*stdFRF).*FRF./abs(FRF);
%   nf=size(FRF,2);
%   freq=freq(1:nf);freq3=[freq(:);freq(:);freq(:)];freq3=sort(freq3); 
%   for III=nf:-1:1
%        FRFstd(:,(III-1)*3+1)=(abs(FRF(:,III))-stdFRF(:,III)) ...
%                                              .*FRF(:,III)./abs(FRF(:,III));
%        FRFstd(:,(III-1)*3+2)=(abs(FRF(:,III))+stdFRF(:,III)) ...
%                                              .*FRF(:,III)./abs(FRF(:,III));
%        FRFstd(:,(III-1)*3+3)=NaN*FRF(:,III);
%   end
  
%%                                                                     Plot

%%                                              FRF/Bode/Nyquist/Multiorder
  plotopt=get(HFRFGUI.RB(1:4),'Value');
  if plotopt{1}; % FRF plot
     Nf=size(FRF,2);grey=[.5 .5 .5];
     figure(HFRFGUI.hFigfd);clf
%      semilogy(freq3,abs(FRFstd(chplot,:))','k')
      semilogy(freq(1:Nf),abs(FRFplus(chplot,:)),'color',grey)
      ax=axis;axis([freq(1) freq(end) ax(3)/5 ax(4)]);
      hold on
      semilogy(freq(1:Nf),abs(FRFminus(chplot,:)),'color',grey)     
     semilogy(freq(1:Nf),abs(FRF(chplot,:)))
     hold off
     title(cell2mat([cell2mat(names(chplot)) '/ ' names(find(CH.active==CH.refch))]))
          
     %legend(Legend,'Location','SouthWest')
  elseif plotopt{2}; % Bode plot  
     figure(HFRFGUI.hFigfd);clf
     magphase(freq,FRF(chplot(1),:));
     legend(Legend{1})
  elseif plotopt{3}; % Nyquist plot
     figure(HFRFGUI.hFigfd);clf
     plot(real(FRF(chplot(1),:)),imag(FRF(chplot(1),:)));
     axis equal
     legend(Legend{1})
  else plotopt{4};   % Multiorder FRF plot  
  end
  
%%                                                                Time data
  if get(HFRFGUI.RB(5),'Value')
     figure(HFRFGUI.hFigtd);clf
     titletext=[cell2mat(names(chplot)) ' @ ' num2str(freq(Ind)) 'Hz'];
%     miny=min(min(y(:,chplot)));maxy=max(max(y(:,chplot)));
%     plot(t,y(:,chplot),miny,t,maxy);title(titletext)
     for I=1:length(chplot)
         yac(:,chplot(I))=y(:,chplot(I))-mean(y(:,chplot(I)));
     end
     plot(t,yac(:,chplot));grid,title(titletext)
     drawnow
%      plot(t.t,y(:,chplot));hold on
%      vax=axis;
%      t.b=sort([t.blocktic t.blocktic t.blocktic]);
%      t.tic=[vax(3)*ones(1,length(t.blocktic)); ...
%          vax(4)*ones(1,length(t.blocktic));NaN*ones(1,length(t.blocktic))];
%      plot(t.b,t.tic(:),'k:'),hold off
     %legend(Legend,'Location','SouthWest')
  end
  
%%                                                                Residuals
  if get(HFRFGUI.RB(6),'Value')
     figure(HFRFGUI.hFigdd)
%      set(gcf,'Position',HFRFGUI.DWpos,'MenuBar','None');
     set(gcf,'MenuBar','None');
     semilogy(freq(1:Nf),RN(chplot(1),:),freq(1:Nf),RH(chplot(1),:),...
                     freq(1:Nf),RS(chplot(1),:),freq(1:Nf),PW(chplot(1),:))
     legend('Relative noise residual','Relative harmonic distorsion',...
 'Relative lack of stationarity','Phase wrap [rad]','Location','NorthEast')
     ax=axis;axis([freq(1) freq(end) ax(3) ax(4)]);
     grid
     drawnow
  else
     try
       HGUI.DWpos=get(HFRFGUI.hFigdd,'Position');
       close(HFRFGUI.hFigdd)
     catch,end
  end
end

%%                                                   Helper function sssGUI
function sssGUI(ind)
global HFRFGUI
HFRFGUI.Fig=figure;
set(HFRFGUI.Fig,'MenuBar','None','NumberTitle','Off', ...
                 'Name','Simo Stepped Sine GUI','Position',[150 150 500 150])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[19 19 152 22])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[19 39 152 22])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[19 59 152 82])
Callbackstr='global HFRFGUI,Hrb=gcbo;ind=find(HFRFGUI.RB==Hrb);set(HFRFGUI.RB(1:4),''Value'',0),set(HFRFGUI.RB(ind),''Value'',1)';
HFRFGUI.RB(1)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','FRF Plot',...
               'Value',1,'Position',[20 120 150 18],'Callback',Callbackstr);
HFRFGUI.RB(2)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Bode Plot',...
               'Value',0,'Position',[20 100 150 18],'Callback',Callbackstr);
HFRFGUI.RB(3)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Nyquist Plot',...
                'Value',0,'Position',[20 80 150 18],'Callback',Callbackstr);
HFRFGUI.RB(4)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Multiorder FRF Plot',...
                'Value',0,'Position',[20 60 150 18],'Callback',Callbackstr);
HFRFGUI.RB(5)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Plot Time Data',...
                                      'Value',1,'Position',[20 40 150 18]);
HFRFGUI.RB(6)=uicontrol(HFRFGUI.Fig,'Style','Radio','String','Plot Distorsion',...
                                      'Value',1,'Position',[20 20 150 18]);

uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[179 19 82 122])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[279 19 82 122])
uicontrol(HFRFGUI.Fig,'Style','Frame','Position',[379 19 82 122])
                                  
ListBoxString{1}='None';for I=1:length(ind),ListBoxString{I+1}=int2str(ind(I));end
HFRFGUI.LB(1)=uicontrol(HFRFGUI.Fig,'Style','Listbox','String',ListBoxString,...
                                      'Value',2,'Position',[180 20 80 90]);
HFRFGUI.LB(2)=uicontrol(HFRFGUI.Fig,'Style','Listbox','String',ListBoxString,...
                                      'Value',1,'Position',[280 20 80 90]);
HFRFGUI.LB(3)=uicontrol(HFRFGUI.Fig,'Style','Listbox','String',ListBoxString,...
                                      'Value',1,'Position',[380 20 80 90]);

uicontrol(HFRFGUI.Fig,'Style','Text','String','Curve 1 ch#','Position',[180 120 80 20]);
uicontrol(HFRFGUI.Fig,'Style','Text','String','(blue)','Position',[180 108 80 20]);
uicontrol(HFRFGUI.Fig,'Style','Text','String','Curve 2 ch#','Position',[280 120 80 20]);
uicontrol(HFRFGUI.Fig,'Style','Text','String','(green)','Position',[280 108 80 20]);
uicontrol(HFRFGUI.Fig,'Style','Text','String','Curve 3 ch#','Position',[380 120 80 20]);
uicontrol(HFRFGUI.Fig,'Style','Text','String','(red)','Position',[380 108 80 20]);

drawnow