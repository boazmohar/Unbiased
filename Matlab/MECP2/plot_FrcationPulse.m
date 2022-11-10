function [f, res] = plot_FrcationPulse(tbl, celltype, intervalType)
%f = plot_FrcationPulse(tbl, celltype)
%   Detailed explanation goes here
%%
if nargin <2
    celltype=1;
end
if nargin <3
    intervalType=0;
end
titles = {'IHC Positive', 'Merged','IHC Negative','Split'};
f=figure(celltype);
clf
f.Color = 'w';
NeuN = strcmp(tbl.IHC, 'NeuN') & tbl.cellType == celltype;
SOX10 = strcmp(tbl.IHC, 'SOX10') & tbl.cellType == celltype;
Iba1 = strcmp(tbl.IHC, 'Iba1') & tbl.cellType == celltype;
if intervalType > 0
    NeuN = NeuN & tbl.intervalType == intervalType;
    SOX10 = SOX10 & tbl.intervalType == intervalType;
    Iba1 = Iba1 & tbl.intervalType == intervalType;
end
[res1,gof1,ci1,legText1] = fitOne_FractionPulse(tbl, NeuN, 'or', 'NeuN');
hold on
[res2,gof2,ci2,legText2] = fitOne_FractionPulse(tbl, SOX10, '*b', 'SOX10');
[res3,gof3,ci3,legText3] = fitOne_FractionPulse(tbl, Iba1, '^g', 'Iba1');
box off;
legend({legText1, legText2, legText3}, 'box','off', 'Interpreter', 'latex')
ylim([0,1.1])
ylabel('Fraction Pulse');
xlabel('Time (h)');
set(findall(gcf,'-property','FontSize'),'FontSize',12)
title(titles{celltype},'fontsize',16)
%%
res = struct();
res.res1 = res1;
res.res2 = res2;
res.res3 = res3;
res.gof1 = gof1;
res.gof2 = gof2;
res.gof3 = gof3;
res.ci1 = ci1;
res.ci2 = ci2;
res.ci3 = ci3;
end

