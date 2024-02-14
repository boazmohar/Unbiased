function result = cellfunp(func, c, varargin)
% Parallel version of cellfun that uses parfor inside
p = inputParser;
addParameter(p, 'UniformOutput', 1, @isscalar);
addParameter(p, 'Round', 1, @isscalar);
parse(p, varargin{:});
result = cell(size(c));
parfor i = 1:numel(c)
    result{i} = func(c{i}, p.Results.Round);
end
if p.Results.UniformOutput % uniform
    result = cell2mat(result);
end