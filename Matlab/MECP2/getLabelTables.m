function [orig,new] = getLabelTables()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
labels = "E:\AlignToAllen\VisuAlign-v0_8\ABA_Mouse_CCFv3_2017_25um.cutlas\labels_orig.txt";
orig = importlabelfile(labels, [16, Inf]);
labels = "E:\AlignToAllen\VisuAlign-v0_8\ABA_Mouse_CCFv3_2017_25um.cutlas\labels.txt";
new = importlabelfile(labels, [16, Inf]);
end

