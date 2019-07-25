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
    text(zs(end)*data.z_spaceing+100,values(end), sprintf('%d', i))
end
legend('Location','bestoutside');
xlabel('AP axis position(\mum)');
ylabel('Median(\pmSE) fraction in vivo ');
ylim([0 1]);
saveas(fig, 'AP_vs_fraction.png')
