%% make table (once):
% List files per animal
baseDir = 'C:\Users\moharb\Dropbox (HHMI)\Projects\Unbised\PSD95_EE';
files = dir([baseDir, '\*s2.tif']);
files = {files.name}';

Tables = cellfun(@get_table_psd, files, 'UniformOutput', false);
% Combine accros animals
tbl = vertcat(Tables{:});
save('tbl_v5.mat', "tbl", '-v7.3');
%% load table
clear 
load('tbl_v5.mat', 'tbl')
%% clean
exclude = {'tract','nerve','peduncle','ventricle','chiasm', 'choroid', 'commissures', 'subependymal','pyramid', 'capsule',...
    'trapezoid', 'bundle', 'callosum','white', 'commissure', 'fiber', 'canal', 'aqueduct','recess', 'root', 'fornix',...
    'radiation', 'alveus', 'fimbria','stria terminalis','medial lemniscus','pathway','fascicle', 'arbor vitae',...
    'fasciculus retroflexus','stria medullaris','external medullary lamina of the thalamus',...
    'brachium of the inferior colliculus','brachium of the superior colliculus', 'doral tegmental decussation', ...
    'dorsal limb', 'dorsal acoustic stria', 'ventral tegmental decussation', 'lateral lemniscus'};
ex_index = [];
for i = 1:height(tbl)
    current = tbl.Name{i};
    if contains(current, exclude)
        ex_index = [ex_index i];
    end
end
th = 20; %px
valid = find(tbl.N > th);
valid = setdiff(valid, ex_index);
tbl2 = tbl(valid, :);
[pNew_AP, ~] =discretize(tbl2.AP,10);
tbl2.AP2 = pNew_AP;
save('Turnover_tbl_v4.mat', "tbl2", '-v7.3');
%% load clean table
load('Turnover_tbl_v4.mat')
%% save v6 for R
names = tbl2.Properties.VariableNames(1:9);
for i = 1:9
    name = names{i};
    data = tbl2{:,i};
    if i == 1 % convert anmials string to numbers
        [C,ia,ic] = unique(data,'legacy');
        data = ic;
    end
    save(name, "data", '-v6')
end
%% diff expression bootstrap aniamls
[group, id] = findgroups(tbl2(:,[6]));
p_all = [];
ratios = [];
names_all= {};
ids_all = [];
index_all = {};
n_boot = 300;
sd_all = [];
means_all = [];
for i = 1:height(id)

    if ~mod(i,10)
        disp(i./height(id))
    end
    index = group==i;
    current = tbl2(group==i,:);
    ee = current.EE; 
    if length(unique(current.ANM)) < 6
        continue
    end
    tau_true = current.tau(ee==0);
    tau_false = current.tau(ee==1);
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
%     x = [tau_false; tau_true];
%     p = anovan(x, {g_anm, g_ee}, 'model','interaction', 'nested',[0,1;0,0], 'varnames',{'ANM','EE'}, 'display','off');
    p_all = [p_all p];
    ratios = [ratios  mean(ratios2)];
    sd_all = [sd_all std(ratios2)];
    names_all = [names_all  current.Name(1)];
    ids_all = [ids_all  current.CCF_ID(1)];
    index_all = [index_all {find(index)}];
end
disp('end')
%%
f=figure(3);
clf;
f.Units = "centimeters";
f.Position = [8, 8, 8, 8];
f.Color='w';
p_all2 = p_all;
p_all2(p_all2==0) = 0.0000001;
scatter(ratios*100-100, -log10(p_all2), 'ok');
box off
% colorbar()
% hist3(X,'CdataMode','auto')
xlabel({'% Change' 'Control vs. EE'})
ylabel('-log_{10} p')
% colorbar
view(2)
exportgraphics(f,['Volcano.pdf'],'ContentType','vector')  
%%
tbl3 = table;
tbl3.ratio = ratios';
tbl3.p = p_all';
tbl3.name = names_all';
tbl3.index = index_all';
tbl3.mean = means_all';
tbl3.id = ids_all';
tbl3.sd = sd_all';
tbl3 = sortrows(tbl3,'ratio','descend');
str = tbl3.name{1};
expression = '[lL]ayer\s(\d)';
[tokens] = regexp(tbl3.name,expression,'tokens', 'once','emptymatch');
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
tbl3.layer = layers';
ca1 = contains(tbl3.name, 'CA1');
tbl3.layer(ca1) = 7;
ca3 = contains(tbl3.name, 'CA3');
tbl3.layer(ca3) = 8;
%%
[group, id] = findgroups(tbl3.layer);
idx = group > 1;
[p,~,stats] = anova1(tbl3.ratio(idx), group(idx)-1)
 
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
names22 = {'Layer 1','Layer 2/3','Layer 4','Layer 5','Layer 6','HC CA1','HC CA3'};
yticklabels(names22(end:-1:1))
% ylabel('Cortical layer / HC subfield')
xlabel({'% Change' 'Control vs. EE'})
exportgraphics(f,['Cortical_layer_change.pdf'],'ContentType','vector')
%%
[group, id] = findgroups(tbl3.layer);
idx = group > 1;
[p,~,stats] = anovan(tbl3.mean(idx), group(idx)-1, 'varnames',{'Layer'})
 
