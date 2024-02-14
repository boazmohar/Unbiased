function tables_all = group_compare_shuffle(tbl, varargin)
%n_boot=3000,threshold_entries=4, colName=groupName, subsample='uniform'
%   subsample can be 

p = inputParser;
addParameter(p, 'n_boot', 3000, @isscalar);
addParameter(p, 'threshold_entries', 4, @isscalar);
addParameter(p, 'colName', "groupName");
addParameter(p, 'show_prog', true, @isboolean);
addParameter(p, 'subsample', 'uniform', @isstring);

parse(p, varargin{:});
n_boot = p.Results.n_boot;
threshold_entries = p.Results.threshold_entries;
colName = p.Results.colName;
show_prog = p.Results.show_prog;
subsample = p.Results.subsample;
[group, id] = findgroups(tbl(:,'CCF_ID'));

tables_all ={};
for i = 1:height(id)

    if ~mod(i,10) && show_prog
        disp(i./height(id)*100);
    end
    current = tbl(group==i,:);
    if length(unique(current.groupName)) < threshold_entries
        disp('skip')
        i
        continue
    end
    
    values = [];
    groups = {};
    anm = {};
    max_vals = 1000;
    for row = 1:height(current)
        vals = current{row,'tau_values'}{1};
        g = {current{row,colName}};
        a = {current{row,'ANM'}};
        n = numel(vals);
        if n > max_vals
            vals = vals(1:max_vals);
            n = max_vals;
        end
        values = [values ; vals];
        groups = [groups ; repmat(g,n,1)];
        anm = [anm ; repmat(a,n,1)];

    end
%     length_total = length(groups);
%     n_values = 10000;
%     if strcmpi(subsample, 'uniform')
%         index1 = 1:floor(length_total / n_values):length_total;
%     elseif strcmpi(subsample, 'random')
%         index1 = randi(length_total, 1, n_values);
%     elseif strcmpi(subsample, 'first')
%         max_i = min(n_values, length_total);
%         index1 = 1:max_i;
%     end
%     tau_sub = values(index1);
%     group_sub = string(groups(index1));
%     anm_sub = string(anm(index1));
    t = table;
    t.tau = double(values);
    try
    t.group = reordercats(categorical( string(groups)), ...
        {'control','rule','random','EE'});
    catch
        continue
    end
    t.anm = categorical(string(anm));
    lme = fitlme(t, 'tau ~ 1 + group + (1|anm)');
    p_all = lme.Coefficients;
    out = current(1,{'AP','Slice','Name','CCF_ID','AP2','new_names','layer'});
    out.p = {p_all};
    tables_all = [tables_all ; out];
end
end