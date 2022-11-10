%% table discription:
% Round 1,2,3
% Animal# 1,2,3
% Sex (M/F)
% EE (+/-)
% AP location ('anm'_lin.xml slice, anchoring, oy='%d')
% Allen ID
% Area n px
% Mean_Pulse
% Mean_Chase
% Median_Pulse
% Medina_Chase
% SD_Pulse
% SD_Chase
%% steps:
% List files per animal
baseDir = 'E:\Dropbox (HHMI)\Projects\Unbised\PSD95_EE';
files = dir([baseDir, '\*s2.tif']);
files = {files.name}';

Tables = cellfun(@get_table_psd, files, 'UniformOutput', false);
% Combine accros animals
%%
tbl = cat(1,Tables{:});
save('tbl_v2.mat','tbl','-v7.3')
%%
clear 
load('tbl_v2.mat', 'tbl')
%%
clear 
load('tbl_v1.mat', 'tbl')
%%
th = 20; %px
valid = tbl.N > th;

tbl2 = tbl(valid,:);
%%
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
%%
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
%%
names2 = mintersect(names{:});
%% filter names
r_idx = find(contains(names2, 'root'));
%fiber tracks
CCF_tree = getCCF_tree();
path = CCF_tree.structure_id_path;
fiber_idx = find(contains(path, '1009'));
exclude = {'tract','nerve','peduncle','ventricle','chiasm', 'choroid', 'commissures', 'trapezoid', 'bundle'};

include = 1:length(names2);
for i=1:length(exclude)
    idx = find(contains(names2, exclude{i}));
    include = setdiff(include, idx);
end
include = setdiff(include, r_idx);
include = setdiff(include, fiber_idx);

names_clean = names2(include);
%%
groups = length(names_clean);
norm_mat = zeros(6,groups);
mean_mat = zeros(6,groups);
pulse_mat = zeros(6,groups);
tau_mat = zeros(6,groups);
for i = 1:groups
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
F.Position = [13.0175   13.5996  5    6.0060];
F.Color = 'w';
clf
hold on
scatter(score(:,2), score(:,1), 20, colors, 'fill', 's')
ylabel(sprintf('PC1 %d%% var',round(explained(1)) ))
xlabel(sprintf('PC2 %d%% var',round(explained(2)) ))
saveas(F,'PCA2.pdf');  
%%
figure(2)
clf
histogram(coeff(:,1), -0.2:0.01:0.2)
hold on
histogram(coeff(:,2), -0.2:0.01:0.2)
legend
%%
nn=20
f=figure(3);
clf
f.Color='w'
pc = 1
pc1_abs = abs(coeff(:,pc));
[vals, idxs] = sort(pc1_abs, 'descend');
names_pc1 = names_clean(idxs(1:nn))
subplot(1,2,1)

barh(coeff(idxs(nn:-1:1), pc), 0.9)
% barh(vals(nn:-1:1))
yticklabels(names_pc1(end:-1:1))
yticks(1:nn)
xlabel('PC1 weight')
pc = 2;
pc1_abs = abs(coeff(:,pc));
[vals, idxs] = sort(pc1_abs, 'descend');
names_pc1 = names_clean(idxs(1:nn));
subplot(1,2,2)

barh(coeff(idxs(nn:-1:1), pc), 0.9)
% barh(vals(nn:-1:1))
yticklabels(names_pc1(end:-1:1))
yticks(1:nn)
xlabel('PC2 weight')
% print(f,'PC weight names.png','-dpng','-r300');  
%%
nn=400;
f=figure(4);
clf
f.Color='w';
pc = 1;
pc1_abs = abs(coeff(:,pc));
[~, idxs] = sort(pc1_abs, 'descend');
names_pc1 = names_clean(idxs);
for i=1:nn
    current = lower(names_pc1{i});
    l = strfind(current, 'layer');
    
    current(l+5) = '-';
    l = strfind(current, 'area');
    current = [current(1:l-2) current(l+4:end)];
    names_pc1{i} = current;
end
subplot(1,2,1)
% wordcloud(names_pc1, 'Shape','rectangle')
title('PC1')
pc = 2;
pc2_abs = abs(coeff(:,pc));
[vals, idxs] = sort(pc2_abs, 'descend');
names_pc2 = names_clean(idxs);
for i=1:nn
    current = lower(names_pc2{i});
    l = strfind(current, 'layer');
    
    current(l+5) = '-';
    l = strfind(current, 'area');
    current = [current(1:l-2) current(l+4:end)];
    names_pc2{i} = current;
