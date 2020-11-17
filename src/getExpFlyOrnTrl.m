function [FlyOrnId,properties] = getExpFlyOrnTrl(fileNames,sortall) 
% parses the filelist and extract the experiment numbers and Orn
% numbers from and assigns the file id to them which is the index of
% the filelist

switch nargin
    case 2
        if isempty(fileNames)
            % try to load experiment file names
            if exist('expmat.names.mat','file')
                load('expmat.names.mat');
                fileNames = pathlist;
            elseif exist('expvid.names.mat','file')
                load('expvid.names.mat');
                fileNames = expvidnames;
            else % get all mat files
                filelist = dir('*.mat');
                fileNames = {filelist.name}';
            end
        end
    case 1
        sortall = 0;    % ignore genotype and experiment name, just get exp # and Orn
            
    case 0
        sortall = 0;    % ignore genotype and experiment name, just get exp # and Orn #
        % try to load experiment file names
        if exist('expmat.names.mat','file')
            load('expmat.names.mat');
            fileNames = pathlist;
        elseif exist('expvid.names.mat','file')
            load('expvid.names.mat');
            fileNames = expvidnames;
        else % get all mat files
            filelist = dir('*.mat');
            fileNames = {filelist.name}';
        end
end

% if a single file given put it in a cell
if ~iscell(fileNames)
    fileNames = {fileNames};
end

% sort the fileNames
fileNames = sort(fileNames);

% create an empty structure for detail collection
s = repmat(struct('dgf',{},'date',{},'geno',{},'flyNum',{},'OrnNum',{},'age',{},'exp',{}),numel(fileNames));

% go over the filenames and get details
for i = 1:numel(fileNames)
    [~,NAME,~] = fileparts(fileNames{i}); 
    sp = strsplit(NAME,'_');
    s(i).dgf = strjoin(sp(1:5),'_');
    s(i).date = strjoin(sp(1:3),'_');
    s(i).geno = sp{4};
    s(i).flyNum = str2double(sp{5}(2:end)); % flyNum number on this date
    s(i).OrnNum = strjoin(sp(7:8),'_'); % Orn number
    s(i).age = str2double(sp{6}(1:end-2)); % age of flies days
    s(i).exp = sp{9}; % experiment carried out
end

if sortall == 0
    % initiate the output matrix
    FlyOrnId = zeros(numel(fileNames),3); % exp id, Orn id, and file id
    % ignore experimental details and just return exp # and trail #
    % find unique experiment
    explist = unique({s.dgf});
    trlist = zeros(size(explist));
    fileind = 1;
    for  i = 1:numel(explist)
        trlist(i) = length(find(strcmp({s.dgf}, explist{i})==1));
        for j = 1:trlist(i)
            FlyOrnId(fileind,1)= i;
            FlyOrnId(fileind,2)= j;
            FlyOrnId(fileind,3)= fileind;
            fileind = fileind + 1;
        end
    end
    
else
    % find unique fly
    flyIDlist = unique({s.dgf});
    % go over the genotypes
    for gi = 1:numel(flyIDlist)
        % find indexes corresponding to this fly
        gind = (find(strcmp({s.dgf}, flyIDlist{gi})==1));
        % among this genotype get experiments
        explist = unique({s(gind).exp});
        % go over the experiments
        for ei = 1:numel(explist)
            expind = (find(strcmp({s(gind).exp}, explist{ei})==1));
            % register the flyNum and Orns for this experiment
            for vti = 1:length(expind)
                FlyOrnId.(flyIDlist{gi}).(explist{ei})(vti).date = s(gind(expind(vti))).date;
                FlyOrnId.(flyIDlist{gi}).(explist{ei})(vti).flyNum = s(gind(expind(vti))).flyNum;
                FlyOrnId.(flyIDlist{gi}).(explist{ei})(vti).OrnNum = s(gind(expind(vti))).OrnNum;
                FlyOrnId.(flyIDlist{gi}).(explist{ei})(vti).age = s(gind(expind(vti))).age;
                FlyOrnId.(flyIDlist{gi}).(explist{ei})(vti).Orn = s(gind(expind(vti))).Orn;
                FlyOrnId.(flyIDlist{gi}).(explist{ei})(vti).flind = gind(expind(vti));
                FlyOrnId.(flyIDlist{gi}).(explist{ei})(vti).filename = fileNames{gind(expind(vti))};
            end
        end
    end
end
properties.fileNames = fileNames;
properties.s = s;
                
          
        
        
    


