function [taus, group_index] = get_taus_psd(tbl, name, group_id)
index = find(contains(tbl.Name, name, 'IgnoreCase',true));
taus = tbl.tau(index);
group_index = ones(1, length(taus)) .* group_id;