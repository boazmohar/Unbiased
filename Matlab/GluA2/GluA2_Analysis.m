
%% Run  rounds
out_path = 'D:\';
tbl1 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round1_try1\', out_path, 1, use_pool=true, applyCalib=2);
tbl2 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round2\', out_path, 2, use_pool=true, applyCalib=2);
tbl3 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round3\', out_path, 3, use_pool=true, applyCalib=2);
tbl4 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round4\', out_path, 4, use_pool=true, applyCalib=2);
tbl5 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round5\', out_path, 5, use_pool=true, applyCalib=2);
tbl6 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round6\', out_path, 6, use_pool=true, applyCalib=2);
tbl7 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round7\', out_path, 7, use_pool=true, applyCalib=2);
tbl8 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round8\', out_path, 8, use_pool=true, applyCalib=0); % zero day animals
tbl9 = get_round_data_GluA2('E:\Unbiased\GluA2\GluA2_round9\', out_path, 9, use_pool=true, applyCalib=0); % zero day animals

%% read rounds
tbl_all = load_data_glua2('D:\', 1:6,true, true);
% tbl_all = load_data_glua2('D:\', 1:7,true, false);
%% remove negative and failed VH3 (rule2)
r = strcmp(tbl_all.groupName, 'rule2');
tbl_all3 = tbl_all(~r,:);
r = strcmp(tbl_all3.groupName, 'negative');
tbl_all3 = tbl_all3(~r,:);
%% save to python
G_region = groupsummary(tbl_all3,"new_names",@(x,y,z) tau_values(x, y, z, 10000),...
    {["tau_values"],["groupName"],["ANM"]});

writetable(tbl_all3(1:end,1:8), 'tbl_glua2.txt', Delimiter='tab')
tau_values = tbl_all3.tau_values;
save('Glua2_tau_values_newCalib.mat','tau_values', '-v7.3')
%% Make A pairwise table:
tbl_pair_ee = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 100, ...
    'name1', "EE", 'name2', "control",...
    'groupName',"groupName", 'is_string',true);
tbl_pair_learn = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 100, ...
    'name1', "rule", 'name2', "random",...
    'groupName',"groupName", 'is_string',true);
save('pairwise_tbls_100_newCalib.mat',"tbl_pair_learn","tbl_pair_ee",'-v7.3')
%% load pairwise table
load('pairwise_tbls_100_newCalib.mat')
%% Plot bar plots:
ee_stats = grpstats(tbl_pair_ee, "new_names", {'mean', 'sem'},'DataVars','ratio');
learn_stats = grpstats(tbl_pair_learn, "new_names", {'mean', 'sem'},'DataVars','ratio');
learn_stats = sortrows(learn_stats,"new_names","ascend");
ee_stats = sortrows(ee_stats,"new_names","ascend");
[~, index] = sort(ee_stats.mean_ratio, 'descend');
make_GluA2_barPlots(tbl_all3, index)
%% totals
tbl_all3.Sum = tbl_all3.C_Mean + tbl_all3.P_Mean;
tbl_all3.ANM = categorical(tbl_all3.ANM);
tbl_all3.groupName = categorical(tbl_all3.groupName);
tbl4 = grpstats(tbl_all3, ["groupName", 'Name', 'ANM'], "median", "DataVars","Sum");
tbl4.groupName = categorical(tbl4.groupName, {'control', 'EE', 'random', 'rule'}, Ordinal=true);
tbl4 = sortrows(tbl4, 'groupName');
% Fit the linear mixed-effects model
lme = fitlme(tbl4,  'median_Sum ~ groupName + (1|ANM)');
%% only with 4 groups
uniqueCCF_IDs = unique(tbl_all3.CCF_ID);
groupNameCounts = arrayfun(@(ccf_id) numel(unique(tbl_all3.groupName(tbl_all3.CCF_ID == ccf_id))), uniqueCCF_IDs);

% Step 3: Keep rows where the corresponding 'CCF_ID' has exactly 4 unique 'groupName' values
validCCF_IDs = uniqueCCF_IDs(groupNameCounts == 4);
tbl5 = tbl_all3(ismember(tbl_all3.CCF_ID, validCCF_IDs), :);

G_CCF = groupsummary(tbl_all3,"CCF_ID",@(x,y,z) tau_values(x, y, z, 10000),...
    {["tau_values"],["groupName"],["ANM"]});

%%
means = cellfun(@(x) x.Coefficients.Estimate, G_CCF.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false);
valid = cellfun(@(x) length(x)==4, means,"UniformOutput",true);
means = means(valid);
ratio_ee = cellfun(@(x) x(1) ./ x(2)   ,means);
ratio_learn = cellfun(@(x) x(3) ./ x(4)   ,means);
id = G_CCF.CCF_ID;
id = id(valid);

tbl_out = table(id, ratio_ee, ratio_learn);

save('ratios_gluA2.mat','tbl_out','-v7.3')
% writetable(tbl_out,'psd95_turnover_ratios_new.txt','Delimiter','\t');


%%
[group, id] = findgroups(tbl_all3.layer);
idx = group > 1;
[p,~,stats] = anovan(tbl_all3.tau(idx), group(idx)-1, 'varnames',{'Layer'})
 
[c,m] = multcompare(stats, "Display","off");
%
f=figure(3);
clf
f.Color='w';
f.Units = 'centimeters';
f.Position = [6,6,4,6];
x2 = m(end:-1:1, 1);
e2 =  m(end:-1:1,2);
x = 1:length(id)-1;
data = x2;
barh(x,data,'LineWidth',1,'FaceColor','none')                
hold on
errorbar(data,x,e2,e2,'horizontal','LineStyle','none','LineWidth',1,'Color',[0.8 0.8 0.8]);    
hold off
box('off')
xlim([0, 4.5])
names22 = {'Layer 1','Layer 2/3','Layer 4','Layer 5','Layer 6','HC CA1',...
    'HC CA2','HC CA3'};
yticklabels(names22(end:-1:1))
xlabel({'Lifetime (days)'})
%%
[group, id] = findgroups(tbl_pair_ee.new_names);
[p,~,stats] = anova1(tbl_pair_ee.ratio,group);
 
[c,m] = multcompare(stats);
%
f=figure(33);
clf
f.Color='w';
f.Units = 'centimeters';
f.Position = [6,6,7,7];
x2 = m(1:end, 1)*100 - 100;
[x2, ii] = sort(x2, 'descend');
e2 =  m(1:end,2)*100;
e2 = e2(ii);
x = 1:length(id);
data = x2;
barh(x,data,'LineWidth',1,'FaceColor','none')                
hold on
errorbar(data,x,e2,e2,'horizontal','LineStyle','none','LineWidth',1,'Color',[0.8 0.8 0.8]);    
hold off
box('off')
yticklabels(id(ii))
ylabel('Brain region')
xlabel({'% Change' 'Control vs. EE'})

%%
[group, id] = findgroups(tbl_all3.new_names);
[p,~,stats] = anova1(tbl_all3.tau,group);
[c,m] = multcompare(stats);
f=figure(34);
clf
f.Color='w';
f.Units = 'centimeters';
f.Position = [6,6,7,7];
x2 = m(1:end, 1);
e2 =  m(1:end,2);
% e2 = e2(ii);
x = 1:length(id);
data = x2;
barh(x,data,'LineWidth',1,'FaceColor','none')                
hold on
errorbar(data, x,e2,e2,'horizontal','LineStyle','none','LineWidth',1,'Color',[0.8 0.8 0.8]);    
hold off
box('off')
yticklabels(id(ii))
ylabel('Brain region')
xlabel({'Lifetime (days)'})
xlim([0,3])
%%  PCA

tbl_counts_by_Name = grpstats(tbl_all3, {'Name'}, @(x)length(unique(x)), 'DataVars','ANM');
names_16 = tbl_counts_by_Name.Fun1_ANM==length(unique(tbl_all3.ANM));
names_16 = tbl_counts_by_Name.Name(names_16);
tbl_pca = grpstats(tbl_all3, {'ANM', 'Name'}, 'mean', 'DataVars','tau');
valid  = matches(tbl_pca.Name, names_16);
tbl_pca = tbl_pca(valid,:);
a = length(names_16);
b = length(unique(tbl_all3.ANM));
pca_mat = reshape(tbl_pca.mean_tau, a, b)';
anms = unique(tbl_pca.ANM, 'stable');
grups = string();
for i = 1:length(anms)
    anm = anms(i);
    idx = find(tbl_all3.ANM==anm, 1);
    grups(i) = tbl_all3.groupName(idx);
end
%%
pca_mat_Z = zscore(pca_mat,[],2);

[wcoeff,score,latent,tsquared,explained] = pca(pca_mat_Z,...
    'Centered',true);
figure(1)
clf
% gscatter3(score(:,1),score(:,2),score(:,3),grups', colors)
gscatter(score(:,1),score(:,2),grups')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
% view(3)


%% umapo
[reduction,umap,clusterIdentifiers,extras] =run_umap(pca_mat, ...
    'n_neighbors',3, 'min_dist', .3, 'init', 'random', 'n_components', 2);

%%
figure(1)
clf
gscatter(reduction(:,1),reduction(:,2),grups', distinguishable_colors(4),[],30)
xlabel('UMAP 1')
ylabel('UMAP 2')
% zlabel('UMAP 3')
% view( 25,14);
%% mixed effects model

% take 100 values from each and make a flat table
tbl_c1 = tbl_all3(ismember(tbl_all3.groupName, {'random','rule'}), :);
[group, id] = findgroups(tbl_c1(:,[1,6]));
maxNum = 10000;
tbl_all2 = {};
for i = 1:height(id)

    if ~mod(i,100)
        disp(i./height(id).*100)
    end
    index = group==i;
    current = tbl_c1(group==i,:);
    data = cell2mat(current.tau_values(:));
    max_index = length(data);
    items = min(max_index, maxNum);
    data = data(randi(max_index, 1, items));
    new = current(ones(1,items), ["ANM","groupName","Name","tau", "layer"]);
    new.tau = data;
   
    tbl_all2 = [tbl_all2 {new}];
end
df = cat(1, tbl_all2{:});

df2 = df;
df2.Name = categorical(df.Name);
df2.ANM = categorical(df.ANM);
df2.groupName = categorical(df.groupName);
df2.layer = categorical(df.layer);
df2.tau = double(df.tau);
%%
EE_mle = fitlme(df2,'tau ~  1 + groupName + (1|Name) + (1|ANM)')
[~,~,STATS] = randomEffects(EE_mle)
s = dataset2table(STATS)
%% correlation to sum
tbl_delta = grpstats(tbl_all3, 'new_names', {'mean'}, "DataVars", {'tau', 'sum'});
tbl_delta2 = tbl_delta(:, [1,3,4]);
tbl_delta2.Properties.VariableNames= {'name', 'meandelta','sum'};
%%
f = figure(55);
clf
f.Color='w';
f.Units = "centimeters";
f.Position = [12,12,18,8];
cmap = distinguishable_colors(12, 'w');   

tbl_delta2.colors =cmap;

scatter(tbl_delta2, "meandelta", "sum", "filled", 'ColorVariable','colors')
% m = fitlm(tbl_delta2, "linear","PredictorVars","meandelta", "ResponseVar","sum");
% title(sprintf('DELTA \nr^2 = %.2f',m.Rsquared.Adjusted  ))
xlabel("GluA2 lifetime (days)")
ylabel('Pulse + Chase')
colormap( gca,cmap );
xlim([3, 4])
hold on
H = gobjects(1,12);
for i = 1:12
    H(i) = scatter(nan,nan,[],tbl_delta2.colors(i,:),'filled', 'DisplayName',tbl_delta2.name(i));
end
l = legend(H, 'NumColumns',4,'box','off');
l.Location = 'southoutside';

%% left over
%     x = [tau_false; tau_true];
%     p = anovan(x, {g_anm, g_ee}, 'model','interaction', 'nested',[0,1;0,0], 'varnames',{'ANM','EE'}, 'display','off');

% read all:
% tbl2 = parquetread(name, "OutputType","table",

%% Hemi
G_layer = groupsummary(tbl_all3,"Hemi",@(x,y,z) tau_values(x, y, z, 1000),...
    {["tau_values"],["groupName"],["ANM"]});
G_layer.means = cellfun(@(x) x.Coefficients.Estimate, G_layer.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
G_layer.SE = cellfun(@(x) x.Coefficients.SE, G_layer.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
means = cat(2, G_layer.means{:});
SEs = cat(2, G_layer.SE{:});
figure(2)
clf

barweb(means, SEs, [], {'Control','EE','Random','Rule'}, [],'Brain region','GluA2 lifetime (days)',...
    viridis)
legend({'right','left'}, 'NumColumns',4,'Location',...
    'northeast', 'box','off')
%% scatter
colororder(jet)
ee_stats = grpstats(tbl_pair_ee, "new_names", {'mean', 'sem'},'DataVars','ratio');
learn_stats = grpstats(tbl_pair_learn, "new_names", {'mean', 'sem'},'DataVars','ratio');
learn_stats = sortrows(learn_stats,"new_names","ascend");
ee_stats = sortrows(ee_stats,"new_names","ascend");
[~, index] = sort(ee_stats.mean_ratio, 'descend');
ee_stats = ee_stats(index, :);
learn_stats = learn_stats(index, :);
figure(11)
clf
set(gcf,'Color','w')
barweb(([ee_stats.mean_ratio learn_stats.mean_ratio ] .* 100) - 100,...
    ([ee_stats.sem_ratio learn_stats.sem_ratio ].* 100),...
    [], ee_stats.new_names,[],'Brain region',...
    {'% change', 'GluA2 lifetime'},viridis(2));
legend({'Control vs. EE','Same task vs. New learning'}, 'NumColumns',1,'Location',...
    'northeast', 'box','off')
% hold on;
% yline(gca, 0,':k', )
% xlim([0.95,1.2])
ylim([-10,25])
%%
colororder(jet)
ee_stats = grpstats(tbl_pair_ee, "layer", {'mean', 'sem'},'DataVars','ratio');
learn_stats = grpstats(tbl_pair_learn, "layer", {'mean', 'sem'},'DataVars','ratio');
ee_stats = ee_stats(2:end, :);
learn_stats = learn_stats(2:end, :);
figure(11)
clf
set(gcf,'Color','w')
barweb(([ee_stats.mean_ratio learn_stats.mean_ratio ] .* 100) - 100,...
    ([ee_stats.sem_ratio learn_stats.sem_ratio ].* 100),...
    [], names22,[],'Brain region',...
    {'% change', 'GluA2 lifetime'},viridis(2));
legend({'Control vs. EE','Same task vs. New learning'}, 'NumColumns',1,'Location',...
    'northeast', 'box','off')
% hold on;
% yline(gca, 0,':k', )
% xlim([0.95,1.2])
ylim([0,55])
%% volcano plot

f=figure(13);
clf;
f.Units = "centimeters";
f.Position = [8, 8, 24, 18];
f.Color='w';
subplot(1,2,1)
tbl_pair_ee2 = sortrows(tbl_pair_ee,"new_names", "ascend");
p_all2 = tbl_pair_ee2.p;
p_all2(p_all2==0) = 2/3000;
gscatter(tbl_pair_ee2.ratio*100-100, -log10(p_all2),tbl_pair_ee2.new_names, distinguishable_colors(12),[],20);
legend('off')
box 'off'
xlabel({'% Change' 'Control vs. EE'})
ylabel('-log_{10} p')

subplot(1,2,2)
tbl_pair_learn2 = sortrows(tbl_pair_learn,"new_names", "ascend");
p_all2 = tbl_pair_learn2.p;
p_all2(p_all2==0) = 2/3000;
gscatter(tbl_pair_learn2.ratio*100-100, -log10(p_all2),tbl_pair_learn2.new_names, distinguishable_colors(12), [], 20);

box off
xlabel({'% Change' 'Random vs. Rule'})
ylabel('-log_{10} p')
%%
[group, id] = findgroups(tbl_all3(:,[1,6]));
maxNum = 1000;
tbl_all2 = {};
median_block = @(block_struct) median(block_struct.data);
for i = 1:height(id)

    if ~mod(i,100)
        disp(i./height(id).*100)
    end
    index = group==i;
    current = tbl_all3(group==i,:);
    a = current.tau_values(:);
    data = cell2mat(cellfun(@single, a, 'UniformOutput' ,false));
%     block_num  = ceil(length(data) ./maxNum);
%     
%     vals2 = blockproc(data, [block_num,1], median_block);
    
    new = current(1,1:8);
%     new(1,9) = {vals2};
    new{1,8} = median(data);
    new.new_names = current.new_names(1);
   
    tbl_all2 = [tbl_all2 {new}];
end
df = cat(1, tbl_all2{:});
writetable(df,'glua2_turnover.txt','Delimiter','\t');
%%
df2 = df;
df2.Name = categorical(df.Name);
df2.ANM = categorical(df.ANM);
df2.groupName = categorical(df.groupName);
df2.layer = categorical(df.layer);
df2.tau = double(df.tau);
%% New early learning
tbl_pair_early = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 30, ...
    'name1', "random", 'name2', "early",...
    'groupName',"groupName", 'is_string',true);
tbl_pair_early_rule = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 30, ...
    'name1', "rule", 'name2', "early",...
    'groupName',"groupName", 'is_string',true);
save('pairwise_tbls_early_30.mat',"tbl_pair_early","tbl_pair_early_rule",'-v7.3')
%% New early learning 2
tbl_pair_early_control = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 30, ...
    'name1', "early", 'name2', "control",...
    'groupName',"groupName", 'is_string',true);
tbl_pair_random_control = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 30, ...
    'name1', "random", 'name2', "control",...
    'groupName',"groupName", 'is_string',true);
save('pairwise_tbls_early2_30.mat',"tbl_pair_early_control","tbl_pair_random_control",'-v7.3')
%% diff plot early
means = cat(2, G_region.means{:});
SEs = cat(2, G_region.SE{:});
rations = [ means(5,:) ./ means(1,:) ; means(5,:) ./ means(1,:)] * 100 - 100;
rations = rations(:,index);
SE2 = [SEs(1,:) ./ means(1,:); SEs(1,:) ./ means(1,:)];
SE2 = SE2(:,index) * 100;
figure(6)
clf
set(gcf,'color','w')
hh=barweb(rations',SE2',...
    [], G_region.new_names(index),[],'Brain region',...
    {'% change', 'GluA2 lifetime'},viridis(2));
ylim([-8 30])
legend({'Control vs. early','Random vs. early'}, 'box','off',...
    'Location','southeast')
camroll(-90)
yticks([0,10,20,30])
set(gca,'LineWidth',2)
set(gca, 'FontName', 'Arial')
set(hh.bars, 'LineWidt',2)
set(hh.errors, 'LineWidt',2)
% print '-PPDF Printer' regio
%% comapre right / left hemi
tbl_pair_side = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 0, ...
    'name1', "right", 'name2', "left",...
    'groupName',"Hemi", 'is_string',true);
