function [] = updateTrialsParadigms(s,src,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% first save what we have here
s.saveData;

switch src 
case s.handles.next_paradigm
    % is there any other recorded paradigm
	s.this_paradigm = getNextAvailableParadigmTrialNumber(s,'parad','next');
case s.handles.prev_paradigm
	s.this_paradigm = getNextAvailableParadigmTrialNumber(s,'parad','prev');
case s.handles.next_trial
	s.this_trial = getNextAvailableParadigmTrialNumber(s,'trial','next');
case s.handles.prev_trial
	s.this_trial = getNextAvailableParadigmTrialNumber(s,'trial','prev');
case s.handles.trial_chooser
	s.this_trial = s.handles.trial_chooser.Value;
case s.handles.paradigm_chooser
	s.this_paradigm = s.ParadnTrialsIndex(s.handles.paradigm_chooser.Value,1);
end
