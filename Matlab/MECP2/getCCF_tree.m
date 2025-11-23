function CCF_tree = getCCF_tree(directory)
% function CCF_tree = getCCF_tree()
% from https://github.com/cortex-lab/allenCCF
if nargin < 1
    directory = 'E:\Unbiased\MECP2\';
end
filename = 'structure_tree_safe_2017.csv';
opts = delimitedTextImportOptions("NumVariables", 21);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["id", "atlas_id", "name", "acronym", "st_level", "ontology_id", "hemisphere_id", "weight",...
    "parent_structure_id", "depth", "graph_id", "graph_order", "structure_id_path", "color_hex_triplet",...
    "neuro_name_structure_id", "neuro_name_structure_id_path", "failed", "sphinx_id", "structure_name_facet", ...
    "failed_facet", "safe_name"];
opts.VariableTypes = ["double", "double", "string", "string", "string", "double", "double", "double", "double", ...
    "double", "double", "double", "string", "double", "string", "string", "categorical", "double", "double", ...
    "double", "string"];
opts = setvaropts(opts, [3, 4, 5, 13, 15, 16, 21], "WhitespaceRule", "preserve");
opts = setvaropts(opts, 14, "TrimNonNumeric", true);
opts = setvaropts(opts, 14, "ThousandsSeparator", ",");
opts = setvaropts(opts, [3, 4, 5, 13, 15, 16, 17, 21], "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
CCF_tree = readtable([directory filename], opts);
end