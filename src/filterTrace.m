% filters the given trace and returns both the filtered trace and remaining
% residue which are spikes and LFP in case of ephys
% modified from spikesort by mahmut demir on 11.19.20
%

function [filteredTrace,Residue] = filterTrace(Trace,pref)

% make sure that pref has the correct fields
if nargin==1
    pref.band_pass = [5 0.5000];
    pref.deltat = 1e-04;
else
    assert(isfield(pref,'band_pass'),' no field as band_pass in pref')
    assert(isfield(pref,'deltat'),' no field as deltat in pref')
end

lc = floor(pref.band_pass(1)*1e-3/pref.deltat);
hc = floor(pref.band_pass(2)*1e-3/pref.deltat);

if any(isnan(Trace))
    cprintf('NaNs found in voltage trace. Cannot continue.' )
    filteredTrace = NaN*Trace;
    Residue = NaN*Trace;
    return
end


LFP = filtfilt(ones(lc,1),lc,Trace);
% now subtract the LFP from the raw voltage to get the spikes
Vf = Trace(:) - LFP(:);
% clean it up; remove some HF noise
filteredTrace = filtfilt(ones(hc,1),hc,Vf);
Residue = LFP;



