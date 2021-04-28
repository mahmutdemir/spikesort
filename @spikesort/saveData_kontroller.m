% spikesort plugin
% plugin_type = 'save-data';
% data_extension = 'kontroller';
%

function [] = saveData_kontroller(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% early escape
if isempty(s.time)
    return
end

if ~s.handles.fileSave_radio.Value
    if any(strcmp('spikes',fieldnames(s.current_data)))
        spikes = s.current_data.spikes;
    else
        data = s.current_data.data;
        nparadigms = length(data);
        spikes(nparadigms).A = [];
        for i = 1:nparadigms
            ntrials =  size(data(i).(s.pref.ephys_channel_name),1);
            temp = data(i).(s.pref.ephys_channel_name)*0;
            temp(isnan(temp)) = 0;
            spikes(i).A = sparse(logical(0*temp));
            spikes(i).B = sparse(logical(0*temp));
            spikes(i).N = sparse(logical(0*temp));
            spikes(i).amplitudes_A = (0*temp);
            spikes(i).amplitudes_B = (0*temp);
            spikes(i).discard = false(ntrials,2); % LFP and Spikes
        end
        clear data
    end
else
    % figure out if there is a spikes variable already
    m = matfile([s.path_name s.file_name]);
    if any(strcmp('spikes',who(m)))
        load([s.path_name s.file_name],'-mat','spikes')
    else
        load([s.path_name s.file_name],'-mat','data')
        % create it, and make an entry for ever single one in data
        nparadigms = length(data);
        spikes(nparadigms).A = [];
        for i = 1:nparadigms
            ntrials =  size(data(i).(s.pref.ephys_channel_name),1);
            temp = data(i).(s.pref.ephys_channel_name)*0;
            temp(isnan(temp)) = 0;
            spikes(i).A = sparse(logical(0*temp));
            spikes(i).B = sparse(logical(0*temp));
            spikes(i).N = sparse(logical(0*temp));
            spikes(i).amplitudes_A = (0*temp);
            spikes(i).amplitudes_B = (0*temp);
            spikes(i).discard = false(ntrials,2); % LFP and Spikes
        end
        clear data
    end
end

spikes(s.this_paradigm).A(s.this_trial,:) = 0;
spikes(s.this_paradigm).B(s.this_trial,:) = 0;
spikes(s.this_paradigm).N(s.this_trial,:) = 0;

spikes(s.this_paradigm).B(s.this_trial,...
    s.spikesTemp.data(s.this_paradigm).B{s.this_trial}) = 1;
spikes(s.this_paradigm).A(s.this_trial,...
    s.spikesTemp.data(s.this_paradigm).A{s.this_trial}) = 1;
spikes(s.this_paradigm).N(s.this_trial,...
    s.spikesTemp.data(s.this_paradigm).N{s.this_trial}) = 1;

% perhaps LFP or
% make sure that following code works fine
if isfield(spikes,'discard')
    if length(spikes(s.this_paradigm).discard(s.this_trial,:)) == 1
        % fix this part of the data
        ntrials =  size(spikes(s.this_paradigm).discard,1);
        tdiscard = spikes(s.this_paradigm).discard;
        spikes(s.this_paradigm).discard = false(ntrials,2); % LFP and Spikes
        for i = 1:ntrials
            if tdiscard(i)
                spikes(s.this_paradigm).discard(i,:) = true(1,2);
            end
        end
    end
else
    load([s.path_name s.file_name],'-mat','data')
    % create it, and make an entry for ever single one in data
    nparadigms = length(data);
    for i = 1:nparadigms
        ntrials =  size(data(i).(s.pref.ephys_channel_name),1);
        spikes(i).discard = false(ntrials,2); % LFP and Spikes
    end
    clear data
end

discardStatus = [s.handles.discard_LFP.Value, s.handles.discard_Spikes.Value];
spikes(s.this_paradigm).discard(s.this_trial,:) = logical(discardStatus);

if ~isempty(s.spikesTemp.data(s.this_paradigm).A{s.this_trial})
    spikes(s.this_paradigm).amplitudes_A(s.this_trial,...
        s.spikesTemp.data(s.this_paradigm).A{s.this_trial}) = ...
        s.spikesTemp.data(s.this_paradigm).A_amplitude{s.this_trial};
end
if ~isempty(s.spikesTemp.data(s.this_paradigm).B{s.this_trial})
    spikes(s.this_paradigm).amplitudes_B(s.this_trial,...
        s.spikesTemp.data(s.this_paradigm).B{s.this_trial}) = ...
        s.spikesTemp.data(s.this_paradigm).B_amplitude{s.this_trial};
end

% also put on as current data
s.current_data.spikes = spikes;

if ~s.handles.fileSave_radio.Value
    if strcmp(s.handles.fileSave_button.Enable,'off')&&(s.handles.fileSave_button.Value == 1)
        save([s.path_name s.file_name],'-append','spikes')
        s.handles.fileSave_button.Enable = 'on';
        s.handles.fileSave_button.Value = 0;
    end
else
    save([s.path_name s.file_name],'-append','spikes')
end

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',('Data saved!'))
end
