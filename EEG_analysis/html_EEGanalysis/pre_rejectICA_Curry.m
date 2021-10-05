function [] = pre_rejectICA_Curry(html)

file_struct_list_set = dir([html.workpath filesep '*.set']); 
file_struct_list_set = {file_struct_list_set .name};
file_struct_list_set = natsort(file_struct_list_set );

Ofile_struct_list_set = dir([html.originpath filesep '*.cnt']); 
Ofile_struct_list_set = {Ofile_struct_list_set .name};
Ofile_struct_list_set = natsort(Ofile_struct_list_set );

EEG = pop_loadcnt([html.originpath filesep Ofile_struct_list_set{1}], 'dataformat', 'auto', 'keystroke', 'on', 'memmapfile', '');
EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
originalEEG = EEG;

for subject_EEG = 1:length(file_struct_list_set)    
        EEG = pop_loadset('filename', file_struct_list_set{subject_EEG}, 'filepath', html.workpath);  %% perform your processing
        EEG.icaquant = icablinkmetrics(EEG,'ArtifactChannel', EEG.skipchannels.data(1,:));
        disp('ICA Metrics are located in: EEG.icaquant.metrics')
        disp('Selected ICA component(s) are located in: EEG.icaquant.identifiedcomponents')
        [~,index] = sortrows([EEG.icaquant.metrics.convolution].');
        EEG.icaquantzmetrics = EEG.icaquant.metrics(index(end:-1:1)); clear index
        %Remove Artifact ICA component(s)
        if EEG.icaquant.identifiedcomponents == 0
           if length(EEG.chanlocs) < 35
               EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical'); % 差補之後再切epoch出現error
           end
           EEG = pop_epoch( EEG, html.eventMark, html.setEpoch, 'epochinfo', 'yes');
           EEG = pop_eegthresh(EEG,1,[3:32] ,-(html.threshValue),html.threshValue,-1,0,0,1);
           EEG = pop_saveset( EEG, 'filename',[file_struct_list_set{subject_EEG},'RejICA', '.set'],'filepath', html.savepath);
        else
           EEG = pop_subcomp(EEG,EEG.icaquant.identifiedcomponents,0);
           if length(EEG.chanlocs) < 35
               EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical'); % 差補之後再切epoch出現error
           end
           EEG = pop_epoch( EEG, html.eventMark, html.setEpoch, 'epochinfo', 'yes');
           EEG = pop_eegthresh(EEG,1,[3:32] ,-(html.threshValue),html.threshValue,-1,0,0,1);
           EEG = pop_saveset( EEG, 'filename',[file_struct_list_set{subject_EEG},'RejICA', '.set'],'filepath', html.savepath);
        end
end
end
