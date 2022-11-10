%%
clear;
close all;
clc;
%% JF585
% 
Round   = 3;
ANM     = 86;
slide   = 3;
cassette = 2;
region  = '003';
% baseDir = '/Volumes/svobodalab/users/moharb/Unbiased/';
baseDir = 'W:\moharb\Unbiased\';
red_dye = 585;
far_red = 669;
l=100;
%% JF552
Round   = 6;
ANM     = 68;
slide   = 43;
cassette = 2;
region  = '003';
% baseDir = '/Volumes/svobodalab/users/moharb/Unbiased/';
baseDir = 'W:\moharb\Unbiased\';
red_dye = 552;
far_red = 669;
l = 39; % label
%% JF541
Round   = 7;
ANM     = 36;
slide   = 5;
cassette = 1;
region  = '003';
% baseDir = '/Volumes/svobodalab/users/moharb/Unbiased/';
baseDir = 'W:\moharb\Unbiased\';
red_dye = 541;
far_red = 669;
l = 39; % label
%%
configuration = 'old';
[Calibration, Blank] = getCalibration(configuration);
%% load data
cd(baseDir)
cd(sprintf('Round%d', Round));
current_dir = pwd();
file = dir(sprintf('*ANM%d*Slide %d*cassette %d*Region %s.tiff',...
    ANM, slide, cassette,region));
file = file.name;
fprintf('Found file: %s\n', file);
%
prob_file = [file(1:end-5) '_Probabilities.h5'];
obj_file = [file(1:end-5) '_Object Predictions.tif'];
baseName = [file(1:end-5) '_'];
if ~isfile(prob_file) || ~isfile(obj_file)
    disp('Error missing files!')
end
%
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

%
cd('raw');
GFP_ds      = imread([baseName 'FITC.tiff']);
JF585_ds    = imread([baseName 'Texas.tiff']);
JF669_ds    = imread([baseName 'CY5.tiff']);
cd(current_dir);
GFP_ds      = GFP_ds(1:sz(1), 1:sz(2));
JF585_ds    = JF585_ds(1:sz(1), 1:sz(2));
JF669_ds    = JF669_ds(1:sz(1), 1:sz(2));
%% create label images, look at them and select an index
label1              = bwlabel(bw_1); % cell
label2              = bwlabel(bw_2); % saturated
label3              = bwlabel(bw_3); % small
numLabels1          = max(label1(:));
numLabels2          = max(label2(:));
numLabels3          = max(label3(:));
numLabelsAll        = numLabels1 + numLabels2 + numLabels3;
fprintf('Found %d cells, %d saturated, %d small\n', ...
    numLabels1, numLabels2, numLabels3);
%% selected index zoomin
% compute forground and background for each label

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
minX = max(x1-30, 1);
minY = max(y1-30, 1);
maxX = min(x1+30, sz(1));
maxY = min(y1+30, sz(2));
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
%
JF585_current    = mean(JF585_ds2(current2), 'all');
JF669_current    = mean(JF669_ds2(current2), 'all');
GFP_bg_current   = mean(GFP_ds2(blank), 'all');
JF585_bg_current = mean(JF585_ds2(blank), 'all');
JF669_bg_current = mean(JF669_ds2(blank), 'all');

JF585_m = (JF585_current - Blank(red_dye)) ./ ...
    Calibration(red_dye);
JF585_b = (JF585_bg_current - Blank(red_dye)) ./ ...
    Calibration(red_dye);
JF669_m = (JF669_current - Blank(far_red)) ./ ...
    Calibration(far_red);
JF669_b =(JF669_bg_current - Blank(far_red)) ./ ...
    Calibration(far_red);

JF585_s = JF585_m - JF585_b;
JF669_s = JF669_m - JF669_b;
JF585_r = JF585_s / (JF585_s + JF669_s);
JF669_r = JF669_s / (JF585_s + JF669_s);

