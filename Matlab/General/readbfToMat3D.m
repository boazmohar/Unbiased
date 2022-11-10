function datamat = readbfToMat3D(filename)
%[datamat, info] = readbfToMat(filename, colors, format)
%   Detailed explanation goes here
data = bfopen(filename);
data1 = data{1,1};
datamat = cat(3,data1{:,1});
