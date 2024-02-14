%%
tbl_all = load_data_glua2();
r = strcmp(tbl_all.groupName, 'rule2');
tbl_all3 = tbl_all(~r,:);
r = strcmp(tbl_all3.groupName, 'negative');
tbl_all3 = tbl_all3(~r,:);
%%
[group, id] = findgroups(tbl_all3(:,[1,6]));
maxNum =30;
tbl_all2 = {};
for i = 1:height(id)

    if ~mod(i,100)
        disp(i./height(id))
    end
    index = group==i;
    current = tbl_all3(group==i,:);
    data = cell2mat(current.tau_values(:));
    max_index = length(data);
    items = min(max_index, maxNum);
    data = data(randi(max_index, 1, items));
    new = current(ones(1,items), ["ANM","groupName","Name","tau", "layer", "Line"]);
    new.tau = data;
   
    tbl_all2 = [tbl_all2 {new}];
end
df = cat(1, tbl_all2{:});

df2 = df;
df2.Name = categorical(df.Name);
df2.ANM = categorical(df.ANM);
df2.groupName = reordercats(categorical(df.groupName), ...
    { 'control','random','EE','rule'});
% df2.groupName = categorical(df.groupName);
df2.layer = categorical(df.layer);
df2.tau = double(df.tau);
df2 = movevars(df2, "tau", "After", "Line");

%%

aov = anova(df2,'tau ~ groupName + Name', ...
    'randomFactors',{'groupName'});
plotComparisons(aov,'Line')
stats(aov)
multcompare(aov, 'groupName')
%%


EE_mle = fitlme(df2,'tau ~ -1 + groupName + (1|Name) + (1|ANM)', ...
    'Verbose', true, 'CheckHessian',true, 'DummyVarCoding','full')
%%
coeff = dataset2table(EE_mle.Coefficients);
[B,BNames,stats] = randomEffects(EE_mle);

stats_tbl = dataset2table(stats)
%%
difference = stats.Estimate(5:end);
pval = stats.pValue(5:end);
s2 = dataset2table(stats(5:end, 1:end));
s2 = sortrows(s2,'Estimate','descend');
pval = s2.pValue;
pval(pval == 0) =1e-10;
scatter(s2.Estimate, -log10(pval));
%%

mdl = stepwiselm(df2(:,2:end));
c = mdl.Coefficients;
c = sortrows(c,"Estimate","descend"); 
%%
p = 3;
PriorMdl = bayeslm(p,ModelType="lasso", ...
    VarNames=["ANM" "groupName" "Name"]);
X = df2(:,{'ANM','groupName','Name'});
y = df2(:,'tau');
PosteriorMdl = estimate(PriorMdl,X,y);