% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user dataIn (see GUIDATA)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global currentState

%fileName = inputdlg('Enter name of the file to save', 'Save configuration');
%drawnow; pause(0.1);                       %   Prevent MatLab from hanging

[fileName,pathName] = uiputfile('conf/*.conf','Save configuration to file');

if (~isempty(fileName))
    dataIn = get(handles.channelsTable, 'data');
    [m, n] = size(dataIn);
    dataOut = get(handles.outputTable, 'data');
    [mm, nn] = size(dataOut);
    output = cell(11 + m + 1 + mm, n);
    
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
    % Save currentState as a vector (rows after each other)
    counter = 1;
    for q = 1:size(currentState,1)
        for qq = 1:size(currentState,2)
            if isempty(currentState{q,qq})
                currentState{q,qq} = 'undefined'; % to save all the columns in xls
            end
            output{8, counter} = currentState{q,qq};
            counter = counter + 1;
        end
    end
    % End currentState save
    output{9, 1} = get(handles.monitor, 'Value');
    output{9, 2} = get(handles.dataLogg, 'Value');
    output{9, 3} = get(handles.impactTest, 'Value');
    output{9, 4} = get(handles.periodic, 'Value');
    output{9, 5} = get(handles.steppedSine, 'Value');
    output{9, 6} = get(handles.multisine, 'Value');
    output{10, 1} = get(handles.autoReport, 'Value');
    output{10, 2} = handles.autoReport.UserData.TesterInfo{1};
    output{10, 3} = handles.autoReport.UserData.TesterInfo{2};
    output{10, 4} = handles.autoReport.UserData.TesterInfo{3};
    output{11, 1} = '###';
    % % MG (mod end)
    
    offset = 11; %Last entry of header
    
    for i = 1:m
        output{offset + i, 1} = dataIn{i, 1};     %   Active
        output{offset + i, 2} = dataIn{i, 2};     %   Referense
        output{offset + i, 3} = dataIn{i, 3};     %   Channel
        %output{10 + i, 4} = dataIn{i, 4};        %   Signal
        output{offset + i, 4} = dataIn{i, 4};     %   Label
        output{offset + i, 5} = dataIn{i, 5};     %   Coupling (AC/DC)
        output{offset + i, 6} = dataIn{i, 6};     %   Type (Voltage/IEPE)
        output{offset + i, 7} = dataIn{i, 7};     %   Voltage
        %output{10 + i, 7} = dataIn{i, 7};        %   Transducer type
        output{offset + i, 8} = dataIn{i, 8};     %   Manufacturer
        output{offset + i, 9} = dataIn{i, 9};     %   Manufacturer ID
        output{offset + i, 10} = dataIn{i, 10};   %   Serial number
        output{offset + i, 11} = dataIn{i, 11};   %   Sensitivity
        output{offset + i, 12} = dataIn{i, 12};   %   Units
        output{offset + i, 13} = dataIn{i, 13};   %   Dof
        output{offset + i, 14} = dataIn{i, 14};   %   Direction
    end
    
    output{offset + m + 1, 1} = '### ###';
    
    j = 1;
    for i = m + 1 + 1:m + 1 + mm
        output{offset + i, 1} = dataOut{j, 1};     %   Active
        output{offset + i, 2} = dataOut{j, 2};     %   Referense
        output{offset + i, 3} = dataOut{j, 3};     %   Channel
        %output{10 + i, 4} = dataOut{j, 4};        %   Signal
        output{offset + i, 4} = dataOut{j, 4};     %   Label
        output{offset + i, 5} = dataOut{j, 5};     %   Coupling
        output{offset + i, 6} = dataOut{i, 6};     %   Type (Voltage/IEPE)
        output{offset + i, 7} = dataOut{j, 7};     %   Voltage
        %output{10 + i, 7} = dataOut{j, 7};        %   Transducer type
        output{offset + i, 8} = dataOut{j, 8};     %   Manufacturer
        output{offset + i, 9} = dataOut{j, 9};     %   Manufacturer ID
        output{offset + i, 10} = dataOut{j, 10};   %   Serial number
        output{offset + i, 11} = dataOut{j, 11};   %   Sensitivity
        output{offset + i, 12} = dataOut{j, 12};   %   Units
        output{offset + i, 13} = dataOut{j, 13};   %   Dof
        output{offset + i, 14} = dataOut{j, 14};   %   Direction
        j = j + 1;
    end
    
    %file = [handles.homePath, '/conf/', fileName{1,1}, '.conf'];
    file = [pathName, fileName];
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