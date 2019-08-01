function  plot_wavelength(files)
%plot_virus Summary of this function goes here
%   Detailed explanation goes here
%%
f1 = figure(22);
f1.Position = [560   430   970   480];
clf;
for i = 1:length(files)
    
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    x = data.invivo_dye;
    if x == 0
        continue
    end
    y = nanmean(data.fraction_sub);
    err = nanstd(data.fraction_sub) ./ sqrt(length(data.fraction_sub));
    scatter(x, y, 90, data.color, ...
        'o', 'filled', 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i, data.Round, data.ANM, ...
        data.dye_name, data.cond))
    hold on;
    text(x,y+.03, sprintf('%d', i))
    errorbar(x, y, err, '.k','HandleVisibility','off')
    fprintf('file: %s, fraction: %.2f+-%.3f, n=%d\n' , ...
        file, y, err, length(data.fraction_sub))
end
legend('Location','bestoutside');
xlabel('Wavelength (nm)');
ylabel('Mean fraction in vivo');
ylim([0 1]);
saveas(f1, 'Wavelength_vs_fraction.png')
%%
n = length(files)-1;
y = cell(1, n);
colors = cell(1, n);
names = cell(1, n);
k=1;
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if data.invivo_dye == 0
        continue
    end
    y(k) = {data.fraction_sub};
    colors(k) = {data.color};
    names(k) = {sprintf('%s: Round %d, ANM %d', data.dye_name, ...
        data.Round, data.ANM)};
    k = k +1;
end
% col=@(x)reshape(x,numel(x),1);
% boxplot2=@(C,varargin)boxplot(cell2mat(cellfun(col,col(C),'uni',0)),cell2mat(arrayfun(@(I)I*ones(numel(C{I}),1),col(1:numel(C)),'uni',0)),varargin{:});

f1 = figure(23);
f1.Position = [560   30   970   480];
clf;
% boxplot2(y, 'DataLim', [-0.5, 1.5]);
distributionPlot(y, 'color',colors, 'histOpt', 1.1, 'showMM', 6, ...
    'xNames', names)
ylim([-0.1, 1.1])
set(gca, 'XTickLabelRotation', -90)
ylabel('Fraction in-vivo')
saveas(f1, 'fraction_violin.png')