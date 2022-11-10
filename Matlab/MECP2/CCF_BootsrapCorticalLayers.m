% function [outputArg1,outputArg2] = CCF_regions_bootstrap1(inputArg1,inputArg2)
close all; clear; clc;
tbl = compute_tbl(0);
%%
cellType = 1;
large = tbl.Large == 1;
rightAP = -2;
ap = tbl.AP == rightAP;
index = large & ap;
data = tbl(index,:);
uniqueFiles = unique(data.filename);
plotFlag =0;
names_all = {};
intervals_all = zeros(18,1);
frec_all = zeros(18,6);
numel_all = zeros(18,6);
k=1;
for anmIndex = 1:length(uniqueFiles)
    file = uniqueFiles{anmIndex};
    for intervalType = 1:3
        data = getOneEntryFilename(tbl,file, cellType, intervalType);
        if intervalType == 1
            [CCF_tbl, CCF_ids] = getCCF_ids(data, plotFlag);
        end
        [newIds,fraction_all,group_all, result_struct, names] = ...
            extractIDsCorticalLayers(data, CCF_ids, CCF_tbl, plotFlag);
        names_all(anmIndex) = {names};
        intervals_all(k) = data.interval;
        [group_allSortes, sortIndex] = sort(group_all);
        numel_all(k, : )= grpstats(fraction_all(sortIndex),group_allSortes', 'numel');
        frec_all(k, :) = grpstats(fraction_all(sortIndex),group_allSortes', {@median});
        k=k+1;
    end
end
%% merge 2 parts

frec_all2 = zeros(15,6);
frec_all2(1:3, :) = frec_all(1:3, :);
temp = cat(3, frec_all(4:6, :) , frec_all(7:9, :));
temp2 = cat(3, numel_all(4:6, :) , numel_all(7:9, :));
s = sum(temp2, 3);
frec_all2(4:6, :) = mean(temp .* temp2, 3) ./ s(1,:);
frec_all2(7:end, :) = frec_all(10:end, :);
intervals_all2 = [intervals_all(1:6) ;intervals_all(10:end)];

%%
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
%
bootNum = 1000;
nData = 15;
decay = zeros(6, bootNum);
ci = zeros(6, bootNum, 2);
for i = 1:6
    parfor boot = 1:bootNum
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = 200; 
        indexBoot = randi(15, 1, nData);
        [xData, yData] = prepareCurveData( intervals_all2(indexBoot), frec_all2(indexBoot,i));
        res = fit( xData, yData, ft, opts );
         t = coeffvalues(res);
        decay(i, boot) = t(1);
        ci(i, boot, :) = confint(res);
    end
end

%%
f=figure(1);
clf
f.Color = 'w';
 f.Units = 'centimeters';
    f.Position = [5, 5, 6,6];
    
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 9)
bar(mean(decay, 2)./24, 'k')
hold on;
 ciMean = squeeze(mean(ci, 2)./24);
m =  mean(decay, 2)./24;
% l_h = prctile(decay, [5, 95], 2)./24 - m
errorbar(1:6, mean(decay, 2)./24, std(decay, [],2)./12, 'color',[0.5, 0.5, 0.5],'LineStyle','none','LineWidth',1.5)
% errorbar(1:6, mean(decay, 2)./24, l_h(:,1),l_h(:,2), 'color',[0.5, 0.5, 0.5],'LineStyle','none','LineWidth',1.5)

xticks(1:6)
xticklabels( {'L1', 'L2/3','L4','L5','L6a','L6b'})
ylabel('MeCP2 \tau (d)')
xlabel('Cortical layer')
box off
xtickangle(45)
% ylim([8,16])
yticks([8,10,12,14, 16])
% export_fig('CorticalLayersMECP2.eps', '-eps');
%%
f=figure(555);
clf
f.Color = 'w';
violinplot(decay')
xticks(1:6)
xticklabels( {'L1', 'L2/3','L4','L5','L6a','L6b'})
ylabel('MeCP2 \tau')
xlabel('Cortical layer')
box off
% xtickangle(45)
% ylim([150,350])
%%
[p,~,stats] =anova1(decay');
[c,m,h,gnames]  = multcompare(stats);