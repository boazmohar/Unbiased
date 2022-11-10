function RGB = makeRGB_PSD(file, series, satRange)
%RGB = makeRGB_Ilastik(file, useMulticore, series, writeH5, satRange)
%  reads data with parfor, normalize and write a hdf5 file

if nargin < 2
    series = 0;
end

if nargin < 3
    satRange = [0.3, 99.7];
end

[sizeY, sizeX, ~, sizeZ] = getInfoBF(file, series);

RGB = zeros(sizeX,sizeY,3, 'uint8');
for c = 1:3
    % load
    fprintf('Loading Ch: %d \n', c)
    data = loadBF_ch(file, series, c);
    data = single(data);
    fprintf('To single done\n')
    
    % clip and norm to 1 per channel
    p = prctile(data, satRange,'all');
    p_low = p(1);
    p_high =p(2);
    data(data<p_low) = p_low;
    data(data>p_high) = p_high;
    data = data - p_low;
    data = data ./ p_high;
    RGB(:,:,c) = uint8(data.*255);
    fprintf('Added to RGB\n\n')
end
outFilename = sprintf('%s_s%d_rgb_uint8_s001.png', file(1:end-5), series);
imwrite(RGB, outFilename)
end

