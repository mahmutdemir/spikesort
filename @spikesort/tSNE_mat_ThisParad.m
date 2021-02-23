% spikesort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2;
%
% created by mahmut demir, 11.19.20
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function tSNE_mat_ThisParad(s)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

%first find all spikes under these parameters
s.findThisParadigmSpikes;

% determine total number of spikes
totNSpikes = 0;
parInd = find(s.ParadnTrialsIndex(:,1)==s.this_paradigm);
for trialInd = 1:s.ParadnTrialsIndex(parInd,2)
    totNSpikes = totNSpikes + length(s.spikesTemp.data(s.this_paradigm).loc{trialInd});
end


snippetLen =  size(s.spikesTemp.data(s.this_paradigm).V_snippets{1},1);
V_snipParad = nan(snippetLen,totNSpikes); % initiate empty snipped container and start concatanating
V_snipParadLabels = nan(3,totNSpikes); % keep track of snippets, [paradigm;trial;loc]

startInd = 1;
for trialInd = 1:s.ParadnTrialsIndex(parInd,2)
    
    if ~isempty(s.spikesTemp.data(s.this_paradigm).loc{trialInd})
        nSpikes = length(s.spikesTemp.data(s.this_paradigm).loc{trialInd});
        endInd = startInd + nSpikes - 1;
        V_snipParad(:,startInd:endInd) = s.spikesTemp.data(s.this_paradigm).V_snippets{trialInd}; % initiate empty snipped container and start concatanating
        V_snipParadLabels(1,startInd:endInd) = s.this_paradigm;
        V_snipParadLabels(2,startInd:endInd) = trialInd;
        V_snipParadLabels(3,startInd:endInd) = s.spikesTemp.data(s.this_paradigm).loc{trialInd};
        startInd = endInd + 1;
    else
%         nSpikes = length(s.spikesTemp.data(s.this_paradigm).loc{trialInd});
%         endInd = startInd + nSpikes - 1;
%         V_snipParad(:,startInd:endInd) = s.spikesTemp.data(s.this_paradigm).V_snippets{trialInd}; % initiate empty snipped container and start concatanating
%         V_snipParadLabels(1,startInd:endInd) = s.this_paradigm;
%         V_snipParadLabels(2,startInd:endInd) = trialInd;
%         V_snipParadLabels(3,startInd:endInd) = s.spikesTemp.data(s.this_paradigm).loc{trialInd};
%         startInd = endInd + 1;
    end
    
end
s.spikesTemp.V_snipParad = V_snipParad;
s.spikesTemp.ParadLabelAll = V_snipParadLabels;
s.spikesTemp.RParad = tsne(V_snipParad')';