%
um_per_px = 1/0.66;
scalebar_um = 20;
scalebar_px = scalebar_um/um_per_px;
x_offset = 4;
y_offest = 58;
sprintf('Px mask: %d, Px BG: %d, F JF669: %.1f, F JF552: %.1f, Fraction: %.2f', ...
    sum(current2, 'all'), sum(blank, 'all'), JF669_s, JF585_s, JF669_r)
%%
close all
f =figure(1);
clf
set(f, 'Units','centimeters')
set(f,'Position', [12,12, 18, 5]);
set(f,'Color','none');
clf;
subplot(1,4,1)
J = imadjust(GFP_ds2);
J2 =cat(3, J, J, J);
J2(:, :, 1) = 0;
J2(:, :, 3) = 0;
B = imoverlay2(J2, current2, 'facealpha',0.6, 'ZeroAlpha', 0, 'colormap','jet');
imshow(B);
% title('GFP mask');

hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
subplot(1,4,2)

B = imoverlay2(J2, blank, 'facealpha',0.5, 'ZeroAlpha', 0, 'colormap','jet');imshow(B, []);

hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
% title('GFP bg');
subplot(1,4,4)
J = imadjust(JF669_ds2 );
J2 =cat(3, J, J, J);
J2(:, :, 2) = 0;
J2(:, :, 3) = 0;
imshow(J2);

% title('Pulse');

hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
subplot(1,4,3)
J = imadjust(JF585_ds2);
J2 =cat(3, J, J, J);
J2(:, :, 2) = J2(:, :, 2)/255*165;
J2(:, :, 3) = 0;
imshow(J2);

% title('Chase');

hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
cd('E:\Dropbox (HHMI)\Projects\Unbised\Paper2020\Figures')
export_fig([file(1:end-5) '_v2.eps'],'-depsc')
    
%%  selected cell zoom out (manual x and y lim)
f2 =  figure(2);
set(f2, 'Units','centimeters')
set(f2,'Position', [12,12, 18, 10]);
set(f2,'Color','none')
clf
minX = max(x1-200, 1);
minY = max(y1-200, 1);
maxX = min(x1+200, sz(1));
maxY = min(y1+200, sz(2));
x_lim = [minY, maxY];
y_lim = [minX, maxX];

scalebar_um = 100;
scalebar_px = scalebar_um/um_per_px;
x_offset = 30;
y_offest = (y_lim(2) - y_lim(1)) * 0.93;


ha = tight_subplot(1, 3);
axes(ha(1))
current = GFP_ds(y_lim(1):y_lim(2), x_lim(1):x_lim(2));
lh = stretchlim(current, [0.01 0.999]);
J = imadjust(current, lh);
J2 =cat(3, J, J, J);
J2(:, :, 1) = 0;
J2(:, :, 3) = 0;
imshow(J2)
hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
start_x = x1 - y_lim(1);
start_y = y1 - x_lim(1);
arrow_x = [0.4,0.5];
arrow_y = [0.4,0.5];
% annotation('arrow', arrow_x, arrow_y, 'color','w', 'linewidth',3)
p1 = [100 100];                         % First Point
p2 = [195 195];                         % Second Point
dp = p2-p1;                         % Difference
h=quiver(p1(1),p1(2),dp(1),dp(2),0,'w','filled','linewidth',3,'MaxHeadSize',10 );
axes(ha(3))
current = JF669_ds(y_lim(1):y_lim(2), x_lim(1):x_lim(2));
lh = stretchlim(current, [0.01 0.999]);
J = imadjust(current, lh);
J2 =cat(3, J, J, J);
J2(:, :, 2) = 0;
J2(:, :, 3) = 0;
imshow(J2)
hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')

axes(ha(2))
current = JF585_ds(y_lim(1):y_lim(2), x_lim(1):x_lim(2));
lh = stretchlim(current, [0.01 0.999]);
J = imadjust(current, lh);
J2 =cat(3, J, J, J);

J2(:, :, 2) = J2(:, :, 2)/255*165;
J2(:, :, 3) = 0;
imshow(J2)
hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')

export_fig([file(1:end-5) '_zoomout_V2.eps'],'-depsc')
% export_fig 'figure1_B.eps' -depsc
