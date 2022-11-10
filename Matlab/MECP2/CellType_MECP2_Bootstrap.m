%% 
close all; clear; clc;
tbl = compute_tbl(0);
%%
large = tbl.Large == 0;
rightAP = -2;
ap = tbl.AP == rightAP;
celltype = tbl.cellType ==   1;
index = large & ap & celltype;
data = tbl(index,:);
NeuN = data(strcmp(data.IHC, 'NeuN'), :);
SOX10 = data(strcmp(data.IHC, 'SOX10'), :);
Iba1 = data(strcmp(data.IHC, 'Iba1'), :);
%%
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
%
bootNum = 3000;
nData = 15;
decayNeuN = zeros(1, bootNum);
decaySOX10 = zeros(1, bootNum);
decayIba1 = zeros(1, bootNum);
parfor boot = 1:bootNum
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = 200; 
    indexBoot = randi(15, 1, nData);
    [xData, yData] = prepareCurveData( NeuN.interval(indexBoot), NeuN.mean(indexBoot));
    res = fit( xData, yData, ft, opts );
    decayNeuN(boot) = coeffvalues(res);
    
    [xData, yData] = prepareCurveData( SOX10.interval(indexBoot), SOX10.mean(indexBoot));
    res = fit( xData, yData, ft, opts );
    decaySOX10(boot) = coeffvalues(res);
    
    [xData, yData] = prepareCurveData( Iba1.interval(indexBoot), Iba1.mean(indexBoot));
    res = fit( xData, yData, ft, opts );
    decayIba1(boot) = coeffvalues(res);
end

%%
decay=[decayNeuN; decaySOX10;decayIba1];
f=figure(1);
clf
f.Color = 'w';
 f.Units = 'centimeters';
    f.Position = [15, 15, 6,6];
    
set(gca,'XColor','k','YColor','k');
set(gca, 'FontSize', 9)
bar(mean(decay, 2)./24, 'k')
hold on;
m =  mean(decay, 2)./24;
ci = prctile(decay, [5, 95], 2)./24;
neg = m - ci(1:end,1);
pos = ci(1:end,2) - m;
s=std(decay, [],2)./12;
% l_h = prctile(decay, [5, 95], 2)./24 - m
% errorbar(1:3, m,s, 'color','none','LineStyle','-','LineWidth',1.5)

    bar(1:3, m,  'FaceColor','none', 'EdgeColor','None')
        hold on;

    errorbar(1:3, m, pos, neg,'color',[.5 .5 .5],'LineStyle','none','LineWidth',1.5)
% errorbar(1:6, mean(decay, 2)./24, l_h(:,1),l_h(:,2), 'color',[0.5, 0.5, 0.5],'LineStyle','none','LineWidth',1.5)

xticks(1:3)
xticklabels( {'NeuN','SOX10','Iba1'})
ylabel('MeCP2 \tau (d)')
xlabel('Cell type marker')
box off
xtickangle(45)
% [p,tbl22, stats] = anova2(decay');
% [results, m] = multcompare(stats);
% ylim([8,16])
% yticks([8,10,12,14, 16])
export_fig('CellTypeMECP2.eps', '-eps');
%% sum
tbl.sum = cellfun(@(x) sum(x, 2), tbl.rawData, 'UniformOutput',false);
tbl.sum_mean = cellfun(@mean, tbl.sum);
tbl.sum_std = cellfun(@std, tbl.sum);
ANM = 0;
IHC = 0;
cellType = 1;
intervalType = 2;
data = getOneEntry(tbl, ANM, IHC, cellType, intervalType, 0, 0, -2, 0);
%%
sum_all = cell2mat(data.sum);
g_ANM = {};
g_IHC= {};
for i = 1:height(data)
    count = data.count(i);
    ANM = data.ANM{i};
    IHC = data.IHC{i};
    g_ANM = cat(1, g_ANM, repmat({ANM}, count, 1));
    g_IHC = cat(1, g_IHC, repmat({IHC}, count, 1));
end
[p,tbl22, stats] = anovan(sum_all,{g_IHC g_ANM}, ...
    'model','full','varnames',{'IHC','ANM'});
[results, m] = multcompare(stats, 'Dimension',1);
%%
f=figure(2);
clf
f.Color = 'w';
 f.Units = 'centimeters';
    f.Position = [15, 15, 6,6];
    
set(gca,'XColor','k','YColor','k');
set(gca, 'FontSize', 9)

y = reshape(data.sum, 3, 5);
e = reshape(data.sum_std, 3, 5);
g = reshape(data.IHC, 3, 5);
g = g(:,1);
l = reshape(data.ANM, 3, 5);
l = l(1,:);
y2 = cellfun(@mean, y)./1000;
x = [1,2,3];
s = 'o.s<d';
for i = 1:5
    scatter(x, y2(:,i), s(i), 'k')
    hold on;
end
xlim([0.7, 3.7])
xticklabels(g)
ylabel('Sum MeCP2 bound dyes (uM)')
xlabel('Cell type marker')
box off
xtickangle(45)
errorbar([1.2,2.2,3.2], mean(y2,2), std(y2, [], 2), 'ko', ...
    'LineStyle', 'none', 'MarkerFaceColor','k')

export_fig('SumMECP2.eps', '-eps');
%% anm stats
[p,tbl22, stats] = anova2(y2');
[results, m] = multcompare(stats);
