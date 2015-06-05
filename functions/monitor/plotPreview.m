function plotPreview(src, event)
% Handles the plotting for the preview

global handles_

preview = getappdata(0, 'previewStruct');

CH = preview.channelInfo;
tmpTable = get(handles_.channelsTable,'Data');
ical = {tmpTable{:,11}}; 
ical = diag(cell2mat(ical(CH.active))');


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
d(dataLen - m + 1:dataLen, 1:n) = (ical * event.Data')';

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
hbar=bar(preview.subplots.master, std(d));
axis(preview.subplots.master, [0 (n + 1) -0.1 5.1]);
set(hbar.Parent,'FontName','Times','FontSize',8);

%   Update channel monitors
for i = 1:4
    if (i <= numberOfChannels)
        plt=plot(preview.subplots.handles(i), t, d(:, preview.currentMonitorRange(i)));
        %             axis(preview.subplots.handles(i), [min(t) max(t) preview.channelData(i).Min preview.channelData(i).Max]);
        set(plt.Parent,'FontName','Times','FontSize',8);
        chanData = preview.channelData(preview.currentMonitorRange(i));
%         title(preview.subplots.handles(i), [chanData.channel, ' #', num2str(chanData.index)]);
        tit=title(preview.subplots.handles(i), [chanData.label, ' (#', num2str(chanData.index) ')']);
        set(tit,'FontName','Times','FontWeight','normal','FontSize',10)
    else
        cla(preview.subplots.handles(i));
        title(preview.subplots.handles(i), '');
    end
end