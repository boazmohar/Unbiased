% function [outputArg1,outputArg2] = CCF_regions_bootstrap1(inputArg1,inputArg2)
close all; clear; clc;
tbl = compute_tbl(0);
set(groot,'defaultLegendAutoUpdate','off')
%%
ANMs = { '473364',  '473365',  '473366'};
Slide = 1;
Section = 4;
IHC = 'NeuN';
cellType = 1;
plotFlag =0;
% all_r2 = zeros(3, 7);
% all_p = zeros(3, 7);
colors = distinguishable_colors(7, 'w');
kk = 1;
figure(1)
clf
levels = [5,7,25];
n_level = length(levels);
i_plot = 0;
ths=[90, 60, 30];
for kk = 1:n_level
    th = ths(kk);
    level = levels(kk);
    names_all = {};
    intervals_all = zeros(9,1);
    frec_all = cell(9,1);
    std_all = cell(9,1);
    k=1;
    for anmIndex = 1:3
        ANM = ANMs{anmIndex};
        
        for intervalType = 1:3
            data = getOneEntry(tbl, ANM, IHC, cellType, intervalType, Slide, Section);
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
    %
    names = mintersect(names_all{:})';
    groups = length(names);
    frec_all2 = zeros(9,groups);
    std_all2 = zeros(9,groups);
    for i = 1:length(names)
        name = names{i};
        for k = 1:9
            if k < 4
                index = strcmpi(names_all{1}, name);
            elseif k < 7
                
                index = strcmpi(names_all{2}, name);
            else
                
                index = strcmpi(names_all{3}, name);
            end
            frec_all2(k,i) = frec_all{k}(index);
            std_all2(k,i) = std_all{k}(index);
        end
    end
    Interval = 2;
    colors = distinguishable_colors(length(names), 'w');
    i_plot=i_plot+1;
    subplot(n_level,1,i_plot)
    gscatter(frec_all2(Interval,:), frec_all2(Interval+3,:), names, colors, 'x', 5)
    hold on;
    gscatter(frec_all2(Interval,:), frec_all2(Interval+6,:), names, colors, 'o', 5, false)
    gscatter(frec_all2(Interval+3,:), frec_all2(Interval+6,:), names, colors, 'd', 5, false)
    x = [frec_all2(Interval,:), frec_all2(Interval,:), frec_all2(Interval+3,:)];
    y = [frec_all2(Interval+3,:), frec_all2(Interval+6,:), frec_all2(Interval+6,:)];
    mdl = fitlm(x,y);
    T=anova(mdl,'summary');
    F=table2array(T(2,4));
    pValue=table2array(T(2,5));
    hold on;
    axis square
    xlabel('Fraction pulse ANM65')
    ylabel('Fraction pulse ANM66')
    all_r2(kk, 3) = mdl.Rsquared.Adjusted;
    all_p(kk, 3) = pValue;
    title(sprintf('R^2=%.2f, p=%2.0e', mdl.Rsquared.Adjusted,pValue))
    ylim([0.58,0.74])
    xlim([0.58,0.74])
    kk=kk+1;
end
%%
figure()
for i = 1:5
subplot(1,5,i)
bar(all_r2(i+4, :))
end
%%
f=figure(666);
clf
f.Color = 'w';
subplot(1,3,1)
%%
[p,~,stats] =anova1(decay');
[c,m,h,gnames]  = multcompare(stats);