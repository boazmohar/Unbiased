function entry = getOneEntry(tbl, ANM, IHC, cellType, intervalType, Slide, Section, AP, Large)
%entry = getOneEntry(tbl, ANM, IHC, cellType, intervalType, Slide, Section)
%   any one = 0 means all conditions
%%
if nargin < 6
    Slide = 0;
end
if nargin < 7
    Section = 0;
end
if nargin < 8
    AP = nan;
end
if nargin < 9
    Large = nan;
end
%%
index = ones(height(tbl),1, 'logical');
if ANM > 0
    ANM_Index       = strcmpi(tbl.ANM(:), ANM);
    index           = index & ANM_Index;
end
%%
if IHC > 0
    IHC_Index       = strcmpi(tbl.IHC(:), IHC);
    index           = index & IHC_Index;
end
%%
if cellType > 0
    Cell_Index      = tbl.cellType == cellType;
    index           = index & Cell_Index;
end
%%
if intervalType > 0
    intType_Index   = tbl.intervalType == intervalType;
    index           = index & intType_Index;
end
%%
if Slide > 0
    Slide_Index   = tbl.Slide == Slide;
    index           = index & Slide_Index;
end
%%
if Section > 0
    Section_Index   = tbl.Section == Section;
    index           = index & Section_Index;
end
%%
if ~isnan(AP)
    AP_Index   = tbl.AP == AP;
    index           = index & AP_Index;
end
%%
if ~isnan(Large)
    Large_Index   = tbl.Large == Large;
    index           = index & Large_Index;
end
%%
entry           = tbl(index,:);
end

