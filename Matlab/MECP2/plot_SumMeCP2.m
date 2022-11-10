function plot_SumMeCP2(data, min_maxSum)
% plot_SumMeCP2(data, min_maxSum)
%   Detailed explanation goes here
%%
tif_file        = data.filename{1};
img_max         = imread([tif_file(1:end-4) '_max_ch3.tif']);
min_max         = prctile(img_max, [0.1,90], 'all');
x               = data.x{1};
y               = data.y{1};
sum_            = sum(data.rawData{1}, 2)./1000;
%% Total MECP2
f2 = figure(2);
clf
f2.Color='w';
ax1 = axes;
imshow(img_max',min_max,'Parent',ax1)
hold on;
ax2 = axes;
scatter(ax2,y, x, 30, sum_, 'fill', 'MarkerFaceAlpha',0.8);
set(gca, 'ydir', 'reverse')
c = overlayColorbar('Sum of all JF dyes (uM');
caxis(min_maxSum)
adjOverlayAxes(ax1,ax2)
f2.Position = [107        104        700        600];
text(0,90,sprintf('ANM: %s, IHC: %s', data.ANM{1}, data.IHC{1}) ,'color','y', 'fontsize',16)