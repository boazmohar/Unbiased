cd('E:\ImagingDM11\MECP2_ANM468893_10Min_Control\10x')
tif_files = dir('*.czi');
tif_files = {tif_files.name}'
%%
for i = 1:length(tif_files)
    filename = tif_files{i};
    name = [filename(1:end-4) '_dye_nM.tif'];
    name2 = [filename(1:end-4) '_frecPulse.tif'];
    datamat= readbfToMat3D(filename);
    % info = data{1,2}.toString;
    data2 = datamat(:, :, [2,3,4]);
    chs = [552,669,608];
    configuration = '880Upright2Tracks';
    im_out  = convert3DImageTonM(data2, chs, configuration, name);
    sum_chs = [1,2,3];
    fraction_chs = [1,2];
    frec_out = getFractionFromImage3D(im_out, sum_chs, fraction_chs, name2);
end

%%
cd('E:\ImagingDM11\MECP2_ANM468893_10Min_Control\10x')
tif_files = dir('*.czi');
tif_files = {tif_files.name}'
%%
for i = 1:length(tif_files)
    filename = tif_files{i};
    name = [filename(1:end-4) '_dye_nM.tif'];
    name2 = [filename(1:end-4) '_frecPulse.tif'];
    datamat= readbfToMat3D(filename);
    % info = data{1,2}.toString;
    data2 = datamat(:, :, [2,3]);
    chs = [669,608];
    configuration = '880Upright2Tracks';
    im_out  = convert3DImageTonM(data2, chs, configuration, name);
    sum_chs = [1,2];
    fraction_chs = [1];
    frec_out = getFractionFromImage3D(im_out, sum_chs, fraction_chs, name2);
end