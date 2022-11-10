cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
close all; clear; clc
%% list all animals
files = dir('Round*.mat');
files = {files.name}';
%%
fig = figure(12);
clf;
fig.Units = 'Centimeters';
fig.Position = [5, 15, 12, 5];
fig.Color = 'white';
x_all1 =  [];
x_all2 = [];
y_all1 = [];
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if ~isfield(data, 'Pixels_mm')
        continue
    end
     switch data.invivo_dye
        case 669
            color = data.color;
        case 552
            color = data.color;
        otherwise
            color='k';
     end
    if data.Round == 0
        marker = 's';
    else
        marker = '*';
    end
    x = nansum(data.virus_sub)./ nansum(data.Pixels_mm);
    y = nanmean(data.fraction_sub);
    x_all1 = [x_all1 x];
    y_all1 = [y_all1 y];
    subplot(1,2,1)
    semilogx(x, y,[marker color])
    hold on;
    x = length(data.virus_sub)./ (nansum(data.Pixels_mm));
    
    x_all2 = [x_all2 x];
    subplot(1,2,2)
    semilogx(x, y, [marker color])
    hold on;
    
end
% legend('Location','bestoutside');

subplot(1,2,1)
xlabel('Sum virus signal (F/mm^2)', 'fontsize',8);
ylabel('Mean fraction in vivo', 'fontsize',8);
ylim([0 1]);
xlim([1e4 2e7])
xticks([1e4 1e5 1e6 1e7]);
a1 = plot(nan, nan, 'm*');
a2 = plot(nan, nan, 'r*');
legend([a1 a2], {'JF669-HTL','JF552-HTL'}, 'box','off', ...
    'location','northoutside','NumColumns' ,3)
box off
subplot(1,2,2)
xlabel('# cells / mm^2');
ylim([0 1]);

xlim([1e2 1e5])

xticks([1e2 1e3 1e4 1e5]);
a1 = plot(nan, nan,  'ks');
a2 = plot(nan, nan, 'k*');
legend([a1 a2 ], {'No virus','Others'}, 'box','off', ...
    'location','northoutside','NumColumns' ,3)
box off
%%
fitlm(x_all1, y_all1)

fitlm(x_all2, y_all1)
%%
export_fig 'SuppVirusTop.eps' -depsc
%%
%%
fig = figure(14);
clf;
fig.Units = 'Centimeters';
fig.Position = [5, 5, 12, 5];
fig.Color = 'white';
x_all_669=[];
y_all_669=[];
x_all_552=[];
y_all_552=[];
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    x = nanmedian(data.fraction_sub);
    y = nanmedian(data.invivo_sub) ./ ...
        nanmedian(data.virus_sub);
    if data.invivo_dye == 552 
        subplot(1,2,1)
        x_all_552 = [x_all_552 x];
        y_all_552 = [y_all_552 y];
    elseif data.invivo_dye == 669
        subplot(1,2,2)
        x_all_669 = [x_all_669 x];
        y_all_669 = [y_all_669 y];
    else
        continue
    end
   
    hold on;
    plot(x, y , '*', 'color',data.color)
    hold on;
    
    
end
subplot(1,2,1)
xlabel('Fraction in-vivo')
ylabel('In-vivo / GFP')
title('JF552-HTL')
xlim([0,1])
ylim([0,0.8]);
subplot(1,2,2)
xlabel('Fraction in-vivo')
title('JF669-HTL')
xlim([0,1])
ylim([0,0.8]);
%%
fitlm(x_all_552, y_all_552)
fitlm(x_all_669, y_all_669)
%%
export_fig 'SuppVirusPerfusion.eps' -depsc
