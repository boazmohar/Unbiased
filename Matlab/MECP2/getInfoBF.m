function [sizeX,sizeY, sizeZ, sizeC] = getInfoBF(filename, seriesNum)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if nargin<2
    seriesNum = 0;
end
bfInitLogging('INFO');
r = loci.formats.Memoizer(bfGetReader(), 0);
r.setId(filename);
r.setSeries(seriesNum);
sizeX = r.getSizeX();
sizeY = r.getSizeY();
sizeZ = r.getSizeZ();
sizeC = r.getSizeZ();
end

