% function [outputArg1,outputArg2] = CCF_regions_bootstrap1(inputArg1,inputArg2)
close all
ANMs = { '473364',  '473365',  '473366'};
Slide = 1;
Section = 4;
IHC = 'NeuN';
cellType = 1;
plotFlag =1;
level=7;
ths=[80, 80, 80];
names_all = {};
intervals_all = zeros(9,1);
frec_all = cell(9,1);
std_all = cell(9,1);
k=1;
bootNum = 100;
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
        f = zeros(length(ids_th), bootNum);
        for region = 1:length(ids_th)
            index = find(IdIndexs2 == ids_th(region));
            l = floor(length(index)./2);
            for boot = 1:bootNum
                f(region, boot) = mean(current(datasample(index,l)));
            end
        end
        frec_all(k) = {f};
        k=k+1;
    end
end
%%
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 200; 
%
names = mintersect(names_all{:});
groups = length(names);
frec_all2 = zeros(9,groups, bootNum);
decay = zeros(groups, bootNum);
for boot = 1:bootNum
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
            
            frec_all2(k,i, boot) = frec_all{k}(index, boot);
        end
        [xData, yData] = prepareCurveData( intervals_all, frec_all2(:,i, boot) );
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
ylim([150,300])
%%
anova1(decay')
[p,~,stats] =anova1(decay');
[c,m,h,gnames]  = multcompare(stats);