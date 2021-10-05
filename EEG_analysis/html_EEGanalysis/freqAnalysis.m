function [alldata2, OUTput] = freqAnalysis(html)

file_struct_list_set = dir([html.workpath filesep '*.set']);
file_struct_list_set = {file_struct_list_set .name};
file_struct_list_set = natsort(file_struct_list_set );

window = html.samrate*html.epolength;
manychan = zeros(32, floor(window/2+1));
alldata2 = zeros(length(file_struct_list_set), 32, floor(window/2+1));
DataTrials = zeros(length(file_struct_list_set),1);

for subject_EEG = 1:length(file_struct_list_set)   
    EEG = pop_loadset('filename', file_struct_list_set{subject_EEG}, 'filepath', html.workpath);  %% perform your processing
    DataTrials(subject_EEG) = length(EEG.epoch);
    for channel=1:32
        sig = reshape( EEG.data(channel,:,:) ,1,[]);
        [sig_w, f] = pwelch ( sig, hamming(window), [], window, EEG.srate,'power');%hamming or hanning/ overlap 50%
        sig_w = sig_w';
        manychan(channel,:) = sig_w;
    end
alldata2 (subject_EEG, :, :) = manychan ;
end
xlswrite(append(html.trialsPath,'/',html.trialsName,'.xls'), DataTrials);

% Extract data of interest
for band = 1:length(html.Freq)
    html.Freq{band} = html.Freq{band}*html.epolength+1;
    html.Freq{band} = html.Freq{band}(1):html.Freq{band}(2);
end

part = length(file_struct_list_set);
outchan = length(html.Freq);
outfreq = length(html.Chan);
outcolumn = outchan * outfreq;

meanPower = zeros(part, 32, outfreq);
meanPowerChannel = zeros(part, outchan, outfreq);
LNmeanPowerChannel = zeros(part, outchan, outfreq);
OUTput = zeros(part, outcolumn);

%Frequency
for n=1:part
    for c=1:32
        for f = 1:length(html.Freq)
            meanPower(n, c, f) = mean(alldata2(n, c, html.Freq{f}));
        end
    end
end

%Channel
for n = 1:part
    for c = 1:length(html.Chan)
        meanPowerChannel(n, c, :) = meanPower(n, html.Chan(c), :);
    end
end

%Natural log trans
LNmeanPowerChannel = log(meanPowerChannel);

for n=1:part
    OUTput(n,:) = reshape(LNmeanPowerChannel(n,:,:),1,[]);
end

%Excel output
xlswrite(append(html.outputPath,'/',html.outputName,'.xls'), OUTput);

end