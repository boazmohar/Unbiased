function folder = get_folder_anm(ANM)
switch ANM
    case {'BM6','BM7','BM8','BM9'}
        folder = 'V:\moharb\GluA2\GluA2_round1_try1';
    case {'C1','C2','C3','C4'}
        folder = 'V:\moharb\GluA2\GluA2_round2';
    case {'NC1','NC2','NC3','NC4','VH1','VH4'}
        folder = 'V:\moharb\GluA2\GluA2_round3';
    case {'VH2','VH3'}
        folder = 'V:\moharb\GluA2\GluA2_round4';
    case {'EE1','EE2', 'EE3'}
        folder = 'V:\moharb\GluA2\GluA2_round5';
    case {'EE4','EE5'}
        folder = 'V:\moharb\GluA2\GluA2_round6';
end