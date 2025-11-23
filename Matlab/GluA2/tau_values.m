function lme = tau_values(vals, groups, ANMs, n_vals, group_order)
%lme = tau_values(vals, groups, ANMs, n_vals)
%   Detailed explanation goes here
%% get valid and meadian reduce by n_vals
if nargin < 4
    n_vals = 1000;
end
if nargin < 5
    group_order ={'control','EE','random','rule'};
end
tic
vals = cellfun(@(x) x(isfinite(x)), vals, "UniformOutput",false);
sprintf('median reduce %d', floor(toc))
median_block = @(block_struct) median(block_struct.data);
vals2 = cellfun(@(x) blockproc(x, [n_vals,1], median_block), vals, "UniformOutput",false);
lengths = cellfun(@numel, vals2, "UniformOutput",false);
valid = cellfun(@(x) x>0, lengths);
lengths = lengths(valid);
vals2 = vals2(valid);
groups = groups(valid);
ANMs = ANMs(valid);
%% make vectors
group_vector = cellfun(@(x, y) repmat({x}, y,1), groups, lengths,'UniformOutput', false);
anm_vector = cellfun(@(x, y) repmat({x}, y,1), ANMs, lengths,'UniformOutput', false);

%% make into a table

sprintf('making table %d', floor(toc))
tbl = table;
tbl.tau = double(vertcat(vals2{:}));
tbl.group = categorical(vertcat(group_vector{:}));
try
    tbl.group = reordercats(tbl.group, group_order);
catch
    disp('Order problem')
end
tbl.anm = vertcat(anm_vector{:});

sprintf('fitting table %d', floor(toc))
lme = fitlme(tbl, 'tau ~ - 1 + group + (-1 + group|anm)', ...
    'DummyVarCoding','full', CovariancePattern='Isotropic');
lme = {lme};