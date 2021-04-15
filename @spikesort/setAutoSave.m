function setAutoSave(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if s.handles.fileSave_radio.Value
    % unable the manual save button
    s.handles.fileSave_button.Value = 0;
    s.handles.fileSave_button.Enable = 'off';
else
    % able the manual save button
    s.handles.fileSave_button.Value = 1;
    s.handles.fileSave_button.Enable = 'on';
end

