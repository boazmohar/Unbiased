%% select slide to look at
Round   = 8;
ANM     = 31;
slide   = 3;
region  = '006';
% baseDir = '/Volumes/svobodalab/users/moharb/Unbiased/';
baseDir = 'V:\users\moharb\Unbiased\';
red_dye = 585;
far_red = 669;
numLabelsToSave = 40;
configuration = 'old';
[Calibration, Blank] = getCalibration(configuration);
%%
cd(baseDir)
cd(sprintf('Round%d', Round));
current_dir = pwd();
file = dir(sprintf('*ANM%d*Slide %d*Region %s.tiff', ANM, slide, region));
file = file.name;
fprintf('Found file: %s\n', file);
%%
prob_file = [file(1:end-5) '_Probabilities.h5'];
obj_file = [file(1:end-5) '_Object Predictions.tif'];
baseName = [file(1:end-5) '_'];
if ~isfile(prob_file) || ~isfile(obj_file)
    disp('Error missing files!')
end
%%
SE          = strel('square',25);
SE2          = strel('square',3);
prob        = imread(obj_file);
sz          = size(prob);
bw_1        = prob == 1; % cell
bw_2        = prob == 3; % saturated cell
bw_3        = prob == 4; % small cell
px          = h5read(prob_file, '/exported_data');
bw_not      = px(1, :, :) > 0.2 | px(2, :, :) > 0.2 | px(7, :, :) > 0.4 |...
    px(8, :, :) > 0.2 | px(9, :, :) > 0.2;
bw_not      = squeeze(bw_not)'; % exclude from neuropil
bw_not_d    = ~imdilate(bw_not, SE2);

%%
cd('raw');
GFP_ds      = imread([baseName 'FITC.tiff']);
JF585_ds    = imread([baseName 'Texas.tiff']);
JF669_ds    = imread([baseName 'Cy5.tiff']);
cd(current_dir);
GFP_ds      = GFP_ds(1:sz(1), 1:sz(2));
JF585_ds    = JF585_ds(1:sz(1), 1:sz(2));
JF669_ds    = JF669_ds(1:sz(1), 1:sz(2));
%%
label1              = bwlabel(bw_1); % cell
label2              = bwlabel(bw_2); % saturated
label3              = bwlabel(bw_3); % small
numLabels1          = max(label1(:));
numLabels2          = max(label2(:));
numLabels3          = max(label3(:));
numLabelsAll        = numLabels1 + numLabels2 + numLabels3;
numLabelsShow       = round(numLabelsAll/numLabelsToSave)-1;
fprintf('Found %d cells, %d saturated, %d small\n', ...
    numLabels1, numLabels2, numLabels3);
GFP_current         = zeros(numLabelsAll, 1);
JF585_current       = zeros(numLabelsAll, 1);
JF669_current       = zeros(numLabelsAll, 1);
GFP_bg_current      = zeros(numLabelsAll, 1);
JF585_bg_current    = zeros(numLabelsAll, 1);
JF669_bg_current    = zeros(numLabelsAll, 1);
%%
% compute forground and background for each label
for l = 1:numLabelsAll
    if mod(l, numLabelsShow) ~= 0
        continue
    end
    disp(l);
    if l <= numLabels1                  % cell
        current         = label1==l;
    elseif l <= numLabels1 + numLabels2 && numLabels2 > 0 % saturated
        current         = label2==(l-numLabels1);
    else                                % small
        current         = label3==(l-(numLabels1 + numLabels2));
    end
    stats_temp = regionprops(current,GFP_ds,'Centroid');
    x1 = round(stats_temp.Centroid(2));
    y1 = round(stats_temp.Centroid(1));
    minX = max(x1-50, 1);
    minY = max(y1-50, 1);
    maxX = min(x1+50, sz(1));
    maxY = min(y1+50, sz(2));
    GFP_ds2 = GFP_ds(minX:maxX, minY:maxY);
    JF585_ds2 = JF585_ds(minX:maxX, minY:maxY);
    JF669_ds2 = JF669_ds(minX:maxX, minY:maxY);
    current2 = current(minX:maxX, minY:maxY);
    bw_not_d2 = bw_not_d(minX:maxX, minY:maxY);
    sz2 = size(current2);
    blank               = zeros(sz2(1), sz2(2), 'logical');
    blank(current2)      = true;
    blank               = logical(imdilate(blank, SE) - current2);
    blank               = blank & bw_not_d2;
%     GFP_current      = mean(GFP_ds2(current2), 'all');
    JF585_current    = mean(JF585_ds2(current2), 'all');
    JF669_current    = mean(JF669_ds2(current2), 'all');
    GFP_bg_current   = mean(GFP_ds2(blank), 'all');
    JF585_bg_current = mean(JF585_ds2(blank), 'all');
    JF669_bg_current = mean(JF669_ds2(blank), 'all');
    
    JF585_m = round((JF585_current - Blank(red_dye)) ./ ...
        Calibration(red_dye));
    JF585_b = round((JF585_bg_current - Blank(red_dye)) ./ ...
        Calibration(red_dye));
    JF669_m = round((JF669_current - Blank(far_red)) ./ ...
        Calibration(far_red));
    JF669_b = round((JF669_bg_current - Blank(far_red)) ./ ...
        Calibration(far_red));
    
    JF585_s = JF585_m - JF585_b;
    JF669_s = JF669_m - JF669_b;
    JF585_r = JF585_s / (JF585_s + JF669_s);
    JF669_r = JF669_s / (JF585_s + JF669_s);
    f=figure('visible','off');
    clf;
    subplot(2,2,1)
    J = imadjust(GFP_ds2);
    B = imoverlay(J, current2, 'red');
    imshow(B);
    title(sprintf('%dpx mask', sum(current2, 'all')));
    subplot(2,2,2)
    B = imoverlay(J, blank, 'red');
    imshow(B, []);
    title(sprintf('%dpx bg', sum(blank, 'all')));
    subplot(2,2,3)
    imshow(JF585_ds2, [150, 600]);
    colormap(parula)
    colorbar();
    title(sprintf('%d-%d=%d,%.2f', JF585_m, JF585_b, JF585_s, JF585_r))
    
    subplot(2,2,4)
    imshow(JF669_ds2, [150, 600]);
    title(sprintf('%d-%d=%d,%.2f', JF669_m, JF669_b,  JF669_s,JF669_r))
    colormap(parula)
    colorbar();
    
    cd('png');
    %             export_fig(sprintf('%s_%d1.jpg', filename, l), f)
    saveas(f, sprintf('%s_%d2.jpg', file, l))
    cd(current_dir);
end
% store values