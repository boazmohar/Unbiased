%% list relevent files
close all; clc; clear;
cd('E:\ImagingDM11\MECP2\RawFiles')
% cd('E:\ImagingDM11\ReImage_40x\New561Laser\Sox10')
files = dir('*.tif');
% files = dir('*Sti*.czi');
files = {files.name}'
%% get small FOVs
xySize = 400;
FOV_start = [1400, 3000];
for i = 4:length(files)
    file = files{i};
    info = getInfoIJ(file);
    for k = 1:2
        data = getData(file, info, FOV_start(k), FOV_start(k),...
            xySize, xySize);
        %%
        output = single(data);
        p_all = squeeze( prctile(data, [0.3, 99.7],[1,2,4]));
        for c = 1:info.chs
            current = single(squeeze(data(:,:,c,:)));
            p_low = single(p_all(1,c));
            p_high = single(p_all(2,c));
            current(current<p_low) = p_low;
            current(current>p_high) = p_high;
            current = current - p_low;
            current = current ./ p_high;
            output(:,:,c,:) = current;
        end
        %%
        RGB = zeros(xySize,xySize,3, info.zs);
        RGB(:,:,1, :) = output(:, :, 1, :);
        RGB(:,:,2, :) = output(:, :, 3, :);
        RGB(:,:,3, :) = (output(:, :, 2, :) + output(:, :, 4, :) + output(:, :, 5, :))./3;
        out_filename = sprintf('%s_Sub%d_rgb.h5',file(1:end-4), k)
        h5create(out_filename, '/rgb', size(RGB), 'ChunkSize', [200,200, 1, 1])
        h5write(out_filename, '/rgb', RGB)
    end
    break
end
%% other subfields with issues
get_subField(files{1},1800, 4400, 840, 1400, 3) % hole
get_subField(files{4},1700, 5200, 600, 900, 3) % White Matter
get_subField(files{4},6000,4000, 600, 600, 4) % More Cortex
%% get for iba
cd('X:\Svoboda Lab\Boaz\ReImage_40x\New561Laser\Shading_Stitching')
files = dir('*Iba1*.ims');
files = {files.name}'
%%
get_subField_ims(files{1}, 1400, 1400, 800, 800, 1);
get_subField_ims(files{1}, 3000, 3000, 800, 800, 2);
get_subField_ims(files{2}, 1400, 1400, 600, 600, 1);
get_subField_ims(files{2}, 3000, 3000, 600, 600, 2);
get_subField_ims(files{3}, 1400, 1400, 600, 600, 1);
get_subField_ims(files{3}, 3000, 3000, 600, 600, 2);
%% get for large NeuN ANM64
cd('X:\Svoboda Lab\Boaz\ReImage_40x\New561Laser\Shading_Stitching')
files = dir('*FOV2*.ims');
files = {files.name}'
%%
get_subField_ims(files{1}, 18400, 5400, 800, 800, 2);
get_subField_ims(files{1}, 950, 6290, 900, 900, 3);

%% Cerrebelum got coor from series 5, *16
file = 'ANM460140_NeuN_Slide3_Section5_Half_Shading Correction.ims';
get_subField_ims(file, 925*16, 125*16, 800, 800, 1);
get_subField_ims(file, 15550, 5330, 800, 800, 2);
%% New tilted
file = 'ANM460141_NeuN_Slide1a_Section3_Half2_Shading Correction.ims';
get_subField_ims(file, 1400*16, 170*16, 800, 800, 1);
get_subField_ims(file, 1000*16, 370*16, 800, 800, 2);
