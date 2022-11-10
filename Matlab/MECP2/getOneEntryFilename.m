function entry = getOneEntryFilename(tbl,filename, cellType, intervalType)
%entry = getOneEntry(tbl, ANM, IHC, cellType, intervalType, Slide, Section)
%   any one = 0 means all conditions
index = ones(height(tbl),1, 'logical');
%%
if ~isempty(filename)
    filename_Index  = strcmpi(tbl.filename(:), filename);
    index           = index & filename_Index;
end
if cellType > 0
    Cell_Index      = tbl.cellType == cellType;
    index           = index & Cell_Index;
end
if intervalType > 0
    intType_Index   = tbl.intervalType == intervalType;
    index           = index & intType_Index;
end
%%
entry           = tbl(index,:);
end

