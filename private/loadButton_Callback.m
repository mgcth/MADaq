% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global currentState

% Columns in the two tables
COLUMNSinINPUTTABLE = 13;
COLUMNSinOUTPUTTABLE = 13;

error = false;
loadFile = false;
directory = [handles.homePath, '\conf'];
selection = '';
raw = {};

%   Input dialog for menuAbout selection
while (~loadFile)
    d = dir(directory);
    str = {d.name};
    [select, status] = listdlg( 'PromptString','Select a file:',...
        'SelectionMode','single',...
        'ListString',str);
    drawnow; pause(0.1);                       %   Prevent MatLab from hanging
    
    selection = [directory, '\', d(select).name];
    type = exist(selection, 'file');
    
    if (status ~= 0)
        
        if (type == 2)      %   File
            loadFile = true;
            
            % load
            %disp(['Selection: ', selection]);
            try
                [num, txt, raw] = xlsread(selection);
            catch e
                errorMsg = {'An error occured, try again.'; ...
                    ['Exception: ', e.identifier]};
                msgbox(errorMsg, 'Exception', 'error');
                drawnow; pause(0.1);                       %   Prevent MatLab from hanging
                set(handles.statusStr, 'String', ['Exception: ', e.identifier]);
                error = true;
            end
        elseif (type == 7)  %   Directory
            directory = selection;
            %disp(['Dir: ', directory]);
        end
        
    else    % cancel operation
        loadFile = true;
        error = true;
    end
end

if (~error)
    %   Get titles
    if (strcmp(raw{2,1}, '#'))
        if (ischar(raw{3,2}))
            set(handles.title1, 'String', raw{3,2});
        else
            set(handles.title1, 'String', '');
        end
        if (ischar(raw{4,2}))
            set(handles.title2, 'String', raw{4,2});
        else
            set(handles.title2, 'String', '');
        end
        if (ischar(raw{5,2}))
            set(handles.title3, 'String', raw{5,2});
        else
            set(handles.title3, 'String', '');
        end
        if (ischar(raw{6,2}))
            set(handles.title4, 'String', raw{6,2});
        else
            set(handles.title4, 'String', '');
        end
    end
    
    %   Get measurement settings
    if (strcmp(raw{7,1}, '##'))
        if (raw{9,1})
            %set(handles.monitor, 'Value', 1);
            monitor_Callback(hObject, eventdata, handles)
        elseif (raw{9,2})
            %set(handles.dataLogg, 'Value', 1);
            dataLogg_Callback(hObject, eventdata, handles)
        elseif (raw{9,3})
            %set(handles.impactTest, 'Value', 1);
            impactTest_Callback(hObject, eventdata, handles)
        elseif (raw{9,4})
            %set(handles.periodic, 'Value', 1);
            periodic_Callback(hObject, eventdata, handles)
        elseif (raw{9,5})
            %set(handles.steppedSine, 'Value', 1);
            steppedSine_Callback(hObject, eventdata, handles)
        elseif (raw{9,6})
            %set(handles.multisine, 'Value', 1);
            multisine_Callback(hObject, eventdata, handles)
        end
        
        % Load currentState as a vector (rows after each other)
        counter = 1;
        for q = 1:size(currentState,1)
            for qq = 1:size(currentState,2)
                currentState{q,qq} = raw{8,counter};
                if q == find([raw{9,:}] == 1)
                    set(eval(sprintf('handles.fun%d', qq)),'String',currentState{q,qq});
                end
                counter = counter + 1;
            end
        end
        % End currentState load
    end
    
    % Load Tester Info
    set(handles.autoReport, 'Value', raw{10,1});
    tmpTesterInfo{1} = raw{10,2};
    tmpTesterInfo{2} = raw{10,3};
    tmpTesterInfo{3} = raw{10,4};
    handles.autoReport.UserData.TesterInfo = tmpTesterInfo;
    
    % Get channels
    [n, m] = size(raw);
    
    a=cell(n,1);
    for i = 1:n
        a{i} = raw{i,1};
    end
    
    inputIndex = find(strcmp(a,'###'));
    outputIndex = find(strcmp(a,'### ###'));
    if isempty(inputIndex) || isempty(outputIndex)
        errordlg('Corrupt save file.');
        return;
    end
    
    dataIn = cell(length(inputIndex + 1:outputIndex - 1), COLUMNSinINPUTTABLE);
    dataOut = cell(length(outputIndex + 1:n), COLUMNSinOUTPUTTABLE);
    set(handles.channelsTable, 'data', dataIn);
    set(handles.outputTable, 'data', dataOut);
    
    %%% START
    SensorsInLabFile=[handles.homePath, '\conf\SensorsInLab.xlsx'];%which([handles.homePath, '\conf\SensorsInLab.xlsx']);
    if ~isempty(SensorsInLabFile)
        [CLL,rawCells]=xls2cell(SensorsInLabFile,5);
        CLL{1}(1,1)={' '};% Replace column header with blank
        handles.channelsTable.ColumnFormat{9}=CLL{:};
    end
    handles.channelsTable.CellEditCallback={@celleditcallback,rawCells};
    %%% END
    
    for i = inputIndex + 1:outputIndex - 1
        
        %   Copy data and check for NaNs in inappropiate places (Hint: No NaNs in string elements)
        temp = cell(1, 13);
        
        temp{1, 1} = raw{i, 1};     %   Active
        temp{1, 2} = raw{i, 2};     %   Referense
        
        if (ischar(raw{i, 3}))      %   Channel
            temp{1, 3} = raw{i, 3};
        else
            temp{1, 3} = '';
        end
        
        if (ischar(raw{i, 4}))      %   Label
            temp{1, 4} = raw{i, 4};
        else
            temp{1, 4} = '';
        end
        
        if (ischar(raw{i, 5}))      %   Coupling
            temp{1, 5} = raw{i, 5};
        else
            temp{1, 5} = '';
        end
        
        temp{1, 6} = raw{i, 6};     %   Voltage
        
        if (ischar(raw{i, 7}))      %   Manufacturer
            temp{1, 7} = raw{i, 7};
        else
            temp{1, 7} = '';
        end
        
        temp{1, 8} = raw{i, 8};     %   Manufacturer ID
        
        temp{1, 9} = raw{i, 9};     %   Serial number
        
        temp{1, 10} = raw{i, 10};   %   Sensitivity
        
        if (ischar(raw{i, 11}))     %   Units
            temp{1, 11} = raw{i, 11};
        else
            temp{1, 11} = '';
        end
        
        if (ischar(raw{i, 12}))     %   Dof
            temp{1, 12} = raw{i, 12};
        else
            temp{1, 12} = '';
        end
        
        if (ischar(raw{i, 13}))     %   Direction
            temp{1, 13} = raw{i, 13};
        else
            temp{1, 13} = '';
        end
        
        %                 if (ischar(raw{i, 3}))      %   Signal type
        %                     temp{1, 3} = raw{i, 3};
        %                 else
        %                     temp{1, 3} = '';
        %                 end
        
        %                 if (ischar(raw{i, 7}))      %   Transducer type
        %                     temp{1, 7} = raw{i, 7};
        %                 else
        %                     temp{1, 7} = '';
        %                 end
        
        dataIn(i - inputIndex, :) = temp(1, :);
        %dataIn(i - inputIndex, :) = { raw{i, 1}, raw{i, 2}, raw{i, 3}, raw{i, 4}, ...
        %                    raw{i, 5}, raw{i, 6}, raw{i, 7}, raw{i, 8}, ...
        %                    raw{i, 9}, raw{i, 10}, raw{i, 11}, raw{i, 12}};
    end
    
    for i = outputIndex + 1:n
        
        %   Copy data and check for NaNs in inappropiate places (Hint: No NaNs in string elements)
        temp = cell(1, 13);
        
        temp{1, 1} = raw{i, 1};     %   Active
        temp{1, 2} = raw{i, 2};     %   Referense
        
        if (ischar(raw{i, 3}))      %   Channel
            temp{1, 3} = raw{i, 3};
        else
            temp{1, 3} = '';
        end
        
        if (ischar(raw{i, 4}))      %   Label
            temp{1, 4} = raw{i, 4};
        else
            temp{1, 4} = '';
        end
        
        if (ischar(raw{i, 5}))      %   Coupling
            temp{1, 5} = raw{i, 5};
        else
            temp{1, 5} = '';
        end
        
        temp{1, 6} = raw{i, 6};     %   Voltage
        
        if (ischar(raw{i, 7}))      %   Manufacturer
            temp{1, 7} = raw{i, 7};
        else
            temp{1, 7} = '';
        end
        
        temp{1, 8} = raw{i, 8};     %  Model
        
        temp{1, 9} = raw{i, 9};     %   Serial number
        
        temp{1, 10} = raw{i, 10};   %   Sensitivity
        
        if (ischar(raw{i, 11}))     %   Units
            temp{1, 11} = raw{i, 11};
        else
            temp{1, 11} = '';
        end
        
        if (ischar(raw{i, 12}))     %   Dof
            temp{1, 12} = raw{i, 12};
        else
            temp{1, 12} = '';
        end
        
        if (ischar(raw{i, 13}))      %   Direction
            temp{1, 13} = raw{i, 13};
        else
            temp{1, 13} = '';
        end
        
        %                 if (ischar(raw{i, 3}))      %   Signal type
        %                     temp{1, 3} = raw{i, 3};
        %                 else
        %                     temp{1, 3} = '';
        %                 end
        
        %                 if (ischar(raw{i, 7}))      %   Transducer type
        %                     temp{1, 7} = raw{i, 7};
        %                 else
        %                     temp{1, 7} = '';
        %                 end
        
        dataOut(i - outputIndex, :) = temp(1, :);
        %dataOut(i - outputIndex, :) = { raw{i, 1}, raw{i, 2}, raw{i, 3}, raw{i, 4}, ...
        %                    raw{i, 5}, raw{i, 6}, raw{i, 7}, raw{i, 8}, ...
        %                    raw{i, 9}, raw{i, 10}, raw{i, 11}, raw{i, 12}};
    end
    
    set(handles.channelsTable, 'data', dataIn);
    set(handles.outputTable, 'data', dataOut);
    
    %   Update status bar
    set(handles.statusStr, 'String', [selection, ' is now loaded ...']);
    
    guidata(hObject, handles);
end