%getSortedData
% part of spike sort package
% extracts A-B spikes, firing rates, LFP and PID from the given filename
% written by mahmut demir 11.22.20
%
function sortedData = getSortedData(fileName,FlyOrnFileInd,Preferences)

sRPIn = Preferences;
% set the defaults
Preferences.dt = 1e-3; %1 ms
Preferences.window = 30e-3; % 30 ms
Preferences.algo = 'causal'; % exponential casual
Preferences.RemPIDArtif = true; % remove the spikes in PID recordings
Preferences.pidNoiseMethod = 'sgolay'; % filtering method to remove spikes from PID
Preferences.pidNoiseSmtlen = .05; % window length for Savitzky-Golay Filtering to remove spikes from PID
Preferences.polynomialOrder = 3; % polynomial order for Savitzky-Golay Filtering to remove spikes from PID

if ~isempty(sRPIn)
    % replace with the given ones
    defFNs = fieldnames(Preferences);
    for i = 1:numel(defFNs)
        if any(strcmp(defFNs{i},fieldnames(sRPIn)))
            Preferences.(defFNs{i}) = sRPIn.(defFNs{i});
        end
    end
end

% initiate the empty structure
sortedData = [];
dsorted = load(fileName,'-mat');
[~,ParadnTrialsIndex] = structureElementLength(dsorted.data);


totTrials = sum(ParadnTrialsIndex(:,2));
for i = 1:size(ParadnTrialsIndex,1)
    theseTrials = find(sum(dsorted.spikes(ParadnTrialsIndex(i,1)).discard,2)==2);
    totTrials = totTrials - sum(theseTrials);
end

if totTrials==0
    return
end


% prepare the butter filter
wn = [5 4000]/(dsorted.SamplingRate/2);
[b,a] = butter(4, wn);

% get parameters for savitsky-golay filter
if strcmpi(Preferences.pidNoiseMethod,'sgolay')
    windowWidth = round(Preferences.pidNoiseSmtlen*dsorted.SamplingRate);
    if iseven(windowWidth)
        windowWidth = windowWidth +1;
    end
end

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
    sortedData.data(i).A = [];
    sortedData.data(i).B = [];
    sortedData.data(i).SpikesTrace = [];
    sortedData.data(i).LFP = [];
    sortedData.data(i).PID = [];
    sortedData.data(i).fileParadTrialLS = [];
    sortedData.data(i).frA = [];
    sortedData.data(i).frB = [];
    sortedData.data(i).DateVec = []; % exact time when the experiment data was recorded
