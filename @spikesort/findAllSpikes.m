% findAllSpikes.m
% part of the spikesort package
%
% created by Srinivas Gorur-Shandilya at 8:58 , 20 November 2015. Contact me at http://srinivas.gs/contact/
% modified by mahmut demir on 11.19.20
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
function [] = findAllSpikes(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

cprintf('green','\n[INFO] ')
cprintf('text','Finding and tsne sorting all spikes...')

pref = s.pref;
% if get(s.handles.prom_auto_control,'Value')
%     %guess some nice value
%     mpp = nanstd(V)/2;
% else
mpp = get(s.handles.spike_prom_slider,'Value');
% end

mpd = pref.minimum_peak_distance;
mpw = pref.minimum_peak_width;
v_cutoff = pref.V_cutoff;


% pre allocate space and and set to empty
try
 s.spikesTemp = rmfield(s.spikesTemp,'data');
catch
end
s.initiateLocalSpikesContainer;

% reset current spikes
s.A = [];
s.B = [];
s.N = [];

% find, tsne and sort all spikes
for parInd = 1:size(s.ParadnTrialsIndex,1)
    parIndData = s.ParadnTrialsIndex(parInd,1);
    this_data = s.current_data.data(1,parIndData);
    s.spikesTemp.data(parIndData).SpikeTrace = nan*this_data.(s.pref.ephys_channel_name);  % holds filtered trace
    s.spikesTemp.data(parIndData).LFP = nan*this_data.(s.pref.ephys_channel_name);  % holds filtered trace
    for trialInd = 1:s.ParadnTrialsIndex(parInd,2)
        cprintf('green','\n[INFO] ')
        cprintf('text',['Paradigm ', num2str(parInd),'/',num2str(size(s.ParadnTrialsIndex,1)),...
            ' - Trial ', num2str(trialInd),'/',num2str(s.ParadnTrialsIndex(parInd,2))])
        
        raw_voltage = this_data.(s.pref.ephys_channel_name)(trialInd,:);
        raw_voltageLFP = this_data.voltage(trialInd,:);
        
        
        if any(isnan(raw_voltage))
            cprintf('red','\n[WARN] ')
            cprintf('NaNs found in voltage trace. Skipping this.' )
            continue
        end
        
        
        
        if s.filter_trace
            [V,~] = filterTrace(raw_voltage,s.pref);
            [~,L] = filterTrace(raw_voltageLFP,s.pref);
            s.spikesTemp.data(parIndData).SpikeTrace(trialInd,:) = V;  % save filtered spike trace in local variable
            s.spikesTemp.data(parIndData).LFP(trialInd,:) = L;  % save filtered LFP trace in local variable
        else
            V = raw_voltage;
        end
        
        % find peaks and remove spikes beyond v_cutoff
        if pref.invert_V
            [~,loc] = findpeaks(-V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
            loc(V(loc) < -abs(v_cutoff)) = [];
        else
            [~,loc] = findpeaks(V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
            loc(V(loc) > abs(v_cutoff)) = [];
        end
        
        
        if s.verbosity
            cprintf('green','\n[INFO]')
            cprintf('text',[' found ' oval(length(loc)) ' spikes'])
        end
        
        if ~isempty(loc)
            
            V_snippets = NaN(pref.t_before+pref.t_after,length(loc));
            if loc(1) < pref.t_before+1
                loc(1) = [];
                V_snippets(:,1) = [];
            end
            if loc(end) + pref.t_after+1 > length(s.filtered_voltage)
                loc(end) = [];
                V_snippets(:,end) = [];
            end
            for i = 1:length(loc)
                V_snippets(:,i) = V(loc(i)-pref.t_before+1:loc(i)+pref.t_after);
            end
            
            s.spikesTemp.data(parIndData).V_snippets(trialInd) = {V_snippets};
        end
        s.spikesTemp.data(parIndData).loc(trialInd) = {loc};
        % update loc
        if (s.this_paradigm==parIndData)&&(s.this_trial==trialInd)
            s.loc = loc;
        end
        
    end
end
