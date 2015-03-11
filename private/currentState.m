function currentState(handles,funNumber)

global currentState

if get(handles.monitor, 'Value')
    currentState{1,funNumber} = get(eval(sprintf('handles.fun%d', funNumber)),'String');
elseif get(handles.dataLogg, 'Value')
    currentState{2,funNumber} = get(eval(sprintf('handles.fun%d', funNumber)),'String');
elseif get(handles.impactTest, 'Value')
    currentState{3,funNumber} = get(eval(sprintf('handles.fun%d', funNumber)),'String');
elseif get(handles.periodic, 'Value')
    currentState{4,funNumber} = get(eval(sprintf('handles.fun%d', funNumber)),'String');
elseif get(handles.steppedSine, 'Value')
    currentState{5,funNumber} = get(eval(sprintf('handles.fun%d', funNumber)),'String');
elseif get(handles.multisine, 'Value')
    currentState{6,funNumber} = get(eval(sprintf('handles.fun%d', funNumber)),'String');
end
