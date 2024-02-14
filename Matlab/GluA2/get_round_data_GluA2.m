function tbl = get_round_data_GluA2(baseDir,outputDir,round, varargin)
%%get_round_data_GluA2(baseDir,outputDir,round, varargin):
% varargin: AP_range=0:50:550, Age_num=4,px_threshold=20, use_pool=true
%   AP and age num for discretization, px_threshold for exluding small
%   regions. use_pool for using parfor, set false to debug.
p = inputParser;
addParameter(p, 'AP_range', 0:50:550, @ismatrix);
addParameter(p, 'px_threshold', 20, @isscalar);
addParameter(p, 'tree_location', 'y:\', @isstring);
addParameter(p, 'use_pool', true);

parse(p, varargin{:});
AP_range = p.Results.AP_range;
px_threshold = p.Results.px_threshold;
tree_location = p.Results.tree_location;
use_pool = p.Results.use_pool;
oldFolder = cd(baseDir);
files = dir([baseDir, '*.png']);
files = {files.name}';
overlay = contains(files,'overlay');
files = files(~overlay);
files = files(1:2:end);
nl = contains(files,'_nl');
assert(sum(nl) == 0)
if use_pool
    Tables = cellfunp(@get_table_glua2, files, 'UniformOutput', false, 'Round',round);
else
    Tables = {};
    for i = 1:numel(files)
        disp(i)
        Tables{i} = get_table_glua2(files{i}, round);
    end
end
tbl = vertcat(Tables{:});
tbl.Age = caldays(tbl.Age);
[pNew_AP, ~] =discretize(tbl.AP,AP_range);
tbl.AP2 = pNew_AP;

%% add 12 regions
CCF_tree = getCCF_tree(tree_location);
Names = {'Isocortex','OLF','HPF','CTXsp','STR','PAL','TH','HY','MB','P', ...
    'CB', 'MY', 'fiber tracts', 'VS'};
Ids = [];
full_names = {};
for i = 1:length(Names)
    name = Names{i};
    index = find(matches(CCF_tree.acronym, name));
    Ids  = [Ids CCF_tree.id(index)];
    full_names  = [full_names CCF_tree.name(index)];
end
new_names = {};
for i = 1:height(tbl)
    id = tbl.CCF_ID(i);
    if id == 0 || id == 997
        new_names = [new_names 'root'];
        continue
    end

    index = find(CCF_tree.id == id);
    list = CCF_tree.structure_id_path(index);
    list = list.split('/');
    list = str2double(list(2:end-1));
    new_id = intersect(Ids, list);
    if isempty(new_id)
        tbl.Name(i)
    end
    new_name = full_names(new_id == Ids);
    new_names = [new_names new_name];
end
tbl.new_names = new_names';
%%
valid = get_valid_index(tbl, px_threshold);
ind = zeros(1,height(tbl));
ind(valid ) = 1;
tbl.valid = ind';
%% add layers
expression = '[lL]ayer\s(\d)';
[tokens] = regexp(tbl.Name,expression,'tokens', 'once','emptymatch');
layers = [];
for i =1:length(tokens)
    c = tokens{i};
    if ~isempty(c)
        v = str2double(c);
        if v == 3
            v=2;
        end
        layers(i) = v;
    else
        layers(i) = 0;
    end
end
tbl.layer = layers';
ca1 = contains(tbl.Name, 'CA1');
tbl.layer(ca1) = 7;
ca3 = contains(tbl.Name, 'CA2');
tbl.layer(ca3) = 8;
ca3 = contains(tbl.Name, 'CA3');
tbl.layer(ca3) = 9;

%%
out_name = sprintf('%sGluA2_round_%d.parquet', outputDir ,round);
parquetwrite(out_name, tbl)
 cd(oldFolder);
end