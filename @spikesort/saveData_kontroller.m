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

% figure out if there is a spikes variable already
m = matfile([s.path_name s.file_name]);
if any(strcmp('spikes',who(m)))
    load([s.path_name s.file_name],'-mat','spikes')
else
    load([s.path_name s.file_name],'-mat','data')
    % create it, and make an entry for ever single one in data
    nparadigms = length(data);
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

spikes(s.this_paradigm).A(s.this_trial,:) = 0;
spikes(s.this_paradigm).B(s.this_trial,:) = 0;
spikes(s.this_paradigm).N(s.this_trial,:) = 0;

spikes(s.this_paradigm).B(s.this_trial,s.B) = 1;
spikes(s.this_paradigm).A(s.this_trial,s.A) = 1;
spikes(s.this_paradigm).N(s.this_trial,s.N) = 1;
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

if ~isempty(s.A)
    spikes(s.this_paradigm).amplitudes_A(s.this_trial,s.A) = s.A_amplitude;
end
if ~isempty(s.B)
    spikes(s.this_paradigm).amplitudes_B(s.this_trial,s.B) = s.B_amplitude;
end

save([s.path_name s.file_name],'-append','spikes')
% also put on as current data
s.current_data.spikes = spikes;

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',['Data saved!'])
end
