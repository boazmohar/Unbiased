function [preImage, preTime] = getPreImage(path, imageSize, preName)
if nargin < 3
    preName = 'Pre_';
end
preString = ['*' preName '*.tif'];
cd(path);
pre = dir(preString);
preTime = datetime(pre(1).date);
pre = {pre.name};
numberPre = length(pre);
preImages = zeros(numberPre, imageSize(1), imageSize(2));
for index = 1:numberPre
    filename = pre{index};
    preImages(index, :, :) = imread(filename);
end
preImage = squeeze(mean(preImages, 1));
figure()
imshow(preImage, prctile(preImage(:), [5 95]));
c = colorbar();
c.Label.String = 'F (AU)';
print('PreImage','-r300','-dpng')
