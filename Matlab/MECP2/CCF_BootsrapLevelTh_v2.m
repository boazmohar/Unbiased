% function [outputArg1,outputArg2] = CCF_regions_bootstrap1(inputArg1,inputArg2)
close all
ANMs = { '473364',  '473365',  '473366'};
Slide = 1;
Section = 4;
IHC = 'NeuN';
cellType = 1;
plotFlag =1;
level=6;
ths=[80, 80, 80];
names_all = {};
intervals_all = zeros(9,1);
frec_all = cell(9,1);
std_all = cell(9,1);
k=1;
for anmIndex = 1:3
    ANM = ANMs{anmIndex};
    th = ths(anmIndex);
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
%%
 ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
%
names = mintersect(names_all{:})'
groups = length(names);
frec_all2 = zeros(9,groups);
bootNum = 1000;
nData = 18;
decay = zeros(groups, bootNum);
for i = 1:length(names)
    i
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
    end
    parfor boot = 1:bootNum
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = 200; 
        indexBoot = randi(9, 1, nData);
        [xData, yData] = prepareCurveData( intervals_all(indexBoot), frec_all2(indexBoot,i));
        res = fit( xData, yData, ft, opts );
        decay(i, boot) = coeffvalues(res);
    end
end

%
f=figure(666);
clf
f.Color = 'w';
bar(mean(decay, 2))
hold on;
errorbar(1:groups, mean(decay, 2), std(decay, [],2), 'k','LineStyle','none','LineWidth',3)
xticks(1:groups)
xticklabels( names)
xtickangle(45)
ylim([150,350])
%%
[p,~,stats] =anova1(decay');
[c,m,h,gnames]  = multcompare(stats);