end
deltheseParad = false(size(ParadnTrialsIndex,1),1);
for i = 1:size(ParadnTrialsIndex,1)
    theseTrials = find(sum(dsorted.spikes(ParadnTrialsIndex(i,1)).discard,2)~=2);
    sortedData.ControlParadigm(i).Name = dsorted.ControlParadigm(ParadnTrialsIndex(i,1)).Name;
    sortedData.ControlParadigm(i).Outputs = dsorted.ControlParadigm(ParadnTrialsIndex(i,1)).Outputs;
    if isempty(theseTrials)
        deltheseParad(i) = true;
        continue
    end
    % get non-discarded data
    time = (1:size(dsorted.data(ParadnTrialsIndex(i,1)).PID,2))/dsorted.SamplingRate;
    
    if sum(~dsorted.spikes(ParadnTrialsIndex(i,1)).discard(:,2))~=0
        % error if the file is not sorted
        if isempty(dsorted.spikes(ParadnTrialsIndex(i,1)).A(~dsorted.spikes(ParadnTrialsIndex(i,1)).discard(:,2),:))...
                || isempty(dsorted.spikes(ParadnTrialsIndex(i,1)).B(~dsorted.spikes(ParadnTrialsIndex(i,1)).discard(:,2),:))
            error([fileName,' may not be sorted at all'])
        end
    end
    
    
    for j = 1:length(theseTrials)
        thisTrial = theseTrials(j);
        if any(isnan(dsorted.data(ParadnTrialsIndex(i,1)).spikes(thisTrial,:)))
            sortedData.data(i).fileParadTrialLS(j,:) = [FlyOrnFileInd,ParadnTrialsIndex(i,1),thisTrial,...
                dsorted.spikes(ParadnTrialsIndex(i,1)).discard(thisTrial,:)];
            sortedData.data(i).SpikesTrace(j,:) = nan;
            sortedData.data(i).PID(j,:) = nan;
            sortedData.data(i).LFP(j,:) = nan;
            sortedData.data(i).A(j,:) = dsorted.spikes(ParadnTrialsIndex(i,1)).A(thisTrial,:);
            sortedData.data(i).B(j,:) = dsorted.spikes(ParadnTrialsIndex(i,1)).B(thisTrial,:);
            % calculate firing rates
            [sortedData.data(i).frA(j,:),~] = spiketimes2f_1(sortedData.data(i).A(j,:),...
                time, Preferences.dt, Preferences.window, Preferences.algo);
            [sortedData.data(i).frB(j,:),~] = spiketimes2f_1(sortedData.data(i).B(j,:),...
                time, Preferences.dt, Preferences.window, Preferences.algo);
            % time stamping doe snot seem to be wroking properly. That
            % looks like kontroller issue. until fixing it, I will use the
            % try option
            try
                sortedData.data(i).DateVec(j,:) = datevec(dsorted.timestamps(3,...
                    dsorted.timestamps(1,:)==ParadnTrialsIndex(i,1)&dsorted.timestamps(2,:)==j));
            catch
            end
        else
            
            sortedData.data(i).fileParadTrialLS(j,:) = [FlyOrnFileInd,ParadnTrialsIndex(i,1),thisTrial,...
                dsorted.spikes(ParadnTrialsIndex(i,1)).discard(thisTrial,:)];
            
            sortedData.data(i).SpikesTrace(j,:) = filtfilt(b,a,dsorted.data(ParadnTrialsIndex(i,1)).spikes(thisTrial,:));
            if Preferences.RemPIDArtif
                if strcmpi(Preferences.pidNoiseMethod,'sgolay')
                    sortedData.data(i).PID(j,:) = sgolayfilt(dsorted.data(ParadnTrialsIndex(i,1)).PID(thisTrial,:),...
                        Preferences.polynomialOrder, windowWidth);
                else % use the same bandpass filter as used in LFP filtering
                    
                    PIDArtifacts = filtfilt(b,a,dsorted.data(ParadnTrialsIndex(i,1)).PID(thisTrial,:));
                    sortedData.data(i).PID(j,:) = dsorted.data(ParadnTrialsIndex(i,1)).PID(thisTrial,:) - PIDArtifacts;
                end
            else
                sortedData.data(i).PID(j,:) = dsorted.data(ParadnTrialsIndex(i,1)).PID(thisTrial,:);
            end
            spikestemp = filtfilt(b,a,dsorted.data(ParadnTrialsIndex(i,1)).voltage(thisTrial,:));
            sortedData.data(i).LFP(j,:) = dsorted.data(ParadnTrialsIndex(i,1)).voltage(thisTrial,:) - spikestemp;
            sortedData.data(i).A(j,:) = dsorted.spikes(ParadnTrialsIndex(i,1)).A(thisTrial,:);
            sortedData.data(i).B(j,:) = dsorted.spikes(ParadnTrialsIndex(i,1)).B(thisTrial,:);
            % calculate firing rates
            [sortedData.data(i).frA(j,:),~] = spiketimes2f_1(sortedData.data(i).A(j,:),...
                time, Preferences.dt, Preferences.window, Preferences.algo);
            [sortedData.data(i).frB(j,:),~] = spiketimes2f_1(sortedData.data(i).B(j,:),...
                time, Preferences.dt, Preferences.window, Preferences.algo);
            % time stamping doe snot seem to be wroking properly. That
            % looks like kontroller issue. until fixing it, I will use the
            % try option
            try
                sortedData.data(i).DateVec(j,:) = datevec(dsorted.timestamps(3,...
                    dsorted.timestamps(1,:)==ParadnTrialsIndex(i,1)&dsorted.timestamps(2,:)==j));
            catch
            end
        end
        disp(['Paradigm: ',num2str(i),'/',num2str(size(ParadnTrialsIndex,1)),' - Trial: ',num2str(j),'/',num2str(length(theseTrials)),' is complete'])
    end
    
    % remove the offset from LFP and PID
    % how long is the signal
    if length(sortedData.data(i).LFP)<5*dsorted.SamplingRate
        getPSLen = round(length(sortedData.data(i).LFP)/10);
    else
        getPSLen = 5*dsorted.SamplingRate;
    end
    % save the mean vakues for later use
    sortedData.data(i).LFP_BaseMean = mean(sortedData.data(i).LFP(:,1:getPSLen),2);
    sortedData.data(i).PID_BaseMean = mean(sortedData.data(i).PID(:,1:getPSLen),2);
    sortedData.data(i).LFP = sortedData.data(i).LFP - mean(sortedData.data(i).LFP(:,1:getPSLen),2);
    sortedData.data(i).PID = sortedData.data(i).PID - mean(sortedData.data(i).PID(:,1:getPSLen),2);
    
    
    
end
sortedData.data(deltheseParad) = [];
sortedData.ControlParadigm(deltheseParad) = [];

