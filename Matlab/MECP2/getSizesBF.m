function [sizeX, sizeY, sizeC, sizeZ] = getSizesBF(filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
bfInitLogging();
reader = bfGetReader(filename);
%%
reader.setSeries(0);
sizeC = reader.getSizeC();
sizeZ = reader.getSizeZ();
sizeX = reader.getSizeX();
sizeY = reader.getSizeY();
end

