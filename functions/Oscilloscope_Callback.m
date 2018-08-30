% --- Executes on button press in Oscilloscope.
function Oscilloscope_Callback(hObject, eventdata, handles)
% hObject    handle to Oscilloscope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global currentState

% % Hint: get(hObject,'Value') returns toggle state of monitor
% val = get(hObject,'Value');
% if (val)

%     set(handles.monitor, 'Value', 0);
%     set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.periodic, 'Value', 0);
%     set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    set(handles.Oscilloscope, 'Value', 1);
    
    set(handles.fun1,'string',currentState{7,1})
    set(handles.fun2Text,'visible','off')
    set(handles.fun2,'visible','off')
    set(handles.fun3Text,'visible','off')
    set(handles.fun3,'visible','off')
    set(handles.fun4Text,'visible','off')
    set(handles.fun4,'visible','off')
    set(handles.fun5Text,'visible','off')
    set(handles.fun5,'visible','off')
    set(handles.fun6Text,'visible','off')
    set(handles.fun6,'visible','off')
    set(handles.fun7Text,'visible','off')
    set(handles.fun7,'visible','off')
    set(handles.fun8Text,'visible','off')
    set(handles.fun8,'visible','off')
    set(handles.fun9Text,'visible','off')
    set(handles.fun9,'visible','off')
% else
%     set(handles.monitor, 'Value', 1);
% end