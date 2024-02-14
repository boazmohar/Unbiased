close all; clc;
clearvars -except tbl
tbl = compute_tbl(0);
set(groot,'defaultLegendAutoUpdate','off')
%%
cellType = 1;
large = tbl.Large == 1;
rightAP = -2;
ap = tbl.AP == rightAP;
index = large & ap;
data = tbl(index,:);
uniqueFiles = unique(data.filename);
plotFlag=0;
% all_r2 = zeros(3, 7);
% all_p = zeros(3, 7);
colors = distinguishable_colors(7, 'w');
levels = [5,7,25];
n_level = length(levels);
nAnms = 5;
nCond = nAnms*3;
i_plot = 0;
ths=[200, 90,30];
all_r2 = zeros(n_level, 10);
all_p = zeros(n_level, 10);
useCheckpoint=1;
CCF_tree = getCCF_tree('E:\MECP2\');
 [~, LabelTables] = getLabelTables('C:\Users\moharb\Dropbox (HHMI)\Projects\Unbised\CCF_tools\VisuAlign\');
 bootNum=1000;
 all_r2_boot =  zeros(n_level, 10, bootNum);
 groupSize_all =zeros(n_level, 1);
 legend_all = cell(n_level, 1);
for kk = 1:n_level
    th = ths(kk);
    level = levels(kk);
    names_all = {};
    intervals_all = zeros(nCond,1);
    frec_all = cell(nCond,1);
    std_all = cell(nCond,1);
    k=1;
    for anmIndex = 1:length(uniqueFiles)
        file = uniqueFiles{anmIndex};
        for intervalType = 1:3
            data = getOneEntryFilename(tbl,file, cellType, intervalType);
            if intervalType == 1
                [CCF_tbl, CCF_ids] = getCCF_ids(data, plotFlag, useCheckpoint, LabelTables);
                [index_tree, ids_th, IdIndexs2, names_th,r,g] = ...
                    extractIDsLevelTh(data, CCF_ids, CCF_tbl, level, th, plotFlag, CCF_tree);
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
    %% combine part 1 and 2
    names_all2 = names_all(1:end-1);
    names_all2{2} = [names_all{2} names_all{3}];
    names_all2(3:end) = names_all(4:end);
    %%
    names = mintersect(names_all2{:});
    groups = length(names);
    frec_all2 = zeros(18,groups);
    std_all2 = zeros(18,groups);
    frec_all2(:) = nan;
    std_all2(:) = nan;
    for i = 1:length(names)
        name = names{i};
        for k = 1:18
            %         [k, floor((k-1)/3)+1]
            subIndex = floor((k-1)/3)+1;
            index = strcmpi(names_all{subIndex}, name);
            if sum(index)
                frec_all2(k,i) = frec_all{k}(index);
                std_all2(k,i) = std_all{k}(index);
            end
        end
    end
    %% merge 2 parts
    frec_all3 = zeros(15,groups);
    std_all3 = zeros(15,groups);
    frec_all3(1:3, :) = frec_all2(1:3, :);
    std_all3(1:3, :) = std_all2(1:3, :);
    temp = cat(3, frec_all2(4:6, :) , frec_all2(7:9, :));
    frec_all3(4:6, :) = nanmean(temp, 3);
    temp = cat(3, std_all2(4:6, :) , std_all2(7:9, :));
    std_all3(4:6, :) = nanmean(temp, 3);
    frec_all3(7:end, :) = frec_all2(10:end, :);
    std_all3(7:end, :) = std_all2(10:end, :);
    intervals_all2 = [intervals_all(1:6) ;intervals_all(10:end)];
    IntervalPairs = [[2, 5]; [2, 8]; [2, 11]; [2,14]; 
                     [5, 8]; [5,11]; [5,14];
                     [8,11]; [8,14];
                     [11,14]];
   bootstrap_p = [];
    for p = 1:length(IntervalPairs)
        p1 = IntervalPairs(p, 1);
        p2 = IntervalPairs(p, 2);
        mdl1 = fitlm(frec_all3(p1,:),frec_all3(p2,:));
        T=anova(mdl1,'summary');
        F=table2array(T(2,4));
        pValue=table2array(T(2,5));
        all_r2(kk, p) = mdl1.Rsquared.Adjusted;
        all_p(kk, p) = pValue; 
        parfor b = 1:bootNum
            index = randi(groups, 1, groups);
            mdl1 = fitlm(frec_all3(p1,index),frec_all3(p2,:));
            all_r2_boot(kk, p, b) = mdl1.Rsquared.Adjusted;
        end
    end
   groupSize_all(kk) = groups;
end
all_r2_bootMean = squeeze(mean(all_r2_boot, 2));
%%

%%

shuffleColor = [0.7,0.7,0.7];
f=figure(1);
clf
f.Units = 'centimeters';
f.Position = [10,10,5,5];
f.Color = 'w';

violinplot(all_r2_bootMean',[], 'ViolinColor',shuffleColor , 'ShowData',false, 'ViolinAlpha',1);
hold on;
s1 = scatter([1,2,3], mean(all_r2, 2), 'k', 'fill');
errorbar([1,2,3], mean(all_r2, 2), std(all_r2, [], 2)./sqrt(10), 'ko')
% xticklabels(groupSize_all)
% ylabel('Mean r^2 across pairs')
s2 = scatter(1,1,36, shuffleColor,'fill','visible','off');
% legend([s1, s2], {'Data','Shuffle'}, 'box','off', 'Position',[0.75,0.7,0.12,0.088]);
ylim([-0.3, 0.9]);
yticks([-0.3, 0, 0.3, 0.6, 0.9]);
% yticklabels([])
% xticklabels([])
xlim([0.5, 3.3])
set(gca,'FontSize',10)
xlabel('# Regions Level')
for kk = 1:3
    text(kk, 0.9, sprintf('n=%d\nRegions',groupSize_all(kk)), 'HorizontalAlignment','center')
end
export_fig('CCF_Bootstrap.eps');