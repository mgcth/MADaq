% --- Executes on button press in steppedSine.
function steppedSine_Callback(hObject, eventdata, handles)
% hObject    handle to monitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of steppedSine
val = get(hObject,'Value');
if (val)
    set(handles.monitor, 'Value', 0);
    set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 0);
    set(handles.periodic, 'Value', 0);
    set(handles.steppedSine, 'Value', 1);
    set(handles.multisine, 'Value', 0);
    
    set(handles.fun2Text,'visible','on')
    set(handles.fun2Text,'string','Frequency list:')
    set(handles.fun2,'visible','on')
    set(handles.fun2,'string','Matlab expr.')
    set(handles.fun3Text,'visible','on')
    set(handles.fun3Text,'string','Amplitude list:')
    set(handles.fun3,'visible','on')
    set(handles.fun3,'string','3')
    set(handles.fun4Text,'visible','on')
    set(handles.fun4Text,'string','Min. # cycles:')
    set(handles.fun4,'visible','on')
    set(handles.fun4,'string','50')
    set(handles.fun5Text,'visible','on')
    set(handles.fun5Text,'string','Distorsion level:')
    set(handles.fun5,'visible','on')
    set(handles.fun5,'string','0.0001')
    set(handles.fun6Text,'visible','on')
    set(handles.fun6Text,'string','Distorsion orders:')
    set(handles.fun6,'visible','on')
    set(handles.fun6,'string','2')
    
    %if
    
    set(handles.fun7Text,'visible','off')
    set(handles.fun7,'visible','off')
    set(handles.fun8Text,'visible','off')
    set(handles.fun8,'visible','off')
    set(handles.fun9Text,'visible','off')
    set(handles.fun9,'visible','off')
else
    set(handles.steppedSine, 'Value', 1);
end