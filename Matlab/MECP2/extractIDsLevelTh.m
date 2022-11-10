function [index_tree, ids_th, IdIndexs2, names_th,r,g] = extractIDsLevelTh(data, CCF_ids, CCF_tbl, level, th, plotFlag, CCF_tree)
%%
if nargin < 6
    plotFlag = 0;
end
if nargin < 7
    CCF_tree = getCCF_tree();

end
%% filter by level
[uIds, ~, IdIndexs] = unique( CCF_ids);
names = cell(length(uIds)-1, 1);
names_High = cell(length(uIds)-1, 1);
newIndexHigh = zeros(length(IdIndexs), 1);
for i = 2:length(uIds)
    id = uIds(i);
    index_tbl = find(CCF_tbl.ID == id);
    
    names{i-1} = CCF_tbl.Name{index_tbl};
    index_tree = find(CCF_tree.id == id);
    depth = CCF_tree.depth(index_tree);
    if depth > level
        p = split(CCF_tree.structure_id_path(index_tree), '/');
        newLabel = str2num(p{level+1});
        index_tblNew = find(CCF_tbl.ID == newLabel);
    else
        newLabel = id;
        index_tblNew = index_tbl;
    end
    names{i-1} = CCF_tbl.Name{index_tbl};
    names_High{i-1} = CCF_tbl.Name{index_tblNew};
    locations = IdIndexs == i;
    newIndexHigh(locations) = newLabel;
end
%
[uIds2, ~, IdIndexs2] = unique(newIndexHigh);
if plotFlag
    figure()
    counts = histcounts(newIndexHigh, unique(newIndexHigh));
    bar(counts)
    set(gca,'YScale','log')
    title(sprintf('Level: %d  -- Count > th: %d', level, sum(counts > th)))
end
%% filter by # cells in each group
names_th = {};
ids_th = [];
k=1;
for i = 1:length(uIds2)
    id = uIds2(i);
    if sum(IdIndexs2 == i) < th || id == 0
        continue
    end
    index_tbl = find(CCF_tbl.ID == id);
    index_tree = find(CCF_tree.id == id);
    names_th{k} = CCF_tbl.Name{index_tbl};
    ids_th(k) = i;
    k=k+1;
end

if plotFlag
    figure()
    colors = distinguishable_colors(length(ids_th), 'w');
end
res = struct();
r = [];
g = {};
for i = 1: length(ids_th)
    current = find(IdIndexs2 == ids_th(i));
    x = data.x{1}(current);
    y = data.y{1}(current);
    frac = data.fraction{1}(current);
    r = [r ;frac];
   
    if plotFlag
        scatter(y, x, 5, colors(i,:), 'filled');
        hold on
    end
    name = names_th{i};
    safename = replace(name, ' ', '_');
    safename = replace(safename, ',', '');
    safename = replace(safename, '/', '_');
    safename = replace(safename, '-', '_');
    safename = replace(safename, '(', '');
    safename = replace(safename, ')', '');
    g1 = repmat({name}, 1, length(frac));
    g = [g g1];
    res.(safename) = frac;
end
if plotFlag
    axis off
%     axis square
    figure()
    a = violinplot(res);
    for i = 1:length(a)
        a(i).ViolinColor = colors(i,:);
    end
    xticklabels(names_th)
    set(gca,'XTickLabelRotation',45)
    ylabel('Fraction Pulse');
    title(data.ANM{1})
end
end

