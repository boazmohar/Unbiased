%% clear
clear all;
clc
close all
%%
session = 1;
switch session
    case 1
        path = "V:\users\moharb\DyeClerance\434848\Dye_Clereance_20190328";
        pre = 'Pre';
    case 2
        path = "V:\users\moharb\DyeClerance\Dye_Clerance_439476_20190326";
        pre = 'Before_3Amp';
    case 3
        path = "V:\users\moharb\DyeClerance\Dye_Clerance_439476_3.25";
        pre = 'Pre';
    case 4
        path = 'V:\users\moharb\DyeClerance\434848\Dye_Clereance_20190328\20x';
        
end
cd(path)
%% load data and pre image

[imageSize, sortedMean, sortedTimes, groupNumber] = LoadImages(path);
preImage = getPreImage(path, imageSize, pre);
%% write images to tiff stack
imwrite(uint16(preImage),'meanImage.tif')
for i= 1:groupNumber
    imwrite(uint16(sortedMean(:, :, i)),'meanImage.tif','WriteMode','append')
end
%%
for i= 1:groupNumber
    if i == 1
        imwrite(uint16(sortedMean(:, :, i)),'meanImage.tif')
    else
        imwrite(uint16(sortedMean(:, :, i)),'meanImage.tif','WriteMode','append')
    end
end
%% align in image J with SIFT and reload
aligned = zeros(imageSize(1), imageSize(2), groupNumber+1);
for i = 1:groupNumber+1
    aligned(:, :, i) = imread('Aligned.tif', i);
end
%% crop to middle
[data_middle, median_middle, BW] = cropMiddle(aligned, imageSize, groupNumber);
%% fit all window pixels median
median_middle = median_middle - min(median_middle);
[fit_res, gof, x] = fitDouble(sortedTimes, median_middle, 'MiddleMedian');

%% PCA the movie
data1 = data_middle;
data1(isnan(data1)) = 0;
data1 = reshape(data1, imageSize(1)*imageSize(1), groupNumber+1);
data1 = data1 - nanmean(data1, 1);
[coeff,score,latent,tsquared,explained,mu] = pca(data1);
comp = reshape(score, imageSize(1), imageSize(1), groupNumber+1);
%% tissue componant
comp_id = 4;
data_pca = zeros(imageSize(1), imageSize(2), groupNumber+1) ;
temp = comp(:, :, comp_id);
temp = temp(:);
Mask = comp(:, :, comp_id) > nanmedian(temp)*2;
imwrite(Mask, ['Mask_' num2str(comp_id) '.jpg']);
for i = 1:groupNumber+1
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
    groupNumber, aligned, x, BW, fit_res);
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
print('PixleMapTau','-r300','-dpng')
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