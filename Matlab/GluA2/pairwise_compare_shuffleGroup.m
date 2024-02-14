function [tbl_out] = pairwise_compare_shuffleGroup(tbl, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;
addParameter(p, 'n_boot', 3000, @isscalar);
addParameter(p, 'threshold_entries', 4, @isscalar);
addParameter(p, 'name1', "rule");
addParameter(p, 'name2', "random");
addParameter(p, 'show_prog', true);
addParameter(p, 'groupName', 'groupName', @isstring);
addParameter(p, 'is_string', true);
addParameter(p, 'subsample', 'uniform', @isstring);

parse(p, varargin{:});
n_boot = p.Results.n_boot;
threshold_entries = p.Results.threshold_entries;
name1 = p.Results.name1;
name2 = p.Results.name2;
show_prog = p.Results.show_prog;
groupName = p.Results.groupName;
is_string = p.Results.is_string;
subsample = p.Results.subsample;

[group, id] = findgroups(tbl(:,'CCF_ID'));
p_all = [];
ratios_all = [];
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
        disp(i./height(id)*100);
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
            index = strcmp(current{:,groupName},n1 );
            vals = current.tau_values(index);
            tau_true = [tau_true cat(1,vals{:})];

        end
        for kk=1:length(name2)
            n2 = name2(kk);
            vals = current.tau_values(strcmp(current{:,groupName},n2));
            tau_false = [tau_false cat(1,vals{:})];
        end
    else
        for kk=1:length(name1)
            n1 = name1(kk);
            vals = current.tau_values(current{:,groupName} == n1);
            tau_true = [tau_true cat(1,vals{:})];
        end
        for kk=1:length(name2)
            n2 = name2(kk);
            valse = current.tau_values(current{:,groupName} == n2);
            tau_false = [tau_false cat(1,vals{:}) ];
        end
    end
    if isempty(tau_true) || isempty(tau_false)
        continue
    end
    tau_false = tau_false(isfinite(tau_false));
    tau_true = tau_true(isfinite(tau_true));
    tau_all = [ tau_false; tau_true];
    group_all = [zeros(1,length(tau_false)) ones(1,length(tau_true))]';
%     length_total = length(group_all);
%     n_values = 300000;
%     if strcmpi(subsample, 'uniform')
%         index1 = 1:floor(length_total / n_values):length_total;
%     elseif strcmpi(subsample, 'random')
%         index1 = randi(length_total, 1, n_values);
%     elseif strcmpi(subsample, 'first')
%         max_i = min(n_values, length_total);
%         index1 = 1:max_i;
%     end
%     tau_sub = tau_all(index1);
%     group_sub = group_all(index1);
    ratios = zeros(1,n_boot);
    parfor b = 1:n_boot
        group_current = Shuffle(group_all);% group_sub(randperm(length(group_sub)));
        ratios(b) = median(tau_all(group_current == 0)) ./ ...
            median(tau_all(group_current == 1));
    end
    ratio_true = median(tau_false) ./ median(tau_true);
    
    r2 = sort(ratios);
    true_rank = find(r2 > ratio_true, 1);
    if isempty(true_rank) || true_rank == n_boot+1
        p = 0;
    else
        p_low = true_rank ./ n_boot;
        p_high = (n_boot - true_rank) ./ n_boot;
        p = min([p_low p_high]) * 2;
    end
%     figure(1);
%     clf;
%     histogram(ratios,20);
%     hold on;
%     xline(ratio_true);
%     title(sprintf('%s: %.2f', current.Name{1}, p));
%     pause
    p_all = [p_all p];
    ratios_all = [ratios_all  ratio_true];
%     sd_all = [sd_all std(ratios2)];
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
tbl_out.ratio = ratios_all';
tbl_out.p = p_all';
tbl_out.name = names_all';
tbl_out.layer = layers_all';
tbl_out.new_names = new_names_all';
tbl_out.index = index_all';
% tbl_out.mean = means_all';
tbl_out.sum = sum_all';
tbl_out.pulse = pulse_all';
tbl_out.id = ids_all';
% tbl_out.sd = sd_all';
tbl_out.sum_sdd = sum_sd_all';
tbl_out = sortrows(tbl_out,'ratio','descend');
end