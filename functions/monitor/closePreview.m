function closePreview (currentHandle, events, handles)

preview = getappdata(0, 'previewStruct');

if (~isempty(preview))
    clear plotPreview; % clear the persisten variables in there
    try logging = preview.adHocLogging;
    catch, logging = false;
    end
    
    if (~logging)
        try preview.session.stop();         catch, end
        try preview.session.release();      catch, end
        try delete(preview.session);        catch, end
        %for i = 1:length(preview.subplots.handles), cla(preview.subplots.handles(i)); cla(preview.figure); end
        try delete(preview.figure);         catch, end
        try rmappdata(0, 'previewStruct');  catch, end
        
        %   Clear DAQ
        daq.reset;
    else
        msgbox('Make sure to stop the free logging before closing the monitor','Free logging in progress...');
    end
end

set(handles.startButton, 'String', 'Start measurement','BackGround',[0 1 0]);
drawnow();