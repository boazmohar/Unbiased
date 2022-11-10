function  makeRGB_CCF_Align()
% makeRGB_CCF_Align()
%   loades series 4 and writes a png 24bit color file for aligmnet with the
%   allen CCF 3.0
files = dir('*.ims');
sizesGB = cell2mat({files.bytes}')/1000000000;
files = {files.name}';
series=4;
useMulticore = 1;
writeH5=0;
satRange=[0.3,99.7];
useLarge=1;
for i = 1:length(files)
    filename = files{i};
    if sizesGB(i) < 30
        continue
    end
    outFilename = sprintf('%s_s%d_rgb_uint8_s001.png', filename(1:end-4), series);
    if isfile(outFilename)
        continue
    end
    outFilename
    RGB = makeRGB_Ilastik(filename, useMulticore, series, writeH5, satRange, useLarge);

    RGB_Max = nanmax(RGB,[],4);
    RGB_Max_uint8 = uint8(RGB_Max.*255);
    
    imwrite(RGB_Max_uint8, outFilename)
    disp('Done');
end
end

