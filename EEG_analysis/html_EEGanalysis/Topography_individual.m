function [] = Topography_individual(html, procEEG)

TFRhann = procEEG{html.ID};

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