end
subplot(1,2,2)
% wordcloud(names_pc2, 'Shape','rectangle')
title('PC2')
%%
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
nn=240;
f=figure(4);
clf
f.Color='w';
pc = 1;
pc1_abs = abs(coeff(:,pc));
[sorted, idxs] = sort(pc1_abs, 'descend');
colors = distinguishable_colors(6, 'w');
names_pc1 = names_clean(idxs(1:nn));
for i=1:nn
    c = lower(names_pc1{i});
    if contains(c, 'layer 1')
        color = colors(1,:);
        a1 = bar(i, sorted(i), 'FaceColor', color);
    elseif contains(c, 'layer 2')
        color = colors(2,:);
        a2 = bar(i, sorted(i), 'FaceColor', color);
    elseif contains(c, 'layer 4')
        color = colors(3,:);
        a3 = bar(i, sorted(i), 'FaceColor', color);
    elseif contains(c, 'layer 5')
        color = colors(4,:);
        a4 = bar(i, sorted(i), 'FaceColor', color);
    elseif contains(c, 'layer 6')
        color = colors(5,:);
        a5 = bar(i, sorted(i), 'FaceColor', color);
    else
        color = colors(6,:);
        a6 = bar(i, sorted(i), 'FaceColor', color);
    end
    hold on
end
xticks('auto')
xlabel('PCA coeff #')
ylabel('PCA weight')
legend([a1,a2,a3,a4,a5,a6],{'Layer 1','Layer 2/3','Layer 4','Layer 5', 'Layer 6', 'Other'}, 'NumColumns',3, 'Box','off')
box('off')
%%
nn=516;

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
    else
        other(end+1) = sorted(i);
        g(end+1) = 6;
    end
end
xx = [l1(2:end), l23(2:end), l4(2:end),l5(2:end),l6(2:end),other(2:end)];
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
x = 1:6;
data = x2;
errhigh = data+e2;
errlow  =data-e2;

bar(x,data,'LineWidth',1,'FaceColor','none')                

hold on

er = errorbar(x,data,e2,e2,'LineStyle','none','LineWidth',1,'Color',[0.8 0.8 0.8]);    


hold off
box('off')
% ylim([0, 3.5])
xticklabels({'Layer 1','Layer 2/3','Layer 4','Layer 5', 'Layer 6', 'Other'})

xlabel('Brain region')
ylabel('PC1 weight')

% exportgraphics(f,['PC1_weights_layers2.pdf'],'ContentType','vector')
%%  
xticks('auto')
xlabel('PCA coeff #')
ylabel('PCA weight')
legend([a1,a2,a3,a4,a5,a6],{'Layer 1','Layer 2/3','Layer 4','Layer 5', 'Layer 6', 'Other'}, 'NumColumns',3, 'Box','off')
box('off')
%%
figure(4)
clf
for i = 1:16
    subplot(4,4,i)
    name = names_pc1(i);
    % name=   "Medial habenula" 
    
    current = normalized(contains(normalized.Name,name),:);
 
    barh(current.fraction(end:-1:1)*100)
    title(name)
    yticks(1:6)
%     yticklabels(names_plot(end:-1:1))
    xlim([90 160])
    xlabel('% diff from mean')
end
%%

pairs = load('pairs_v1.mat','pairs');
%
[C, ia, ic] = unique(pair_ids, 'rows');

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
f.Position = [680   525   241   453];
colors = ['m','m','g','m','m','g'];
x= [1,1.05,1.5,0.9,0.95,1.55];
alpha = 0.33;  
for i=1:6
    cc = ci.Fun_tau{i};
    mm = m.mean_tau(i);
    xneg = mm-cc(1);
    xpos = cc(2) - mm;
    h = errorbar(x(i),mm,xneg ,xpos, ['s' colors(i)], 'MarkerFaceColor', colors(i));
    hold on 
% Set transparency (undocumented)
    set([h.Bar, h.Line], 'ColorType', 'truecoloralpha', 'ColorData', [h.Line.ColorData(1:3); 255*alpha])
    set([h.Cap, h.MarkerHandle], 'EdgeColorType', 'truecoloralpha', 'EdgeColorData', [h.Cap.EdgeColorData(1:3); 255*alpha])
    set(h.MarkerHandle, 'FaceColorType', 'truecoloralpha', 'FaceColorData', [h.Cap.FaceColorData(1:3); 255*alpha])
   

end
ylim([6,11])
xlim([0.75, 1.8])
xticks([0.975, 1.525])
xticklabels({'EE','Control'})
box('off')
ylabel('Half-life (day)')
%

