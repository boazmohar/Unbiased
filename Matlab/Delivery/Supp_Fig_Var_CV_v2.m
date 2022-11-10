cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
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
for i = 2:length(files)
    data = all_data{i};
    zs = sort(unique(data.z));
    values = zeros(length(zs), 1);
    errors = zeros(length(zs), 1);
    CVs =  zeros(length(zs), 1);
    for k = 1:length(zs)
        z = zs(k);
        current = data.fraction_sub(data.z == z);
        values(k) = nanmedian(current);
        std_ = nanstd(current);
        errors(k) = std_ ./ sqrt(length(current));
        CVs(k) = std_ / nanmean(current);
        if errors(k) > 0.5
            values(k) = nan;
        end
    end
     switch data.invivo_dye
        case 669
            color = 'r';%data.color;
        case 552
            color = '#ffa400';%, data.color;
        otherwise
            color='k';
    end
    errorbar(zs.*data.z_spaceing/1000, values, errors, 'color',color , 'DisplayName',  ...
        sprintf('R%d-ANM%d:%s', data.Round, data.ANM, ...
        data.dye_name), 'linewidth',0.5)
    hold on;
end
% legend('Location','bestoutside');
xlabel('AP axis position(mm)');
ylabel('Median(\pmSE) fraction in vivo ');
ylim([0 1]);
xlim([0 14]);
box off;

export_fig 'figure_Var_A.eps' -depsc
%%
fig = figure(16);
fig.Units = 'Centimeters';
fig.Position = [5, 5, 12, 8];
fig.Color = 'white';
clf;
x_all_6 = [];
y_all_6 = [];
x_all_5 = [];
y_all_5 = [];
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
    switch data.invivo_dye
        case 669
            color = 'r';data.color;
             x_all_6 = [x_all_6; x];
             y_all_6 = [y_all_6; values_norm];
        case 552
            color = '#ffa400';%data.color;
             x_all_5 = [x_all_5; x];
             y_all_5 = [y_all_5; values_norm];
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
[Y1, E] = discretize(x_all_6,n_bins);
centers_669 = (E(1:end-1) + E(2:end))/2;
mean_values_669 = zeros(1, n_bins);
mean_SE_669 = zeros(1, n_bins);
for i = 1:n_bins
    current = y_all_6(Y1==i);
    mean_values_669(i) = nanmean(current);
    mean_SE_669(i) = nanstd(current) ./ sqrt(length(current));
end
errorbar(centers_669/1000, mean_values_669, mean_SE_669, 'color','r', 'linewidth',3, ...
    'DisplayName', 'Mean \pm SE');

[Y2, E] = discretize(x_all_5,n_bins);
centers_5 = (E(1:end-1) + E(2:end))/2;
mean_values_5 = zeros(1, n_bins);
mean_SE_5 = zeros(1, n_bins);
for i = 1:n_bins
    current = y_all_5(Y2==i);
    mean_values_5(i) = nanmean(current);
    mean_SE_5(i) = nanstd(current) ./ sqrt(length(current));
end
errorbar(centers_5/1000, mean_values_5, mean_SE_5, 'color','#ffa400', 'linewidth',3, ...
    'DisplayName', 'Mean \pm SE');
plot([0, 14], [1 1], '--', 'color',[0.5, 0.5, 0.5], ...
    'linewidth', 2,'DisplayName','Y=1');
% legend('Location','bestoutside');
xlabel('AP axis position(mm)');
ylabel('Norm. Median(\pmSE) fraction in vivo ');
ylim([0.4 1.6]);
xlim([-0.1, 14]);
box off;
%%
[p,a,b ]= kruskalwallis(y_all_6, Y1)
multcompare(b)

%%
[p,a,b ]= kruskalwallis(y_all_5, Y2)
multcompare(b)
%%
export_fig 'figure_Var_B.eps' -depsc

%%
cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
close all; clear;
% list all animals
files = dir('Round*.mat');
files = {files.name}';
i_all = [26,28,12]; % 2a = 18, 2b = 26
zs=[14, 14, 14];
um_per_px = 1/0.66;
scalebar_um = 1000;
scalebar_px = scalebar_um/um_per_px;
x_offset = 4000;
y_offest = -3500;
f = figure(1);
    clf;
    set(f, 'color', 'white')
    set(f, 'units','centimeter')
    set(f, 'position', [5,5,12,6]);
    
    set(f, 'units','normalized')
    f.PaperPositionMode = 'auto';
    axs = matlab.graphics.axis.Axes.empty();
for k = 1:3
    file = files{i_all(k)};
    data = load(file, 'current');
    data = data.current;
    disp(data.invivo_dye)
    z = zs(k);  
  
    index = data.z == z;
    axs(k) = subaxis(3,3,k*3-2, 'Spacing', 0.06, 'Padding', 0.001, 'Margin', 0.07,...
        'SpacingVert', 0.01);
    current = data.fraction_sub(index);
    scatter(data.y(index), data.x(index), 10, current, ...
        'filled');
    hold on;
    if k == 1
        plot( [x_offset, x_offset+scalebar_um],[y_offest, y_offest],'linewidth',3,'color','k')
    end
    text(-4000, 1400, sprintf('JF%d-CV:%.2f',data.invivo_dye,...
        nanstd(current)./ nanmean(current)),'color','k')
    caxis([0, 1]);
    colormap(jet(256));
    axis off
end
linkaxes(axs, 'xy');
cv_669 = [];
cv_552 = [];
cv_other = [];
for i = 2:length(files)
    data = load(files{i});
    data = data.current;
    zs = unique(data.z);
    cvs = [];
    for k = 1:length(zs)
        z = zs(k);
        current = data.fraction_sub(data.z == z);
        values = nanmedian(current);
        std_ = nanstd(current);
        cvs(k) = std_/values;
    end
    switch  data.invivo_dye
        case 669
            cv_669 = [cv_669 nanmean(cvs)];
        case 552
            cv_552 = [cv_552 nanmean(cvs)];
        otherwise
            cv_other = [cv_other nanmean(cvs)];
    end
end
subplot(3,5,[3,4,5,8,9,10,13,14,15])
cla();
% x = [mean(cv_669); mean(cv_552); mean(cv_other)]
% e = [std(cv_669)./sqrt(length(cv_669)); std(cv_552)./sqrt(length(cv_552));...
%     std(cv_other)./sqrt(length(cv_other))]
%  barweb( x,e, [], [],[],[],'Fraction in-vivo CV',[],[],{'JF669','JF552','Others'});
g = [ones(length(cv_669),1) ;ones(length(cv_552),1)*2; ...
    ones(length(cv_other),1)*3];
x = [cv_669 cv_552 cv_other];
plotSpread(x, 'distributionIdx',g,'distributionColors',{'r','#ffa400','k'});
% boxplot(x, g,'Labels',{'JF669','JF552','Others'},'Whisker',1, ...
%     'colors','mrk','symbol','');
xticklabels({'JF669','JF552','Others'});
ylabel('Fraction in-vivo CV')
ylim([0,3]);
box off
%%

[p, tbl, stat] = anova1(x',g);
multcompare(stat,'CType','bonferroni')
%%
export_fig 'figure_Var_C.eps' -depsc