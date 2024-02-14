function tbl_all = load_data_glua2(varargin)
%% tbl_all = load_data_glua2(varargin) outpath = 'D:\', rounds = 'all',
%negative = true, append_CA1 = True
% 
if nargin < 1
    out_path = 'D:\';
else
    out_path = varargin{1};
end
if nargin < 2 || strcmpi(varargin{2}, 'all')
    rounds = 1:6;
else
    rounds = varargin{2};
end
if nargin < 3 
    negative = true;
else
    negative = varargin{3};
end
if nargin < 4
    append_CA1 = true;
else
    append_CA1 = varargin{4};
end
if negative
    temp = load("negative_control_bad_regions.mat", 'tbl_regect');
    tbl_regect = temp.tbl_regect;
end
all_tables = {};

for i = 1:length(rounds)
    tic
    % read valid rows only (over Thrshold for # pixels + not NaN):
    name =[out_path sprintf('GluA2_round_%d.parquet', rounds(i))];
    fprintf('loading: %s, Negative: %s, HC: %s\n', name, negative, append_CA1)
    rf = rowfilter("valid");
    info = parquetinfo(name);
    rf2 = rf.valid == 1;
    tbl = parquetread(name, "OutputType","table", RowFilter=rf2,SelectedVariableNames=info.VariableNames );
    if negative
        c = ~ismember(tbl.CCF_ID, tbl_regect.id);
        tbl = tbl(c,:);
    end
    if append_CA1
        name_hc =[sprintf('CA1_tbl_round%d.mat', rounds(i))];
        hc = load(name_hc);
        tbl = vertcat(tbl, hc.tbl_hc);
    end
    all_tables(i) = {tbl};
    toc
end
tbl_all= vertcat(all_tables{:});
end