errorbar(1, m2(1,1), m2(1,2) , m2(1,2), 'sm', 'MarkerFaceColor', 'm', 'Linewidth',2);
errorbar(1.5, m2(2,1), m2(2,2) , m2(2,2), 'sg', 'MarkerFaceColor', 'g', 'Linewidth',2);
%%

m = varfun(@mean,outputs,'GroupingVariables',{ 'ANM'}, 'InputVariables','fraction');
s = varfun(@(x) std(x, 1,'all'),outputs,'GroupingVariables',{'ANM'}, 'InputVariables','fraction');
groupnames =  {'ANM1 EE+','ANM2 EE+','ANM3 Control','ANM4 EE+','ANM5 EE+','ANM6 Control'};

colors = distinguishable_colors(6, 'w');
barweb(m.mean_fraction, s.Fun_fraction./sqrt(s.GroupCount), [],['Animals'])
legend( {'ANM1 EE+','ANM2 EE+','ANM3 Control','ANM4 EE+','ANM5 EE+','ANM6 Control'});
ylabel('Fraction Pulse')
%%
[~, ranks] = sort(normalized.fraction)
%%
[p,~,stats, terms] =anovan(normalized.fraction, { normalized.Name, normalized.EE, normalized.AP},'model','full', 'continuous', [3])
multcompare(stats, 'Dimension', [2])
%%
[p,~,stats, terms] =anovan(tbl.fraction, { tbl.Name, tbl.ANM, tbl.AP},'model','full', 'continuous', [3])
multcompare(stats, 'Dimension', [2])
%%
CCF_tree = getCCF_tree();
layerIdx = ~cellfun(@isempty, strfind(CCF_tree.name, 'layer'));
cortexIdx = ~cellfun(@isempty, strfind(CCF_tree.structure_id_path, '315'));
corticalLayersIndex = layerIdx & cortexIdx;
corticalLayersIds = CCF_tree.id(corticalLayersIndex);
% corticalLayersNames = CCF_tree.name(corticalLayersIndex);
uIds = unique( tbl2.CCF_ID);
newIds = intersect(uIds, corticalLayersIds);
if newIds(1) == 0
    newIds = newIds(2:end);
end
[~,loc] = ismember(newIds,CCF_tree.id);
[~, CCF_tbl] = getLabelTables();
names = CCF_tbl.Name(loc);
%%
sz = size(names);
layer = zeros(sz);
for i = 1:sz(1)
      
    k = regexp(names{i}, '\d', 'once');

    layer(i) = str2double( names{i}(k));
end
%%
colors = distinguishable_colors(6, 'w');
figure(1)
clf
hold on
layer_res = cell(6, 2);
frac_all = [];
layer_group = [];
EE_all = [];
for i = 1:size(newIds)
    id = newIds(i);
    l = layer(i);
    color = colors(l,:);
    current = tbl2(id==tbl2.CCF_ID,:);
    plot(current.AP, current.fraction, '.','color',color)
    layer_res{l, 1} = [layer_res{l, 1}; current.AP];
    layer_res{l, 2} = [layer_res{l, 2}; current.fraction];
    frac_all = [frac_all;  current.fraction];
    layer_group = [layer_group; ones(length(current.fraction), 1).*l];
    EE_all = [EE_all;current.EE];
 
end
legend({'1','2','3','4','5','6'})
xlabel('AP axis')
ylabel('Fraction Pulse')
%%
means = cellfun(@mean, layer_res);
stds = cellfun(@std, layer_res);
N = cellfun(@(x) length(x), layer_res);
%%
errorbar( means([1,2,4,5,6],2), stds([1,2,4,5,6],2)./ sqrt(N([1,2,4,5,6],1)))
ylim([0, 0.3])
ax = gca
xticks(1:5)
xticklabels({'L1','L2/3','L4','L5','L6'})
%%

[p,~,stats] =anova1(frac_all, layer_group)
multcompare(stats);
names = {'L1','L2/3','L4','L5','L6'};
yticklabels(names(end:-1:1))
%%

[p,~,stats] =anovan(frac_all, [layer_group,EE_all ], 'varnames', {'Layers','EE'} ,'model','interaction')
multcompare(stats, 'Dimension',[1,2]);
% names = {'L1','L2/3','L4','L5','L6'};
% yticklabels(names(end:-1:1))
%%
figure(2)
clf
plot(layer_res{1,1}, layer_res{1,2},'.')
hold on
plot(layer_res{6,1}, layer_res{6,2},'o')