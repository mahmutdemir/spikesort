% plots the selected variable as the stimulus in the secondary plot
% mahmut demir oct 16 2020

function [] = plotSelectedStim(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% load stimulus
s.pref.stimulus_channel_name = s.handles.stim_channel.String{s.handles.stim_channel.Value};
s.readData;

