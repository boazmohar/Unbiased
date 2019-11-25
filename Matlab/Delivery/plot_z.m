function plot_z(files)
fig = figure(15);
fig.Position = [2500   440   970   480];
clf;
for i = 2:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    zs = sort(unique(data.z));
    values = zeros(length(zs), 1);
    errors = zeros(length(zs), 1);
    for k = 1:length(zs)
        z = zs(k);
        current = data.fraction_sub(data.z == z);
        values(k) = nanmedian(current);
        std_ = nanstd(current);
        errors(k) = std_ ./ sqrt(length(current));
        if errors(k) > 0.5
            values(k) = nan;
        end
    end
    errorbar(zs.*data.z_spaceing, values, errors, 'color',data.color , 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i, data.Round, data.ANM, ...
        data.dye_name, data.cond), 'linewidth',0.5)
    hold on;
    text(zs(end)*data.z_spaceing+150,values(end), sprintf('%d', i))
end
legend('Location','bestoutside');
xlabel('AP axis position(\mum)');
ylabel('Median(\pmSE) fraction in vivo ');
ylim([0 1]);
box off;
saveas(fig, 'AP_vs_fraction.png')
%%
fig = figure(16);
fig.Position = [2500   40   970   480];
clf;
x_all = [];
y_all = [];
for i = 2:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    zs = sort(unique(data.z));
    if length(zs) < 10
        continue
    end
    values = zeros(length(zs), 1);
    errors = zeros(length(zs), 1);
    for k = 1:length(zs)
        z = zs(k);
        current = data.fraction_sub(data.z == z);
        values(k) = nanmedian(current);
        std_ = nanstd(current);
        errors(k) = std_ ./ sqrt(length(current));
        if errors(k) > 0.5
            values(k) = nan;
        end
%         errors(k) = nanstd(current);
    end
    index_norm = zs.*data.z_spaceing > 900 & zs.*data.z_spaceing < 2500;
    values_norm = values./median(values(index_norm));
    ratio = values(1) ./ values_norm(1);
    errors_norm = errors./ratio;
    x = zs.*data.z_spaceing;
    x_all = [x_all; x];
    y_all = [y_all; values_norm];
    errorbar(x, values_norm, errors_norm, 'color',data.color , 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i, data.Round, data.ANM, ...
        data.dye_name, data.cond), 'linewidth',0.5)
    hold on;
    text(zs(end)*data.z_spaceing+150,values_norm(end), sprintf('%d', i))
end
plot([900, 2500], [1.3 1.3], 'c', 'linewidth', 10,'DisplayName',...
    'Normalization region');

n_bins = 20;
[Y, E] = discretize(x_all,n_bins);
centers = (E(1:end-1) + E(2:end))/2;
mean_values = zeros(1, n_bins);
mean_SE = zeros(1, n_bins);
for i = 1:n_bins
    current = y_all(Y==i);
    mean_values(i) = nanmean(current);
    mean_SE(i) = nanstd(current) ./ sqrt(length(current));
end
errorbar(centers, mean_values, mean_SE, 'color','k', 'linewidth',3, ...
    'DisplayName', 'Mean \pm SE');

plot([0, 14000], [1 1], '--', 'color',[0.5, 0.5, 0.5], ...
    'linewidth', 2,'DisplayName','Y=1');
legend('Location','bestoutside');
xlabel('AP axis position(\mum)');
ylabel('Normalized Median(\pmSE) fraction in vivo ');
ylim([0.4 1.6]);
box off;
saveas(fig, 'AP_vs_fraction_norm.png')
