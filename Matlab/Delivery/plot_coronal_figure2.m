%%
clear;
close all;
clc;
%% pick a session
cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
close all; clear;
% list all animals
files = dir('Round*.mat');
files = {files.name}';
i = 26; % 2a = 18, 2b = 26
file = files{i};
data = load(file, 'current');
data = data.current;
%%
um_per_px = 1/0.66;
scalebar_um = 1000;
scalebar_px = scalebar_um/um_per_px;
x_offset = 500;
y_offest = -1800;
%%
zs = unique(data.z);
f = figure(1);
clf;
set(f, 'color', 'white')
set(f, 'units','normalized')
set(f, 'position', [0.2, 0.2, .7, .7]);
f.PaperPositionMode = 'auto';
s = ceil(sqrt(length(zs)));

axs = matlab.graphics.axis.Axes.empty();
for i = 1:length(zs)
    z = zs(i);
    index = data.z == z;
    axs(i) = subaxis(s,s,i, 'Spacing', 0.02, 'Padding', 0.001, 'Margin', 0.07,...
        'SpacingVert', 0.02);
    scatter(data.y(index), data.x(index), 10, data.fraction_sub(index), ...
        'filled');
     if i == 1
         hold on;
        plot( [x_offset, x_offset+scalebar_um],[y_offest, y_offest],'linewidth',3,'color','k')
    end
    caxis([0, 1]);
    colormap(jet(256));
    axis off
    str = data.filenames{i}(6:end-1);
    str = strrep(str, 'Round', 'R');
    str = strrep(str, 'Slide ', 'S');
    str = strrep(str, 'from cassette ', 'C');
    str = strrep(str, '_Region 00', ' Re');
%     title(sprintf('%s', str), 'Interpreter', 'none', 'color','white')
end
subplot(s, s, i+1);
scatter(1, 1, 1, 1, '.');
caxis([0, 1]);
colormap(jet(128));
axis off;
cbar = colorbar('color','k', 'location', 'south');
cbar.Label.String = 'Fraction in-vivo';
cbar.Label.Color = 'k';
linkaxes(axs, 'xy');
%%
masks =length( data.CellType);
frac = nanmedian(data.fraction_sub);
se = nanstd(data.fraction_sub);
sprintf('# masks: %d, Fraction in-vivo median: %.2f +- %.2f', masks,...
    frac, se)
%%
% export_fig 'figure2A.eps' -depsc