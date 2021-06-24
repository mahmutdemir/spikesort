function setDiscardControl(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if s.handles.discard_control.Value
    % discard both LFP and Spikes
    s.handles.discard_LFP.Value = 1;
    s.handles.discard_Spikes.Value = 1;
else
    % undo discard both LFP and Spikes
    s.handles.discard_LFP.Value = 0;
    s.handles.discard_Spikes.Value = 0;
end

% set the time in case it is a corrupted recording
if isempty(s.time)
    s.time = (1:size(s.current_data.data(s.this_paradigm).(s.pref.ephys_channel_name)(s.this_trial,:),2))/s.sampling_rate;
end

% set the discard value to true if discard status is changed
s.saveData;

% now update the control
s.updateDiscardControl;