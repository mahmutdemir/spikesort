function updateDiscardControl(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% unpack data
try
    spikes = s.current_data.spikes;
catch
    set(s.handles.discard_control,'Value',0,'String','Discard','FontWeight','normal')
    % update radio buttons as well
    s.handles.discard_LFP.Value = 0;
    s.handles.discard_Spikes.Value = 0;
    
    % update axis colors
    s.updateDiscardAxisColor;
    return
end

if isfield(spikes,'discard')
    discard_this = false;
    try
        discard_this = spikes(s.this_paradigm).discard(s.this_trial,:);
    catch
    end
    if any(discard_this)
        set(s.handles.discard_control,'Value',1,'String','Discarded!','FontWeight','bold')
        if length(discard_this)==2
            % update radio buttons as well
            s.handles.discard_LFP.Value = discard_this(1);
            s.handles.discard_Spikes.Value = discard_this(2);
        elseif length(discard_this)==1
            s.handles.discard_LFP.Value = 1;
            s.handles.discard_Spikes.Value = 1;
        else
            disp('How did this happen?')
            % this happened probbaly the discard filed is tranposed
            % simply do this if that is the case
            % spikes.discard = spikes.discard';
            % save([s.path_name s.file_name],'-append','spikes')
            keyboard
        end
    else
        set(s.handles.discard_control,'Value',0,'String','Discard','FontWeight','normal')
        % update radio buttons as well
        s.handles.discard_LFP.Value = 0;
        s.handles.discard_Spikes.Value = 0;
    end
else
    % nothing has been discarded
    set(s.handles.discard_control,'Value',0,'String','Discard','FontWeight','normal')
    % update radio buttons as well
    s.handles.discard_LFP.Value = 0;
    s.handles.discard_Spikes.Value = 0;
end

% update axis colors
s.updateDiscardAxisColor;