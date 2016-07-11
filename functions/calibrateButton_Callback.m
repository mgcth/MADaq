% --- Executes on button press in calibrateButton.
function calibrateButton_Callback(hObject, eventdata, handles)
% hObject    handle to calibrateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user dataIn (see GUIDATA)

% Author: Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% June 2016; Latest revision: 21-june-2016

%% Initiate
hObject.BackgroundColor=[.94 .94 .94];

%   Get state of session if existing
calibrat = getappdata(0, 'previewStruct');
try     running = ~isempty(preview) && preview.session.IsRunning;
catch,  running = false;
end
if (~running)
    % Initialise the test setup
	calibrat = startInitialisation(hObject, eventdata, handles);
end    
calibrat.session.DurationInSeconds=10;%          Collect 10s data each time
Ts=1/calibrat.session.Rate;

%                    Get info about channnels including calibration setting
CHdata = get(handles.channelsTable, 'data');
Ych=find(cell2mat(CHdata(:,1)));
for I=1:length(Ych),Ycal(I)=calibrat.channelData(I).sensitivity;end
% ycal=diag(cell2mat(CHdata(Ych,11)));

%% Get calibrator data
prompt = {'Calibration frequency [Hz]: ________________________', ...
          'Calibration amplitude: (Default is B&K 4294)___________'};
dlg_title = 'Calibrator Data';
num_lines = 1;
defaultans = {'159.2','14.142'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
fcal=str2num(answer{1});acal=str2num(answer{2});
if fcal>100,Ncyc=100;elseif fcal>10,Ncyc=10;elseif fcal>1, Ncyc=2;else,error;end

%%                                                            Create figure
% fh=figure;
% fh.Resize='off';fh.NumberTitle='off';fh.Position=[30 400 800 600];
[FH,SPH,PBH,TBH]=CalSensFig;

done=false;nxt=true;givemsg=true;


while ~done
%%                                                             Collect data
  if nxt
    subplot(SPH(1))
    plot(SPH(1),[0 1],[0 1],'r',[0 1],[1 0],'r')
    ht=text(.6,.5,'Working!');ht.FontSize=15;
    [y,t]=calibrat.session.startForeground();
    y=y*diag(Ycal);
    nt=size(y,1);
    nxt=false;
%   end

%%                Make a couple regressions from last trailing part of data
    order=0;refch=1;
    icyc=ceil(2/fcal/Ts);
    for I=1:Ncyc
      ind=nt-I*icyc+1:nt-(I-1)*icyc;
      [c,rn,rh,~,~,~,yf]=steppedSine_harmonics(y(ind,:),Ts,fcal,order,refch);
      C(:,I)=c(:);
    end
  
%%                                     Find strongest signal-to-noise ratio  
    [snr,indx]=sort(abs(c)./rn,'descend');
    MeanAmp=mean(abs(C(indx(1),:)));
    COVAmp=std(abs(C(indx(1),:)))/MeanAmp;
  
%%                                                     Calibration GUI here
%   figure;
    tp=t(ind);tp=tp-tp(1);
    if SPH(1).UserData, % Plot in new figure
      SPH(1).UserData=false;
      fh=figure;
      plot(fh,tp,y(ind,indx(1)),tp,yf(:,indx(1)));
      title(fh,CHdata{Ych(indx(1)),3});
    end
    UD=SPH(1).UserData;
    plot(SPH(1),tp,y(ind,indx(1)),tp,yf(:,indx(1)));
    title(SPH(1),CHdata{Ych(indx(1)),3});
    xlabel(SPH(1),'t [s]')
    SPH(1).UserData=UD;
    try
      plot(SPH(2),tp,y(ind,indx(2)),tp,yf(:,indx(2)));
      title(SPH(2),CHdata{Ych(indx(2)),3})
      xlabel(SPH(2),'t [s]')
    catch,end
    try
      plot(SPH(3),tp,y(ind,indx(3)),tp,yf(:,indx(3)));
      title(SPH(3),CHdata{Ych(indx(3)),3})
      xlabel(SPH(3),'t [s]')
    catch,end

%%                                                    Show calibration data
    PresCal=Ycal(indx(1));
    TBH(1).String=num2str(PresCal/1000);% Present calibration
    TBH(2).String=num2str(1000/PresCal);% and its inverse
    SuggCal=MeanAmp/acal*Ycal(indx(1));
    TBH(3).String=num2str(SuggCal/1000);% Suggested calibration
    TBH(4).String=sprintf('%0.2f',100*abs(1-SuggCal/PresCal));% % diff
    TBH(5).String=num2str(1000/SuggCal);% and its inverse
    TBH(6).String=num2str(100*COVAmp);% C.O.V.
    try
      MeanAmp2=mean(abs(C(indx(2),:)));
      TBH(7).String=num2str(100*MeanAmp2/MeanAmp);
    catch,end  
    try
      MeanAmp3=mean(abs(C(indx(3),:)));
      TBH(8).String=num2str(100*MeanAmp3/MeanAmp);
    catch,end  
  end
  
  if PBH(1).UserData,% "Accept" toggle
    PBH(1).UserData=false;
    if givemsg
      givemsg=false;
      uiwait(msgbox({'Calibration for sensor will be updated for use in this session.' ' ' ...
                     'NB! Excel datasheet with sensor data (SensorsInLab.xlsx) will not be updated.' ' '},'Calibration update message','modal'))
    end    
    SuggCal=MeanAmp/acal*Ycal(indx(1));
    calibrat.channelData(indx(1)).sensitivity=SuggCal;
    CHdata{Ych(indx(1)),11}=SuggCal;
    set(handles.channelsTable, 'data', CHdata);
    SensorsInLabFile=[handles.homePath filesep 'conf' filesep 'SensorsInLab.xlsx'];
    set(handles.sensorDataBaseText,'String',...
        ['( Sensor data from: ' SensorsInLabFile ' but after calibration update)']);
  end  
  if PBH(2).UserData,% "Next" toggle
    nxt=true;
    PBH(2).UserData=false;
  end  
  if PBH(3).UserData,% "Done" toggle
    PBH(3).UserData=false;
    done=true;
  end  
  

  pause(0.1)
  
%   subplot(221),plot(tp,y(ind,indx(1)),tp,yf(:,indx(1)));
%   title(CHdata{Ych(indx(1)),3})
%   try
%   subplot(222),plot(tp,y(ind,indx(2)),tp,yf(:,indx(2)));
%   title(CHdata{Ych(indx(2)),3})
%   catch,end
%   try
%   subplot(223),plot(tp,y(ind,indx(3)),tp,yf(:,indx(3)));
%   title(CHdata{Ych(indx(3)),3})
%   catch,end
  
end  
set(handles.statusStr, 'String', 'Calibration done.');
delete(FH);

