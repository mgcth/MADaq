% --- Executes on button press in impactTest.
function impactTest_Callback(hObject, eventdata, handles)
% hObject    handle to impactTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global currentState

% Hint: get(hObject,'Value') returns toggle state of impactTest
val = get(hObject,'Value');
if (val)
%     set(handles.monitor, 'Value', 0);
%     set(handles.dataLogg, 'Value', 0);
    set(handles.impactTest, 'Value', 1);
    set(handles.periodic, 'Value', 0);
%     set(handles.steppedSine, 'Value', 0);
    set(handles.multisine, 'Value', 0);
    set(handles.Oscilloscope, 'Value', 0);
    
    set(handles.fun1,'string',currentState{3,1})
    set(handles.fun2Text,'visible','on')
    set(handles.fun2Text,'string','Fade time [s]:')
    set(handles.fun2,'visible','on')
    set(handles.fun2,'string',currentState{3,2})
    set(handles.fun3Text,'visible','off')
%     set(handles.fun3Text,'string','Reference points:')
    set(handles.fun3,'visible','off')
%     set(handles.fun3,'string',currentState{3,3})
    set(handles.fun4Text,'visible','on')
    set(handles.fun4Text,'string','Cut-off [Hz]:')
    set(handles.fun4,'visible','on')
    set(handles.fun4,'string',currentState{3,4})
    set(handles.fun5Text,'visible','on')
    set(handles.fun5Text,'string','Reference label:')
    set(handles.fun5,'visible','on')
    set(handles.fun5,'string',currentState{3,5})
    set(handles.fun6Text,'visible','off')
    set(handles.fun6,'visible','off')
    set(handles.fun7Text,'visible','off')
    set(handles.fun7,'visible','off')
    set(handles.fun8Text,'visible','off')
    set(handles.fun8,'visible','off')
    set(handles.fun9Text,'visible','off')
    set(handles.fun9,'visible','off')
else
    set(handles.impactTest, 'Value', 1);
end