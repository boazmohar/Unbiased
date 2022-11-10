function  plot_log_k_lz(files)
%plot_log_k_lz Summary of this function goes here
%   Detailed explanation goes here
names = {'JF479' 'JF502' 'JF503' 'JF519' 'JF525' 'JF526' 'JF549' 'JFX549' ...
    'JF552' 'RhP' 'SF554' 'JF559' 'JP567' 'JF570' 'JF571' 'JF585' 'JF593' ...
    'JF608' 'JF635' 'JF646' 'JFX646' 'SiRhP' 'SF650' 'JF669' 'JF690' ...
    'JF711' 'JF722' 'JF724', 'JF541', 'JF533'};
nm = [479 502 503 519 525 526 549 548 552 554 554 559 567 570 571 585 ...
    593 608 635 646 645 652 650 669 690 711 722 724 541 533];

k_lz = [2.8765 4.3291 0.0435 0.5926 0.0676 0.0050 3.4667  nan ...
    0.6951 nan nan 6.2222 nan 2.2410 7.9286 0.001 6.0552 0.0911 0.001 ...
    0.0014 nan nan nan 0.2622 2.9000 0.001 0.0258 0.001 2.5 0.24];
log_k_lz = log(k_lz);
f1 = figure(14);
f1.Position = [560   530   970   480];
clf;
data_all_klz = [];
data_all_dye = {};
data_all_frac = [];
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if data.double
        edge = 'k';
    else
        edge = 'none';
    end
    index = find(strcmp(data.dye_name, names));
    if isempty(index)
        continue
    end
    fprintf('file: %s, fraction: %.2f, Klz: %.2f\n' , ...
        file, nanmean(data.fraction_sub), k_lz(index))
    scatter(log_k_lz(index), nanmean(data.fraction_sub), 50, data.color, ...
        data.marker, 'filled', 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i, data.Round, data.ANM, ...
        data.dye_name, data.cond), 'MarkerEdgeColor', edge, 'linewidth',2)
    hold on;
    data_all_klz(i) = log_k_lz(index);
    data_all_dye(i) ={data.dye_name};
    data_all_frac(i) = nanmean(data.fraction_sub);
    text(log_k_lz(index)+0.2, nanmean(data.fraction_sub), sprintf('%d', i))
    
   
end
legend('Location','bestoutside');
xlabel('Log k_{L-Z}');
ylabel('Mean fraction in vivo');
ylim([0 1]);
saveas(f1, 'log_k_lz_vs_fraction.png')
f2 = figure(15);
clf
scatter(log_k_lz, nm)
hold on;
dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points
text(log_k_lz+dx, nm+dy, names);
xlabel('Log k_{L-Z}');
ylabel('\lambda max');
saveas(f2, 'log_k_lz_vs_l_max.png')
tbl = table(data_all_dye', data_all_klz', data_all_frac');
tbl.Properties.VariableNames = {'Dye','Log Klz','Fraction invivo'};
writetable(tbl, 'KLZ.csv')