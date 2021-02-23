% spikesort plugin
% plugin_type = 'cluster';
% plugin_dimension = 2;
%
% allows you to manually cluster a reduced-to-2D-dataset by drawling lines around clusters
% usage:
% C = sscm_ManualCluster(R);
%
% where R C a 2xN matrix
%
% this is derived from ManualCluster.m, but renamed for plugin-compatibility for spikesort
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
%
% This work C licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
% largely built out of legacy code I wrote in 2011 for Carlotta's spike sorting
function ManualCluster(s)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% which clustering method is called
method = (get(s.handles.method_control,'Value'));
temp = get(s.handles.method_control,'String');
method = temp{method};

switch method
    case {'PCA','ProbPCA','multiCoreTSNE','tSNE','tSNE_mat'}
        RedDim = s.spikesTemp.data(s.this_paradigm).R{s.this_trial};
        V_Snippets = s.spikesTemp.data(s.this_paradigm).V_snippets{s.this_trial};
        loc = s.loc;
    case 'tSNE_mat_AllParadNTrials'
        RedDim = s.spikesTemp.RAll;
        V_Snippets = s.spikesTemp.V_snipAll;
        V_Labels = s.spikesTemp.V_snipAllLabels;
        loc = V_Labels(3,:);
    case 'tSNE_mat_ThisParad'
        RedDim = s.spikesTemp.RParad;
        V_Snippets = s.spikesTemp.V_snipParad;
        V_Labels = s.spikesTemp.ParadLabelAll;
        loc = V_Labels(3,:);
    otherwise
        cprintf('red','[WARN] ')
        cprintf('text','Unexpected dimensinality reduction type.')
        keyboard
end


idx = manualCluster(RedDim,V_Snippets,{'A neuron','B neuron','Noise','Coincident Spikes'},@s.showSpikeInContext);



switch method
    case {'PCA','ProbPCA','multiCoreTSNE','tSNE','tSNE_mat'}
        A = loc(idx==1);
        B = loc(idx==2);
        N = loc(idx==3);
        
        % handle coincident spikes
        A = unique([A loc(idx==4)]);
        B = unique([B loc(idx==4)]);
        
        s.A = A;
        s.B = B;
        s.N = N;
        s.spikesTemp.data(s.this_paradigm).A(s.this_trial) = {A};
        s.spikesTemp.data(s.this_paradigm).B(s.this_trial) = {B};
        s.spikesTemp.data(s.this_paradigm).N(s.this_trial) = {N};
        
    case 'tSNE_mat_AllParadNTrials'
        % save all spikes in the local temporary structure
        for parInd = 1:size(s.ParadnTrialsIndex,1)
            parIndData = s.ParadnTrialsIndex(parInd,1);
            for trialInd = 1:s.ParadnTrialsIndex(parInd,2)
                if ~isempty(s.spikesTemp.data(parIndData).loc{trialInd})
                    thisInd = logical((V_Labels(1,:)==parIndData).*(V_Labels(2,:)==trialInd));
                    loci = loc(thisInd);
                    idxi = idx(thisInd);
                    A = loci(idxi==1);
                    B = loci(idxi==2);
                    N = loci(idxi==3);
                    
                    % handle coincident spikes
                    A = unique([A loci(idxi==4)]);
                    B = unique([B loci(idxi==4)]);
                    
                    s.spikesTemp.data(parIndData).A(trialInd) = {A};
                    s.spikesTemp.data(parIndData).N(trialInd) = {N};
                    s.spikesTemp.data(parIndData).B(trialInd) = {B};
                    if (s.this_paradigm==parIndData)&&(s.this_trial==trialInd)
                        s.A = A;
                        s.N = N;
                        s.B = B;
                    end
                    
                else
                    
                    A = [];
                    B = [];
                    N = [];
                    
                    s.spikesTemp.data(parIndData).A(trialInd) = {A};
                    s.spikesTemp.data(parIndData).N(trialInd) = {N};
                    s.spikesTemp.data(parIndData).B(trialInd) = {B};
                    if (s.this_paradigm==parIndData)&&(s.this_trial==trialInd)
                        s.A = A;
                        s.N = N;
                        s.B = B;
                    end
                end
            end
        end
        
    case 'tSNE_mat_ThisParad'
        % save all spikes in the local temporary structure
        for trialInd = 1:s.ParadnTrialsIndex(s.this_paradigm==s.ParadnTrialsIndex(:,1),2)
            if ~isempty(s.spikesTemp.data(s.this_paradigm).loc{trialInd})
                thisInd = logical((V_Labels(1,:)==s.this_paradigm).*(V_Labels(2,:)==trialInd));
                loci = loc(thisInd);
                idxi = idx(thisInd);
                A = loci(idxi==1);
                B = loci(idxi==2);
                N = loci(idxi==3);
                
                % handle coincident spikes
                A = unique([A loci(idxi==4)]);
                B = unique([B loci(idxi==4)]);
                
                s.spikesTemp.data(s.this_paradigm).A(trialInd) = {A};
                s.spikesTemp.data(s.this_paradigm).N(trialInd) = {N};
                s.spikesTemp.data(s.this_paradigm).B(trialInd) = {B};
                if (s.this_trial==trialInd)
                    s.A = A;
                    s.N = N;
                    s.B = B;
                end
            else
                
                A = [];
                B = [];
                N = [];
                
                s.spikesTemp.data(s.this_paradigm).A(trialInd) = {A};
                s.spikesTemp.data(s.this_paradigm).N(trialInd) = {N};
                s.spikesTemp.data(s.this_paradigm).B(trialInd) = {B};
                if (s.this_trial==trialInd)
                    s.A = A;
                    s.N = N;
                    s.B = B;
                end
            end
        end
    otherwise
        cprintf('red','[WARN] ')
        cprintf('text','Unexpected dimensinality reduction type.')
        keyboard
end


% cleanup
set(s.handles.ax1_spike_marker,'Visible','off');




