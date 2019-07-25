%% clear
clear;
clc
close all
%%
session = 4;
switch session
    case 1
        path = "V:\users\moharb\DyeClerance\434848\Dye_Clereance_20190328";
        pre = 'Pre_';
    case 2
        path = "V:\users\moharb\DyeClerance\Dye_Clerance_439476_20190326";
        pre = 'Before_3Amp';
    case 3
        path = "V:\users\moharb\DyeClerance\Dye_Clerance_439476_3.25";
        pre = 'Pre';
    case 4
        path = 'V:\users\moharb\DyeClerance\434848\Dye_clearance_552_20190514\565';
        pre = 'Pre_';
end
cd(path)
%% load data and pre image
[imageSize, sortedMean, sortedTimes, groupNumber] = LoadImages(path);
preImage = getPreImage(path, imageSize, pre);
mean2 = cat(3, preImage, sortedMean);
groupNumber = groupNumber+1;
%% normzlize
[target,normalized] = PreReg_Target(imageSize,groupNumber, mean2);
%%
target = normalized(:, :, 1);
figure()
imshow(target)
%% Align
opts = Reg_args('Confidence', 99, 'ScaleFactor', 1.0900, 'MaxRatio',0.9,...
    'NumLevels', 25, 'transform', 'similarity', 'MaxDistance', 4)
%%
[target,registered] = Register_ORB(imageSize,groupNumber, mean2, ...
    target, normalized, opts);
%% crop to middle
[data_middle, median_middle, BW] = cropMiddle(registered, imageSize, groupNumber);
%% fit all window pixels median
median_middle = median_middle - min(median_middle);
[fit_res, gof, x] = fitDouble(sortedTimes, median_middle, 'MiddleMedian');

%% PCA the movie
data1 = data_middle;
data1(isnan(data1)) = 0;
data1 = reshape(data1, imageSize(1)*imageSize(1), groupNumber);
data1 = data1 - nanmean(data1, 1);
[coeff,score,latent,tsquared,explained,mu] = pca(data1);
comp = reshape(score, imageSize(1), imageSize(1), groupNumber);
%% tissue componant
comp_id = 5;
data_pca = zeros(imageSize(1), imageSize(2), groupNumber) ;
temp = comp(:, :, comp_id);
temp = temp(:);
Mask = comp(:, :, comp_id) > nanmedian(temp)*2;
figure()
imshow(Mask)
imwrite(Mask, ['Mask_' num2str(comp_id) '.jpg']);
for i = 1:groupNumber
    data_pca(:, :, i) = squeeze(data_middle(:, :, i)).*Mask;
end
data_pca(data_pca==0) = nan;
median_pca = squeeze(nanmedian(nanmedian(data_pca, 1), 2));
median_pca = median_pca(2:end)-median_pca(1);
median_pca =median_pca - nanmin(median_pca);
[fit_res2, gof2, x2]= fitDouble(sortedTimes, median_pca,...
    ['PCAMedian_' num2str(comp_id)]);
%% fit per pixel
%% downsample 2x
[data_a, data_b,  data_c,data_d, data_e] = FitPixelDouble(imageSize, ...
    groupNumber, registered, x, BW, fit_res);
%% clean
clean_b = data_b;
clean_e = data_e;
switched = find(clean_b > clean_e);
temp = clean_b(switched);
clean_b(switched) = clean_e(switched);
clean_e(switched) = temp;
f = figure(1);
clf
subplot(1,2,1)
imshow(clean_b, [0, 50])
colormap(gca, viridis(256))
c = colorbar;
c.Label.String = '\tau_1 (Min)';
subplot(1,2,2)
imshow(clean_e, [0, 500])
colormap(gca, viridis(256))
c = colorbar;
c.Label.String = '\tau_2 (Min)';
print('PixleMapTau2','-r300','-dpng')
%%
save

%%
data_seg = squeeze(data_middle(:,:,3));
data_seg = data_seg - min(data_seg(:));
data_seg = data_seg ./max(data_seg(:));
data_seg(isnan(data_seg)) = 0;
[BW,maskedImage, L] = segmentImage(data_seg,5);
%%
preImage2 = preImage - min(preImage(:));
preImage2 = preImage2 ./max(preImage2(:));
%%
figure()
B = labeloverlay(preImage2,L);
imshow(B)
colorbar()

% % write images to tiff stack
% imwrite(uint16(preImage),'meanImage.tif')
% for i= 1:groupNumber
%     imwrite(uint16(sortedMean(:, :, i)),'meanImage.tif','WriteMode','append')
% end
% %
% for i= 1:groupNumber
%     if i == 1
%         imwrite(uint16(sortedMean(:, :, i)),'meanImage.tif')
%     else
%         imwrite(uint16(sortedMean(:, :, i)),'meanImage.tif','WriteMode','append')
%     end
% end