function output = get_subField_ims(file,startX, startY, sizeX, sizeY, FOV_num, writeFile, p_range)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%%
if nargin < 6
    FOV_num = 0;
end
if nargin < 7
    writeFile = 1;
end
if nargin < 8
    p_range = [0.3, 99.7];
end

%%
[~, ~, sizeC, sizeZ] = getSizesBF(file);
f = bfopenS(file, startX, startY, sizeX, sizeY, 1);
data = f{1};
data = cat(3, data{:,1});
data = permute(reshape(data, sizeY,sizeX, sizeZ, sizeC), [1,2,4,3]);
%%
output = single(data);
data = single(data);
data(data == 0) = nan;
p_all = squeeze( prctile(data, p_range,[1,2,4]));
for c = 1:sizeC
    current = squeeze(data(:,:,c,:));
    p_low = single(p_all(1,c));
    p_high = single(p_all(2,c));
    current(current<p_low) = p_low;
    current(current>p_high) = p_high;
    current = current - p_low;
    current = current ./ p_high;
    output(:,:,c,:) = current;
end
%%
if writeFile
    RGB = zeros(sizeY,sizeX,3, sizeZ);
    RGB(:,:,1, :) = output(:, :, 1, :);
    RGB(:,:,2, :) = output(:, :, 3, :);
    RGB(:,:,3, :) = (output(:, :, 2, :) + output(:, :, 4, :) + output(:, :, 5, :))./3;
    out_filename = sprintf('%s_Sub%d_rgb.h5',file(1:end-4), FOV_num)
    h5create(out_filename, '/rgb', size(RGB), 'ChunkSize', [200,200, 1, 1])
    h5write(out_filename, '/rgb', RGB)
end

