function previewMenuUpdate (hObject, eventData, handles)
preview = getappdata(0, 'previewStruct');

value = get(hObject, 'value');

preview.currentMonitorRange = [1 2 3 4] + 4 * (value - 1);

if (max(preview.currentMonitorRange) > length(preview.session.Channels))
    preview.currentMonitorRange = (1:mod(length(preview.session.Channels), 4)) + 4 * (value - 1);
end

%     %   Set  titles
%     for i = 1:4
%         if (length(preview.currentMonitorRange) >= i)
%             chanData = preview.channelData(preview.currentMonitorRange(i));
%             title(preview.subplots.handles(i), [chanData.channel, ' #', chanData.index]);
%         else
%             title(preview.subplots.handles(i), '');
%         end
%     end

setappdata(0, 'previewStruct', preview);