function plotPreview(src, event)
% Handles the plotting for the preview

preview = getappdata(0, 'previewStruct');

try
    if (preview.logging.freeLogging)
        logData(src, event, preview.logging.files);
    end
catch,  end

numberOfChannels = length(preview.currentMonitorRange);

dataLen = 15000;
[m, n] = size(event.Data);

persistent t d filterData;
if (isempty(t) || isempty(d) || (min(t) > min(event.TimeStamps)))
    t = zeros(dataLen, 1);
    d = zeros(dataLen, n);
    filterData = zeros(1, n);
end

%   Update time and data values to be plotted
t = circshift(t, -m);
d = circshift(d, -m);
t(dataLen - m + 1:dataLen, :) = event.TimeStamps;
d(dataLen - m + 1:dataLen, 1:n) = event.Data;

%   Update master monitor
%     oldFilterData = filterData .* 0.9;
%     filterData = mean(event.Data);
%     for i = 1:n
%         newData = filterData(1, i) / preview.channelData(i).Max;
%
%         if (newData > oldFilterData(1, i))
%             filterData(1, i) = newData;
%         end
%     end
%     bar(preview.subplots.master, filterData);
bar(preview.subplots.master, std(d));
axis(preview.subplots.master, [0 (n + 1) -0.1 5.1]);


%   Update channel monitors
for i = 1:4
    if (i <= numberOfChannels)
        plot(preview.subplots.handles(i), t, d(:, preview.currentMonitorRange(i)));
        %             axis(preview.subplots.handles(i), [min(t) max(t) preview.channelData(i).Min preview.channelData(i).Max]);
        chanData = preview.channelData(preview.currentMonitorRange(i));
        title(preview.subplots.handles(i), [chanData.channel, ' #', num2str(chanData.index)]);
    else
        cla(preview.subplots.handles(i));
        title(preview.subplots.handles(i), '');
    end
end