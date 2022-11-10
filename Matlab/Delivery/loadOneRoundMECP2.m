function loadOneRoundMECP2(current, basePath, savePath)

%% Calibration

%% load data
cd(basePath)
fprintf('ANM: %s\n', current.ANM)
cd(current.Folder)
round_dir  = pwd();
masks      = dir('Mask*.mat');
dates      = datetime({masks.date});
latest     = dates == max(dates);
mask       = masks(latest).name;
loaded     = load(mask);
data       = loaded.data;
mask_date  = masks(latest).date;
%% resave data after conversion to uM and to in-vivo/ex-vivo
%% get file names
Anm                 = sprintf('ANM%d', current.ANM);
current.MaskData    = mask_date;
current.Ch_Names    = data.Ch_Names;
current             = add_marker_MECP2(current);
fprintf('ANM:%d @ %s,%s\n', current.ANM, pwd(), mask);
cd(round_dir);
objProb             = dir('*Object*.tif');
probFiles           = sort_nat({objProb.name});
filenames           = cell(1, length(probFiles));
for f =1:length(probFiles)
    k               = strfind(probFiles{f},'_');
    filenames(f)    = {probFiles{f}(1:k(end))};
end
current.filenames   = filenames;
current.Image_Size  = data.Image_Size;
current.x           = cell2mat(data.x);
current.y           = cell2mat(data.y);
current.z           = cell2mat(data.z);
current.CellType    = cell2mat(data.Cell_Type);
current.Pixels      = data.Pixels;
current.Pixels_mm   = current.Pixels * 5.6778 / 1000000;
%% up to here !!!!!!!
values = cell2mat(data.Values(:, 1));
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
save(sprintf('ANM%d', current.ANM), 'current')
end

