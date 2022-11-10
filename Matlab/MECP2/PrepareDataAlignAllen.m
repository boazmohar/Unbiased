
%% load the 4th series (~2000x2000) and make a RGB png image (24bit)
makeRGB_CCF_Align()

%% 
% 1. copy to E:\AlignToAllen\rgb24bit_png
% 2. start E:\AlignToAllen\QuickNII\FileBuilder.bat
% 3. save XML to E:\AlignToAllen\rgb24bit_png
% 4. load the XML and align in QuickNII
% 5. export json and load in VisuAlign
% 6. export to get a png with colors coresponding to
% 'E:\AlignToAllen\VisuAlign-v0_8\ABA_Mouse_CCFv3_2017_25um.cutlas\labels.txt'
% 7. Copy back to working directory and rename to [filename(1:end-4) % '_label.png']
%%
clear; close all;clc
%% Get data and CCF tree
tbl = compute_tbl(0);
% data = tbl(242,:); % 66 wrong
% data = tbl(182,:); % 65 wrong!
% data = tbl(26,:) % 140
% data = tbl(74,:); % 141
% data = tbl(122,:); % 64
plotFlag = 1;
[CCF_tbl, CCF_ids] = getCCF_ids(data, plotFlag);
%%
close all
level=5;
th=80;
plotFlag=1;
[index_tree, ids_th, IdIndexs2, names_th,r,g] = extractIDsLevelTh(data, CCF_ids, CCF_tbl, level, th, plotFlag);

[p,~,stats] =kruskalwallis(r, g');
multcompare(stats);
%%
%% get cortical layers has 315 in the hiaracy and layer

plotFlag = 1;
[newIds,fraction_all,group_all, result_struct] = extractIDsCorticalLayers(data, CCF_ids, plotFlag);
