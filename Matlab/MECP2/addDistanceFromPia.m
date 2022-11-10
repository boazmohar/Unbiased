function tbl = addDistanceFromPia(tbl)
[C,~,ic] = unique(tbl.filename);
for i = 1:length(C)
    index = find(ic == i);
    data = tbl(index, :);
    [l,dist] = getDistanceFromPia(data);
    tbl.piaLine(index) = l;
    tbl.dist(index) = dist;
    close all;
    clc
    
end