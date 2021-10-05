function [] = pre_rejectICA_autoEventSelect_conditionSplit_Curry(html)

file_struct_list_set = dir([html.workpath filesep '*.set']); 
file_struct_list_set = {file_struct_list_set .name};
file_struct_list_set = natsort(file_struct_list_set);

putt = readmatrix(html.behavioral_data_path); % Read beahavioral data
numsize = size(putt);

% Extract index of different condition
reject_trials = cell(numsize(2),1);
for subject_EEG = 1:numsize(2)
    reject_trials{subject_EEG} = cell(2,1); % 1 for Good, 2 for Bad
    % Find the index of nonzero element
    reject_trials{subject_EEG}{1} = find(putt(:,subject_EEG) == 0); % Find all the Good trials
    % Find the index of zero element
    reject_trials{subject_EEG}{2} = find(putt(:,subject_EEG) > 0); % Find all the Bad trials
end

index_of_unwanted_epoch = cell(length(file_struct_list_set), 1);

for subject_EEG = 1:length(file_struct_list_set)
    index_of_unwanted_epoch{subject_EEG} = cell(2,1);
    EEG = pop_loadset('filename', file_struct_list_set{subject_EEG}, 'filepath', html.workpath);    
    eegEvent = struct2table(EEG.event);
    
    for condition = 1:2
    indexEventSpike = find(eegEvent.type == 201); % Index of event spike
    indexEventSpike = indexEventSpike(reject_trials{subject_EEG}{condition}); % Remove unwanted event spike
    indexEvent1 = find(eegEvent.type == 1); % Index of event 1
    
    subEvent1 = table2array(eegEvent(indexEvent1, [2,3])); % Extract array of event 1 (back swing)

    % Find event 1 which are close to event spike
    Event1indexAll = 1:length(indexEventSpike);
    for m = 1:length(indexEventSpike)
        
        Marker = eegEvent.latency(indexEventSpike(m));
        vecMarker = ones(length(subEvent1),1,'double'); 
        vecMarker = vecMarker.*Marker; % latency vector of event spike
        
        Distance = vecMarker - subEvent1(:,1); % spike.latency - 1.latency
        % -500 <= spike.latency - 1.latency <= 600 (higher value means later time point)
        Event1index = find(Distance<=600 & Distance>=-500); % If 1 is 500ms slower or 600ms faster than spike  
        
        % Save index
        if length(Event1index)>1 % Too many event 1s close to event spike 
            Event1indexAll(m) = -1;
        elseif length(Event1index)<1 % No event 1 close to event spike 
            Event1indexAll(m) = 0;
        else
            Event1indexAll(m) = Event1index;
        end
    end
    
    Unwanted = 1:length(indexEvent1); % 因為後續要把不要的epoch刪掉，所以要存成不要的epoch形式
    Event1indexAll(Event1indexAll == 0) = [];
    Event1indexAll(Event1indexAll == -1) = [];
    Unwanted(Event1indexAll) = [];
    index_of_unwanted_epoch{subject_EEG}{condition} = Unwanted; % Save index of unwanted epoch
    disp(append('Finished file: ', file_struct_list_set{subject_EEG}))
    end
end

% Reject ICA
Ofile_struct_list_set = dir([html.originpath filesep '*.cnt']); 
Ofile_struct_list_set = {Ofile_struct_list_set .name};
Ofile_struct_list_set = natsort(Ofile_struct_list_set );

EEG = pop_loadcnt([html.originpath filesep Ofile_struct_list_set{1}], 'dataformat', 'auto', 'keystroke', 'on', 'memmapfile', '');
EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
originalEEG = EEG;

for subject_EEG = 1:length(file_struct_list_set)    
        for condition = 1:2
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
           EEG = pop_rejepoch( EEG, index_of_unwanted_epoch{subject_EEG}{condition}, 0); % Unwanted event 1
           EEG = pop_eegthresh(EEG,1,[3:32] ,-(html.threshValue),html.threshValue,-1,0,0,1);
           if condition == 1
             EEG = pop_saveset( EEG, 'filename',[file_struct_list_set{subject_EEG},'Good', '.set'],'filepath', html.Good_savepath);
           else
             EEG = pop_saveset( EEG, 'filename',[file_struct_list_set{subject_EEG},'Bad', '.set'],'filepath', html.Bad_savepath);
           end
        else
           EEG = pop_subcomp(EEG,EEG.icaquant.identifiedcomponents,0);
           if length(EEG.chanlocs) < 35
               EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical'); % 差補之後再切epoch出現error
           end
           EEG = pop_epoch( EEG, html.eventMark, html.setEpoch, 'epochinfo', 'yes');
           EEG = pop_rejepoch( EEG, index_of_unwanted_epoch{subject_EEG}{condition}, 0); % Unwanted event 1
           EEG = pop_eegthresh(EEG,1,[3:32] ,-(html.threshValue),html.threshValue,-1,0,0,1);%3:17
           if condition == 1
             EEG = pop_saveset( EEG, 'filename',[file_struct_list_set{subject_EEG},'Good', '.set'],'filepath', html.Good_savepath);
           else
             EEG = pop_saveset( EEG, 'filename',[file_struct_list_set{subject_EEG},'Bad', '.set'],'filepath', html.Bad_savepath);
           end
        end
        end
end
end