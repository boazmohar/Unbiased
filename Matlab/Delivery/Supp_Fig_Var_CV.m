% cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
cd('C:\Users\moharb\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
close all; clear;
%% list all animals
files = dir('Round*.mat');
files = {files.name}';

all_data = cell(length(files), 1);
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    all_data(i) = {data.current};
end
%%
fig = figure(15);
fig.Units = 'Centimeters';
fig.Position = [5, 5, 12, 8];
fig.Color = 'white';
clf;
N_s = cell(1,length(files)-1);
for i = 2:length(files)
    data = all_data{i};
    zs = sort(unique(data.z));
    values = zeros(length(zs), 1);
    errors = zeros(length(zs), 1);
    CVs =  zeros(length(zs), 1);
    N = zeros(length(zs), 1);
    for k = 1:length(zs)
        z = zs(k);
        current = data.fraction_sub(data.z == z);
        values(k) = nanmedian(current);
        std_ = nanstd(current);
        N(k) = length(current);
        errors(k) = std_ ./ sqrt(length(current));
        CVs(k) = std_ / nanmean(current);
        if errors(k) > 0.5
            values(k) = nan;
        end
    end
     switch data.invivo_dye
        case 669
            color = data.color;
        case 552
            color = data.color;
        otherwise
            color='k';
    end
    errorbar(zs.*data.z_spaceing/1000, values, errors, 'color',color , 'DisplayName',  ...
        sprintf('R%d-ANM%d:%s', data.Round, data.ANM, ...
        data.dye_name), 'linewidth',0.5)
    N_s{i-1} = N;
    hold on;
end
% legend('Location','bestoutside');
xlabel('AP axis position(mm)');
ylabel('Median(\pmSE) fraction in vivo ');
ylim([0 1]);
xlim([0 14]);
box off;

% export_fig 'figure_Var_A.eps' -depsc
%%
fig = figure(16);
fig.Units = 'Centimeters';
fig.Position = [5, 5, 12, 8];
fig.Color = 'white';
clf;
x_all = [];
y_all = [];
for i = 2:length(files)
   
    data = all_data{i};
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
    switch data.invivo_dye
        case 669
            color = data.color;
        case 552
            color = data.color;
        otherwise
            color='k';
    end
    errorbar(x/1000, values_norm, errors_norm, 'color',color , 'DisplayName',  ...
        sprintf('%d:R%d,ANM%d,%s,%s', i, data.Round, data.ANM, ...
        data.dye_name, data.cond), 'linewidth',0.5);
    hold on;
    
end
plot([0.9, 2.5], [1.3 1.3], 'b', 'linewidth', 10,'DisplayName',...
    'Normalization region');

n_bins = 20;
[Y, E] = discretize(x_all,n_bins);
centers_669 = (E(1:end-1) + E(2:end))/2;
mean_values_669 = zeros(1, n_bins);
mean_SE_669 = zeros(1, n_bins);
for i = 1:n_bins
    current = y_all(Y==i);
    mean_values_669(i) = nanmean(current);
    mean_SE_669(i) = nanstd(current) ./ sqrt(length(current));
end
errorbar(centers_669/1000, mean_values_669, mean_SE_669, 'color','k', 'linewidth',3, ...
    'DisplayName', 'Mean \pm SE');

plot([0, 14], [1 1], '--', 'color',[0.5, 0.5, 0.5], ...
    'linewidth', 2,'DisplayName','Y=1');
% legend('Location','bestoutside');
xlabel('AP axis position(mm)');
ylabel('Norm. Median(\pmSE) fraction in vivo ');
ylim([0.4 1.6]);
xlim([-0.1, 14]);
box off;
% export_fig 'figure_Var_B.eps' -depsc
%%
fig = figure(16);
fig.Units = 'Centimeters';
fig.Position = [5, 5, 12, 8];
fig.Color = 'white';
clf;
x_all_669 = [];
y_all_669 = [];
x_all_552 = [];
y_all_552 = [];
for i = 2:length(files)
    data = all_data{i};
    zs = sort(unique(data.z));
    if length(zs) < 10
        continue
    end
    values = zeros(length(zs), 1);
    CVs = zeros(length(zs), 1);
    for k = 1:length(zs)
        z = zs(k);
        current = data.fraction_sub(data.z == z);
        std_ = nanstd(current);
        CVs(k) = std_ ./ nanmean(current);
    end
    x = zs.*data.z_spaceing;
    switch data.invivo_dye
        case 669
            color = data.color;
            x_all_669 = [x_all_669; x];
            y_all_669 = [y_all_669; CVs];
        case 552
            color = data.color;

            x_all_552 = [x_all_552; x];
            y_all_552 = [y_all_552; CVs];
        otherwise
            color='k';
    end
    plot(x/1000, CVs,  'color',color , 'linewidth',0.5);
    hold on;
    
end
n_bins = 13;
[Y, E] = discretize(x_all_669,n_bins);
centers_669 = (E(1:end-1) + E(2:end))/2;
mean_values_669 = zeros(1, n_bins);
mean_SE_669 = zeros(1, n_bins);
for i = 1:n_bins
    current = y_all_669(Y==i);
    mean_values_669(i) = nanmedian(current);
    mean_SE_669(i) = nanstd(current) ./ sqrt(length(current));
end

[Y, E] = discretize(x_all_552,n_bins);
centers_552 = (E(1:end-1) + E(2:end))/2;
mean_values_552 = zeros(1, n_bins);
mean_SE_552 = zeros(1, n_bins);
for i = 1:n_bins
    current = y_all_552(Y==i);
    mean_values_552(i) = nanmedian(current);
    mean_SE_552(i) = nanstd(current) ./ sqrt(length(current));
end

a = errorbar(centers_669/1000, mean_values_669, mean_SE_669, 'color','m', 'linewidth',3, ...
    'DisplayName', 'JF669');


b = errorbar(centers_552/1000, mean_values_552, mean_SE_552, 'color','r', 'linewidth',3, ...
    'DisplayName', 'JF552');
ax = gca();
 ax.YScale = 'log';
legend([a, b], 'Location','south', 'NumColumns',2,'box','off');
xlabel('AP axis position(mm)');
ylabel('CV fraction in vivo ');
% ylim([0.4 1.6]);
xlim([-0.1, 14]);
box off;
% export_fig 'figure_Var_C2.eps' -depsc