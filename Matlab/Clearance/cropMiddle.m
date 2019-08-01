function [data_middle, median_middle, BW, pos] = cropMiddle(registered, ...
    imageSize, groupNumber, offset, BW)
if nargin < 4
    offset = 2;
end
if nargin < 5
    figure()
    h = imshow(squeeze(registered(:, :,2)), []);
    e = imellipse(gca, [100 100 100 100]);
    pause();
    %%
    pos = getPosition(e);
    x = pos(1);
    y = pos(2);
    d1 = pos(3);
    d2 = pos(4);
    BW = createMask(e,h);
else
    pos = [];
end
data_middle = zeros(imageSize(1), imageSize(2), groupNumber) ;
for i = 1:groupNumber
    data_middle(:, :, i) = squeeze(registered(:, :, i)).*BW;
end
data_middle(data_middle == 0) = nan;
median_middle = squeeze(nanmedian(nanmedian(data_middle, 1), 2));
median_middle = median_middle-median_middle(1);
median_middle = median_middle(offset:end);
close();