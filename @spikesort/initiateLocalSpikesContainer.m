% initiateLocalSpikesContainer.m
% part of the spikesort package
%
% created by mahmut demir , 11.20.20
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function [] = initiateLocalSpikesContainer(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

s.spikesTemp = [];

% do a loop over paradigms with data
for i = 1:size(s.ParadnTrialsIndex,1)
    paradIndex = s.ParadnTrialsIndex(i,1);
    s.spikesTemp.data(paradIndex).A(s.ParadnTrialsIndex(i,2)) = {[]};
    s.spikesTemp.data(paradIndex).B(s.ParadnTrialsIndex(i,2)) = {[]};
    s.spikesTemp.data(paradIndex).N(s.ParadnTrialsIndex(i,2)) = {[]};
    s.spikesTemp.data(paradIndex).loc(s.ParadnTrialsIndex(i,2)) = {[]};
    s.spikesTemp.data(paradIndex).R(s.ParadnTrialsIndex(i,2)) = {[]};
    s.spikesTemp.data(paradIndex).V_snippets(s.ParadnTrialsIndex(i,2)) = {[]};
    s.spikesTemp.data(paradIndex).SpikeTrace = [];
    s.spikesTemp.data(paradIndex).LFP = [];
    s.spikesTemp.data(paradIndex).A_amplitude(s.ParadnTrialsIndex(i,2)) = {[]};
    s.spikesTemp.data(paradIndex).B_amplitude(s.ParadnTrialsIndex(i,2)) = {[]};
end
