% spikesort plugin
% plugin_type = 'read-data';
% data_extension = 'kontroller';
%
function s = readData_kontroller(s,src,event)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if isempty(s.this_paradigm) || isempty(s.this_trial)
    return
end

% enable everything; we'll disable things later
s.handles.prev_trial.Enable = 'on';
s.handles.next_trial.Enable = 'on';
s.handles.next_paradigm.Enable = 'on';
s.handles.prev_paradigm.Enable = 'on';
s.handles.paradigm_chooser.Enable = 'on';
s.handles.trial_chooser.Enable = 'on';

% read the voltage trace for the current file
s.current_data = load([s.path_name s.file_name],'-mat');
m = matfile([s.path_name s.file_name]);

% read the number of paradigms we have
nparadigms = length(m.data);

if s.this_paradigm == nparadigms
    s.handles.next_paradigm.Enable = 'off';
end
if s.this_paradigm == 1
    s.handles.prev_paradigm.Enable = 'off';
end

if s.this_paradigm > size(m.data,2)
    % abort, no data for this paradigm
    s.raw_voltage = [];
    s.stimulus = [];
    set(s.handles.ax1_data,'XData',NaN,'YData',NaN);
    set(s.handles.ax2_data,'XData',NaN,'YData',NaN);
    s.handles.prev_trial.Enable = 'off';
    s.handles.next_trial.Enable = 'off';
    s.handles.trial_chooser.Enable = 'off';
    return
end

this_data = m.data(1,s.this_paradigm);
if isempty(this_data.(s.pref.ephys_channel_name))
    % abort, no data for this trial (how did we even get here?)
    s.raw_voltage = [];
    s.stimulus = [];
    set(s.handles.ax1_data,'XData',NaN,'YData',NaN);
    set(s.handles.ax2_data,'XData',NaN,'YData',NaN);
    return
end


s.raw_voltage = this_data.(s.pref.ephys_channel_name)(s.this_trial,:);


% read the stimulus trace for the current file for the current trial
s.stimulus = this_data.(s.pref.stimulus_channel_name)(s.this_trial,:);

% if container is empty initiate it
if isempty(s.spikesTemp)
    s.initiateLocalSpikesContainer;
end

% is this already sorted?
if any(strcmp('spikes',who(m)))
    try
        this_spikes = m.spikes(1,s.this_paradigm);
        allSavedSpikes = [find(this_spikes.A(s.this_trial,:)),...
            find(this_spikes.B(s.this_trial,:))];
        
        
        try
            allLocalSpikes = [s.spikesTemp.data(s.this_paradigm).A{s.this_trial}(:);...
                s.spikesTemp.data(s.this_paradigm).B{s.this_trial}(:)];
        catch
            allLocalSpikes = [];
        end
        if ~isempty(allSavedSpikes) && isempty(allLocalSpikes)
            s.spikesTemp.data(s.this_paradigm).A(s.this_trial) = {find(this_spikes.A(s.this_trial,:))};
            s.spikesTemp.data(s.this_paradigm).B(s.this_trial) = {find(this_spikes.B(s.this_trial,:))};
            s.spikesTemp.data(s.this_paradigm).N(s.this_trial) = {find(this_spikes.N(s.this_trial,:))};
            % update spikes as well
            s.A = find(this_spikes.A(s.this_trial,:));
            s.B = find(this_spikes.B(s.this_trial,:));
            s.N = find(this_spikes.N(s.this_trial,:));
            
        elseif isempty(allSavedSpikes) && ~isempty(allLocalSpikes )
            s.A = s.spikesTemp.data(s.this_paradigm).A{s.this_trial};
            s.B = s.spikesTemp.data(s.this_paradigm).B{s.this_trial};
            s.N = s.spikesTemp.data(s.this_paradigm).N{s.this_trial};
        else
            % decide which one to use
            s.A = s.spikesTemp.data(s.this_paradigm).A{s.this_trial};
            s.B = s.spikesTemp.data(s.this_paradigm).B{s.this_trial};
            s.N = s.spikesTemp.data(s.this_paradigm).N{s.this_trial};
        end
    catch
        % use local data
        % if notr created just do so
        if ~isfield(s.spikesTemp,'data')
            % initiate local spikes structure
            s.initiateLocalSpikesContainer;
            % update the spikes
            s.A = [];
            s.B = [];
            s.N = [];
        elseif ~isfield(s.spikesTemp.data,'A')
            s.initiateLocalSpikesContainer;
            % update the spikes
            s.A = [];
            s.B = [];
            s.N = [];
        else
            s.A = s.spikesTemp.data(s.this_paradigm).A{s.this_trial};
            s.B = s.spikesTemp.data(s.this_paradigm).B{s.this_trial};
            s.N = s.spikesTemp.data(s.this_paradigm).N{s.this_trial};
        end
    end
end

% update the trial chooser with the number of trials we have in this paradigm
ntrials = size(this_data.(s.pref.ephys_channel_name),1);
trial_text = {};
for i = 1:ntrials
    trial_text{i} = ['Trial ' oval(i)];
end
s.handles.trial_chooser.String = trial_text;

s.handles.trial_chooser.Value = s.this_trial;

% disable some buttons as needed
if s.this_trial == ntrials
    s.handles.next_trial.Enable = 'off';
end
if s.this_trial == 1
    s.handles.prev_trial.Enable = 'off';
end

% update the discard control
s.updateDiscardControl;






