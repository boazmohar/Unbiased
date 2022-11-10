clear all
load('tbl_v1.mat', 'tbl')
%%
th = 20; %px
valid = tbl.N > th;

tbl2 = tbl(valid,:);
%%

ap_tbl = varfun(@length,tbl,'GroupingVariables',{'ANM', 'AP'}, 'InputVariables','EE');
a = discretize(ap_tbl.AP,18);
c = arrayfun(@(x)length(find(a == x)), unique(a), 'Uniform', false)
%%
[group, id] = findgroups(tbl2(:,[1,2,3, 6]));
outputs = table;
for i = 1:height(id)
    current = tbl2(group==i,:)
    if height(current) == 1
        outputs = [outputs; current]
    else
        wmean(current.fraction, current.N)
        break
    end
end