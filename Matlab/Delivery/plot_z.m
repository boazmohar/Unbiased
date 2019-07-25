function fig = plot_z(files)
fig = figure(15);
fig.Position = [2500   440   970   480];
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
%         errors(k) = nanstd(current);
    end
    errorbar(zs.*data.z_spaceing, values, errors, ['-' data.marker], 'color',data.color , 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i, data.Round, data.ANM, ...
        data.dye_name, data.cond), 'linewidth',0.5)
    hold on;
    text(zs(end)*data.z_spaceing+150,values(end), sprintf('%d', i))
end
legend('Location','bestoutside');
xlabel('AP axis position(\mum)');
ylabel('Median(\pmSE) fraction in vivo ');
ylim([0 1]);
saveas(fig, 'AP_vs_fraction.png')
%%
fig = figure(16);
fig.Position = [2500   40   970   480];
clf;
y_all = {}
error_all = {}
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if data.double
        edge = 'k';
    else
        edge = 'none';
    end
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
    values_norm = values./median(values(1:9));
    ratio = values(1) ./ values_norm(1);
    errors_norm = errors./ratio;
    errorbar(zs.*data.z_spaceing, values_norm, errors_norm, ...
        ['-' data.marker], 'color',data.color , 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i, data.Round, data.ANM, ...
        data.dye_name, data.cond), 'linewidth',0.5)
    hold on;
    text(zs(end)*data.z_spaceing+150,values_norm(end), sprintf('%d', i))
end
plot([0, 14000], [1 1], 'k', 'linewidth', 2);
legend('Location','bestoutside');
xlabel('AP axis position(\mum)');
ylabel('Normalized Median(\pmSE) fraction in vivo ');
ylim([0.4 1.6]);
saveas(fig, 'AP_vs_fraction_norm.png')
