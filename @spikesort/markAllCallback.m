% modifies all spikes in the viewport to whatever is the currently chosen mode

function [] = markAllCallback(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end


% compatability layer
A = s.A(:);
B = s.B(:);
xlimits = get(s.handles.ax1,'XLim');

% get all spikes in viewport 
if get(s.handles.mode_new_A,'Value') == 1
    % ignore this case 
	cprintf('red','\n[WARN] ')
	cprintf('text','You cannot mark all spikes if this mode is chosen.')
	return

elseif get(s.handles.mode_new_B,'Value')==1
    % ignore this case 
	cprintf('red','\n[WARN] ')
	cprintf('text','You cannot mark all spikes if this mode is chosen.')
	return

elseif get(s.handles.mode_delete,'Value') == 1
   	these_spikes = (B>xlimits(1)/s.pref.deltat & B<xlimits(2)/s.pref.deltat);
	B(these_spikes) = [];
	these_spikes = (A>xlimits(1)/s.pref.deltat & A<xlimits(2)/s.pref.deltat);
	A(these_spikes) = [];
elseif get(s.handles.mode_A2B,'Value') == 1 
	these_spikes = (A>xlimits(1)/s.pref.deltat & A<xlimits(2)/s.pref.deltat);
	B = sort([B; A(these_spikes)]);
	A(these_spikes) = [];

elseif get(s.handles.mode_B2A,'Value') == 1
	these_spikes = (B>xlimits(1)/s.pref.deltat & B<xlimits(2)/s.pref.deltat);
	A = sort([A; B(these_spikes)]);
	B(these_spikes) = [];
end

s.A = A;
s.B = B;
s.spikesTemp.data(s.this_paradigm).A(s.this_trial) = {A};
s.spikesTemp.data(s.this_paradigm).B(s.this_trial) = {B};
