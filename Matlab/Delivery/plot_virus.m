function  plot_virus(files)
%plot_virus Summary of this function goes here
%   Detailed explanation goes here
%%
f1 = figure(12);
f1.Position = [560   430   970   480];
clf;
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if data.double
        edge = 'k';
    else
        edge = 'none';
    end
    x = nansum(data.virus_sub)./ nansum(data.Pixels_mm);
    y = nanmean(data.fraction_sub);
    fprintf('file: %s, fraction: %.2f\n' , file, nanmean(data.fraction_sub))
    scatter(x, y, 90, data.color, ...
        data.marker, 'filled', 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i, data.Round, data.ANM, ...
        data.dye_name, data.cond), 'MarkerEdgeColor', edge, 'linewidth',2)
    hold on;
    text(x,y+.03, sprintf('%d', i))
end
legend('Location','bestoutside');
xlabel('Sum virus / mm^2');
ylabel('Mean fraction in vivo');
ylim([0 1]);
saveas(f1, 'Sumvirus_vs_fraction.png')
set(gca, 'XScale', 'log')
saveas(f1, 'Sumvirus_vs_fraction_log.png')
f2 = figure(13);
f2.Position = [560 20 970 480];
clf;
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if data.double
        edge = 'k';
    else
        edge = 'none';
    end
    x = length(data.virus_sub)./ (nansum(data.Pixels_mm));
    y = nanmean(data.fraction_sub);
    scatter(x, y, 90, data.color, ...
        data.marker, 'filled', 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i,data.Round, data.ANM, ...
        data.dye_name, data.cond), 'MarkerEdgeColor', edge, 'linewidth',2)
    text(x, y+0.03, sprintf('%d', i))
    hold on;
end
legend('Location','bestoutside');
xlabel('# cells / mm^2');
ylabel('Mean fraction in vivo');
ylim([0 1]);
saveas(f2, 'Cells_vs_fraction.png')
set(gca, 'XScale', 'log')
saveas(f2, 'Cells_vs_fraction_log.png')