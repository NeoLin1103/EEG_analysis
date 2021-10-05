function [procEEG] = freqAnalysis_FieldTrip(html)

file_struct_list_EEG = dir([html.workpath filesep '*.set']); 
filename_list_EEG = {file_struct_list_EEG.name};
filename_list_EEG = natsort(filename_list_EEG);

procEEG = cell(length(filename_list_EEG),1);

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmfft';
cfg.taper        = 'hamming';
cfg.foi          = html.band(1):(1/html.epolength):html.band(2);
cfg.tapsmofrq    = 1;

for subject_EEG = 1:length(filename_list_EEG)
    EEG = pop_loadset('filename', filename_list_EEG{subject_EEG}, 'filepath', html.workpath);
    data = eeglab2fieldtrip(EEG, 'preprocessing');
    TFRhann = ft_freqanalysis(cfg, data);    
    procEEG{subject_EEG} = TFRhann;
end
end