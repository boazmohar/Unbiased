cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
close all; clear;
%% list all animals
files = dir('Round*.mat');
files = {files.name}';
%%
fig = figure(12);
clf;
fig.Units = 'Centimeters';
fig.Position = [5, 5, 12, 4];
fig.Color = 'white';

subplot(1,2,1)
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if ~isfield(data, 'Pixels_mm')
        continue
    end
     switch data.invivo_dye
        case 669
            color = 'r';%data.color;
            shape = 'o';
        case 552
            color = [1, 0.64, 0];%data.color;
            shape = 'o';
         case 0
             shape = 's';
            color='k';
        otherwise
            color='k';
            shape = 'o';
    end
    x = nansum(data.virus_sub)./ nansum(data.Pixels_mm);
    y = nanmean(data.fraction_sub);
    fprintf('file: %s, fraction: %.2f\n' , file, nanmean(data.fraction_sub))
    scatter(x, y, 30, color, 'filled',shape)
    hold on;
end
% legend('Location','bestoutside');
xlabel('Sum virus signal (AU/mm^2)', 'fontsize',8);
ylabel('Mean fraction in vivo', 'fontsize',8);
ylim([0 1]);
a1 = scatter(nan, nan, 30, 'r', 'filled', 'o');
a2 = scatter(nan, nan, 30,[1, 0.64, 0], 'filled','o');
legend([a1 a2 ], {'JF669-HTL','JF552-HTL'}, 'box','off', ...
    'location','northoutside','NumColumns' ,3)
box off

ax = gca();
ax.XAxis.Scale = 'log';
%
subplot(1,2,2)
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if ~isfield(data, 'Pixels_mm')
        continue
    end
     switch data.invivo_dye
        case 669
            color = 'r';%data.color;
            shape = 'o';
        case 552
            color = [1, 0.64, 0];%data.color;
            shape = 'o';
         case 0
             shape = 's';
            color='k';
        otherwise
            color='k';
            shape = 'o';
    end
    x = length(data.virus_sub)./ (nansum(data.Pixels_mm));
    y = nanmean(data.fraction_sub);
    scatter(x, y, 30, color, 'filled', shape)
    hold on;
end
xlabel('# cells / mm^2');
% ylabel('Mean fraction in vivo');
ylim([0 1]);
ax = gca();
ax.XAxis.Scale = 'log';
a3 = scatter(nan, nan, 30, 'k', 'fill', 's');
a4 = scatter(nan, nan, 30, 'k', 'fill', 'o');
legend([a3 a4 ], {'No virus','Others'}, 'box','off', ...
    'location','northoutside','NumColumns' ,3)
box off

export_fig 'SuppVirusCells_V2.eps' -depsc
%%
fig = figure(13);
clf;
fig.Units = 'Centimeters';
fig.Position = [5, 5, 12, 4];
fig.Color = 'white';

for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if data.invivo_dye == 552 
        subplot(1,2,1)
        color = [1, 0.64, 0];
    elseif data.invivo_dye == 669
        subplot(1,2,2)
        color = 'r';
    else
        continue
    end
    x = nanmedian(data.fraction_sub);
    y = nanmedian(data.invivo_sub) ./ ...
        nanmedian(data.virus_sub);
    hold on;
    scatter(x, y, 30, color, 'fill')
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

export_fig 'SuppVirusPerfusion.eps' -depsc
