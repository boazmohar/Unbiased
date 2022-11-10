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
    % 1
    mdl1 = fitlm(frec_all2(Interval,:),frec_all2(Interval+3,:));
    T=anova(mdl1,'summary');
    F=table2array(T(2,4));
    pValue=table2array(T(2,5));
    all_r2(kk, 1) = mdl1.Rsquared.Adjusted;
    all_p(kk, 1) = pValue;
    
    %2
    mdl2 = fitlm(frec_all2(Interval,:),frec_all2(Interval+6,:));
    T=anova(mdl2,'summary');
    F=table2array(T(2,4));
    pValue=table2array(T(2,5));
    all_r2(kk, 2) = mdl2.Rsquared.Adjusted;
    all_p(kk, 2) = pValue;
    
    mdl3 = fitlm(frec_all2(Interval+3,:),frec_all2(Interval+6,:));
    T=anova(mdl3,'summary');
    F=table2array(T(2,4));
    pValue=table2array(T(2,5));
    all_r2(kk, 3) = mdl3.Rsquared.Adjusted;
    all_p(kk, 3) = pValue;
    %% plot
    Xnew = 0.58:0.02:0.78;
    colors = distinguishable_colors(length(names), 'w');
    subplot(1,n_level,kk)
    gscatter(frec_all2(Interval,:), frec_all2(Interval+3,:), names, colors, 'x', 5, false)
    hold on;
    ypred = predict(mdl1,Xnew');
    plot(Xnew', ypred, 'k:x')
    gscatter(frec_all2(Interval,:), frec_all2(Interval+6,:), names, colors, 'o', 5, false)
    ypred = predict(mdl2,Xnew');
    plot(Xnew', ypred, 'k:o')
    gscatter(frec_all2(Interval+3,:), frec_all2(Interval+6,:), names, colors, 'd', 5, false)
    ypred = predict(mdl3,Xnew');
    plot(Xnew', ypred, 'k:d')
    axis square
    xlabel('Fraction pulse ANM x')
    ylabel('Fraction pulse ANM y')
    title(sprintf('Mean R^2=%.2f', mean(all_r2(kk,:))))
    ylim([0.58,0.78])
    xlim([0.58,0.78])
end
