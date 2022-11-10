%%
clear; close all; clc;
tbl = compute_tbl(0);
%%
cellType = 1;
large = tbl.Large == 1;
rightAP = -5;
ap = tbl.AP == rightAP;
index = large & ap;
round = tbl.Round == 2;
index = index & round;
data = tbl(index,:);
uniqueFiles = unique(data.filename);
nAnms = 2;
nCond = nAnms*3;
plotFlag =1;
level=3;
ths=[1700, 1000];
names_all = {};
intervals_all = zeros(nCond,1);
frec_all = cell(nCond,1);
std_all = cell(nCond,1);
k=1;
for anmIndex = 1:length(uniqueFiles)
    file = uniqueFiles{anmIndex};
    th = ths(anmIndex);
    for intervalType = 1:3
        data = getOneEntryFilename(tbl,file, cellType, intervalType);
        if intervalType == 1
            [CCF_tbl, CCF_ids] = getCCF_ids(data, plotFlag);
            [index_tree, ids_th, IdIndexs2, names_th,r,g] = ...
                extractIDsLevelTh(data, CCF_ids, CCF_tbl, level, th, plotFlag);
            names_all(anmIndex) = {names_th};
        end
        intervals_all(k) = data.interval;
        current = data.fraction{1};
        f = [];
        s = [];
        for region = 1:length(ids_th)
            index = IdIndexs2 == ids_th(region);
            f(region) = nanmedian(current(index));
            s(region) = nanstd(current(index))./sqrt(sum(index));
        end
        frec_all(k) = {f};
        std_all(k) = {s};
        k=k+1;
    end
end
%%
names = mintersect(names_all{:});
groups = length(names);
frec_all2 = zeros(6,groups);
std_all2 = zeros(6,groups);
frec_all2(:) = nan;
std_all2(:) = nan;
for i = 1:length(names)
    name = names{i};
    for k = 1:6
%         [k, floor((k-1)/3)+1]
        subIndex = floor((k-1)/3)+1;
        index = strcmpi(names_all{subIndex}, name);
        if sum(index)
            frec_all2(k,i) = frec_all{k}(index);
            std_all2(k,i) = std_all{k}(index);
        end
    end
end
%%
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
%
bootNum = 3000;
nData = 10;
decay = zeros(2, bootNum);
for i = 1:2
    i
    parfor boot = 1:bootNum
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = 200; 
        indexBoot = randi(6, 1, nData);
        [xData, yData] = prepareCurveData( intervals_all(indexBoot), frec_all2(indexBoot,i));
        res = fit( xData, yData, ft, opts );
        decay(i, boot) = coeffvalues(res);
    end
end
%%
f=figure(2);
clf
f.Color = 'w';
 f.Units = 'centimeters';
    f.Position = [5, 5, 6,6];
    
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 9)
bar(mean(decay, 2)./24, 'k')
hold on;
% l_h = prctile(decay, [5, 95], 2)./24 
% errorbar(1:6, mean(decay, 2)./24, m-l_h(:,1),l_h(:,2)-m, 'color',[0.5, 0.5, 0.5],'LineStyle','none','LineWidth',1.5)
errorbar(1:2, mean(decay, 2)./24, std(decay, [],2)./12, 'color',[0.5, 0.5, 0.5],'LineStyle','none','LineWidth',1.5)
xticks(1:2)
xticklabels( names)
ylabel('MeCP2 \tau (d)')
xlabel('Brain region')
box off
xtickangle(45)
ylim([8,15])
export_fig('BrainRegionsMECP2.eps', '-eps');

%%
f=figure(555);
clf
f.Color = 'w';
violinplot(decay')
xticks(1:6)
xticklabels( names)
ylabel('MeCP2 \tau')
xlabel('Brain region')
box off
xtickangle(45)
% ylim([150,350])

%%

f=figure(55);
clf
f.Color='w';
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 100; 
%
legText = {};
a1 = axes();
 colors = distinguishable_colors(groups, 'w');
 ci_all = [];
 res_all = [];
 
for x = 1:groups
    [xData, yData] = prepareCurveData( intervals_all2, frec_all3(:,x) );
    [res, gof] = fit( xData, yData, ft, opts );
    if plotFlag
        a1(x) = errorbar(intervals_all2,frec_all3(:,x), std_all3(:,x), 'o', 'MarkerFaceColor', colors(x,:),...
            'MarkerEdgeColor', colors(x,:));
        hold on
         b = plot(res);
        b.Color = colors(x,:);
    end
    ci = confint(res);
    ci_all = [ci_all ci];
    res_all = [res_all coeffvalues(res)];
    t = sprintf('%.0f [%.0f-%.0f]',coeffvalues(res),ci(1),ci(2));
    legText(x) = {[names_th{x} ': $\tau$=' t]};
end
if plotFlag
    legend(a1,legText, 'box','off', 'Interpreter', 'latex')
    ylim([0, 1])
    ylabel('Fraction pulse')
    xlabel('Time (h)')
    box off
end
%%
figure(666)
clf
f.Color = 'w';
bar(res_all)
hold on;
errorbar(1:groups, res_all, res_all-ci_all(1,:), (res_all-ci_all(2,:))*-1, 'LineStyle','none')
xticks(1:groups)
xticklabels( names)
xtickangle(45)
ylim([200 400])