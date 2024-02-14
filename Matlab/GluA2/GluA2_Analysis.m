
%% Run  rounds
out_path = 'D:\';
tbl1 = get_round_data_GluA2('V:\moharb\GluA2\GluA2_round1_try1\', out_path, 1, use_pool=true);
tbl2 = get_round_data_GluA2('V:\moharb\GluA2\GluA2_round2\', out_path, 2, use_pool=true);
tbl3 = get_round_data_GluA2('V:\moharb\GluA2\GluA2_round3\', out_path, 3, use_pool=true);
tbl4 = get_round_data_GluA2('V:\moharb\GluA2\GluA2_round4\', out_path, 4);
tbl5 = get_round_data_GluA2('V:\moharb\GluA2\GluA2_round5\', out_path, 5);
tbl6 = get_round_data_GluA2('V:\moharb\GluA2\GluA2_round6\', out_path, 6);
%% read rounds
tbl_all = load_data_glua2('D:\', 1:6,true, true);
%% remove negative and failed VH3 (ruls2)
r = strcmp(tbl_all.groupName, 'rule2');
tbl_all3 = tbl_all(~r,:);
r = strcmp(tbl_all3.groupName, 'negative');
tbl_all3 = tbl_all3(~r,:);
%% save to python
G_region = groupsummary(tbl_all3,"new_names",@(x,y,z) tau_values(x, y, z, 10000),...
    {["tau_values"],["groupName"],["ANM"]});

writetable(tbl_all3(1:end,1:8), 'tbl_glua2.txt', Delimiter='tab')
tau_values = tbl_all3.tau_values;
save('Glua2_tau_values.mat','tau_values', '-v7.3')
%%
tbl_pair_side = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 0, ...
    'name1', "right", 'name2', "left",...
    'groupName',"Hemi", 'is_string',true);

%% Make A pairwise table:
tbl_pair_ee = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 300, ...
    'name1', "EE", 'name2', "control",...
    'groupName',"groupName", 'is_string',true);
tbl_pair_learn = pairwise_compare_shuffleGroup(tbl_all3, 'n_boot', 3000, ...
    'name1', "rule", 'name2', "random",...
    'groupName',"groupName", 'is_string',true);
save('pairwise_tbls_3000.mat',"tbl_pair_learn","tbl_pair_ee",'-v7.3')
%%
load('pairwise_tbls.mat')
%% Brain Regions 
G_region = groupsummary(tbl_all3,"new_names",@(x,y,z) tau_values(x, y, z, 10000),...
    {["tau_values"],["groupName"],["ANM"]});
G_region.means = cellfun(@(x) x.Coefficients.Estimate, G_region.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false);
G_region.SE = cellfun(@(x) x.Coefficients.SE, G_region.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false);
%%

color_order = [0 255 0 ; 255 0 255; 1 249 198; 0 99 124]./255;
means = cat(2, G_region.means{:});
SEs = cat(2, G_region.SE{:});
f = figure(1);
clf
f.Color = 'w';

hh = barweb(means(:,index)', SEs(:,index)', [], G_region.new_names(index), [],'Brain region','GluA2 lifetime (days)',...
    color_order);
legend('off')
ylim([3,5.5])
yticks([3,4,5])
camroll(-90)
set(gca,'LineWidth',2)
set(gca, 'FontName', 'Arial')
set(hh.bars, 'LineWidt',2)
set(hh.errors, 'LineWidt',2)
% print '-PPDF Printer' regions.pdf -dwinc
%% Layers
tbl_layer = tbl_all3(tbl_all3.layer>0,:);
G_layer = groupsummary(tbl_layer,"layer",@(x,y,z) tau_values(x, y, z, 1000),...
    {["tau_values"],["groupName"],["ANM"]});
G_layer.means = cellfun(@(x) x.Coefficients.Estimate, G_layer.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
G_layer.SE = cellfun(@(x) x.Coefficients.SE, G_layer.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
%%
means = cat(2, G_layer.means{:});
SEs = cat(2, G_layer.SE{:});

f = figure(2);
clf
f.Color = 'w';
names22 = {'Layer 1','Layer 2/3','Layer 4','Layer 5','Layer 6','HC CA1','HC CA2','HC CA3'};
hh = barweb(means', SEs', [], names22, [],'Brain region','GluA2 lifetime (days)',...
    color_order)
legend({'Control','EE','Random','Rule'}, 'NumColumns',4,'Location',...
    'southoutside', 'box','off')

ylim([3,6])
yticks([2,3,4,5,6])
camroll(-90)
set(gca,'LineWidth',2)
set(gca, 'FontName', 'Arial')
set(hh.bars, 'LineWidt',2)
set(hh.errors, 'LineWidt',2)
print '-PPDF Printer' layers.pdf -dwinc
%% CA1
l1 = contains(tbl_all3.Name, 'Field CA1,');
tbl_l1 = tbl_all3(l1,:);
G_CA1 = groupsummary(tbl_l1,"Name",@(x,y,z) tau_values(x, y, z, 1000),...
    {["tau_values"],["groupName"],["ANM"]});
G_CA1.means = cellfun(@(x) x.Coefficients.Estimate, G_CA1.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
G_CA1.SE = cellfun(@(x) x.Coefficients.SE, G_CA1.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)

%%
f = figure(3);
means = cat(2, G_CA1.means{:});
SEs = cat(2, G_CA1.SE{:});
clf
f.Color='w';
hh = barweb(means', SEs', [], G_CA1.Name, [],'Brain region','GluA2 lifetime (days)',...
    color_order);
% legend({'Control','EE','Random','Rule'}, 'NumColumns',4,'Location',...
%     'northeast', 'box','off')

ylim([1.5,5.5])
yticks([2,3,4,5])
camroll(-90)
set(gca,'LineWidth',2)
set(gca, 'FontName', 'Arial')
set(hh.bars, 'LineWidt',2)
set(hh.errors, 'LineWidt',2)
print '-PPDF Printer' CA1.pdf -dwinc
%% diff plot region
means = cat(2, G_region.means{:});
SEs = cat(2, G_region.SE{:});
rations = [ means(1,:) ./ means(2,:) ; means(3,:) ./ means(4,:)] * 100 - 100;
rations = rations(:,index);
SE2 = [SEs(1,:) ./ means(1,:); SEs(3,:) ./ means(3,:)];
SE2 = SE2(:,index) * 100;
figure(6)
clf
set(gcf,'color','w')
hh=barweb(rations',SE2',...
    [], G_region.new_names(index),[],'Brain region',...
    {'% change', 'GluA2 lifetime'},viridis(2));
ylim([-8 30])
legend({'Control vs. EE','Random vs. Rule'}, 'box','off',...
    'Location','southeast')
camroll(-90)
yticks([0,10,20,30])
set(gca,'LineWidth',2)
set(gca, 'FontName', 'Arial')
set(hh.bars, 'LineWidt',2)
set(hh.errors, 'LineWidt',2)
% print '-PPDF Printer' regions_ratios.pdf -dwinc
%% diff plot layer
means = cat(2, G_layer.means{:});
SEs = cat(2, G_layer.SE{:});
rations = [ means(1,:) ./ means(2,:) ; means(3,:) ./ means(4,:)] * 100 - 100;

SEs = [SEs(1,:) ./ means(1,:) ; ...
    SEs(3,:) ./ means(3,:) ]*100;
figure(6)
clf
set(gcf,'color','w')
hh=barweb(rations',SEs',[], names22,[],'Brain region',...
    {'% change', 'GluA2 lifetime'},viridis(2));
ylim([0 45])
yticks([0,15,30,45])
% legend({'Control vs. EE','Random vs. Rule'}, 'box','off',...
%     'Location','north')
% camroll(-90)
set(gca,'LineWidth',2)
set(gca, 'FontName', 'Arial')
set(hh.bars, 'LineWidt',2)
set(hh.errors, 'LineWidt',2)
print '-PPDF Printer' layers_ratios.pdf -dwinc
%%
means = cat(2, G_CA1.means{:});
SEs = cat(2, G_CA1.SE{:});
rations = [ means(1,:) ./ means(2,:) ; means(3,:) ./ means(4,:)] * 100 - 100;

SEs = [SEs(1,:) ./ means(1,:) ; ...
    SEs(3,:) ./ means(3,:) ]*100;
figure(6)
clf
set(gcf,'color','w')
hh=barweb(rations',SEs',[], G_CA1.Name,[],'Brain region',...
    {'% change', 'GluA2 lifetime'},viridis(2));
ylim([0 65])
yticks([0,15,30,45, 60])
% legend({'Control vs. EE','Random vs. Rule'}, 'box','off',...
%     'Location','north')
% camroll(-90)
set(gca,'LineWidth',2)
set(gca, 'FontName', 'Arial')
set(hh.bars, 'LineWidt',2)
set(hh.errors, 'LineWidt',2)
print '-PPDF Printer' CA1_ratios.pdf -dwinc
%%
grpstats(tbl_l1, {'groupName'}, {'mean', 'std'}, 'DataVars','tau')

grpstats(tbl_l1, {'Name', 'groupName'}, {'mean'}, 'DataVars','tau')
%%
tbl_HC = tbl_all(strcmp(tbl_all.new_names, 'Hippocampal formation'),:);
grpstats(tbl_HC, {'groupName'}, {'mean', 'std'}, 'DataVars','tau')
grpstats(tbl_HC, {'ANM', 'groupName'}, {'mean', 'std'}, 'DataVars','tau')
%%

%
[group, id] = findgroups(tbl_pair.layer);
idx = group > 1;
[p,~,stats] = anova1(tbl_pair.ratio(idx), group(idx)-1)
 
[c,m] = multcompare(stats, 'CriticalValueType','hsd');
%
f=figure(2);
clf
f.Color='w';
f.Units = 'centimeters';
f.Position = [6,6,5,7];
x2 = m(end:-1:1, 1)*100 - 100;
e2 =  m(end:-1:1,2)*100;
x = 1:length(id)-1;
data = x2;
barh(x,data,'LineWidth',1,'FaceColor','none')                
hold on
errorbar(data,x,e2,e2,'horizontal' ,'LineStyle','none','LineWidth',1,'Color',[0.8 0.8 0.8]);    
hold off
box('off')
names22 = {'Layer 1','Layer 2/3','Layer 4','Layer 5','Layer 6','HC CA1','HC CA2','HC CA3'};
yticklabels(names22(end:-1:1))
% ylabel('Cortical layer / HC subfield')
% xlabel({'% Change' 'Random vs. Rule'})
xlabel({'% Change' 'Control vs. EE'})
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