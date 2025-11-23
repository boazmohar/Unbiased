%% load data
tbl_all = load_data_glua2('D:\', 1:6, false, false);
%%
stats = grpstats(tbl_all, {'groupName'}, {'mean'} , 'DataVars',{'P_Mean','C_Mean', 'P_STD','C_STD'});
f = figure(1);
f.Color = 'w';
f.Units = 'centimeters';

handles = barweb([stats.mean_P_Mean  stats.mean_C_Mean], ...
    [stats.mean_P_STD  stats.mean_C_STD], [],stats.groupName,...
    "Region intensity", 'Group','Dye concentration',[],[],{'Pulse','Chase'});
legend('off')
legend({'Pulse','Chase'}, 'Box','off')
% yticks(0:0.1:0.41)
handles.ax.TickLength = [0.01, 0.01];
export_fig('negative_control.eps')
%%
tbl_neg = tbl_all;
tbl_neg.is_neg = strcmp(tbl_all.groupName, 'negative');
stats2 = grpstats(tbl_neg, {'is_neg','Name'}, {'mean'} , 'DataVars',{'P_Mean','C_Mean', 'P_STD','C_STD'});
stats2 = sortrows(stats2,"Name","ascend");
names_issue = {};
k=1;
[group, id] = findgroups(stats2.Name);
for i = 1:height(id)
    current = stats2(group==i, :);
    if height(current) < 2
        names_issue(k) = {current.Name};
        k=k+1;
        continue
    end
    assert(strcmp(current.Name{1}, current.Name{2}), 'wrong names');
    neg = find(current.is_neg == 1);
    not = find(current.is_neg == 0);
    assert(length(neg)==1)
    assert(length(not)==1)
    pulse_th = current.mean_P_Mean(neg)+current.mean_P_STD(neg)*2;
    chase_th = current.mean_C_Mean(neg)+current.mean_C_STD(neg)*2;
    if current.mean_P_Mean(not) < pulse_th || current.mean_C_Mean(not) < chase_th
        names_issue(k) = {current.Name(1)};
        k=k+1;
    end
end
%% get CCF Ids of leaves
CCF_tree = getCCF_tree('y:\');
index_all = [];
k=1;
for i = 1:length(names_issue)
    name = names_issue{i};
    name = name.replace(',','');
    ccf_tree_index = find(strcmp(name, CCF_tree.name));
    current = CCF_tree(ccf_tree_index,:);
    ccf_id = ['/' num2str(current.id) '/'];
    childs = find(contains(CCF_tree.structure_id_path, ccf_id));
    if length(childs) == 1 
        index_all(k) = ccf_tree_index;
        k=k+1;
    end
end
%% conver to table
tbl_regect = CCF_tree(index_all,:);

%% save
save('negative_control_bad_regions.mat','tbl_regect')
