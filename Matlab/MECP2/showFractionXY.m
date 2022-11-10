function f1 = showFractionXY(data, img_max, cLims, cmap, tau_flag)
fraction        = data.fraction{1};
x               = data.x{1};
y               = data.y{1};
%% overlay with tif file
if nargin < 2 || isempty(img_max)
    tif_file        = data.filename{1};
    img_max         = imread([tif_file(1:end-4) '_max_ch3.tif']);
end
if nargin < 3 || isempty(cLims)
    cLims = [0 0];
end
if nargin < 4 || isempty(cmap)
    cmap = 'viridis';
end
if nargin < 5 || isempty(tau_flag)
    tau_flag = true;
end
if tau_flag
    fraction = data.interval ./ log(1./fraction) ./ 24;
end
%%
f1 = figure();
clf
f1.Color='w';
ax1 = axes;
min_max = prctile(img_max, [0.1,99], 'all');
imshow(img_max',min_max,'Parent',ax1)
hold on;
ax2 = axes;
scatter(ax2,y,x, 15, fraction, 'fill', 'MarkerFaceAlpha',1);
set(gca, 'ydir', 'reverse')
c = overlayColorbar('Fraction pulse', 'eastoutside');
if sum(cLims) == 0
    min_max = prctile(fraction, [1, 99]);
    caxis(min_max)
else
    caxis(cLims);
end
colormap(ax2, cmap)
% text(0,100,sprintf('Fraction pulse %dh', data.interval), 'fontsize', 16, 'color','w')
adjOverlayAxes(ax1,ax2)
f1.Position = [107        104        700        600];

