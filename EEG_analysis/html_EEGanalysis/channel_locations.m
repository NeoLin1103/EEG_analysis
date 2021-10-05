function [channelLocs] = channel_locations(html)

file_struct_list_set = dir([html.workpath filesep '*.set']); 
file_struct_list_set = {file_struct_list_set .name};
file_struct_list_set = natsort(file_struct_list_set);

EEG = pop_loadset('filename', file_struct_list_set{1}, 'filepath', html.workpath);
channelLocs = EEG.chanlocs;
end