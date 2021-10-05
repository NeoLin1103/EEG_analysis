function [] = pre_ICA(html)

file_struct_list_EEG = dir([html.workpath filesep '*.cnt']); 
filename_list_EEG = {file_struct_list_EEG.name};
filename_list_EEG = natsort(filename_list_EEG);

for subject_EEG = 1:length(filename_list_EEG)
    EEG = pop_loadcnt([html.workpath filesep filename_list_EEG{subject_EEG}], 'dataformat', 'auto', 'keystroke', 'on', 'memmapfile', '');  %% perform your processing 
    EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    
    EEG = pop_eegfiltnew(EEG, 'locutoff',html.highPass,'hicutoff',html.lowPass,'plotfreqz',1);
    EEG = movechannels(EEG,'Location','skipchannels','Direction','Remove','Channels',{'VEOG','HEOG'});
    EEG = pop_rejchan(EEG, 'elec',[1:32] ,'threshold',5,'norm','on','measure','kurt');
    EEG = pop_runica(EEG, 'icatype', 'runica', 'options', {'extended',1,'block',floor(sqrt(EEG.pnts/3)),'anneal',0.98});
    EEG = pop_saveset( EEG, 'filename',[filename_list_EEG{subject_EEG},'ICA', '.set'],'filepath',html.savepath);
end

end