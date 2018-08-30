function YLim=fpsplot(hax,t,y,YLim,fps,tw)
%FPSPLOT
%Inputs: hax  - Handle of the axes of the plot
%        t    - Vector with discrete times associated with y
%        y    - Data vector to plot 
%        Ylim - The y axis limits of plot
%        fps  - Number of frames per second (plot update rate)
%        tw   - Duration to plot
%Output: Ylim - The updated y axis limits of plot

%%                                                                 Initiate
if nargin<5,fps=40;end,if isempty(fps), fps=40;end
if nargin<6,tw=1.0;end,if isempty(tw), tw=1.0;end
if nargin<7,tit='';end,
if isempty(YLim),Ylim=[Inf -Inf];end

dt=t(2)-t(1);
T=1/fps;
% YLim=[min(y) max(y)];
ntw=floor(tw/dt);
ntT=floor(T/dt);
nt=length(y);

%%                                                            Initiate plot
ind=1:ntw;
tic
try 
  hp=plot(hax,t(ind),y(ind));grid on;
  set(hax,'FontName','Times');
catch,% Return if too little data available
  lasterr
  return
end  

%%                                                              Plot "film"
I=1;
while 1
  ind=ind+ntT;
  if ind(end)>nt,break,end
  hp.XData=t(ind);hp.YData=y(ind);
  YLim=[min([YLim(1) min(y(ind))]) max([YLim(2) max(y(ind))])];
  hax.YLim=YLim;
  hax.XTick=round([t(ind(1)) t(ind(end))],1);
  hax.XLim=hax.XTick;
  hax.XGrid='on';hax.YGrid='on';
  Twait=I*T-toc;
  if Twait>0% Draw if there is time to do it
    pause(Twait)
%     drawnow
  end  
  I=I+1;
end  
