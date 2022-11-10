clear;
close all;
clc;
cd('E:\Dropbox (HHMI)\Projects\Unbised\Clearance');
%%
files = dir('Clearance*.mat');
mat_files = sort_nat({files.name});
files = dir('Clearance*.tif');
registered_files = sort_nat({files.name});
n_files = length(files);
figure(12);
clf;
T = table;
fit_res_all = [];
x_all = [];
y_all = [];
for i = 1:n_files
    if i == 5
        continue
    end
    data = load(mat_files{i});
    data = data.data;
    n_timepoints = size(data.movie, 3);
    reg = zeros(data.imagesize(1), data.imagesize(2), n_timepoints);
    for k = 1:n_timepoints
        reg(:, :, k) = imread(registered_files{i}, k);
    end
    figure();
    h = imshow(squeeze(nanmean(reg, 3)), []);
    e = imellipse(gca, data.median_pos);
    BW = createMask(e,h); 
    [data_middle, median_middle, BW, pos] = cropMiddle(reg, ...
    data.imagesize, n_timepoints, data.offset, BW);
    t = sort(data.times);
    if isfield(data,'median_new') && ~isempty(data.median_new)
        median_middle = data.median_new(data.offset:end);
    end
    median_middle = median_middle ./ max(median_middle);
    [fit_res, gof, x, opts] = fitDouble(t(data.offset:end), ...
        median_middle, sprintf('%d:Dye:%s', i, data.dye));
 
    close;
    switch data.dye
        case 'JF525'
            color = 'g';
        case 'JF669'
            color = 'm';
        case 'JF552'
            color = 'r';
    end
    figure(12); 
    set(gca, 'xlim', [0.1, 1400])
    a = plot(x, median_middle);
    x_all = [x_all; x];
    y_all = [y_all ; median_middle];
    a.Color = color;
    hold on;
    ci = confint(fit_res);
    x_t = table(i,string(data.dye),fit_res.a, fit_res.b, fit_res.c, fit_res.d, ...
        fit_res.e, ci(1,:), ci(2,:), {fit_res});
    T = [T; x_t];
    if (isfield(data, 'Liver')) && data.Liver == 1
        a.LineStyle=':';
    end
end
edges = [-1, 0.1, 1, 4, 16, ];
T.Properties.VariableNames = {'i' 'dye' 'a' 'b' 'c' 'd' 'e' 'ci_low', ...
    'ci_high', 'fit'};
f = figure(12);
f.Units = 'centimeters';
f.Position = [10, 10, 6, 5];
f.Color = 'w';
xlim([0 2700])
ylabel('Normalized F')
xlabel('Time (Min)')
box off;
set(gca, 'xScale','linear');
E = [0, 0.2,1, 4, 10, 20, 50, 100, 200, 400, 1000, 2700];
Y = discretize(x_all,E);
n_bins = length(unique(Y));
centers = (E(1:end-1) + E(2:end))/2;
mean_values = zeros(1, n_bins);
mean_SE = zeros(1, n_bins);
for i = 1:n_bins
    current = y_all(Y==i);
    mean_values(i) = nanmedian(current);
    mean_SE(i) = nanstd(current) ./ sqrt(length(current));
end
errorbar(centers, mean_values, mean_SE, 'color','k', 'linewidth',1.5, ...
    'DisplayName', 'Mean \pm SE');
%%
T.Properties.VariableNames = {'i' 'dye' 'a' 'b' 'c' 'd' 'e' 'ci_low', ...
    'ci_high', 'fit'};
tau1 = mean(T.b);
tau2 = mean(T.d);
ratio = mean(T.a./T.c);
free = mean(T.e);

tau1_s = std(T.b)./sqrt(11);
tau2_s = std(T.d)./sqrt(11);
ratio_s = std(T.a./T.c)./sqrt(11);
free_s = std(T.e)./sqrt(11);
legend off
t1 = text(100,1, ...
    sprintf('$$ \\tau_{1}=%.0f \\pm %.0f,\\tau_{2}=%.0f \\pm %.0f $$', ...
    tau1, tau1_s, tau2, tau2_s),'Interpreter','latex');
t2 = text(100, 0.85, sprintf('$$ a/b=%.1f \\pm %.1f,c=%.2f \\pm %.2f$$ ' , ...
    ratio, ratio_s, free, free_s),'Interpreter','latex');
t1.Visible = 'off';
t2.Visible = 'off';

ylim([-0.1, 1.1])

set(gca, 'xScale','linear');

export_fig 'Population Lin_v2.eps' -depsc
% print
JF552 = plot([0, 0], [1, 1], 'r', 'visible','off');
JF669 = plot([0, 0], [1, 1], 'm', 'visible','off');
JF525 = plot([0, 0], [1, 1], 'g', 'visible','off');
Liver = plot([0, 0], [1, 1], 'k:', 'visible','off');
Brain = plot([0, 0], [1, 1], 'k', 'visible','off');
legend([JF552, JF669, JF525, Brain, Liver], {'JF_{552}','JF_{669}','JF_{525}', 'Brain','Liver'}, 'box','off')
set(gca, 'xScale','log');
export_fig 'Population Log_v2.eps' -depsc
