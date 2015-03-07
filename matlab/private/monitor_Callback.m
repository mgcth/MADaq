% --- Executes on button press in monitor.
function monitor_Callback(hObject, eventdata, handles)
% hObject    handle to monitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global currentState

% Hint: get(hObject,'Value') returns toggle state of monitor
val = get(hObject,'Value');
if (val)
    set(handles.monitor, 'Value', 1);
    set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.periodic, 'Value', 0);
    set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    
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
else
    set(handles.monitor, 'Value', 1);
end