[c,m] = multcompare(stats);
%
f=figure(2);
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
xlim([6, 16])
names22 = {'Layer 1','Layer 2/3','Layer 4','Layer 5','Layer 6','HC CA1','HC CA3'};
yticklabels(names22(end:-1:1))
% ylabel('Cortical layer / HC subfield')
xlabel({'Lifetime (days)'})
exportgraphics(f,['Cortical_layer_lifetime.pdf'],'ContentType','vector')
%% reassign names CCF higher level:
CCF_tree = getCCF_tree();
Names = {'Isocortex','OLF','HPF','CTXsp','STR','PAL','TH','HY','MB','P','CB', 'MY'};
Ids = [];
full_names = {};
for i = 1:length(Names)
    name = Names{i};
    index = find(matches(CCF_tree.acronym, name));
    Ids  = [Ids CCF_tree.id(index)];
    full_names  = [full_names CCF_tree.name(index)];
end
new_names = {};
k = 0;
for i = 1:height(tbl3)
    id = tbl3.id(i);
    index = find(CCF_tree.id == id);
    list = CCF_tree.structure_id_path(index);
    list = list.split('/');
    list = str2double(list(2:end-1));
    new_id = intersect(Ids, list);
    if isempty(new_id)
        tbl3.name(i)
    end
    new_name = full_names(new_id == Ids);
    new_names = [new_names new_name];
    k=k+1;
end
tbl3.new_names = new_names';
%%
[group, id] = findgroups(tbl3.new_names);
[p,~,stats] = anova1(tbl3.ratio,group);
 
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

exportgraphics(f,['CCF_change.pdf'],'ContentType','vector')
%%
[group, id] = findgroups(tbl3.new_names);
[p,~,stats] = anova1(tbl3.mean,group);
[c,m] = multcompare(stats);
%%
f=figure(34);
clf
f.Color='w';
f.Units = 'centimeters';
f.Position = [6,6,7,7];
x2 = m(1:end, 1);
e2 =  m(1:end,2);
e2 = e2(ii);
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
xlim([6, 16])
exportgraphics(f,['CCF_lifetime.pdf'],'ContentType','vector')
%%
th = 30; %px
valid = tbl.N > th;
tbl2 = tbl(valid,:);
%
[group, id] = findgroups(tbl2(:,[1,2,3, 6]));
outputs = table;
for i = 1:height(id)
    current = tbl2(group==i,:);
    if height(current) == 1
        outputs = [outputs; current];
    else
        current2 = current(1,:);
        current2.fraction =  wmean(current.fraction, current.N);
        current2.N =sum(current.N);
        current2.P_Mean =  wmean(current.P_Mean, current.N);
        current2.P_STD =  wmean(current.P_STD, current.N);
        current2.C_Mean =  wmean(current.C_Mean, current.N);
        current2.C_STD =  wmean(current.C_STD, current.N);
        current2.AP =  wmean(current.AP, current.N);
        
        outputs = [outputs; current2];
    end
end
%
m = varfun(@mean,outputs,'GroupingVariables',{'ANM'}, 'InputVariables','fraction');
s = varfun(@(x) std(x, 1,'all'),outputs,'GroupingVariables',{'ANM'}, 'InputVariables','fraction');
normalized = outputs;
% zscore = outputs;
norm_cell = {};
names = {};
mean_cell = {};
pulse_cell = {};
tau_cell = {};
for i = 1:height(m)
    anm = m.ANM{i}
    index = contains(outputs.ANM,anm);
    index_mean = contains(m.ANM,anm);
    normalized.fraction(index) = normalized.fraction(index) / m.mean_fraction(index_mean);
