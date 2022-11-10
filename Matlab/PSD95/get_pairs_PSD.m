%%get pairs
clear all
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
normalized = outputs;
for i = 1:height(m)
    anm = m.ANM{i};
    index = contains(outputs.ANM,anm);
    index_mean = contains(m.ANM,anm);
    normalized.fraction(index) = normalized.fraction(index) / m.mean_fraction(index_mean);
end
%%

m2 = varfun(@mean,normalized,'GroupingVariables',{'ANM'}, 'InputVariables','fraction')
%%

[group, id] = findgroups(normalized(:,[6]));
pair_df = [];
pair_ids = [];
pair_types = [];
for i = 1:height(id)
    idx = find(group==i);
    current = normalized(idx,:);
    rows = height(current);
    if rows == 1
        continue
    else
        for k=1:rows-1
            for j = k+1:rows
                a = current(k,:);
                b = current(j,:);
                df = a.fraction - b.fraction;
                if a.EE == b.EE
                    pair_df = [pair_df; df; df*-1];
                    pair_ids = [pair_ids; [idx(k) idx(j)]; [idx(j) idx(k)]];
                    if a.EE
                         pair_types = [pair_types; 1; 2];
                    else
                         pair_types = [pair_types; 2; 1];
                        
                    end
                elseif a.EE
                    pair_df = [pair_df; df; ];
                    pair_ids = [pair_ids; [idx(k) idx(j)]; ];
                    pair_types = [pair_types; 3];
                else
                    pair_df = [pair_df; df*-1];
                    pair_ids = [pair_ids;  [idx(j) idx(k)]];
                    pair_types = [pair_types; 3];
                end
            end
        end
                        
    end
end
%%
pairs = struct('df',pair_df,'ids',pair_ids,'types',pair_types );
save('pairs_v1.mat','pairs','-v7.3');
%%
[C, ia, ic] = unique(pair_ids, 'rows');
