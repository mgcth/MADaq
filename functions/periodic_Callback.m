% --- Executes on button press in periodic.
function periodic_Callback(hObject, eventdata, handles)
% hObject    handle to monitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global currentState

% Hint: get(hObject,'Value') returns toggle state of periodic
val = get(hObject,'Value');
if (val)
    set(handles.monitor, 'Value', 0);
    set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.periodic, 'Value', 1);
    set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    
    set(handles.fun1,'string',currentState{4,1})
    set(handles.fun2Text,'visible','on')
    set(handles.fun2Text,'string','Cycle duration [s]:')
    set(handles.fun2,'visible','on')
    set(handles.fun2,'string',currentState{4,2})
    set(handles.fun3Text,'visible','on')
    set(handles.fun3Text,'string','Periodic function:')
    set(handles.fun3,'visible','on')
    set(handles.fun3,'string',currentState{4,3})
    set(handles.fun4Text,'visible','on')
    set(handles.fun4Text,'string','Repeats:')
    set(handles.fun4,'visible','on')
    set(handles.fun4,'string',currentState{4,4})
    set(handles.fun5Text,'visible','on')
    set(handles.fun5Text,'string','Initiation repeats:')
    set(handles.fun5,'visible','on')
    set(handles.fun5,'string',currentState{4,5})
    set(handles.fun6Text,'visible','on')
    set(handles.fun6Text,'string','Max amplitude [N]:')
    set(handles.fun6,'visible','on')
    set(handles.fun6,'string',currentState{4,6})
    set(handles.fun7Text,'visible','on')
    set(handles.fun7Text,'string','Freq. range [Hz]:')
    set(handles.fun7,'visible','on')
    set(handles.fun7,'string',currentState{4,7})
    set(handles.fun8Text,'visible','off')
    set(handles.fun8,'visible','off')
    set(handles.fun9Text,'visible','off')
    set(handles.fun9,'visible','off')
else
    set(handles.periodic, 'Value', 1);
end