%     zscore.fraction(index) =  (normalized.fraction(index) - m.mean_fraction(index_mean)) ./ s.Fun_fraction(index_mean);
    norm_cell{i} = normalized.fraction(index);
%     z_cell{i} = zscore.fraction(index);
    f = outputs.fraction(index);
    mean_cell{i} = f;
    tau_cell{i} = 14./log(1./f);
    pulse_cell{i} = outputs.P_Mean(index);
    names{i} = normalized.Name(index);
end
names2 = mintersect(names{:});
% filter names
r_idx = find(contains(names2, 'root'));
%fiber tracks
CCF_tree = getCCF_tree();
path = CCF_tree.structure_id_path;
% fiber_idx = find(contains(path, '1009'));
exclude = {'tract','nerve','peduncle','ventricle','chiasm', 'choroid', 'commissures', 'subependymal',...
    'trapezoid', 'bundle', 'callosum','white', 'commissure', 'fiber', 'canal', 'aqueduct','recess'};

include = 1:length(names2);
for i=1:length(exclude)
    idx = find(contains(names2, exclude{i}));
    include = setdiff(include, idx);
end
include = setdiff(include, r_idx);
% include = setdiff(include, fiber_idx);
names_clean = names2(include);
%%
g_anm = length(names_clean);
norm_mat = zeros(6,g_anm);
mean_mat = zeros(6,g_anm);
pulse_mat = zeros(6,g_anm);
tau_mat = zeros(6,g_anm);
for i = 1:g_anm
    n = names_clean(i);
    for k = 1:6
        idx = find(contains(names{k}, n));
        norm_mat(k, i) = mean(norm_cell{k}(idx));
        mean_mat(k, i) = mean(mean_cell{k}(idx));
        pulse_mat(k, i) = mean(pulse_cell{k}(idx));
        tau_mat(k, i) = mean(tau_cell{k}(idx));
    end
end

