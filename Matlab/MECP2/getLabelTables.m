function [orig,new] = getLabelTables(directory)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if nargin == 0
    directory = "Y:\AlignToAllen\VisuAlign-v0_8\ABA_Mouse_CCFv3_2017_25um.cutlas\";
end
labels = strcat(directory,"labels_orig.txt");
orig = importlabelfile(labels, [16, Inf]);
labels = strcat(directory,"labels.txt");
new = importlabelfile(labels, [16, Inf]);
end

