% spikesort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2; 
% 
% created by mahmut demir, 11.19.20
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function tSNE_mat_AllParadNTrials(s)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

%first find all spikes under these parameters
s.findAllSpikes;

% determine total number of spikes
totNSpikes = 0;
for parInd = 1:size(s.ParadnTrialsIndex,1)
    parIndData = s.ParadnTrialsIndex(parInd,1);
    for trialInd = 1:s.ParadnTrialsIndex(parInd,2)
        totNSpikes = totNSpikes + length(s.spikesTemp.data(parIndData).loc{trialInd});
    end
end


snippetLen =  s.pref.t_before+s.pref.t_after;
V_snipAll = nan(snippetLen,totNSpikes); % initiate empty snipped container and start concatanating
V_snipAllLabels = nan(3,totNSpikes); % keep track of snippets, [paradigm;trial;loc]

startInd = 1;
for parInd = 1:size(s.ParadnTrialsIndex,1)
    parIndData = s.ParadnTrialsIndex(parInd,1);
    for trialInd = 1:s.ParadnTrialsIndex(parInd,2)
          
        if ~isempty(s.spikesTemp.data(parIndData).loc{trialInd})
            nSpikes = length(s.spikesTemp.data(parIndData).loc{trialInd});
            endInd = startInd + nSpikes - 1;
            V_snipAll(:,startInd:endInd) = s.spikesTemp.data(parIndData).V_snippets{trialInd}; % initiate empty snipped container and start concatanating
            V_snipAllLabels(1,startInd:endInd) = parIndData;
            V_snipAllLabels(2,startInd:endInd) = trialInd;
            V_snipAllLabels(3,startInd:endInd) = s.spikesTemp.data(parIndData).loc{trialInd};
            startInd = endInd + 1;
        end
        
    end
end
s.spikesTemp.V_snipAll = V_snipAll;
s.spikesTemp.V_snipAllLabels = V_snipAllLabels;
s.spikesTemp.RAll = tsne(V_snipAll')';