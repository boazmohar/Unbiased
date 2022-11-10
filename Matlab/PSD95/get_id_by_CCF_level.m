function [id_out,name_out] = get_id_by_CCF_level(CCF_tree, CCF_tbl, id, names)
if id == 0
    id_out  = 0;
    name_out = 'root';
else
    index_tree = find(CCF_tree.id == id);
    depth = CCF_tree.depth(index_tree);
    if depth > level
        p = split(CCF_tree.structure_id_path(index_tree), '/');
        id_out = str2num(p{level+1});
    else
        id_out = id;
    end
    index_tblNew = CCF_tbl.ID == id_out;
    name_out = CCF_tbl.Name{index_tblNew};
    if contains(name_out,exclude)
          id_out  = 0;
         name_out = 'root';
    end
end
end