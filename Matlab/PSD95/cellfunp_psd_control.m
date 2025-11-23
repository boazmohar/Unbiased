function result = cellfunp_psd_control(func, c, UniformOutput, LabelTables, calibType)
% Parallel version of cellfun that uses parfor inside

parfor i = 1:numel(c)
    result{i} = func(c{i}, LabelTables, calibType);
end
if UniformOutput % uniform
    result = cell2mat(result);
end