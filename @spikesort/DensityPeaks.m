% % spikesort plugin
% plugin_type = 'cluster';
% plugin_dimension = 2;
%
% this plugin for spikesort uses the density peaks algorithm to automatically cluster spikes into 3 clusters (noise, B and A)
%
%
% created by Srinivas Gorur-Shandilya. Contact me at http://srinivas.gs/contact/
%
function DensityPeaks(s)

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
    case 'tSNE_mat_AllParadNTrials'
        RedDim = s.spikesTemp.RAll;
        V_Snippets = s.spikesTemp.V_snipAll;
        V_Labels = s.spikesTemp.V_snipAllLabels;
    case 'tSNE_mat_ThisParad'
        RedDim = s.spikesTemp.RParad;
        V_Snippets = s.spikesTemp.V_snipParad;
        V_Labels = s.spikesTemp.ParadLabelAll;
    otherwise
        cprintf('red','[WARN] ')
        cprintf('text','Unexpected dimensinality reduction type.')
        keyboard
end

% unpack data
L = densityPeaks(RedDim,'n_clusters',3,'percent',2);


% figure out which label is which
r = zeros(3,1);
for i = 1:3
    r(i) = mean(max(V_Snippets(:,L==i)) - min(V_Snippets(:,L==i)));
end

% if we have to show the final solution, show it
if s.pref.show_dp_clusters
    temp = figure('Position',[0 0 800 800]); hold on
    c = lines(3);
    for i = 1:3
        plot(RedDim(1,L==i),RedDim(2,L==i),'+','Color',c(i,:))
    end
    prettyFig
    [~,idx]=sort(r,'descend');
    LL = {'A','B','noise'};
    legend(LL(idx))
    drawnow
    pause(1)
    delete(temp)
end

switch method
    case {'PCA','ProbPCA','multiCoreTSNE','tSNE','tSNE_mat'}
        s.spikesTemp.data(s.this_paradigm).A(s.this_trial) = {s.loc(L == find(r==max(r)))};
        s.spikesTemp.data(s.this_paradigm).N(s.this_trial) = {s.loc(L == find(r==min(r)))};
        s.spikesTemp.data(s.this_paradigm).B(s.this_trial) = {s.loc(L == find(r==median(r)))};
        % also update spikes
        s.A = s.loc(L == find(r==max(r)));
        s.N = s.loc(L == find(r==min(r)));
        s.B = s.loc(L == find(r==median(r)));
    case 'tSNE_mat_AllParadNTrials'
        % assign the current spikes
        loc = V_Labels(3,:);
        % save all spikes in the local temporary structure
        for parInd = 1:size(s.ParadnTrialsIndex,1)
            parIndData = s.ParadnTrialsIndex(parInd,1);
            for trialInd = 1:s.ParadnTrialsIndex(parInd,2)
                if ~isempty(s.spikesTemp.data(parIndData).loc{trialInd})
                    thisInd = logical((V_Labels(1,:)==parIndData).*(V_Labels(2,:)==trialInd));
                    thisloc = loc(thisInd);
                    thisL = L(thisInd);
                    s.spikesTemp.data(parIndData).A(trialInd) = {thisloc(thisL == find(r==max(r)))};
                    s.spikesTemp.data(parIndData).N(trialInd) = {thisloc(thisL == find(r==min(r)))};
                    s.spikesTemp.data(parIndData).B(trialInd) = {thisloc(thisL == find(r==median(r)))};
                    if (s.this_paradigm==parIndData)&&(s.this_trial==trialInd)
                        s.A = thisloc(thisL == find(r==max(r)));
                        s.N = thisloc(thisL == find(r==min(r)));
                        s.B = thisloc(thisL == find(r==median(r)));
                    end
                end
            end
        end
        
    case 'tSNE_mat_ThisParad'
        % assign the current spikes
        loc = V_Labels(3,:);
        % save all spikes in the local temporary structure
        for trialInd = 1:s.ParadnTrialsIndex(s.this_paradigm==s.ParadnTrialsIndex(:,1),2)
            if ~isempty(s.spikesTemp.data(s.this_paradigm).loc{trialInd})
                thisInd = logical((V_Labels(1,:)==s.this_paradigm).*(V_Labels(2,:)==trialInd));
                thisloc = loc(thisInd);
                thisL = L(thisInd);
                s.spikesTemp.data(s.this_paradigm).A(trialInd) = {thisloc(thisL == find(r==max(r)))};
                s.spikesTemp.data(s.this_paradigm).N(trialInd) = {thisloc(thisL == find(r==min(r)))};
                s.spikesTemp.data(s.this_paradigm).B(trialInd) = {thisloc(thisL == find(r==median(r)))};
                if (s.this_trial==trialInd)
                    s.A = thisloc(thisL == find(r==max(r)));
                    s.N = thisloc(thisL == find(r==min(r)));
                    s.B = thisloc(thisL == find(r==median(r)));
                end
            end
        end
    otherwise
        cprintf('red','[WARN] ')
        cprintf('text','Unexpected dimensinality reduction type.')
        keyboard
end


