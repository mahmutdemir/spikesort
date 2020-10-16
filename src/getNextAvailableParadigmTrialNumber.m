function ParadTrialNumber = getNextAvailableParadigmTrialNumber(s,ParadorTrial,Direction)
%getNextAvailableParadigmTrialNumber
%   ParadNumber = getNextAvailableParadigmTrialNumber(s,ParadorTrial,Direction)
%   returns the next available (i.e. recorded) paradigm or trial number in 
%   the current data file. ParadorTrial is 'parad', or 'trial'. Direction 
%   is either 'next', or 'prev' ( both case insensitive)
%   written by mahmut demir 10/9/20
%

if strcmpi(ParadorTrial,'parad')
thisParadInd = find(s.this_paradigm==s.ParadnTrialsIndex(:,1));
if strcmpi(Direction,'next')
    % if this the last one circle to start
    if s.ParadnTrialsIndex(end,3)==thisParadInd
        ParadTrialNumber = s.ParadnTrialsIndex(1,1);
    elseif s.ParadnTrialsIndex(end,3)>thisParadInd
        ParadTrialNumber = s.ParadnTrialsIndex(thisParadInd+1,1);
    else
        disp('Paradigm number is larger than available paradimgs. How did this happen?')
        keyboard
    end
else
    % if this the first one circle to end
    if s.ParadnTrialsIndex(1,3)==thisParadInd
        ParadTrialNumber = s.ParadnTrialsIndex(end,1);
    elseif s.ParadnTrialsIndex(1,3)<thisParadInd
        ParadTrialNumber = s.ParadnTrialsIndex(thisParadInd-1,1);
    else
        disp('Paradigm number is smaller (negative) than available paradimgs. How did this happen?')
        keyboard
    end
end
else
    thisParadInd = find(s.this_paradigm==s.ParadnTrialsIndex(:,1));
    thisTrialInd = s.this_trial;
if strcmpi(Direction,'next')
    % if this the last one circle to start
    if s.ParadnTrialsIndex(thisParadInd,2)==thisTrialInd
        ParadTrialNumber = 1;
    elseif s.ParadnTrialsIndex(thisParadInd,2)>thisTrialInd
        ParadTrialNumber = s.this_trial+1;
    else
        disp('Trial number is larger than total number of trials. How did this happen?')
        keyboard
    end
else
    % if this the first one circle to end
    if thisTrialInd==1
        ParadTrialNumber = s.ParadnTrialsIndex(thisParadInd,2);
    elseif thisTrialInd>1
        ParadTrialNumber = s.this_trial-1;
    else
        disp('Trial number is negative. How did this happen?')
        keyboard
    end
end
end
