% merge structures and consolidate structures
% part of spikesort package
% written by mahmut demir 11.22.20
%
function s = AppendSortedSpikeS(s1,s2)

% make sure that these structures include these fields
expField = {'fileName';'data';'ControlParadigm'};
for i = 1:numel(expField)
    assert(any(strcmp(fieldnames(s1),expField(i))),['s1 does not include necessary field: ',expField{i}])
    assert(any(strcmp(fieldnames(s2),expField(i))),['s2 does not include necessary field: ',expField{i}])
end

assert(all(strcmp(fieldnames(s1.data),fieldnames(s2.data))),'data field names must be identical')
assert(all(strcmp(fieldnames(s1.col),fieldnames(s2.col))),'data column names must be identical')

pn1 = {s1.ControlParadigm.Name};
pn2 = {s2.ControlParadigm.Name};

% append the filename
s1.fileName = [s1.fileName,s2.fileName];
datafn = fieldnames(s1.data);

for pidx = 1:numel(pn2)
    if any(strcmp(pn1,pn2(pidx)))
        for fnidx = 1:numel(datafn)
            % are these vector have different lengths
            do = s1.data(strcmp(pn1,pn2(pidx))).(datafn{fnidx});
            da = s2.data(pidx).(datafn{fnidx});
            lo = size(do,2);
            la = size(da,2);
            if lo==la
                s1.data(strcmp(pn1,pn2(pidx))).(datafn{fnidx}) = [do;da];
            elseif lo>la
                da(:,la+1:lo) = nan;
                s1.data(strcmp(pn1,pn2(pidx))).(datafn{fnidx}) = [do;da];
            else
                do(:,lo+1:la) = nan;
                s1.data(strcmp(pn1,pn2(pidx))).(datafn{fnidx}) = [do;da];
            end
            
        end
    else
        % a new paradigm, pad at the end
        if pidx<=numel(s2.data) % do not append if the data is empty
            s1.data = [s1.data,s2.data(pidx)];
            s1.ControlParadigm = [s1.ControlParadigm,s2.ControlParadigm(pidx)];
        end
    end
end

s = s1;