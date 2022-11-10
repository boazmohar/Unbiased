%% clear and load data
clear;
close all;
clc
cd('E:\ImagingDM11\Turnover');
files = dir('*.csv');
files= {files.name}';
%%
% 
% colors = ['r', 'b', 'g'];
% titles = {'4h','24h','48h'};
y1_All = [];
y2_All = [];
y1_Alls = [];
y2_Alls = [];
for i = 1:3
    fig=figure(i);
    clf;
    fig.Units = 'Centimeters';
    fig.Position = [7*i,15, 4, 3];
    fig.Color = 'white';
    file = files{i};
    opts = delimitedTextImportOptions("NumVariables", 3);

    % Specify range and delimiter
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";

    opts.VariableNames = ["x", "Pulse", "Chase"];
    opts.VariableTypes = ["double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    data = readtable(file, opts);
    data = data(1:end-1,:);
    Pulse = data{:,2} - min(data{:,2});
    
    Chase = data{:,3} - min(data{:,3});
    
    a1 = plot(Pulse, '-','color','yellow');
    hold on;
    a2 = plot(Chase, 'r-');
    ylim([0, 30])
    yticks([0, 15, 30])
    if i > 1
      set(gca,'YTickLabel',[]);
    end
    xlabel('DV axis (um)');
    if i ==1
        
        ylabel('Mean F (AU)');
        
    end
    box off
    outfile = [file(1:end-4) '_V2.eps'];
    sum1 = Pulse + Chase;
    fraction = Pulse./sum1;
  
%     yyaxis right
    y1 =  mean(fraction(50:100));
    y2 =  mean(fraction(210:310));
    
    
    y1s =  std(fraction(50:100));
    y2s =  std(fraction(210:310));
    
    y1_All(i) = y1;
    y2_All(i) = y2;
    y1_Alls(i) = y1s;
    y2_Alls(i) = y2s;
%     plot([50,100], [y1 y1], '-','color',colors(i), 'linewidth',2);
%     hold on;
%     
%     plot([210,310], [y2 y2],'-', 'color',colors(i), 'linewidth',2);
%     ax = gca();
%     ax.YColor = colors(i);
%     ylim([0,1])
%     if i == 3
%         yyaxis right
%         ylabel('Fraction pulse');
%     end
    if i ==1
        legend([a1,a2],{'Pulse (JF552)','Chase (JF669)'}, 'box','off');
    else
      
    end
    export_fig(outfile,'-depsc');
end
%%
fig=figure(4);
clf;
fig.Units = 'Centimeters';
fig.Position = [7*4,15, 4, 3];
fig.Color = 'white';
x = [4, 24, 48];
errorbar(x, y1_All,y1_Alls, 'ok')
hold on;
errorbar(x, y2_All,y2_Alls, 'sk')
legend({'L1','L5'}, 'box','off', 'Location','best')
% ylim([0,1])
ylabel('Fraction Pulse');
xlabel('Time (h)');
box off
xlim([0, 50])
export_fig('Figure6F_GluA1_L1vsL5.eps')
%% for figure 6
cd('E:\ImagingDM11\Turnover\Figure6');
files = dir('*.csv');
files= {files.name}';
colors = ['r', 'b', 'g'];
titles = {'4h','24h','48h'};
for i = 1:3
    fig=figure(i);
    color = colors(i);
    clf;
    fig.Units = 'Centimeters';
    fig.Position = [7*i,15, 4, 3];
    fig.Color = 'white';
    file = files{i};
    opts = delimitedTextImportOptions("NumVariables", 6);

    % Specify range and delimiter
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";

    % Specify column names and types
    opts.VariableNames = ["VarName1", "Area", "Mean", "Mode", "Min", "Max"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    % Import the data
    data = readtable(file, opts);
    sum1 = data{1:30, 3} + data{31:end, 3};
    fraction = data{1:30, 3} ./ sum1;
    histogram(fraction, linspace(0,0.7,31), 'FaceColor','k');
    hold on;
    m1 = median(fraction)
    plot([m1, m1], [0,15], 'k:', 'linewidth',2);
    title(titles{i}, 'color','k')
    ylim([0, 15])
    xlabel('Mean turnover');
    if i ==1
        ylabel('#spines');
    end
    box off
    outfile = [file(1:end-4) '_V2.eps'];
    export_fig(outfile,'-depsc');
end
%%
%% clear and load data
clear;
close all;
clc
cd('E:\ImagingDM11\Turnover\Figure6\');
files = dir('*.tif');
files= {files.name}';
rMap = brewermap(128,'Reds');
pMap = brewermap(128,'Purples');
fMap = brewermap(128,'*YlGnBu');

for i= 1:3
    file = files{i};
    
    pulse = imread(file, 1);
    chase = imread(file, 2);
    sum_img = pulse + chase;
    bg = prctile(sum_img(:), 75);
    mask_ng = sum_img < bg;
    fraction = single(pulse) ./ (single(pulse) + single(chase));
    fraction(mask_ng) = nan;
    figure(i)
    subplot(2,2,1)
    imshow(pulse, []);
    title(file)
    colormap(gca, rMap);
    subplot(2,2,2)
    imshow(chase, []);
    
    colormap(gca, pMap);
    subplot(2,2,3)
    imshow(sum_img, []);
    subplot(2,2,4)
    high = prctile(fraction(:), 99.5);
    imshow(fraction, [0 high]);
    colormap(gca, fMap);
    colorbar()
end
