function stopOscilloscope

global ScopeFeed currentState
try
  PassDoubleThruFile(ScopeFeed.MMF,uint8(2));
catch
end

try
  stop(ScopeFeed.oscillo.session);
%   daq.reset
catch
end

try,close(ScopeFeed.Hao);catch,end
ScopeFeed.startButton.String='Start measurement';
ScopeFeed.startButton.BackgroundColor=[0 1 0];
ScopeFeed.startButton.UserData=0;
ScopeFeed.statusStr.String='READY!';

% FileName=ScopeFeed.MMF.Filename;
CurrentState=currentState; % Save global to survive the clearALL
clearALL;
currentState=CurrentState;
% delete(Filename);
% delete(fullfile(tempdir,'DataContainer*.mat'));
delete(fullfile(tempdir,'abraScope.mat'));
end

function clearALL
clear all
end
