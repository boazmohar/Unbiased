%%
clear; close all; clc;
tbl = compute_tbl(0);
%%
cellType = 1;
large = tbl.Large == 1;
rightAP = -2;
ap = tbl.AP == rightAP;
index = large & ap;
data = tbl(index,:);
uniqueFiles = unique(data.filename);
nAnms = 5;
nCond = nAnms*3;
plotFlag =0;
level=5;
ths=[80, 80, 80, 80, 80, 80];
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
%% merge 2 parts change to weighted mean!
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
%%
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
%
bootNum = 3000;
nData = 15;
decay = zeros(6, bootNum);
for i = 1:6
    i
    parfor boot = 1:bootNum
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = 200; 
        indexBoot = randi(15, 1, nData);
        [xData, yData] = prepareCurveData( intervals_all2(indexBoot), frec_all3(indexBoot,i));
        res = fit( xData, yData, ft, opts );
        decay(i, boot) = coeffvalues(res);
    end
end
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
names2 = mintersect(names_all{:});
groups2 = length(names2);
frec_all2 = zeros(6,groups2);
std_all2 = zeros(6,groups2);
frec_all2(:) = nan;
std_all2(:) = nan;
for i = 1:length(names2)
    name = names2{i};
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
decay2 = zeros(2, bootNum);
for i = 1:2
    i
    parfor boot = 1:bootNum
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = 200; 
        indexBoot = randi(6, 1, nData);
        [xData, yData] = prepareCurveData( intervals_all(indexBoot), frec_all2(indexBoot,i));
        res = fit( xData, yData, ft, opts );
        decay2(i, boot) = coeffvalues(res);
    end
end
%%
names_all = [names names2];
decay_all = [decay ;decay2];
%%
f=figure(2);
clf
f.Color = 'w';
 f.Units = 'centimeters';
    f.Position = [5, 5, 8,6];
    
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 9)
bar(mean(decay_all, 2)./24, 'k')
hold on;
l_h = prctile(decay_all, [5, 95], 2)./24 ;
m = mean(decay_all, 2)./24;
errorbar(1:8, m, m-l_h(:,1),l_h(:,2)-m, 'color',[0.5, 0.5, 0.5],'LineStyle','none','LineWidth',1.5)
% errorbar(1:8, mean(decay_all, 2)./24, std(decay_all, [],2)./12, 'color',[0.5, 0.5, 0.5],'LineStyle','none','LineWidth',1.5)
xticks(1:8)
xticklabels( names_all)
ylabel('MeCP2 \tau (d)')
xlabel('Brain region')
box off
xtickangle(45)
ylim([5,20])
% export_fig('BrainRegionsMECP2_2.eps', '-eps');
%%
all_res = '';
for i = 1:8
    all_res =   [all_res  sprintf('%s: %.1f [%.1f,%.1f]', names_all{i},    m(i), l_h(i,1), l_h(i,2)) '; '];
end
all_res