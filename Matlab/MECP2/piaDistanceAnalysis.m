% function calcBinnedPiaDist(tbl)
clear
tbl = load_tbl();
%% get the 15 datasets (ANM x IHC)
ANM = 0;
IHC = 0;
cellType = 1;
intervalType = 0;
data = getOneEntry(tbl, ANM, IHC, cellType, intervalType)

%%
edges = linspace(0,1800,9);
binNumber = length(edges)-1;
mean_all = zeros(height(data), binNumber);
mean_all(:) = nan;
se_all = zeros(height(data), binNumber);
se_all(:) = nan;
valid_ones = zeros(1,binNumber, 'logical');
for i = 1:height(data)
    dist = data.dist{i}*0.25;
    fraction = data.fraction{i};
    fraction = fraction- mean(fraction, 'all');
    [Y,E] = discretize(dist, edges);
    valid = valid_ones;
    u = unique(Y);
    u = u(~isnan(u));
    valid(u) = 1;
    %     m_dist = grpstats(dist, Y, 'mean');
    mean_all(i,valid) = grpstats(fraction, Y, 'mean');
    se_all(i,valid) = grpstats(fraction, Y, 'sem');
    
end
%%
IHCs = unique(tbl.IHC);
x = (E(1:end-1) + E(2:end))./2;
colors = ['-or','-sb','-^g'];
f= figure(1);
clf
f.Color='w';
f.Position = [560   311   426   637];
for i = 1:3
    subplot(3,1,i)
    index = strcmpi(data.IHC, IHCs{i});
    current = mean_all(index,:);
    current = (current+1)*100;
    errorbar(x, nanmean(current, 1), nanstd(current, [], 1)./sqrt(size(current,1)), colors(i))
    ylim([98, 102]);
%     xlim([0, 2000])
    title(IHCs{i})
    [p,~,stats] = anova1(current, [],'off');
    if p < 0.05
        c = multcompare(stats, 'Display','off');
        hold on;
        c2 = c(c(:, 1) ==1 , end);
        c_i = find(c2 < 0.05)+1;
        y_ = ones(1, length(c_i))*101.5;
        plot(x(c_i), y_, '*k')
    end
    box off
    if i == 3
        xlabel('Distance from pia (um)')
    else
        xticklabels([]);
    end
    ylabel('%  mean fraction pulse')
end
% export_fig('Distance_All.png');