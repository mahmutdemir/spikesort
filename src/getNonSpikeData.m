%getNonSpikeData
% part of spike sort package
% extracts PID from the given filename
% written by mahmut demir 02.04.21
%
function sortedData = getNonSpikeData(fileName,FlyOrnFileInd,Preferences)

sRPIn = Preferences;
% set the defaults
Preferences.dt = 1e-3; %1 ms
Preferences.window = 30e-3; % 30 ms
Preferences.algo = 'causal'; % exponential casual
Preferences.ignoreSpikes = 0; % enfore spike sorting, and get cleaned LFP and spikes

if ~isempty(sRPIn)
    % replace with the given ones
    defFNs = fieldnames(Preferences);
    for i = 1:numel(defFNs)
        if any(strcmp(defFNs{i},fieldnames(sRPIn)))
            Preferences.(defFNs{i}) = sRPIn.(defFNs{i});
        end
    end
end

% initiate the emcpoty structure
sortedData = [];
dsorted = load(fileName,'-mat');
[~,ParadnTrialsIndex] = structureElementLength(dsorted.data);


totTrials = sum(ParadnTrialsIndex(:,2));
for i = 1:size(ParadnTrialsIndex,1)
    theseTrials = find(sum(dsorted.data.PID(ParadnTrialsIndex(i,1)).discard,2)==2);
    totTrials = totTrials - sum(theseTrials);
end

if totTrials==0
    return
end


% prepare the butter filter
wn = [5 4000]/(dsorted.SamplingRate/2);
[b,a] = butter(4, wn);

% get paradimgs with data

sortedData.fileName = {fileName};
% define what each column in fileParadTrialLS is
sortedData.col.flyNum = 1; % column for fly number
sortedData.col.OrnFlyNum = 2; % column for ORN # in given fly
sortedData.col.fileNum = 3; % column for fileNumber (refers to fielNames)
sortedData.col.paradNuminFile = 4; % column for recorded paradigm
sortedData.col.trialNuminParad = 5; % column for ORN # in given fly
sortedData.col.discardLFP = 6; % column for LFP discarding (1: discard)
sortedData.col.discardSpikes = 7; % column for Spike, Spike Rate discarding (1: discard)

% do a loop over paradigms with data
for i = 1:size(ParadnTrialsIndex,1)
    sortedData.data(i).PID = [];
    sortedData.data(i).fileParadTrialLS = [];

end
deltheseParad = false(size(ParadnTrialsIndex,1),1);
for i = 1:size(ParadnTrialsIndex,1)
    theseTrials = find(sum(dsorted.data.PID(ParadnTrialsIndex(i,1)).discard,2)~=2);
    sortedData.ControlParadigm(i).Name = dsorted.ControlParadigm(ParadnTrialsIndex(i,1)).Name;
    sortedData.ControlParadigm(i).Outputs = dsorted.ControlParadigm(ParadnTrialsIndex(i,1)).Outputs;
    if isempty(theseTrials)
        deltheseParad(i) = true;
        continue
    end

    
    for j = 1:length(theseTrials)
        thisTrial = theseTrials(j);
        if any(isnan(dsorted.data(ParadnTrialsIndex(i,1)).spikes(thisTrial,:)))
            sortedData.data(i).fileParadTrialLS(j,:) = [FlyOrnFileInd,ParadnTrialsIndex(i,1),thisTrial,...
                dsorted.data.PID(ParadnTrialsIndex(i,1)).discard(thisTrial,:)];
            sortedData.data(i).PID(j,:) = nan;

        else
            
            sortedData.data(i).fileParadTrialLS(j,:) = [FlyOrnFileInd,ParadnTrialsIndex(i,1),thisTrial,...
                dsorted.data.PID(ParadnTrialsIndex(i,1)).discard(thisTrial,:)];
            PIDArtifacts = filtfilt(b,a,dsorted.data(ParadnTrialsIndex(i,1)).PID(thisTrial,:));
            sortedData.data(i).PID(j,:) = dsorted.data(ParadnTrialsIndex(i,1)).PID(thisTrial,:) - PIDArtifacts;

        end
        disp(['Paradigm: ',num2str(i),'/',num2str(size(ParadnTrialsIndex,1)),' - Trial: ',num2str(j),'/',num2str(length(theseTrials)),' is complete'])
    end
    
    % remove the offset from LFP and PID
    % how long is the signal
    if length(sortedData.data(i).PID)<5*dsorted.SamplingRate
        getPSLen = round(length(sortedData.data(i).PID)/10);
    else
        getPSLen = 5*dsorted.SamplingRate;
    end
    % save the mean vakues for later use
    sortedData.data(i).PID_BaseMean = mean(sortedData.data(i).PID(:,1:getPSLen),2);
    sortedData.data(i).PID = sortedData.data(i).PID - mean(sortedData.data(i).PID(:,1:getPSLen),2);
    
    
    
end
sortedData.data(deltheseParad) = [];
sortedData.ControlParadigm(deltheseParad) = [];

