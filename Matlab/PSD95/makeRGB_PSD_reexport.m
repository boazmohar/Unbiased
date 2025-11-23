function RGB = makeRGB_PSD_reexport(file, satRange)

if nargin < 2
    satRange = [0.3, 99.7];
end

info = imfinfo(file);
sizeX = info.Width;
sizeY = info.Height;

RGB = zeros(sizeY,sizeX,3, 'uint8');
names = {'DAPI.tiff', 'CY3.tiff', 'CY5.tiff' };
for c = 1:3
    full_name = [file(1:end-8) names{c}];
    data = imread(full_name);
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
outFilename = sprintf('%srgb.png', file(1:end-8));
imwrite(RGB, outFilename)
end

