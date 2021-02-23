function setDiscardControlLFPNSpike(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% set the discard value to true if discard status is changed
% set the time in case it is a corrupted recording
if isempty(s.time)
    s.time = (1:size(s.current_data.data(s.this_paradigm).spikes(s.this_trial,:),2))/s.sampling_rate;
end

s.saveData;

% now update the control
s.updateDiscardControl;

% update axis colors
s.updateDiscardAxisColor;
