% findSpikes.m
% part of the spikesort package
% 
% created by Srinivas Gorur-Shandilya at 8:58 , 20 November 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
function findSpikes(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if any(isnan(s.raw_voltage))
    cprintf('red','\n[WARN] ')
    cprintf('NaNs found in voltage trace. Cannot continue.' )
    return
end

if ~isempty(s.A) || ~isempty(s.B)
    return
end

pref = s.pref;
if s.filter_trace
	V = s.filtered_voltage;

    % if get(s.handles.kill_ringing_control,'Value')
    %     s.killRinging;
    % end

else
	V = s.raw_voltage;
end

if get(s.handles.prom_auto_control,'Value')
	%guess some nice value
	mpp = nanstd(V)/2;
else
	mpp = get(s.handles.spike_prom_slider,'Value');
end

mpd = pref.minimum_peak_distance;
mpw = pref.minimum_peak_width;
v_cutoff = pref.V_cutoff;

% save the spikes trace and LFP
if s.filter_trace
    this_data = s.current_data.data(1,s.this_paradigm);
    raw_voltage = this_data.(s.pref.ephys_channel_name)(s.this_trial,:);
    raw_voltageLFP = this_data.voltage(s.this_trial,:);
    [s.spikesTemp.data(s.this_paradigm).SpikeTrace(s.this_trial,:),~] = ...
        filterTrace(raw_voltage,s.pref);
    [~,s.spikesTemp.data(s.this_paradigm).LFP(s.this_trial,:)] = ...
        filterTrace(raw_voltageLFP,s.pref);
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


% cut out the snippets
% Do we have R, snippets and loc on the local structure
if isfield(s.spikesTemp.data,'R')
     s.spikesTemp.data(s.this_paradigm).R(s.this_trial) = {[]};
else
    [s.spikesTemp.data.R] = deal({[]});
end
if ~isfield(s.spikesTemp.data,'V_snippets')
    [s.spikesTemp.data.V_snippets] = deal({[]});
end
if ~isfield(s.spikesTemp.data,'loc')
    [s.spikesTemp.data.loc] = deal({[]});
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
        V_snippets(:,i) = s.filtered_voltage(loc(i)-pref.t_before+1:loc(i)+pref.t_after);
    end

    s.spikesTemp.data(s.this_paradigm).V_snippets(s.this_trial) = {V_snippets};
end

s.spikesTemp.data(s.this_paradigm).loc(s.this_trial) = {loc};
%update the loc
s.loc = loc;
