function [info] = getInfoIJ(filename)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
info = imfinfo(filename, 'tif');
ijInfo = split(info.ImageDescription);
images = regexp(ijInfo{2}, '=(\d*)', 'tokens');
info.images = str2num(images{1}{1});
chs = regexp(ijInfo{3}, '=(\d*)', 'tokens');
info.chs = str2num(chs{1}{1});
zs = regexp(ijInfo{4}, '=(\d*)', 'tokens');
info.zs = str2num(zs{1}{1});
end

