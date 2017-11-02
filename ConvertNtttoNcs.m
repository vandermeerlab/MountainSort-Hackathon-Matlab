function [csc] =ConvertNtttoNcs(cfg_in)
%% ConvertNtttoNcs: convert a .ntt discontinuous file into multiple .ncs continously sampled files 



%% default parameters
cfg_def.fin = {};
cfg_def.fout = 'out.ncs';

cfg = ProcessConfig(cfg_def,cfg_in);

data_out = [];
%% identify channel numbers from ntt

%% extract elements from Ntt file
% for iF = 1:length(cfg.fin)
[Timestamps, ScNumbers, CellNumbers, Features, Samples, Header] =  Nlx2MatSpike(cfg.fin{iF}, [1 1 1 1 1], 1, 1, [] );
Fs = regexp([Header{:}],'(?<=SamplingFrequency[^0-9]*)[0-9]*','match')
AdChan = regexp([Header{20}],'(?<=ADChannel[^0-7]*)[0-7]*','match');
csc_chan =str2num(AdChan{1})-1;


% get a corresponding .ncs
[csc_Timestamps, ~, ~, ~, ~, csc_Header] = Nlx2MatCSC(['CSC' num2str(csc_chan) '.ncs'], [1 0 0 0 0 1], 1, 1, []);



%% convert vales into nChanx(2xnsamples_per_spikexnEvents
% Concatenate with zeros(size(snippet,2)) between snippets such that you end up with a 2D matrix of 4x(2x40xN)
% The rows must be the channels of the ntrode
% Zeroes can be any length but should be at least as long as a snippet
% The padding is important so that when Mountainsort detects events and makes its own clips, there will not be overlap between the waveforms of neighboring spikes!
waves = permute(Samples,[2,1,3]);
raw =reshape(cat(2,waves,zeros(size(waves))),4,2*32*size(waves,3)); % code modified from https://bitbucket.org/franklab/trodes2ff_shared/src/d360eaf7bce693cb37b8ad56a89c7d45406d63fa/waves2mda.m?at=develop&fileviewer=file-view-default
% event_times=peak_inds+(0:size(Samples,3)-1)*2*32;
% event_times = int32(event_times);
