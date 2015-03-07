% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg('Enter name of the file to save', 'Save configuration');
drawnow; pause(0.1);                       %   Prevent MatLab from hanging

if (~isempty(answer))
    data = get(handles.channelsTable, 'data');
    [m, n] = size(data);
    output = cell(10 + m, n);
    
    output{1, 1} = 'NB: Changing this file may corrupt it!';
    output{2, 1} = '#';
    output{3, 1} = 'Title1';
    output{3, 2} = get(handles.title1, 'String');
    output{4, 1} = 'Title2';
    output{4, 2} = get(handles.title2, 'String');
    output{5, 1} = 'Title3';
    output{5, 2} = get(handles.title3, 'String');
    output{6, 1} = 'Title4';
    output{6, 2} = get(handles.title4, 'String');
    output{7, 1} = '##';
    output{8, 1} = get(handles.fun1, 'String');
    output{8, 2} = get(handles.fun2, 'String');
    output{8, 3} = get(handles.fun3, 'String');
    output{8, 4} = get(handles.fun4, 'String');
    output{8, 5} = get(handles.fun5, 'String');
    output{8, 6} = get(handles.fun6, 'String');
    output{8, 8} = get(handles.fun7, 'String');
    output{8, 9} = get(handles.fun8, 'String');
    output{8, 9} = get(handles.fun9, 'String');
    output{9, 1} = get(handles.monitor, 'Value');
    output{9, 2} = get(handles.dataLogg, 'Value');
    output{9, 3} = get(handles.impactTest, 'Value');
    output{9, 4} = get(handles.periodic, 'Value');
    output{9, 5} = get(handles.steppedSine, 'Value');
    output{9, 6} = get(handles.multisine, 'Value');
    output{10, 1} = '###';
    % % MG (mod end)
    
    offset = 10; %Last entry of header
    
    for i = 1:m
        output{offset + i, 1} = data{i, 1};     %   Active
        output{offset + i, 2} = data{i, 2};     %   Channel
        %output{10 + i, 3} = data{i, 3};        %   Signal
        output{offset + i, 3} = data{i, 3};     %   Label
        output{offset + i, 4} = data{i, 4};     %   Coupling
        output{offset + i, 5} = data{i, 5};     %   Voltage
        %output{10 + i, 7} = data{i, 7};        %   Transducer type
        output{offset + i, 6} = data{i, 6};     %   Manufacturer
        output{offset + i, 7} = data{i, 7};     %   Manufacturer ID
        output{offset + i, 8} = data{i, 8};     %   Serial number
        output{offset + i, 9} = data{i, 9};     %   Sensitivity
        output{offset + i, 10} = data{i, 10};   %   Units
        output{offset + i, 11} = data{i, 11};   %   Dof
        output{offset + i, 12} = data{i, 12};   %   Direction
    end
    
    file = [handles.homePath, '/conf/', answer{1,1}, '.conf'];
    try
        if exist(file, 'file')
            delete(file);
        end
        xlswrite(file, output);
        set(handles.statusStr, 'String', [file, ' was saved to the disk ...']);
    catch e
        errorMsg = {'An error occured, try again.'; ...
            ['Exception: ', e.identifier]};
        msgbox(errorMsg, 'Exception', 'error');
        drawnow; pause(0.1);                       %   Prevent MatLab from hanging
        set(handles.statusStr, 'String', ['Exception: ', e.identifier]);
    end
    
end