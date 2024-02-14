function [tbl_out] = pairwise_compare(tbl, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;
addParameter(p, 'n_boot', 300, @isscalar);
addParameter(p, 'threshold_entries', 4, @isscalar);
addParameter(p, 'name1', 'rule');
addParameter(p, 'name2', 'random');
addParameter(p, 'show_prog', true, @isboolean);
addParameter(p, 'groupName', 'groupName', @isstring);
addParameter(p, 'is_string', true);

parse(p, varargin{:});
n_boot = p.Results.n_boot;
threshold_entries = p.Results.threshold_entries;
name1 = p.Results.name1;
name2 = p.Results.name2;
show_prog = p.Results.show_prog;
groupName = p.Results.groupName;
is_string = p.Results.is_string;

[group, id] = findgroups(tbl(:,'CCF_ID'));
p_all = [];
ratios = [];
names_all= {};
layers_all= [];
new_names_all= {};
ids_all = [];
index_all = {};

sd_all = [];
means_all = [];
sum_all = [];
pulse_all = [];
sum_sd_all =[];
for i = 1:height(id)

    if ~mod(i,10) && show_prog
        disp(i./height(id))
    end
    index = group==i;
    current = tbl(group==i,:);
    if length(unique(current.ANM)) < threshold_entries
        continue
    end

    tau_true = [];
    tau_false = [];
    if is_string
        for kk=1:length(name1)
            n1 = name1(kk);
            tau_true = [tau_true current.tau(strcmp(current{:,groupName},n1 ))];

        end
        for kk=1:length(name2)
            n2 = name2(kk);
            tau_false = [tau_false current.tau(strcmp(current{:,groupName},n2))];
        end
    else
        for kk=1:length(name1)
            n1 = name1(kk);
            tau_true = [tau_true current.tau(current{:,groupName} == n1 )];
        end
        for kk=1:length(name2)
            n2 = name2(kk);
            tau_false = [tau_false current.tau(current{:,groupName} == n2)];
        end
    end
    if isempty(tau_true) || isempty(tau_false)
        continue
    end
    n_select =height(current);
    boot_index = randi(n_select, n_select, n_boot);
    boot_val = current.tau(boot_index);
    means_all = [means_all mean(boot_val, [1,2])];
    

    n_select =length(tau_true);
    boot_index = randi(n_select, n_select, n_boot);
    boot_val = tau_true(boot_index);
    means_true = mean(boot_val, 1);

    n_select = length(tau_false);
    boot_index = randi(n_select, n_select, n_boot);
    boot_val = tau_false(boot_index);
    means_false = mean(boot_val, 1);
    ratios2 = means_false./means_true;
    [~,p] = ttest(ratios2-1);

    p_all = [p_all p];
    ratios = [ratios  mean(ratios2)];
    sd_all = [sd_all std(ratios2)];
    names_all = [names_all  current.Name(1)];
    layers_all = [layers_all  current.layer(1)];
    new_names_all = [new_names_all  current.new_names(1)];
    ids_all = [ids_all  current.CCF_ID(1)];
    index_all = [index_all {find(index)}];
    sum_all = [sum_all mean(current.P_Mean + current.C_Mean, 'omitnan')];
    sum_sd_all = [sum_sd_all std(current.P_Mean + current.C_Mean, 'omitnan')];
    pulse_all = [pulse_all mean(current.P_Mean, 'omitnan')];
end
tbl_out = table;
tbl_out.ratio = ratios';
tbl_out.p = p_all';
tbl_out.name = names_all';
tbl_out.layer = layers_all';
tbl_out.new_names = new_names_all';
tbl_out.index = index_all';
tbl_out.mean = means_all';
tbl_out.sum = sum_all';
tbl_out.pulse = pulse_all';
tbl_out.id = ids_all';
tbl_out.sd = sd_all';
tbl_out.sum_sdd = sum_sd_all';
tbl_out = sortrows(tbl_out,'ratio','descend');
end