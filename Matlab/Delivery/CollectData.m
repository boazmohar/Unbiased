%% clear all
clear; close all;
unbiased_dm11 = 'V:\users\moharb\Unbiased';
unbiased_dropbox = 'F:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis';
cd(unbiased_dm11)
%%
folders = dir('Round*');
folders = {folders.name};
for i = 1:length(folders)
    cd(unbiased_dm11);
    folder = folders{i};
    round = folder(end);
    
    switch round
        case '2'
            anm1 = struct('ANM',59,'invivo_dye',669,'exvivo_dye',585,...
                'cond','single-20-20', 'Round',2, 'Folder', folder, 'virus_name', 'GFP');
            anm2 = struct('ANM',60,'invivo_dye',669,'exvivo_dye',585,...
                'cond','half-20-20', 'Round',2, 'Folder', folder, 'virus_name', 'GFP');
            All_anms = [anm1, anm2];
        case '3'
            anm1 = struct('ANM',85,'invivo_dye',585,'exvivo_dye',669,...
                'cond','single-30-10','Round',3, 'Folder', folder, 'virus_name', 'GFP');
            anm2 = struct('ANM',86,'invivo_dye',585,'exvivo_dye',669,...
                'cond','single-10-30', 'Round',3, 'Folder', folder, 'virus_name', 'GFP');
            All_anms = [anm1, anm2];
        case '5'
            anm1 = struct('ANM',31,'invivo_dye',669,'exvivo_dye',585,...
                'cond','single-20-20', 'Round',5, 'Folder', folder, 'virus_name', 'GFP');
            anm2 = struct('ANM',32,'invivo_dye',669,'exvivo_dye',585,...
                'cond','double', 'Round',5, 'Folder', folder, 'virus_name', 'GFP');
            anm3 = struct('ANM',33,'invivo_dye',669,'exvivo_dye',585,...
                'cond','double', 'Round',5, 'Folder', folder, 'virus_name', 'GFP');
            anm4 = struct('ANM',34,'invivo_dye',669,'exvivo_dye',585,...
                'cond','single-10-30', 'Round',5, 'Folder', folder, 'virus_name', 'GFP');
            anm5 = struct('ANM',35,'invivo_dye',669,'exvivo_dye',585,...
                'cond','single-10-30', 'Round',5, 'Folder', folder, 'virus_name', 'GFP');
            All_anms = [anm1, anm2, anm3, anm4, anm5];
        case '6'
            anm1 = struct('ANM',40,'invivo_dye',552,'exvivo_dye',669,...
                'cond','3pm, 7pm', 'Round',6, 'Folder', folder, 'virus_name', 'GFP');
            anm2 = struct('ANM',66,'invivo_dye',552,'exvivo_dye',669,...
                'cond','3pm, 7pm', 'Round',6, 'Folder', folder, 'virus_name', 'GFP');
            anm3 = struct('ANM',67,'invivo_dye',552,'exvivo_dye',669,...
                'cond','3pm, 9am', 'Round',6, 'Folder', folder, 'virus_name', 'GFP');
            anm4 = struct('ANM',68,'invivo_dye',552,'exvivo_dye',669,...
                'cond','9am', 'Round',6, 'Folder', folder, 'virus_name', 'GFP');
            All_anms = [anm1, anm2, anm3, anm4];
        case '7'
            anm1 = struct('ANM',39,'invivo_dye',552,'exvivo_dye',669,...
                'cond','single-20-20', ...
                'Round',7, 'Folder', folder, 'virus_name', 'GFP');
            anm2 = struct('ANM',36,'invivo_dye',541,'exvivo_dye',669,...
                'cond','single-20-20', 'Round',7, 'Folder', folder, 'virus_name', 'GFP');
            anm3 = struct('ANM',37,'invivo_dye',559,'exvivo_dye',669,...
                'cond','single-20-20', 'Round',7, 'Folder', folder, 'virus_name', 'GFP');
            anm4 = struct('ANM',38,'invivo_dye',533,'exvivo_dye',669,...
                'cond','single-20-20', 'Round',7, 'Folder', folder, 'virus_name', 'GFP');
%             anm5 = struct('ANM',40,'invivo_dye',533,'exvivo_dye',669,...
%                 'cond','single-20-20', 'Round',7, 'Folder', folder, 'virus_name', 'GFP');
            All_anms = [anm1, anm2, anm3, anm4];
        case '8'
            
            anm1 = struct('ANM',31,'invivo_dye',669,'exvivo_dye',585,...
                'cond','single-20-20','Round',8, 'Folder', folder, 'virus_name', 'GFP');
            anm2 = struct('ANM',33,'invivo_dye',552,'exvivo_dye',669,...
                'cond','single-20-20',  'Round',8, 'Folder', folder, 'virus_name', 'GFP');
            anm3 = struct('ANM',32,'invivo_dye',612,'exvivo_dye',552,...
                'cond','single-20-20', 'Round',8, 'Folder', folder, 'virus_name', 'GFP');
            anm4 = struct('ANM',34,'invivo_dye',608,'exvivo_dye',552,...
                'cond','single-20-20', 'Round',8, 'Folder', folder, 'virus_name', 'GFP');
            anm5 = struct('ANM',35,'invivo_dye',609,'exvivo_dye',552,...
                'cond','single-20-20', 'Round',8, 'Folder', folder, 'virus_name', 'GFP');
            All_anms = [anm1, anm2, anm3, anm4, anm5];
        otherwise
            continue
    end
    
    loadOneRound(All_anms, unbiased_dm11, unbiased_dropbox);
    
end
