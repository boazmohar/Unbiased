clear;
close all;
clc;
cd('E:\Dropbox (HHMI)\Projects\Unbised\Clearance');
%%
files = dir('Clearance*.mat');
mat_files = sort_nat({files.name});
files = dir('Clearance*.tif');
registered_files = sort_nat({files.name});
n_files = length(files);
%% select and load
figure(12);
clf;
i=6
%
filename = mat_files{i};
data = load(filename);
data = data.data;
n_timepoints = size(data.movie, 3);
reg = zeros(data.imagesize(1), data.imagesize(2), n_timepoints);
for k = 1:n_timepoints
    reg(:, :, k) = imread(registered_files{i}, k);
end
h = imshow(squeeze(nanmean(reg, 3)), []);
e = imellipse(gca, data.median_pos);
BW = createMask(e,h); 
[data_middle, median_middle, BW, pos] = cropMiddle(reg, ...
data.imagesize, n_timepoints, data.offset, BW);
t = sort(data.times);
if isfield(data,'median_new') && ~isempty(data.median_new)
    median_middle = data.median_new(data.offset:end);
end
%%
FOV = 3.343; %mm
px = data.imagesize(1);
mm_px= FOV/px;
scale_mm =1;
scale_px = scale_mm/mm_px;
offset_x = 10;
offset_y = 230;
%
f = figure(1)
clf
f.Units = 'Centimeters';
f.Position = [10, 10, 13, 5];
f.Color = 'w';
times = [0, data.offset, 6, 13, 18];
durations_diff = diff(t);
durations = cumsum(durations_diff) - sum(durations_diff(1:data.offset));
ha = tight_subplot(1,length(times));
for t1 = 1:length(times)
   current = times(t1);
   if current == 0
        name = 'Baseline';
   else
       name = string(   durations(current));
   end
   axes(ha(t1));
   h = imshow(reg(:,:, current+1), [200, 16000]);
   if current == 0
       hold on;
       e = imellipse(gca, data.median_pos);
%        e = drawellipse('Center', [142.0683 126.1488], 'SemiAxes',[77.6902 77.8462],...
%            'RotationAngle', 311,'AspectRatio',0.998,'InteractionsAllowed', 'none' ,...
%            'FaceAlpha',0);
       plot([offset_x, offset_x + scale_px], [offset_y, offset_y], 'color','w','linewidth',3)
   end
   title(name, 'fontsize',8)
end
export_fig([filename '_Example_Snaps.eps'])
%%
median_middle = median_middle ./ max(median_middle);
    [fit_res, gof, x, opts] = fitDouble_Figure(t(data.offset:end), ...
        median_middle, filename);
%% pixel wise
data.frames_per_timepoint
imageSize = data.imagesize;
groupNumber = n_timepoints;
registered = reg;
[data_a, data_b, data_c, data_d, data_e] = FitPixelDouble(imageSize, ...
    groupNumber, registered, x, BW, fit_res, data.offset);
%%
%% clean
clean_b = data_b;
clean_e = data_e;
switched = find(clean_b > clean_e);
temp = clean_b(switched);
clean_b(switched) = clean_e(switched);
clean_b(clean_b>20) = nan;
clean_e(switched) = temp;
f = figure(3);
clf
f.Color='w';
subplot(1,2,1)
imshow(clean_b, [0, 8])

% xlim([25 112]);
% ylim([21 107]);
colormap(gca, viridis(256))
c = colorbar;
c.Label.String = '\tau_1 (Min)';
subplot(1,2,2)
clean_e(clean_e>1000) = nan;
imshow(clean_e, [0, 300])
colormap(gca, viridis(256))
c = colorbar;
c.Label.String = '\tau_2 (Min)';
% xlim([25 112]);
% ylim([21 107]);
export_fig([filename '_Pixel.eps']);
%%
%% PCA the movie
data1 = data_middle;
data1(isnan(data1)) = 0;
data1 = reshape(data1, imageSize(1)*imageSize(1), groupNumber);
data1 = data1 - nanmean(data1, 1);
[coeff,score,latent,tsquared,explained,mu] = pca(data1);
comp = reshape(score, imageSize(1), imageSize(1), groupNumber);
%% tissue componant
for comp_id = 2:5
    data_pca = zeros(imageSize(1), imageSize(2), groupNumber) ;
    temp = comp(:, :, comp_id);
    temp = temp(:);
    Mask = comp(:, :, comp_id) > nanmedian(temp)*2;
    figure()
    imshow(Mask,[])
    imwrite(Mask, [filename 'Mask_' num2str(comp_id) '.jpg']);
    for i = 1:groupNumber
        data_pca(:, :, i) = squeeze(data_middle(:, :, i)).*Mask;
    end
    data_pca(data_pca==0) = nan;
    median_pca = squeeze(nanmedian(nanmedian(data_pca, 1), 2));
    median_pca = median_pca(2:end)-median_pca(1);
    median_pca =median_pca ./nanmax(median_pca);
    [fit_res2, gof2, x2]= fitDouble_Figure(t(data.offset+1:end), ...
         median_pca(data.offset:end), [filename '_PCAMedian_' num2str(comp_id)]);
end