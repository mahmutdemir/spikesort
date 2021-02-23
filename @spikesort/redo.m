function redo(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

s.spikesTemp.data(s.this_paradigm).A(s.this_trial) = {[]};
s.spikesTemp.data(s.this_paradigm).B(s.this_trial) = {[]};
s.spikesTemp.data(s.this_paradigm).N(s.this_trial) = {[]};
% update spikes as well
s.A = [];
s.B = [];
s.N = [];

s.use_this_fragment = [];

s.plotResp;

% s.saveData;

% find spikes
s.findSpikes;

% re-enable some things
s.handles.method_control.Enable = 'on';