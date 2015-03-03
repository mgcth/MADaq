function TrigOpt = nidaq_trigger_fcn_template
%NIDAQ_TRIGGER_FNC_TEMPLATE

% Read TrigOpt data from trigger file when it exist
% Objects read from TrigOpt are: TrigOpt.u        - source signal
%                                TrigOpt.tu       - Times associated with u
%                                TrigOpt.Repeat   - =true in repeat mode
%                                TrigOpt.File     - Name of file for data
if exist('triggerdata.mat','file')
    load triggerdata
    TrigOpt.Go=true;
    delete('triggerdata.mat');
else
    TrigOpt.Go=false;
end


