function setDiscardControlLFPNSpike(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% set the discard value to true if discard status is changed
s.saveData;

% now update the control
s.updateDiscardControl;

% update axis colors
s.updateDiscardAxisColor;
