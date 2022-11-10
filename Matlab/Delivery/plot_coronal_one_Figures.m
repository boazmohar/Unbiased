function plot_coronal_one_Figures(i, z, x_offset, y_offest, scalebar_um)
%% Load
cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
% list all animals
files = dir('Round*.mat');
files = {files.name}';
file = files{i};
data = load(file, 'current');
data = data.current;
%% scale bar posision
if nargin < 3
    x_offset = 500;
end
if nargin < 4
    y_offest = -1800;
end
if nargin < 5
    scalebar_um = 1000;
end
%%
f = figure(1);
f.Color='w';
f.Units='Centimeters';

f.Position=[7 7 4,4];
clf;
index = data.z == z;
scatter(data.y(index), data.x(index), 10, data.fraction_sub(index), ...
    'filled');
hold on;
plot( [x_offset, x_offset+scalebar_um],[y_offest, y_offest],'linewidth',3,'color','k')

caxis([0, 1]);
colormap(jet(256));
daspect([1,1,1])
axis off
%%
masks =length( data.CellType);
frac = nanmedian(data.fraction_sub);
se = nanstd(data.fraction_sub);
sprintf('# masks: %d, Fraction in-vivo median: %.2f +- %.2f', masks,...
    frac, se)
%%
% export_fig 'figure2A.eps' -depsc