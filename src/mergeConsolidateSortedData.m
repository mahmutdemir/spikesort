%mergeConsolidateSortedData
% s = mergeConsolidateSortedData(pathlist)
% merge-consolidate sorted data
% part of spike sort package
% written by mahmut demir 11.22.20
%
function s = mergeConsolidateSortedData(pathlist,Preferences)

if nargin==1
    Preferences = []; % use defaults defined in getSortedData
end

% figure out number of Flies and Neurons
% Attention: This code assumes a fixed file name structure
% see: 2020_11_12_22abGU59b_F1_7do_ab3_6_PA2But.kontroller
% you have to ieither reformat your file names or this code
[FlyOrnId,properties] = getExpFlyOrnTrl(pathlist);
if isrow(properties.fileNames)
    fileNames = properties.fileNames'; % get sorted file names
else
    fileNames = properties.fileNames; % get sorted file names
end
    

% are there any bad files
discardedFiles = false(size(fileNames));

% find the first file with some sorted un-discarded data
found = 0;
for i = 1:numel(fileNames)
    if ~found
        disp(['File: ',num2str(i),'/',num2str(numel(fileNames)),' : ',fileNames{i}])
        
        s = getSortedData(fileNames{i},FlyOrnId(i,:),Preferences);
        
        if ~isempty(s)
            disp('file is not empty. will use this')
            found = i;
        else
            disp('file is empty. Discarding...')
            discardedFiles(i) = true;
        end
    end
end


% continue appending
for i = (found+1):numel(fileNames)
    disp(['File: ',num2str(i),'/',num2str(numel(fileNames)),' : ',fileNames{i}])
    
    sdt = getSortedData(fileNames{i},FlyOrnId(i,:),Preferences);
    
    if ~isempty(sdt)
        disp('file is not empty. will use this')
        s = AppendSortedSpikeS(s,sdt);
    else
        disp('file is empty. Discarding...')
        discardedFiles(i) = true;
    end
    
end

% save discarded files list
s.discardedFiles = discardedFiles;

% remove empty entries
delTheseEntries = false(numel(s.data),1);
for i = 1:numel(s.data)
    if isempty(s.ControlParadigm(i).Name)
        delTheseEntries(i) = true;
    end
end
s.data(delTheseEntries) = [];
s.ControlParadigm(delTheseEntries) = [];

% sort the control paradigm names and discard Air on, off, and empty ones
[~,idx] = sort({s.ControlParadigm.Name});

if any(idx~=(1:numel(idx)))
    %resort paradigms
    st = s;
    st = rmfield(st,'data');
    st = rmfield(st,'ControlParadigm');
    for i = 1:numel(idx)
        st.data(i) = s.data(idx(i));
        st.ControlParadigm(i) = s.ControlParadigm(idx(i));
    end
    s = st;
    clear st
end
% remove non needed and empty paradigms
removeTheseParadigms = {'Air_On','Air_Off'};
delTheseEntries = false(numel(s.data),1);
for i = 1:numel(s.data)
    if any(strcmpi(s.ControlParadigm(i).Name,removeTheseParadigms))
        delTheseEntries(i) = true;
        
    end
end
s.data(delTheseEntries) = [];
s.ControlParadigm(delTheseEntries) = [];
