function [] = Topography_group(html, procEEG)

TFRhann = procEEG{1};
for subject_EEG = 2:length(procEEG)
    TFRhann.powspctrm = TFRhann.powspctrm + procEEG{subject_EEG}.powspctrm;
end
TFRhann.powspctrm = TFRhann.powspctrm/length(procEEG);

cfg = [];
cfg.rotate = 90;
layout = ft_prepare_layout(cfg, TFRhann);

%Natural log trans
TFRhann.powspctrm = log(TFRhann.powspctrm);

cfg        = [];
cfg.layout = layout;
cfg.colorbar = 'yes';
cfg.xlim   = [html.band(1), html.band(2)]; % Frequency band
figure;
ft_topoplotER(cfg, TFRhann);
end