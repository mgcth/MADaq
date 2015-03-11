function previewSliderUpdate(hObject, eventData, handles)
%     preview = getappdata(0, 'previewStruct');
%
%     sliderVal = floor(get(hObject, 'value'));
%     maxVal = get(hObject, 'Max');
%     if (sliderVal ~= maxVal)
%         preview.currentMonitorRange = [1 2 3 4] + 4 * sliderVal;
%
%         if (max(preview.currentMonitorRange) > length(preview.session.Channels))
%             preview.currentMonitorRange = (1:mod(length(preview.session.Channels), 4)) + 4 * sliderVal;
%         end
%     end
%
%     setappdata(0, 'previewStruct', preview);
