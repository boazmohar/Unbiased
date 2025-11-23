function valid = get_valid_index(tbl,threshold, noise)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%%
exclude = {'root','fiber tracts', 'ventricular systems'};
ex_index = [];
for i = 1:height(tbl)
    current = tbl.new_names{i};
    if contains(current, exclude)
        ex_index = [ex_index i];
    end
end
if nargin < 2
    threshold = 20; %px
end
if nargin < 2
    noise = 160; %px
end
valid = find(tbl.N > threshold);
valid = setdiff(valid, ex_index);
end