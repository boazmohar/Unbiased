%%
close all; clc; clear;
cd('E:\Dropbox (HHMI)\Projects\Unbised\PSD95_EE')
load('Turnover_tbl_v4.mat')
%%
expression = '[lL]ayer\s(\d)';
[tokens] = regexp(tbl2.Name,expression,'tokens', 'once','emptymatch');
layers = {};
for i =1:length(tokens)
    c = tokens{i};
    if ~mod(i,30)
        disp(i./length(tokens))
    end
    if ~isempty(c)
         v = str2double(c);
        if v == 3 || v == 2
            v="layer 2/3";
        else
            v = sprintf('layer %s', c);
        end
        layers(i) = {string(v)};
    else
        layers(i) = {"other"};
    end
end
tbl2.layer = layers';
ca1 = contains(tbl2.Name, 'CA1');
tbl2.layer(ca1) = {"CA1"};
ca2 = contains(tbl2.Name, 'CA2');
tbl2.layer(ca2) = {"CA2"};
ca3 = contains(tbl2.Name, 'CA3');
tbl2.layer(ca3) = {"CA3"};
% take 100 values from each and make a flat table
[group, id] = findgroups(tbl2(:,[1,6]));
maxNum = 30;
tbl_all = {};
for i = 1:height(id)

    if ~mod(i,100)
        disp(i./height(id))
    end
    index = group==i;
    current = tbl2(group==i,:);
    data = cell2mat(current.tau_values(:));
    max_index = length(data);
    items = min(max_index, maxNum);
    data = data(randi(max_index, 1, items));
    new = current(ones(1,items), ["ANM","EE","Name","tau", "layer"]);
    new.tau = data;
   
    tbl_all = [tbl_all {new}];
end
df = cat(1, tbl_all{:});

df2 = df;
df2.Name = categorical(df.Name);
df2.ANM = categorical(df.ANM);
df2.EE = categorical(df.EE);
df2.layer = categorical([df.layer{:}]');
df2.tau = double(df.tau);
%%
clc
EE_mle = fitlme(df2,'tau ~   1 + EE + (1|ANM)+ (1|Name)');
% 
% 

% comp=compare(lme2,lme)
%%
coeff = dataset2table(EE_mle.Coefficients);
[~,~,stats] = randomEffects(EE_mle);
random_vars = dataset2table(stats);
anms = random_vars(1:6, [2,4,5,6,7,8,9,10]);
anms.EE = [1,1,2,1,1,2]';
%%
F = fitted(EE_mle);
anms = categories(unique(df2.ANM));
all_f = [];
ees =  categories(unique(df2.EE));
for anm = 1:6
    f = F(df2.ANM == anms{anm});
    all_f = [all_f f(1)];

end

%%
figure(1)
clf
x = [1,1,2,1,1,2];
y = all_f;
% scatter(x, y);
% hold on
se = random_vars.SEPred(1:6);
errorbar(x, y, se, '*')
%% layers
Layer_lme = fitlme(df2,'tau ~ EE+ layer + (1|ANM) ')
%%
[B,Bnames,stats] = randomEffects(Layer_lme);
stats2 = dataset2table(stats);
stats3 = stats2(7:end,2:end);
for i = 1:height(stats3)
    row = stats3(i,:);
    Level = row.Level{1};
    name = split(Level,' ');
    name2 = join(name(1:end-1), ' ');
    stats3.Level(i) = name2;
    stats3.Name(i) = name(end);
end
%%
[group, id] = findgroups(stats3(:,1));
maxNum = 100;
tbl_all = {};
for i = 1:height(id)

    if ~mod(i,10)
        disp(i./height(id))
    end
    index = group==i;
    current = stats3(group==i,:);
    if length(unique(current.Name)) ==1
        continue
    end
    row = current(1,1:3);
    f = strcmp(current.Name,'false');
    t = strcmp(current.Name,'true');
%     if current.pValue(f) > 0.00001 && current.pValue(t) > 0.00001
%         continue
%     end
    ratio = current.Estimate(t) - current.Estimate(f);
    row.Estimate = ratio;
   tbl_all = [tbl_all {row}];
end
ratio_tbl = cat(1, tbl_all{:});
ratio_tbl = sortrows(ratio_tbl,'Estimate','descend')
%%
expression = '[lL]ayer\s(\d)';
[tokens] = regexp(ratio_tbl.Level,expression,'tokens', 'once','emptymatch');
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
ratio_tbl.layer = layers';
ca1 = contains(ratio_tbl.Level, 'CA1');
ratio_tbl.layer(ca1) = 7;
ca3 = contains(ratio_tbl.Level, 'CA3');
ratio_tbl.layer(ca3) = 8;
[group, id] = findgroups(ratio_tbl.layer);
idx = group > 1 & group < 7;
[p,~,stats] = anova1(ratio_tbl.Estimate(idx), group(idx)-1)
 
[c,m] = multcompare(stats, 'CriticalValueType','hsd');
%
f=figure(2);
clf
f.Color='w';
f.Units = 'centimeters';
f.Position = [6,6,5,7];
x2 = m(end:-1:1, 1)*100 - 100;
e2 =  m(end:-1:1,2)*100;
x = 1:length(id)-3;
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