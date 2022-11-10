cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
close all; clear; clc
%% list all animals
files = dir('Round*.mat');
files = {files.name}';

all_data = cell(length(files), 1);
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    all_data(i) = {data.current};
end
%% fraction vs wavelength
fig = figure(15);
fig.Units = 'Centimeters';
fig.Position = [5, 5, 12, 4];
fig.Color = 'w';
clf;
JF669_counter = 0;
JF669_all = [];
JF552_counter = 0;
JF552_all = [];
Others_all=[];
for i = 2:length(files)
    data = all_data{i};
    y = nanmean(data.fraction_sub);
    x = data.invivo_dye;
    switch data.invivo_dye
        case 669
            color = data.color;
            JF669_counter = JF669_counter+1;
            JF669_all = [JF669_all y];
        case 552
            color = data.color;
            JF552_counter = JF552_counter+1;
            JF552_all = [JF552_all y];
        otherwise
            color='k';
            Others_all = [Others_all y];
    end
    if data.double
        m = 'o';
        l=1;
    else
        m='o';
        l=1;
    end
    scatter(x, y, 20, color,  'Marker' , m, 'linewidth',l)
    hold on;
end
ylim([-.1,1]);
xlim([500, 700])
text(669, 0.95, 'JF669', 'color', 'm','HorizontalAlignment', 'center')
text(552, 0.8, 'JF552','color','r','HorizontalAlignment', 'center')
text(620, 0.5, 'Others','color','k','HorizontalAlignment', 'center')
xlabel('Dye wavelength (nm)');
ylabel('Fraction in-vivo');
JF669_mean = mean(JF669_all);
JF669_SD = std(JF669_all);
JF552_mean = mean(JF552_all);
JF552_SD = std(JF552_all);
Others_mean = mean(Others_all);
Others_SD = std(Others_all);
errorbar(669+10, JF669_mean, JF669_SD, '*m', 'linewidth',1.5);
errorbar(552+10, JF552_mean, JF552_SD, '*r', 'linewidth',1.5);
errorbar(620, Others_mean, Others_SD, '*k', 'linewidth',1.5);
sprintf('669: %.2f +- %.2f, 552: %.2f +- %.2f, Others: %.2f +- %.2f',...
    JF669_mean, JF669_SD,...
    JF552_mean, JF552_SD,...
    Others_mean, Others_SD)
%%
g = [ones(length(JF669_all),1) ;ones(length(JF552_all),1)*2; ...
    ones(length(Others_all),1)*3];
x = [JF669_all JF552_all Others_all];
[p, tbl, stat] = anova1(x',g);
multcompare(stat,'CType','bonferroni')
%%
export_fig 'figure2C.eps' -depsc
%% fraction vs Klz
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
fig = figure(15);

fig.Color = 'none';
fig.Units = 'Centimeters';
fig.Position = [5, 5, 6, 4];
clf;
Other_counter = 0;
for i = 2:length(files)
    data = all_data{i};
    y = nanmean(data.fraction_sub);
    index = find(strcmp(data.dye_name, names));
    if isempty(index)
        continue
    end
    Other_counter = Other_counter+1
    x =log_k_lz(index);
    switch data.invivo_dye
        case 669
            color = data.color;
        case 552
            color = data.color;
        otherwise
            color='k';
    end
    
    scatter(x, y, 20, color, 'fill')
    hold on;
    
end
r=rectangle('Position', [-2, 0, 2, 1],'linewidth',2,...
    'linestyle','--');
text(-5.2, 0.8, 'JF669', 'color', 'm')
text(0.3, 0.6, 'JF552','color','r')
ylim([0,1]);
xlim([-7, 3])
xlabel('Log k_{L-Z}');
ylabel('Fraction in-vivo');


export_fig 'figure2D.eps' -depsc
%% calibration to GFP?
GFP_HT_ratio = cell(1,1);
figure(1)
clf
k=1
category = [];
mean_all =[];
for i = 2:length(files)
    data = all_data{i};
    if data.blank_exvivo ~= 150 && data.blank_invivo ~=150
        sd_noise = nanstd(data.virus_bg);
        index = data.virus_sub > sd_noise*2;
        current = data.sum_sub ./ data.virus_sub;
        current = current(index);
        GFP_HT_ratio(k) = {current};
        size(current)
        mean_all(k) = nanmedian(current);
        errorbar(k,nanmedian(current), nanstd(current), 'b*');
        text(k,1.2,sprintf('In:%d,Ex:%d',data.invivo_dye,...
            data.exvivo_dye),'Rotation',90);
        hold on;
         k=k+1;
    end
end
ylim([0 1.8])
box off
xlabel('Animal #')
ylabel('Invivo+Exvivo / Virus')
xticks([1,5,9,13,17])
%%
[p,h,stats] = signrank(mean_all- median(mean_all));
figure(2)
clf
boxplot(mean_all);
ylim([0 1])
% c = multcompare(stats);
