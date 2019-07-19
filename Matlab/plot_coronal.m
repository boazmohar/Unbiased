%% plot coronal
function f = plot_coronal(data)
zs = unique(data.z);
f = figure('color', 'black', 'units','normalized','position',[0, 0, 1, 1]);
f.PaperPositionMode = 'auto';
s = ceil(sqrt(length(zs)));
axs = matlab.graphics.axis.Axes.empty();
for i = 1:length(zs)
    z = zs(i);
    index = data.z == z;
    
    axs(i) = subaxis(s,s,i, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0.1,...
        'SpacingVert', 0.03);
    scatter(data.y(index), data.x(index), 10, data.fraction_sub(index), ...
        'filled')
    caxis([0, 1]);
    colormap(jet(128));
    axis off
    str = data.filenames{i}(6:end-1);
    str = strrep(str, 'Round', 'R');
    str = strrep(str, 'Slide ', 'S');
    str = strrep(str, 'from cassette ', 'C');
    str = strrep(str, '_Region 00', ' Re');
    title(sprintf('%s', str), 'Interpreter', 'none', 'color','white')
end
subplot(s, s, i+1);
scatter(1, 1, 1, 1, '.');
caxis([0, 1]);
colormap(jet(128));
axis off;
cbar = colorbar('color','white');
cbar.Label.String = 'Fraction';
cbar.Label.Color = 'white';
linkaxes(axs, 'xy');
title('R=Round,S=Slide,C=cassette,Re=Region')