function loadOneRound(All_anms, basePath, savePath)

%% Calibration

%% load data
cd(basePath)
cd(sprintf('Round%d', All_anms(1).Round))
round_dir  = pwd();
masks      = dir('Mask*.mat');
dates      = datetime({masks.date});
latest     = dates == max(dates);
mask       = masks(latest).name;
loaded     = load(mask);
data       = loaded.data;
mask_date  = masks(latest).date;
%% resave data after conversion to uM and to in-vivo/ex-vivo
for i = 1:length(All_anms)
    %% get file names
    current             = All_anms(i);
    Anm                 = sprintf('ANM%d', current.ANM);
    current.MaskData    = mask_date;
    
    current.Ch_Names    = data.Ch_Names;
    current             = add_marker(current);
    fprintf('R:%d,ANM:%d @ %s,%s\n', current.Round, current.ANM, ...
        pwd(), mask);
    cd(round_dir);
    if strcmpi(current.virus_name, 'mRuby')
        cd('RFP')
        objProb             = dir('*Object*.tif');
        cd('..')
    else
        objProb             = dir('*Object*.tif');
    end
    probFiles           = sort_nat({objProb.name});
    files2              = contains(probFiles, Anm);
    files3              = probFiles(files2);
    filenames           = cell(1, length(files3));
    for f =1:length(files3)
        k               = strfind(files3{f},'_');
        filenames(f)    = {files3{f}(1:k(end))};
    end
    current.filenames   = filenames;
    current.Image_Size  = data.Image_Size(files2, :);
    current.x           = cell2mat(data.x(files2));
    current.y           = cell2mat(data.y(files2));
    current.z           = cell2mat(data.z(files2));
    current.z           = current.z - min(current.z);
    current.CellType    = cell2mat(data.Cell_Type(files2));
    current.Pixels      = data.Pixels(files2);
%     current.Pixels_mm   = current.Pixels * 5.6778 / 1000000;
 
    values = cell2mat(data.Values(files2, 1));
    bg = cell2mat(data.BG(files2, 1));
    current.virus     = values(:, current.virus_index);
    current.invivo    = values(:, current.invivo_index);
    current.exvivo    = values(:, current.exvivo_index);
    current.virus_bg  = bg(:, current.virus_index);
    current.invivo_bg = bg(:, current.invivo_index);
    current.exvivo_bg = bg(:, current.exvivo_index);
    if isfield(current, 'configuration')
        [Calibration, Blank] = getCalibration(current.configuration);
    else
        [Calibration, Blank] = getCalibration();
    end
    current.blank_invivo = Blank(current.invivo_dye);
    current.blank_exvivo = Blank(current.exvivo_dye);
    current.slope_invivo = Calibration(current.invivo_dye);
    current.slope_exvivo = Calibration(current.exvivo_dye);
    current.invivo = (current.invivo - current.blank_invivo)...
        / current.slope_invivo;
    current.invivo_bg = (current.invivo_bg - current.blank_invivo)...
        / current.slope_invivo;
    current.exvivo = (current.exvivo - current.blank_exvivo)...
        / current.slope_exvivo;
    current.exvivo_bg = (current.exvivo_bg - current.blank_exvivo)...
        / current.slope_exvivo;
    current.virus_sub = current.virus - current.virus_bg;
    current.invivo_sub = current.invivo - current.invivo_bg;
    current.exvivo_sub = current.exvivo- current.exvivo_bg;
    current.sum = current.invivo + current.exvivo;
    current.fraction = current.invivo ./ current.sum;
    current.sum_sub = current.invivo_sub + current.exvivo_sub;
    current.fraction_sub = current.invivo_sub ./ current.sum_sub;
    cd(savePath);
    save(sprintf('Round%d_ANM%d', current.Round, current.ANM), 'current')
end
end

