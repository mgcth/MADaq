% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

global currentState

set(handles.startButton, 'String', 'Loading!','BackGround',[1 0 0]);

% Columns in the two tables
COLUMNSinINPUTTABLE = 14;
COLUMNSinOUTPUTTABLE = 2;

error = false;
loadFile = false; 
directory = [handles.homePath, '\conf'];
selection = '';
raw = {};

if ~isfield(handles,'DaqReset')
  handles.DaqReset=false;
end

%   Input dialog for menuAbout selection
while (~loadFile)
    if handles.DaqReset
        pathName=tempdir;
        fileName='Temporary.conf';
        handles.DaqReset=false;
    else
      [fileName,pathName] = uigetfile('conf/*.conf','Select the load file');
    end
    selection = [pathName fileName];
    type = exist(selection, 'file');
    
    if ~isempty(fileName)
        
        if (type == 2)      %   File
            loadFile = true;
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
        if (raw{9,3})
            impactTest_Callback(hObject, eventdata, handles)
        elseif (raw{9,4})
            periodic_Callback(hObject, eventdata, handles)
        elseif (raw{9,6})
            multisine_Callback(hObject, eventdata, handles)
        elseif (raw{9,7})
            Oscilloscope_Callback(hObject, eventdata, handles)
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
    % Get channels
    [n, m] = size(raw);
    a=cell(n,1);
    for i = 1:n, a{i} = raw{i,1}; end
    
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
        handles.channelsTable.ColumnFormat{10}=CLL{:};
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
        else, temp{1, 3} = ''; end        
        if (ischar(raw{i, 4}))      %   Label
            temp{1, 4} = raw{i, 4};
        else, temp{1, 4} = ''; end       
        if (ischar(raw{i, 5}))      %   Coupling (AC/DC)
            temp{1, 5} = raw{i, 5};
        else, temp{1, 5} = ''; end     
        if (ischar(raw{i, 6}))      %   Type (Voltage/IEPE)
            temp{1, 6} = raw{i, 6};
        else, temp{1, 6} = ''; end       
        temp{1, 7} = raw{i, 7};     %   Voltage      
        if (ischar(raw{i, 8}))      %   Manufacturer
            temp{1, 8} = raw{i, 8};
        else, temp{1, 8} = ''; end        
        temp{1, 9} = raw{i, 9};     %   Manufacturer ID       
        temp{1, 10} = raw{i, 10};     %   Serial number      
        temp{1, 11} = raw{i, 11};   %   Sensitivity       
        if (ischar(raw{i, 12}))     %   Units
            temp{1, 12} = raw{i, 12};
        else, temp{1, 12} = ''; end       
        if (ischar(raw{i, 13}))     %   Dof
            temp{1, 13} = raw{i, 13};
        else, temp{1, 13} = ''; end
        try, temp{1, 14} = num2str(raw{i, 14});catch, temp{1, 14}='';end % Node
        dataIn(i - inputIndex, :) = temp(1, :);
    end  
    for i = outputIndex + 1:n        
        %   Copy data and check for NaNs in inappropiate places (Hint: No NaNs in string elements)
        temp = cell(1, 2);      
        temp{1, 1} = raw{i, 1};     %   Active
        if (ischar(raw{i, 2}))      %   Channel
            temp{1, 2} = raw{i, 2};
        else, temp{1, 2} = ''; end       
        dataOut(i - outputIndex, :) = temp(1, :);
    end
    set(handles.channelsTable, 'data', dataIn);
    set(handles.outputTable, 'data', dataOut);    
    %   Update status bar
    set(handles.statusStr, 'String', [selection, ' is now loaded ...']);
    set(handles.startButton, 'String', 'Start measurement','BackGround',[0 1 0]);
    guidata(hObject, handles);
end