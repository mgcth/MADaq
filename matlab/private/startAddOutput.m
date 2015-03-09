function startAddOutput(handles, sessionObject)

% Add output channels
dataOut = get(handles.outputTable, 'data');
[mm, nn] = size(dataOut);
j = 1;

for i = 1:mm
    if dataOut{i,1} == 1
        chan = textscan(dataOut{i,3}, '%s%s', 'Delimiter', '/', 'CollectOutput', 1);
        sessionObject.session.addAnalogOutputChannel(char(chan{1}(1)), 0, 'Voltage');
        
        % Increment channels counter
        j = j + 1;
    end
end