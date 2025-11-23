function tbl = get_table_glua2(name, round, LabelTables, applyCalib)
if nargin < 2
    round = 1;
end
% parse animal ID, Sex, group and pulus chase interval
[ANM, sex, group, age, line, p_c_interval] = parse_name_glua2(name, round); 
% find AP location
[AP, index] =  get_AP_glua2(name, ANM);
% load allen png
if nargin < 3 || isempty(LabelTables)
    atlas_dir = 'D:\VisuAlign-v0_8\ABA_Mouse_CCFv3_2017_25um.cutlas\';
    [~, LabelTables] = getLabelTables(atlas_dir);
end
if nargin < 4
    applyCalib = 1;
end
png_name = [name(1:end-4) '_nl.png'];
if ~isfile(png_name)
    tbl = table;
    return
end
png = imread(png_name);

% raw data (nan < threshold)
try
    mask_name = [name(1:end-4) '_Probabilities.tif'];
    mask = imread(mask_name);
catch
    disp('issue')
end
t = 128; % 0-256 mask that was exported from ilastik to segment tissue 
bin_mask = uint16(mask > t);
try % different export software from slide scanner makes different names
    pulse_name = [name(1:end-4) '_CY5.tiff'];
    chase_name = [name(1:end-4) '_CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
catch
    pulse_name = [name(1:end-4) '-CY5.tiff'];
    chase_name = [name(1:end-4) '-CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
end
raw_size = size(rawPulse);
bin_mask2 = single(imresize(bin_mask,raw_size(1:2), 'nearest'));
rawPulse = single(rawPulse) .* bin_mask2;
rawPulse(rawPulse==0) = nan;
rawChase = single(rawChase).* bin_mask2;
rawChase(rawChase==0) = nan;
%% add hemishperes
label_size = size(mask);
if isfile('hemi.mat')
    gt_hemi = load('hemi.mat');
    gt_hemi = gt_hemi.gTruth;
    gt_index = find(contains(gt_hemi.DataSource.Source,name), 1);
    if ~isempty(gt_hemi.LabelData{gt_index,1}{1})
        tbl = do_hemi_glua2(gt_hemi, gt_index, label_size, png, LabelTables, rawPulse, rawChase,...
            ANM, sex, group, age, line, AP, index, name, round, applyCalib, p_c_interval);
    else
        tbl = do_both_glua2(png, LabelTables, rawPulse, rawChase,...
            ANM, sex, group, age, line, AP, index, name, round, applyCalib, p_c_interval);
    end
else
    tbl = do_both_glua2(png, LabelTables, rawPulse, rawChase,...
            ANM, sex, group, age, line, AP, index, name, round, applyCalib, p_c_interval);
end