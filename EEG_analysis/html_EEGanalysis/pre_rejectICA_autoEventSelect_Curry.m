function [] = pre_rejectICA_autoEventSelect_Curry(html)

file_struct_list_set = dir([html.workpath filesep '*.set']); 
file_struct_list_set = {file_struct_list_set .name};
file_struct_list_set = natsort(file_struct_list_set );

putt = readmatrix(html.behavioral_data_path);
Putt_list = cell(length(file_struct_list_set), 1);
for subject_EEG = 1:length(file_struct_list_set)
    Putt_list{subject_EEG} = find(~isnan(putt(:,subject_EEG))); % Get index of trails in interest
end

index_of_unwanted_epoch = cell(length(file_struct_list_set), 1);

for subject_EEG = 1:length(file_struct_list_set)
    EEG = pop_loadset('filename', file_struct_list_set{subject_EEG}, 'filepath', html.workpath);    
    eegEvent = struct2table(EEG.event);
    
    indexEventSpike = find(eegEvent.type == 201); % Index of event spike
    indexEventSpike = indexEventSpike(Putt_list{subject_EEG}); % Remove unwanted event spike
    indexEvent1 = find(eegEvent.type == 1); % Index of event 1
    
    subEvent1 = table2array(eegEvent(indexEvent1, [2,3])); % Extract array of event 1 (back swing)

    Event1indexAll = 1:length(indexEventSpike);

    % Find event 1 which are close to event spike
    for m = 1:length(indexEventSpike)
        
        Marker = eegEvent.latency(indexEventSpike(m));
        vecMarker = ones(length(subEvent1),1,'double'); 
        vecMarker = vecMarker.*Marker; % latency vector of event spike
        
        Distance = vecMarker - subEvent1(:,1); % spike.latency - 1.latency
        % -500 <= spike.latency - 1.latency <= 600 (higher value means later time point)
        Event1index = find(Distance<=600 & Distance>=-500); % If 1 is 500ms slower or 600ms faster than spike  
        
        if length(Event1index)>1 % Too many event 1s close to event spike 
            Event1indexAll(m) = -1;
        elseif length(Event1index)<1 % No event 1 close to event spike 
            Event1indexAll(m) = 0;
        else
            Event1indexAll(m) = Event1index;
        end
    end
    
    Unwanted = 1:length(indexEvent1);
    Event1indexAll(Event1indexAll == 0) = [];
    Event1indexAll(Event1indexAll == -1) = [];
    Unwanted(Event1indexAll) = [];
    index_of_unwanted_epoch{subject_EEG} = Unwanted; % Save index of unwanted epoch
    disp(append('Finished file: ', file_struct_list_set{subject_EEG}))
end
% Reject ICA
    
% file_struct_list_set = dir([html.workpath filesep '*.set']); 
% file_struct_list_set = {file_struct_list_set .name};
% file_struct_list_set = natsort(file_struct_list_set );

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
           EEG = pop_rejepoch( EEG, index_of_unwanted_epoch{subject_EEG}, 0); % Unwanted event 1
           EEG = pop_eegthresh(EEG,1,[3:32] ,-(html.threshValue),html.threshValue,-1,0,0,1);
           EEG = pop_saveset( EEG, 'filename',[file_struct_list_set{subject_EEG},'RejICA', '.set'],'filepath', html.savepath);
        else
           EEG = pop_subcomp(EEG,EEG.icaquant.identifiedcomponents,0);
           if length(EEG.chanlocs) < 35
               EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical'); % 差補之後再切epoch出現error
           end
           EEG = pop_epoch( EEG, html.eventMark, html.setEpoch, 'epochinfo', 'yes');
           EEG = pop_rejepoch( EEG, index_of_unwanted_epoch{subject_EEG}, 0); % Unwanted event 1
           EEG = pop_eegthresh(EEG,1,[3:32] ,-(html.threshValue),html.threshValue,-1,0,0,1);%3:17
           EEG = pop_saveset( EEG, 'filename',[file_struct_list_set{subject_EEG},'RejICA', '.set'],'filepath', html.savepath);
        end
end
end