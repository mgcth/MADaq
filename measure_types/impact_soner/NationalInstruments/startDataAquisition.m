function startDataAquisition(so)
global data nScans triggerLevel scanData

if(exist('tempLog.mat') == 2)
    delete('tempLog.mat');
    disp('old log deleted')
end

so.IsContinuous = true;
lh = so.addlistener('DataAvailable', @GetImpact);
fprintf('Data aquisition started... ')
so.startBackground();

% Wait until the temporary log is created in @GetImpact
        while 1
            if isequal(exist('tempLog.mat'),2)
                break
            else
                pause(0.01);
            end
        end