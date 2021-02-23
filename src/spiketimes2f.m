% spikestimes2f.m
% accepts a vector of spike times and returns a firing rate estimate using a Gaussian smoothing window. 
% Usage: f =  spiketimes2f(spiketimes,time,dt,window,algo)
% 
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
function [f,t] =  spiketimes2f(spiketimes,time,dt,window,algo)

switch nargin 
case 0
	help spiketimes2f
	return
case 1
	if issparse(spiketimes)
		% assume dt = 1e-4, and that the time vector is simply defined
		time = 1e-4*(1:length(spiketimes));
		dt = 1e-4; dt = 3e-3; window = 3e-2;
		algo = 'causal';
	else
		error('Need to define a time vector:')
		help spiketimes2f
	end
case 2
	dt = 10*mean(diff(time)); % desired rate of output firing rate
	window = 30*dt; % smoothing window
	algo = 'causal';
case 3
	window = 30*dt;
	algo = 'causal';
	
case 4
	algo = 'causal';
end
f=NaN;

debug_mode = 0;


% validate spiketimes 
if isvector(spiketimes)
	if debug_mode
		disp('spiketimes is a vecotr')
	end
	ntrials = 1;
	spiketimes = spiketimes(:);
	if length(unique(spiketimes)) == 2 && sum(unique(spiketimes)) == 1
		% all OK
		if debug_mode
			disp('spiketimes is binary data')
		end
	else
		% error('not binary data')
		temp = sparse(length(time),1);
		temp(nonzeros(spiketimes))=1;
		spiketimes = temp; clear temp
		if debug_mode
			disp('spiketimes is not binary, but i converted it to binary')
		end
	end
else
	if debug_mode
		disp('spiketimes is NOT a vector')
	end
	[a,b] = size(spiketimes);
	if b > a
		spiketimes = spiketimes';
		b=a;
	end
	if length(unique(spiketimes)) == 2
		% binary data
		% for i = 1:b
		% 	temp=find(spiketimes(:,i));
		% 	spiketimes(:,i) = 0;

		% 	spiketimes(1:length(temp),i) = temp;
		% end
	else
		disp('need to convert to binary data')
		keyboard
	end
	ntrials = b;
end


switch algo
	case 'gauss'
		disp('need to convert all computations on binary data')
		% t=min(time):dt:max(time);
		% f = zeros(length(t),ntrials);

		% for i = 1:ntrials
		% 	thesespikes = mean(diff(time))*nonzeros(spiketimes(:,i))+min(time);
		% 	for j = 1:length(thesespikes)
	 %        	f(:,i) = f(:,i) + normpdf(t,thesespikes(j),window)';
	 %        end

		% end
	case 'causal'
		% uses a causal exponential Kernel, see pg 14 of Dayan & Abott Theoretical Neuroscience
		t=min(time):dt:max(time);
		alpha = 1/window; 
		f = zeros(length(t),ntrials);
		deltat = time(2)-time(1);
		tt=0:deltat:1;
		K = ((alpha^2)*exp(-alpha*tt).*tt);
		for i = 1:ntrials
			ff = filter(K,1,full(spiketimes(:,i)));
			% subsample this to desired sampling rate
			f(:,i) = interp1(time,ff,t);
		end

		


end
