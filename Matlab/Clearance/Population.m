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
    if i == 1
        export_fig('All_fits_liver', gcf, '-pdf');
    else
        export_fig('All_fits_liver', gcf, '-pdf', '-append');
    end
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
    a = plot(fit_res);
    a.DisplayName = sprintf('%2d:%s \\tau_{fast}%2d, \\tau_{slow}%3d, ratio %1.2f', i, data.dye, ...
        round(fit_res.b), round(fit_res.d), fit_res.a/fit_res.c);
    a.Color = color;
    if i > 5
        a.LineWidth=2;
    end
    if (isfield(data, 'Liver')) && data.Liver == 1
        a.LineStyle=':';
    end
    hold on;
    ci = confint(fit_res);
    x_t = table(i,string(data.dye),fit_res.a, fit_res.b, fit_res.c, fit_res.d, ...
        fit_res.e, ci(1,:), ci(2,:), {fit_res});
    T = [T; x_t];
   
end

T.Properties.VariableNames = {'i' 'dye' 'a' 'b' 'c' 'd' 'e' 'ci_low', ...
    'ci_high', 'fit'};
f = figure(12); 

xlim([0 1400])
f.Position = [700   204   897   643];
ylabel('F Normalized)')
xlabel('Time (Min)')
box off;
hLegend = findobj(gcf, 'Type', 'Legend');
hLegend.Box = 'off';
hLegend.Position = [0.5806    0.5049    0.2798    0.3904];
set(gca, 'xScale','linear');
print('Population_wLiver','-r300','-dpng')
xlim([0 100])
print('PopulationZoomIn','-r300','-dpng')
set(gca, 'xScale','log');
xlim([0 1400])
hLegend.Position = [0.1469    0.2467    0.2798    0.3904];
print('Population_wLiver_log','-r300','-dpng')
