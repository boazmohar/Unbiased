function get_subField(file,startX, startY, sizeX, sizeY, FOV_num)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
info = getInfoIJ(file);

data = getData(file, info, startX, startY, sizeX, sizeY);
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
RGB = zeros(sizeY,sizeX,3, info.zs);
RGB(:,:,1, :) = output(:, :, 1, :);
RGB(:,:,2, :) = output(:, :, 3, :);
RGB(:,:,3, :) = (output(:, :, 2, :) + output(:, :, 4, :) + output(:, :, 5, :))./3;
out_filename = sprintf('%s_Sub%d_rgb.h5',file(1:end-4), FOV_num)
h5create(out_filename, '/rgb', size(RGB), 'ChunkSize', [200,200, 1, 1])
h5write(out_filename, '/rgb', RGB)

end

