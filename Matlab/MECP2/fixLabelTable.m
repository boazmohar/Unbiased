%% make each color unique in the label output!
labels = "E:\AlignToAllen\VisuAlign-v0_8\ABA_Mouse_CCFv3_2017_25um.cutlas\labels_orig.txt";
labelsorig = importlabelfile(labels, [16, Inf]);
RGB_mat = [labelsorig.R labelsorig.G labelsorig.B];
[u, ~, ic] = unique(RGB_mat, 'rows');
for i = 1:length(u)
    currentGroup = find(ic == i);
    R_orig = RGB_mat(currentGroup(1), 1);
    for j = 2: length(currentGroup)
        RGB_mat(currentGroup(j), 1) = mod(R_orig(1) + j - 1, 255);
    end
    
end
%%
[u2, ~, ic2] = unique(RGB_mat, 'rows');
assert(length(u2) == height(labelsorig))
tbl_new = labelsorig;
tbl_new.R = RGB_mat(:,1);
tbl_new.G = RGB_mat(:,2);
tbl_new.B = RGB_mat(:,3);
%%
header = makeLabelHeader();
file_h = fopen('E:\AlignToAllen\VisuAlign-v0_8\ABA_Mouse_CCFv3_2017_25um.cutlas\temp.txt','w');
fprintf(file_h, '%s\r\n', header{:});
fprintf(file_h, '    0     0    0    0        0  0  0    "Clear Label"\r\n');
fclose(file_h);
%%
writetable(tbl_new, 'E:\AlignToAllen\VisuAlign-v0_8\ABA_Mouse_CCFv3_2017_25um.cutlas\temp2.txt', 'Delimiter', '\t', ...
    'QuoteStrings',true)