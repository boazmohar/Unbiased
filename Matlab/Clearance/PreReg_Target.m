function [target,normalized] = PreReg_Target(imageSize,groupNumber, ...
    mean2, target_num, hist_levels)
%[target,normalized] = PreReg_Target(imageSize,groupNumber, mean2, target_num, hist_levels)
%   Detailed explanation goes here

if nargin < 5
    hist_levels = 2048;
end
if nargin < 4
    target_num = 3;
end
normalized = zeros(imageSize(1), imageSize(2), groupNumber, 'single');
for i = 1:groupNumber
    I = mean2(:, :, i);
    I = I - min(I(:));
    I = I ./ max(I(:));
    normalized(:, :, i) = single(histeq(I,hist_levels));
end
%%
new2 = reshape(normalized, imageSize(1)* imageSize(2), groupNumber);
new2_mean = mean(new2, 2);
all_c = zeros(1, groupNumber);
for i = 1:groupNumber
    c = corrcoef(new2(:, i), new2_mean);
    all_c(i) = c(1, 2);
end
[~, C] = sort(all_c, 'descend');
target = mean(normalized(:, :, C(1:target_num)), 3); 
figure(); 
subplot(1,2,1);
plot(all_c, '*');
title('Correlation to the mean');
subplot(1,2,2);
imshow(target);
title('Target');
end