%% PCA
[coeff,score,latent,tsquared,explained,mu] = pca(tau_mat,'Centered', true, 'NumComponents',2);
% [coeff,score,latent,tsquared,explained,mu] = pca(pulse_mat', 'Centered', false, 'NumComponents',2);
%
% colors = dist inguishable_colors(6, 'w');
% colors = jet(6);
colors = [[1,0,1]; [1,0,1]; [0,1,0]; [1,0,1]; [1,0,1]; [0,1,0]];
F = figure(1);
F.Units = 'centimeters';
F.Position = [13 13 3 6];
F.Color = 'w';
clf
hold on
scatter(score(:,2), score(:,1), 20, colors, 'fill', 's')
ylabel(sprintf('PC1 (%d%% var)',round(explained(1)) ))
xlabel(sprintf('PC2 (%d%% var)',round(explained(2)) ))
exportgraphics(F,['PCA_v3.pdf'],'ContentType','vector')  
%%
nn=g_anm;
names_pc1 = names_clean(1:nn);
[~, LabelTables] = getLabelTables();
acr_all = [];
id_all = [];
for i=1:nn
    id1 =find(contains(LabelTables.Name, names_pc1(i)));
    if length(id1) > 1
        id1 = id1(1);
    end
    if isempty(id1)
        temp = strrep(names_pc1(i), '-',' ');
        find(contains(LabelTables.Name,temp,'IgnoreCase',true))
    end
    id2 = LabelTables.ID(id1);
    acr_id = find(CCF_tree.id==id2);
    acr = CCF_tree.acronym(acr_id);
    acr_all = [acr_all acr];
    id_all = [id_all CCF_tree.atlas_id(acr_id)];
end
%%
pc = 1;
pc1_abs = abs(coeff(:,pc));
[sorted, idxs] = sort(pc1_abs, 'descend');
colors = distinguishable_colors(6, 'w');
names_pc1 = names_clean(idxs(1:nn));
l1 = [0];
l23 = [0];
l4 = [0];
l5 = [0];
l6 = [0];
ca1 = [0];
ca3 = [0];
other = [0];
g = [0];
for i=1:length(pc1_abs)
    c = lower(names_pc1{i});
    if contains(c, 'layer 1')
        l1(end+1) = sorted(i);
        g(end+1) = 1;
    elseif contains(c, 'layer 2')
        g(end+1) = 2;
        l23(end+1) = sorted(i);
    elseif contains(c, 'layer 4')
        g(end+1) = 3;
        l4(end+1) = sorted(i);
    elseif contains(c, 'layer 5')
        g(end+1) = 4;
        l5(end+1) = sorted(i);
    elseif contains(c, 'layer 6')
        g(end+1) = 5;
        l6(end+1) = sorted(i);
    elseif contains(c, 'ca1')
        g(end+1) = 6;
        ca1(end+1) = sorted(i);
    elseif contains(c, 'ca3')
        g(end+1) = 7;
        ca3(end+1) = sorted(i);
    else
        other(end+1) = sorted(i);
        g(end+1) = 8;
    end
end
xx = [l1(2:end), l23(2:end), l4(2:end),l5(2:end),l6(2:end),ca1(2:end),ca3(2:end),other(2:end)];
gg = g(2:end);
% boxplot(xx,gg) 
[p,~,stats] =anova1(xx, gg);
[c,m] = multcompare(stats);
%%
f=figure(4);
clf
f.Color='w';
f.Units = 'centimeters';
f.Position = [6,6,7,6];
x2 = m(1:end, 1);
e2 =  m(1:end,2);
e2(6:7) = nan;
x = 1:8;
data = x2;
errhigh = data+e2;
errlow  =data-e2;
bar(x,data,'LineWidth',1,'FaceColor','none')                
hold on
er = errorbar(x,data,e2,e2,'LineStyle','none','LineWidth',1,'Color',[0.8 0.8 0.8]);    
hold off
box('off')
xticklabels({'Layer 1','Layer 2/3','Layer 4','Layer 5', 'Layer 6','CA1','CA3', 'Other'})
xlabel('Brain region')
ylabel('PC1 weight')
% exportgraphics(f,['PC1_weights_layers2.pdf'],'ContentType','vector')
%%
all_res = '';
for i = 1:length(names)
    all_res =   [all_res  sprintf('%s: %.3f [%.3f,%.3f]', names{i},    data(i), errhigh(i), errlow(i)) '; '];
end
all_res
%% by name for all (not considering px)

outputs.tau = 14./log(1./outputs.fraction);
tbl.tau = 14./log(1./tbl.fraction);
taus_all = [];
g_all = [];
names = {'layer 1','layer 2','layer 4','layer 5','layer 6','ca1','ca3'};
for i =1:length(names)
    [taus, group_index] = get_taus_psd(outputs, names{i}, i);
    taus_all = [taus_all ;taus];
    g_all = [g_all; group_index'];
end
[p,~,stats] =anova1(taus_all, g_all, 'g');
[c,m] = multcompare(stats);
%%
ANM = tbl.ANM == 'R2_M2';
Slice =  tbl.Slice == 11;
all = ANM & Slice;
tbl2 = tbl(all,:)

%%
f=figure(5);
clf
f.Color='w';
f.Units = 'centimeters'; 
f.Position = [6,6,4,6];
x2 = m(1:end, 1);
e2 =  m(1:end,2);
x = 1:7;
data = x2;
errhigh = data+e2;
errlow  =data-e2;
bar(x,data,'LineWidth',1,'FaceColor','none')                
hold on
er = errorbar(x,data,e2,e2,'LineStyle','none','LineWidth',1,'Color',[0.8 0.8 0.8]);    
hold off
box('off')
xticklabels(names)
xlabel('Brain region')
ylabel('Lifetime (days)')
ylim([6,16])
% exportgraphics(f,['Lifetime_layers2.pdf'],'ContentType','vector')
%%
all_res = '';
for i = 1:length(names)
    all_res =   [all_res  sprintf('%s: %.1f [%.2f,%.1f]', names{i},    data(i), errhigh(i), errlow(i)) '; '];
end
all_res
%%
outputs.tau = 14./log(1./outputs.fraction);
[p,~,stats] = anova1(outputs.tau, outputs.EE);
[c,m] = multcompare(stats);
m = varfun(@mean,outputs,'GroupingVariables',{ 'ANM'}, 'InputVariables','tau');
ci = varfun(@(x) {bootci(1000,@mean,x)} ,outputs,'GroupingVariables',{'ANM'}, 'InputVariables','tau');
x = varfun(@mean,outputs,'GroupingVariables',{ 'ANM'}, 'InputVariables','tau');
g = [0,0,1,0,0,1];
[~,~,stats] = anova1 (x.mean_tau, g);
[c2,m2] = multcompare(stats);
%% Sub plot C
f=figure(22);
clf
f.Color='w';
f.Units = 'centimeters'
f.Position = [6   5   3   5.3];
colors = ['m','m','g','m','m','g'];
x= [1,1.05,1.5,0.9,0.95,1.55];
alpha = 0.33;  
for i=1:6
    cc = ci.Fun_tau{i};
    mm = m.mean_tau(i);
    xneg = mm-cc(1);
    xpos = cc(2) - mm;
    h = errorbar(x(i),mm,xneg ,xpos, ['s' colors(i)], 'MarkerFaceColor', colors(i), 'MarkerSize',3);
    hold on 
% Set transparency (undocumented)
    set([h.Bar, h.Line], 'ColorType', 'truecoloralpha', 'ColorData', [h.Line.ColorData(1:3); 255*alpha])
    set([h.Cap, h.MarkerHandle], 'EdgeColorType', 'truecoloralpha', 'EdgeColorData', [h.Cap.EdgeColorData(1:3); 255*alpha])
    set(h.MarkerHandle, 'FaceColorType', 'truecoloralpha', 'FaceColorData', [h.Cap.FaceColorData(1:3); 255*alpha])
   

end
ylim([10,16])
xlim([0.75, 1.8])
xticks([0.975, 1.525])
xticklabels({'EE','Control'})
box('off')
ylabel('Lifetime (days)')
%

errorbar(1, m2(1,1), m2(1,2) , m2(1,2), 'sm', 'MarkerFaceColor', 'm', 'Linewidth',1.5, 'MarkerSize',3);
errorbar(1.5, m2(2,1), m2(2,2) , m2(2,2), 'sg', 'MarkerFaceColor', 'g', 'Linewidth',1.5, 'MarkerSize',3);

% exportgraphics(f,['Lifetime_Animals.pdf'],'ContentType','vector')  
sprintf('EE: %.2f +- %.2f, Control:  %.2f +- %.2f',  m2(1,1), m2(1,2), m2(2,1), m2(2,2))
%% CCF level 5 based analysis
CCF_tree = getCCF_tree();
[~, CCF_tbl] = getLabelTables();   
level =5;
new_names = {};
new_ids = [];
for i = 1:height(outputs)
    id = outputs.CCF_ID(i);
    [id_out,name_out] = get_id_by_CCF_level(CCF_tree, CCF_tbl, id, level, exclude);
    new_ids(i) = id_out;
    new_names{i} = name_out;
end
outputs.CCF_new_ids = new_ids';
outputs.CCF_new_names = new_names';
%%
[group, id] = findgroups(outputs(:,[1,16]));
level5 = table;
for i = 1:height(id)
    current = outputs(group==i,:);
    if height(current) < 7
%         level5 = [outputs; current];
        continue
    else
        current2 = current(1,:);
        current2.N =sum(current.N);
        current2.tau = wmean(current.tau, current.N);
        level5 = [level5; current2];
    end
end
%%
ci = varfun(@(x) {bootci(1000,@mean,x)} ,level5,'GroupingVariables',{'CCF_new_names'}, 'InputVariables','tau');
m = varfun(@mean,level5,'GroupingVariables',{ 'CCF_new_names'}, 'InputVariables','tau');

hold on;
f=figure(33);
clf
f.Color='w';
f.Position = [680   525   241   453];
colors = ['m','m','g','m','m','g'];
x= 1:height(m)-1 ;
for i=1:height(m)-1
    cc = ci.Fun_tau{i};
    mm = m.mean_tau(i);
    xneg = mm-cc(1);
    xpos = cc(2) - mm;
    bar(i, mm,'LineWidth',1,'FaceColor','none' )
        hold on 

    h = errorbar(x(i),mm,xneg ,xpos, 'LineStyle','none','Color',[0.8,0.8,0.8]);


end
ylim([6,11])
xlim([0 height(m)])
box off;
xticks(x)
xticklabels(m.CCF_new_names)
%%

m = varfun(@mean,outputs,'GroupingVariables',{ 'CCF_new_names'}, 'InputVariables',{'tau', 'N'});
s = varfun(@std,outputs,'GroupingVariables',{ 'CCF_new_names'}, 'InputVariables',{'tau', 'N'});
index = m.GroupCount > 20;
m = m(index, :);
s = s(index, :);
se = s.std_tau ./ sqrt(s.GroupCount);
%%
figure(11)
clf
bar(1:height(m)-1, m.mean_tau(1:end-1),'LineWidth',1,'FaceColor','none')
hold on

errorbar(m.mean_tau(1:end-1),se(1:end-1), 'LineStyle','none','Color',[0.8,0.8,0.8])

xticks(1:height(m)-1)
xticklabels(m.CCF_new_names)
box off;
ylim([7,11])
xlim([0,height(m)])
%% Try with anovaN
[pNew_AP, E] =discretize(tbl2.AP,10);
tbl2.AP2 = pNew_AP;
[group, id] = findgroups(tbl2(:,[3,6,20]));
n=10;
values = [];
group_anm = {};
group_EE = [];
group_ccf = [];
for i = 1:height(id)
    if ~mod(i,10)
        disp(i)
    end
    current = tbl2(group==i,:);
    for j =1:height(current)
        v = current.tau_values{j};
        s = size(v);
        if s(2) > 1
            disp(i)
        end
        max_len = min(n, s(1));
        values = [values; v(1:max_len)];
        anm = current.ANM{j};
        group_anm = [group_anm repmat(current.ANM(j), 1, max_len)];
        group_EE = [group_EE repmat(current.EE(j), 1, max_len)];
        group_ccf = [group_ccf repmat(current.CCF_ID(j), 1, max_len)];
    end
end
%%
[p,tbl,stats,terms] = anovan(values, {group_EE, group_ccf}, "model","full");
[c,m] = multcompare(stats, "Dimension",2);

%% diff expression bootstrap pixels
[pNew_AP, E] =discretize(tbl2.AP,10);
tbl2.AP2 = pNew_AP;
[group, id] = findgroups(tbl2(:,[6, 20]));
p_all = [];
ratios = [];
ee_true_all = [];
ee_false_all = [];
names_all= {};
index_all = {};
n_boot = 300;
n_select = 30;
sd_all = [];
for i = 1:height(id)

    if ~mod(i,10)
        disp(i./height(id))
    end
    index = group==i;
%     if sum(index) <= 6
%         continue
%     end
    current = tbl2(group==i,:);
    ee = current.EE; 
    if length(unique(current.ANM)) < 6
        continue
    end
%     g_anm = [];
%     g_ee = [];
%     k=1;
    if sum(ee==1)
         ee_false = current.tau_values(ee==1);
         tau_false = cat(1,ee_false{:} );
%          lengths = cellfun(@length, ee_false);
%          for g =1:length(lengths)
%             g_anm = [g_anm ones(1,lengths(g))*k];
%             g_ee = [g_ee ones(1,lengths(g))*1];
%             k=k+1;
%          end
%          ee_false_all = [ee_false_all mean(tau_false)];
    end
    if sum(ee==0)
         ee_true = current.tau_values(ee==0);
         tau_true = cat(1,ee_true{:} );
%          lengths = cellfun(@length, ee_true);
%          for g =1:length(lengths)
%             g_anm = [g_anm ones(1,lengths(g))*k];
%             g_ee = [g_ee ones(1,lengths(g))*2];
%             k=k+1;
%          end
%          ee_true_all = [ee_true_all mean(tau_true)];
    end
    n_select = min(n_select, length(tau_true));
    boot_index = randi(length(tau_true), n_select, n_boot);
    boot_val = tau_true(boot_index);
    means_true = mean(boot_val, 1);

    n_select = min(n_select, length(tau_false));
    boot_index = randi(length(tau_false), n_select, n_boot);
    boot_val = tau_false(boot_index);
    means_false = mean(boot_val, 1);
    ratios2 = means_false./means_true;
    p = signrank(ratios2-1, [], 'method','exact');
%     x = [tau_false; tau_true];
%     p = anovan(x, {g_anm, g_ee}, 'model','interaction', 'nested',[0,1;0,0], 'varnames',{'ANM','EE'}, 'display','off');
    p_all = [p_all p];
    ratios = [ratios  mean(ratios2)];
    sd_all = [sd_all std(ratios2)];
    names_all = [names_all  current.Name(1)];
    index_all = [index_all {find(index)}];
end
disp('end')
