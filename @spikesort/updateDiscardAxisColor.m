function updateDiscardAxisColor(s,~,~)
% sets the plot panels color to red
if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% if s.handles.discard_control.Value
%     s.handles.ax1.Color = 'r';
%     s.handles.ax2.Color = 'r';
% else
%     s.handles.ax1.Color = 'w';
%     s.handles.ax2.Color = 'w';
% end

if s.handles.discard_LFP.Value
    s.handles.ax2.Color = 'r';
    s.handles.discard_LFP.BackgroundColor = 'r';
else
    s.handles.ax2.Color = 'w';
    s.handles.discard_LFP.BackgroundColor = [0.9400 0.9400 0.9400];
end
if s.handles.discard_Spikes.Value
    s.handles.ax1.Color = 'r';
    
    s.handles.discard_Spikes.BackgroundColor = 'r';
else
    s.handles.ax1.Color = 'w';
    
    s.handles.discard_Spikes.BackgroundColor = [0.9400 0.9400 0.9400];
end

if ~s.handles.discard_Spikes.Value&&~s.handles.discard_LFP.Value
    s.handles.discard_control.BackgroundColor = [0.9400 0.9400 0.9400];
else
    s.handles.discard_control.BackgroundColor = 'r';
end