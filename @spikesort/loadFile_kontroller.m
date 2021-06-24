% spikesort plugin
% plugin_type = 'load-file';
% data_extension = 'kontroller';
%
function s = loadFile_kontroller(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

s.dataLoaded = 0;

if ~s.dataLoaded
    % read the voltage trace for the current file
    s.current_data = load([s.path_name s.file_name],'-mat');
    s.dataLoaded = 1;
end



% read the file
m = matfile([s.path_name s.file_name]);

% get the output channel names
s.output_channel_names = m.OutputChannelNames;

% read sampling rate
s.sampling_rate = m.SamplingRate;


% update the paradigm names in the paradigm chooser
temp = m.ControlParadigm;
temp = {temp.Name};

% only show those control paradigms that have any data in them
[~,s.ParadnTrialsIndex] = structureElementLength(m.data);
paradigms_with_data = s.ParadnTrialsIndex(:,1);
s.handles.paradigm_chooser.String = temp(paradigms_with_data);

% if sorted, correct discard situation if it does not exist
if isfield(s.current_data,'spikes')
    if ~isfield(s.current_data.spikes,'discard')
        % append discard and set all to false
        for iprd = 1:size(s.ParadnTrialsIndex,1)
            
            s.current_data.spikes(s.ParadnTrialsIndex(iprd,1)).discard = ...
                false(s.ParadnTrialsIndex(iprd,2),2);
        end
    else
        % perhaps the discard is single value discard. fix that to lfp
        % and spikes
        for iprd = 1:size(s.ParadnTrialsIndex,1)
            if prod(size(s.current_data.spikes(s.ParadnTrialsIndex(iprd,1)).discard))...
                    ~=(s.ParadnTrialsIndex(iprd,2)*2)
                disctemp = s.current_data.spikes(s.ParadnTrialsIndex(iprd,1)).discard;
                s.current_data.spikes(s.ParadnTrialsIndex(iprd,1)).discard = false(s.ParadnTrialsIndex(iprd,2),2);
                if isempty(disctemp)
                    continue
                end
                for itrl = 1:length(disctemp)
                    s.current_data.spikes(s.ParadnTrialsIndex(iprd,1)).discard(itrl,:) = ...
                        logical(ones(1,2)*disctemp(itrl));
                end
                
            end
        end
    end
end

% populate some fields for the UX
set(s.handles.valve_channel,'String',s.output_channel_names)

% update stimulus listbox with all input channel names
fl = fieldnames(m.data);

% make sure that we have the requested varibale
if ~ismember(s.pref.ephys_channel_name,fl)
    if strcmp(s.pref.ephys_channel_name,'spikes')
        % set it to voltage
        s.pref.ephys_channel_name = 'voltage';
    end
    % assert it
    assert(ismember(s.pref.ephys_channel_name,fl),'Data doe snot include neither "spikes" nor "voltage"')
end


% also add all the control signals
set(s.handles.stim_channel,'String',[fl(:); s.output_channel_names(:)]);


% update response listbox with all the input channel names
set(s.handles.resp_channel,'String',fl);


% go to the first trial and paradigm with data
s.this_paradigm  = paradigms_with_data(1);
s.handles.paradigm_chooser.Value = s.ParadnTrialsIndex(1,3);
% s.this_trial = 1;

% set the data read and save manual
s.handles.fileSave_button.Value = 0;
s.handles.fileSave_button.Enable = 'on';
s.handles.fileSave_radio.Value = 0;
s.handles.fileSave_radio.Enable = 'on';



