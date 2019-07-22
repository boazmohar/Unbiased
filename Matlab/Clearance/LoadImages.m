function [imageSize, sortedMean, sortedTimes, groupNumber] = LoadImages(path)
cd(path);
files = dir('*min_*.tif');
names = {files.name};
dates = datetime({files.date});
names2 = cellfun(@(x){x(1:end-10)}, names);
[uniqueNames, ~ ,uniqueIndexs] = unique(names2);
first = imread(names{1});
imageSize = size(first);
groupNumber = length(uniqueNames);
meanImages = zeros(imageSize(1), imageSize(2), groupNumber);
times = NaT(1, groupNumber);
fprintf('Found %d groups\n', groupNumber);
fprintf('Found %d files\n', length(names));
fprintf('Image size:  %dx%d px\n', imageSize(1), imageSize(2));
for i= 1:groupNumber
    indexs = find(uniqueIndexs==i);
    numberFiles = length(indexs);
    current = zeros(numberFiles, imageSize(1), imageSize(2));
    for index = 1:numberFiles
        filename = names{indexs(index)};
        current(index, :, :) = imread(filename);
    end
    times(i) = dates(indexs(index));
    meanImage = squeeze(mean(current, 1));
    meanImages(:, :, i) = meanImage;
end
[sortedTimes, sortIndex] = sort(times);
sortedMean = meanImages(:, :, sortIndex);
end