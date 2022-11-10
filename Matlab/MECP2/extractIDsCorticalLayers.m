function [newIds,fraction_all,group_all, result_struct, names] = extractIDsCorticalLayers(data, CCF_ids,CCF_tbl, plotFlag)
%[newIds,fraction_all,group_all, result_struct] = extractIDsCorticalLayers(data, CCF_ids, plotFlag)
%   Detailed explanation goes here

%% find cortical layer indexes
CCF_tree = getCCF_tree();
layerIdx = ~cellfun(@isempty, strfind(CCF_tree.name, 'layer'));
cortexIdx = ~cellfun(@isempty, strfind(CCF_tree.structure_id_path, '315'));
corticalLayersIndex = layerIdx & cortexIdx;
corticalLayersIds = CCF_tree.id(corticalLayersIndex);
% corticalLayersNames = CCF_tree.name(corticalLayersIndex);
uIds = unique( CCF_ids);
newIds = intersect(uIds, corticalLayersIds);
if newIds(1) == 0
    newIds = newIds(2:end);
end
[~,loc] = ismember(newIds,CCF_tree.id);
names = CCF_tbl.Name(loc);


%%
if plotFlag
    f = figure();
    f.Color = 'w';
    colors = distinguishable_colors(length(newIds), 'w');
end
result_struct = struct();
fraction_all = [];
group_all = {};
for i = 1: length(newIds)
    current = find(CCF_ids == newIds(i));
    x = data.x{1}(current);
    y = data.y{1}(current);
    frac = data.fraction{1}(current);
    fraction_all = [fraction_all ;frac];
    
    if plotFlag
        scatter(y, x, 5, colors(i,:), 'filled');
        hold on
    end
    name = names{i};
    safename = replace(name, ' ', '_');
    safename = replace(safename, ',', '');
    safename = replace(safename, '/', '_');
    safename = replace(safename, '-', '_');
    nameL = split(name, ' ');
    g1 = repmat(nameL(end), 1, length(frac));
    group_all = [group_all g1];
    result_struct.(safename) = frac;
end
if plotFlag
    axis off
    axis square
    figure()
    a = violinplot(result_struct);
    for i = 1:length(a)
        a(i).ViolinColor = colors(i,:);
    end
    xticklabels(names)
    set(gca,'XTickLabelRotation',45)
    [p,~,stats] =anova1(fraction_all, group_all');
    [c,m,h,gnames]  = multcompare(stats);
    %%
    f=figure(1);
    clf;
    f.Position = [680   558   338   420];
    [sortNames, ii] = sort(gnames);
    f.Color = 'w';
    bar([1,2,3,4,5,6],m(ii,1))
    hold on
    errorbar([1,2,3,4,5,6],m(ii,1),m(ii,2), 'k', 'linewidth',2','linestyle','none')
    box off
    xticklabels(sortNames)
    ylabel('Fraction pulse')
    ylim([0.6, 0.65])
    xlabel('Cortical layer')
    
end
end
