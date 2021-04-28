% spikesort plugin
% plugin_type = 'manual-save';
% data_extension = 'kontroller';
%

function [] = write2DiskNow(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

s.handles.fileSave_button.Value = 1;
s.handles.fileSave_button.Enable = 'off';

% save data
s.saveData;