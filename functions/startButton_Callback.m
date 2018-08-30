% --- Executes on button press of startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global Impact

%% Close processes gracefully
if hObject.UserData==1,% Impact test running, close it prematurely
  stopImpact;
  clearALL;
  return
elseif hObject.UserData==2,% Impact test running, close it
elseif hObject.UserData==3,% Periodic test running, close it
elseif hObject.UserData==4,% Steppedsine test running, close it
elseif hObject.UserData==5,% Multisine test running, close it
elseif hObject.UserData==6,% Oscilloscope running, close it prematurely
  stopOscilloscope;
  clearALL;
  return
elseif hObject.UserData>0%Still not zero? Set it to zero
  hObject.UserData=0;
end



% Check which test
% if get(handles.monitor,'Value') == 1 % if monitor
%     TestType='monitor';
%     dataOut = startMonitor(hObject, eventdata, handles);
%     
% elseif get(handles.dataLogg,'Value') == 1 % if standard test
%     TestType='logging';
%     dataOut = startLogg(hObject, eventdata, handles);
    
if handles.impactTest.Value == 1 % if impactTest
% Save some stuff before clear
    if ~isempty(Impact)
      IMPACT=Impact; save('IMPACT','IMPACT'); 
    end  
    TestType='impact';
    try
      try
        load('IMPACT','IMPACT');
        Impact.Trained=IMPACT.Trained;
        Impact.HitCrestFactor=IMPACT.HitCrestFactor;
      catch, end    
      dataOut = startImpact(hObject, eventdata, handles);
%       return
    catch
      set(handles.startButton, 'String', 'Start measurement','BackGround',[0 1 0]);      
      clear all
%       clc
      msgbox(['Problem encountered. Please try to restart measurement.' ...
          ' Last Error Message: ' lasterr])
      return
    end  
elseif handles.periodic.Value == 1 % if periodic
    TestType='periodic';
    dataOut = startPeriodic(hObject, eventdata, handles);
    
% elseif handles.steppedSine.Value == 1 % if steppedSine
%     TestType='steppedsine';
%     dataOut = startMultisine(hObject, eventdata, handles);
    
elseif handles.multisine.Value == 1 % if multisine
    TestType='multisine';
    dataOut = startMultisine(hObject, eventdata, handles);

elseif handles.Oscilloscope.Value == 1 % if oscilloscope
    TestType='oscilloscope';
    ScopeFeed = startOscilloscope(hObject, eventdata, handles);    
    %% Find possible stop state and size info
    while 1
      [~,~,Size,Iret]=GetDoubleFromFile(ScopeFeed.MMF);
      if Iret==-2
        stopOscilloscope;
        break
      end
      pause(0.1)
    end  
else

end

TS=[];FRD=[];
try dataOut; catch, dataOut=[]; end
if iscell(dataOut)
  for I=1:length(dataOut)
    if strcmpi(class(dataOut{I}),'timeseries')
      TS=dataOut{I};
    elseif strcmpi(class(dataOut{I}),'frd') || strcmpi(class(dataOut{I}),'idfrd')
      FRD=dataOut{I};
    end    
  end  
else
  if strcmpi(class(dataOut),'timeseries')
    TS=dataOut;
  elseif strcmpi(class(dataOut),'frd') || strcmpi(class(dataOut),'idfrd')
    FRD=dataOut;
  end    
end

try TestType; catch, TestType='none'; end
if strcmpi(TestType,'impact') || strcmpi(TestType,'periodic') || ...
    strcmpi(TestType,'steppedsine') || strcmpi(TestType,'multisine') || ...
     strcmpi(TestType,'logging')
  [uff,rpt]=abraDAQterm(TS,FRD);
else
  uff=false;rpt=false;
end

% Check if report is to be generated
if rpt
    try
        dataIn = dataOut;
        abraDAQ_report(dataIn,handles)
    catch
        errordlg('Something wrong with the report generation.')
    end

end

% Check if write to UFF
if uff
    [filen,pathen] = uiputfile('*.uff','Select UFF filename and location');
    frd2uff([pathen filen],FRD);
end
end

function clearALL
clear all
return
end