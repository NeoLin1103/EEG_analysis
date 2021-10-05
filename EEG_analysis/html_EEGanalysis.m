% Ū���ɮרöi��e�b�q�T���e�B�z
html = [];
html.workpath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331/';
html.savepath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331/ICA';
html.highPass = 1; % High pass frequency of filter
html.lowPass = 30; % Low pass frequency of filter

pre_ICA_Curry(html);
clear all; clc;

% �ܰT���e�B�z����
html = [];
html.workpath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331/ICA';
html.savepath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331/ICA/rejectICA';
html.originpath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331/'; % File path of raw data
html.eventMark = {'1'}; % Event marker label
html.setEpoch = [-2,0]; % Epoch range relative to the event marker (in second)
html.threshValue = 150; % Threshold value for epochs rejection

pre_rejectICA_Curry(html);
clear all; clc;

% �۰ʱư���������event marker
html = [];
html.workpath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/Append/test';
html.savepath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/Append/test/rejectICA';
html.behavioral_data_path = "C:/Users/HTML/Desktop/Neo_test_210309/RSP_putting_.performance.xlsx";
html.originpath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/Append'; % File path of raw data
html.eventMark = {'1'}; % Event marker label
html.setEpoch = [-2,0]; % Epoch range relative to the event marker (in second)
html.threshValue = 150; % Threshold value for epochs rejection

pre_rejectICA_autoEventSelect_Curry(html);
clear all; clc;

% �۰ʰϤ����籡��
html = [];
html.workpath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/Append/test';
html.Good_savepath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/Append/test/rejectICA/Good';
html.Bad_savepath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/Append/test/rejectICA/Bad';
html.behavioral_data_path = "C:/Users/HTML/Desktop/Neo_test_210309/RSP_putting_.performance.xlsx";
html.originpath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/Append'; % File path of raw data
html.eventMark = {'1'}; % Event marker label
html.setEpoch = [-2,0]; % Epoch range relative to the event marker (in second)
html.threshValue = 150; % Threshold value for epochs rejection

pre_rejectICA_autoEventSelect_conditionSplit_Curry(html);
clear all; clc;

% Ū���q���I�s������m
html = [];
html.workpath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331/ICA/rejectICA';

ChannelLocations = channel_locations(html);

% �W�v�����R
html = [];
html.workpath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331/ICA/rejectICA';
html.trialsPath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331'; % File path for number of trials record
html.trialsName = 'numberOfTrials'; % File name for number of trials record
html.samrate = 1000; % Sampling rate
html.epolength = 2; % Epoch length in second
% html.Freq = {[4,7.5],[8,12.5],[13,20.5],[21,30]}; % Frequency bands to extract
html.Freq = {[12,15]};
% html.Chan = [5,15,17,31]; % Channels to extract
html.Chan = [15];
html.outputPath = 'E:/��Ƴƥ�-�i�椤Raw Data/20.NSC107GOLF (2018)/�ĤG��/Peter0331'; % File path for output
html.outputName = 'Result_peter_SMR'; % File name for output

[All, ROI] = freqAnalysis(html);

% Compare the result with original script (checked)
% �����W�v�q�M�q���I������

% �ϥ�FieldTrip�M��i���W�v�����R�A�i�H�t�X�ϥ�topographyø�sfunction
html = [];
html.workpath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/Append/ICA/rejectICA';
html.band = [1,30]; % Frequency band to analysis
html.epolength = 2; % Epoch length in second

procEEG = freqAnalysis_FieldTrip(html);

html = [];
html.band = [1,30];
html.epolength = 2;
html.Freq = {[4,7.5],[8,12.5],[13,20.5],[21,30]};
html.Chan = [5,15,17,31];
html.outputPath = 'E:/��Ƴƥ�-�i�椤Raw Data/23. Neo�ӽ�/'; % File path for output
html.outputName = 'Result_thesis'; % File name for output

Results = freqAnalysis_output_FieldTrip(html, procEEG);

% ø�s���a�ι�
html = [];
html.ID = 34;
html.band = [4,8];

Topography_individual(html, procEEG);

html = [];
html.band = [4,8];

Topography_group(html, procEEG);