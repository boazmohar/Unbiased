function  makeRGB_CCF_Align_PSD()
% makeRGB_CCF_Align()
%   loades series 4 and writes a png 24bit color file for aligmnet with the
%   allen CCF 3.0
orig = 'X:\Svoboda Lab\Boaz\PSD95-HT EE\EE Round2\SlideScanner\2022-01-16 09-23\s2\EE_Round2_10x\';
new = 'E:\Unbiased\PSD95\PSD95_EE_14 days\ReExport\EE_Round2_10x\'
files = dir([new '*.tiff']);
files = {files.name}';
files = strcat(new, files);
series=0;
satRange=[0.5,99.5];
for i = 1:length(files)
    filename = files{i};
    makeRGB_PSD_reexport(filename, series, satRange);
    disp('Done');
end
end

