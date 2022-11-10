%% Figure 4c - Example Coronal section from ANM 
close all;
clc;
clear;
cd('Z:\moharb\MECP2')
tbl = compute_tbl(0);
%%
ANMs = {'473364', '473365', '473366'};
for i = 1:3
    cellType = 1;
    ANM = ANMs{i};
    IHC = 'NeuN';
    intervalType = 2;
    Section = 0;
    Slide =0;
    AP = -2;
    Large = 1;
    data = getOneEntry(tbl, ANM, IHC, cellType, intervalType, Slide, Section, AP, Large);
    f = showFractionXY(data );
    f.Units = 'centimeters';
    f.Position = [5, 5, 8,8];
    colorbar('off')
    colormap('viridis')
    im = gca();
    alpha(im,0.4);
%     im.CLim = [0.5, 0.8];R
    im.CLim = [5,13];
    outName = sprintf('MeCP2_Coronal_%s_v2.png',ANM) ;
    export_fig(outName, '-png', '-r300');
    fprintf('ANM %s: Interval %.1f, Min %.2f, Max %.2f\n', ANM, data.interval/24.0, im.CLim(1), im.CLim(2))
end
%% Cerebellum
    cellType = 1;
    ANM = '460141';
    IHC = 'NeuN';
    intervalType = 2;
    Section = 0;
    Slide =1;
    AP = -5;
    Large = 1;
    data = getOneEntry(tbl, ANM, IHC, cellType, intervalType, Slide, Section, AP, Large);
    f = showFractionXY(data);
    f.Units = 'centimeters';
    f.Position = [5, 5, 8,8];
    colorbar('off')
    colormap('viridis')
    im = gca();
    alpha(im,0.4);
    im.CLim = [5,13];
    outName = sprintf('MeCP2_Cer_%s_v2.png',ANM) ;
    export_fig(outName, '-png', '-r300');
    %%
    
   f=figure(111);
   clf
    f.Units = 'centimeters';
    f.Position = [5, 5, 8,8];
    f.Color='w'
   im = imshow(rand(200,200));
    colormap('viridis')
    colorbar()
    clim([5,13]);
    outName = sprintf('MeCP2_Cer_%s_cbv2.eps',ANM) ;
    export_fig(outName, '-eps');