function [OUTput] = freqAnalysis_output_FieldTrip(html, procEEG)
% Extract data of interest
for band = 1:length(html.Freq)
    html.Freq{band} = (html.Freq{band} - html.band(1))*html.epolength+1;
    html.Freq{band} = html.Freq{band}(1):html.Freq{band}(2);
end

part = length(procEEG);
outchan = length(html.Freq);
outfreq = length(html.Chan);
outcolumn = outchan * outfreq;

meanPower = zeros(part, 32, outfreq);
meanPowerChannel = zeros(part, outchan, outfreq);
OUTput = zeros(part, outcolumn);

%Frequency
for n=1:part
    for c=1:32
        for f = 1:length(html.Freq)
            meanPower(n, c, f) = mean(log(procEEG{n}.powspctrm(c, html.Freq{f}))); % Log transform
        end
    end
end

%Channel
for n = 1:part
    for c = 1:length(html.Chan)
        meanPowerChannel(n, c, :) = meanPower(n, html.Chan(c), :);
    end
end

for n=1:part
    OUTput(n,:) = reshape(meanPowerChannel(n,:,:),1,[]);
end

%Excel output
xlswrite(append(html.outputPath,'/',html.outputName,'.xls'), OUTput);
end