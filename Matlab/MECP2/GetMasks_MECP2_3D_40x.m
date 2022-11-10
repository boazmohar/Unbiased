% function GetMasks_MECP2_Controls(n_ch)r
%%GetMasks_par_files_v3(cores, ch_names)
% cores: namber of paralilizaiton to do < 1 ==> none
% ch_names: raw file endings to read, defulats to : 'FITC','Texas','Cy5'

% Pixel: 1-nuclei, 2-bg, 3-AutoFlu, 4-Border, 5-NoSignal, 6-Artifact (hole)
% Object: 1-NeuN, 2-Merge, 3-Negative, 4-Split
clear; close all; clc
cd('V:\users\moharb\MECP2')
dirBase = pwd;
rawDir = 'E:\ImagingDM11\MECP2\RawFiles';
n_ch=5;
objPred     = dir('*Object*.tiff');
objPred   = sort_nat({objPred.name})'
numFiles    = length(objPred);
fprintf('found %d probFiles\n', numFiles)
x           = cell(numFiles,1);
y           = cell(numFiles,1);
z           = cell(numFiles,1);
Values      = cell(numFiles, 1);
Background  = cell(numFiles, 1);
Cell_Type   = cell(numFiles,1);
Pixels      = zeros(numFiles,1);
SE          = strel('cuboid',[25,25,3]);
SE2         = strel('cuboid',[3,3,1]);
all_sz      = zeros(numFiles,3);
info_all    = cell(numFiles,1);
rawInfo_all = cell(numFiles,1);
ANMs        = cell(numFiles,1);
%%
for i =5:numFiles
    cd(dirBase);
    % read prob image
    filename    = objPred{i};
    info = imfinfo(filename);
    Zs = length(info);
    info = info(1);
    fprintf('Loading i: %d, file: %s, Zs: %d\n',i, filename, Zs);
    predections = zeros(info.Width, info.Height, Zs, 'uint16');
    for z_ = 1:Zs
        predections(:,:,z_) = imread(filename, z_)';
        fprintf('%d,',z_);
    end
    fprintf('Done\n')
    sz              = size(predections);
    all_sz(i, :)    = sz;
    bw_NeuN         = predections == 1; % NeuN
    bw_Merge        = predections == 2; % NeuN
    bw_Neg          = predections == 3; % Negatvie
    bw_Split        = predections == 4; % NeuN
    clear predections
    % read nuropil from h5
    k           = strfind(filename,' ');
    baseName    = filename(1:k(1)-8);
    ANMs{i}     = baseName(4:9);
    objIdent    = [baseName '_Object Identities.h5'];
    % get labels
    labelAll    = squeeze(h5read(objIdent, '/exported_data'));
    labelNeuN   = uint32(bw_NeuN) .* labelAll;
    labelMerge  = uint32(bw_Merge) .* labelAll;
    labelNeg    = uint32(bw_Neg) .* labelAll;
    labelSplit  = uint32(bw_Split) .* labelAll;
    
    Ids_NeuN    = unique(labelNeuN);
    Ids_Merge   = unique(labelMerge);
    Ids_Neg     = unique(labelNeg);
    Ids_Split   = unique(labelSplit);
    Ids_NeuN    = Ids_NeuN(2:end);
    Ids_Merge   = Ids_Merge(2:end);
    Ids_Neg     = Ids_Neg(2:end);
    Ids_Split   = Ids_Split(2:end);
    fprintf('i: %d,NeuN:%d,Merge:%d, Neg:%d, Split:%d\n',  i, length(Ids_NeuN), length(Ids_Merge), length(Ids_Neg),...
        length(Ids_Split));
    clear bw_NeuN bw_Neg bw_Split bw_Merge  
    clear labelSplit labelNeuN labelMerge labelNeg
    pixelName   = [baseName '_Probabilities.h5']; 
    px          = h5read(pixelName, '/exported_data');
    fprintf('Done reading %s\n', pixelName)
    bw_not      = px(:, :, 1, :) > 0.2 | px(:, :, 3, :) > 0.2 | px(:, :, 6, :) > 0.2;
    bw_not      = squeeze(bw_not); % exclude from neuropil other nuclei AutoFlu and Artifact
    bw_not_d    = ~imdilate(bw_not, SE2); % avoid border pixels by dilating
    Pixels(i)   = sqrt(sum(px(:, :, 3, :) < 0.2, 'all'));
    clear px bw_not
    % get raw data
    cd(rawDir)
    rawFile = [baseName(1:end-4) '.tif'];
    rawInfo = getInfoIJ(rawFile);
    all_channels = getData(rawFile, rawInfo);
    cd(dirBase)
    numLabelsAll        = max(labelAll, [],'all');
    
    forground           = zeros(numLabelsAll, n_ch);
    background          = zeros(numLabelsAll, n_ch);
    xyz = regionprops(labelAll,'Centroid');
    xyz = round(cell2mat({xyz.Centroid}'));
 
    minX = xyz(:, 2) - 50;
    maxX = xyz(:, 2) + 50;
    minX(minX<1) = 1;
    maxX(maxX>sz(1)) = sz(1);
    minY = xyz(:, 1) - 50;
    maxY = xyz(:, 1) + 50;
    minY(minY<1) = 1;
    maxY(maxY>sz(2)) = sz(2);
    minZ = xyz(:, 3) - 5;
    maxZ = xyz(:, 3) + 5;
    minZ(minZ<1) = 1;
    maxZ(maxZ>sz(3)) = sz(3);
    % compute forground and background for each label
    fprintf('Starting masks\n')
    for l = 1:numLabelsAll
        current         = labelAll(minX(l):maxX(l), minY(l):maxY(l), ...
            minZ(l):maxZ(l));
        current2        = current == l;
        bw_not_d2       = bw_not_d(minX(l):maxX(l), minY(l):maxY(l), ...
            minZ(l):maxZ(l));
        sz2             = size(current2);
        blank           = zeros(sz2(1), sz2(2), sz2(3), 'logical');
        blank(current2) = true;
        blank           = logical(imdilate(blank, SE) - current2);
        blank           = blank & bw_not_d2;
        for ch = 1:n_ch
            ch_current          = squeeze(all_channels(minX(l):maxX(l), ...
                minY(l):maxY(l), ch, minZ(l):maxZ(l)));
            forground(l, ch)    = mean(ch_current(current2), 'all');
            background(l, ch)   = mean(ch_current(blank), 'all');
        end
       
        if mod(l, 50) == 0
            fprintf('.')
        end
        if mod(l, 2000) == 0
            fprintf('\n')
        end
    end
    
    fprintf('Done masks\n')
    % store values
    x{i}            = xyz(:, 1);
    y{i}            = xyz(:, 2);
    z{i}            = xyz(:, 3);
    Background{i}   = background;
    Values{i}       = forground;
    types           = zeros(numLabelsAll,1);
    info_all{i}     = info;
    rawInfo_all{i}  = rawInfo;
    types(int16(Ids_NeuN))    = 1;
    types(int16(Ids_Merge))  = 2;
    types(int16(Ids_Neg))    = 3;
    types(int16(Ids_Split))  = 4;
    Cell_Type{i}            = types;
    fprintf('Finished iteration %d of %d\n', i, numFiles);
end
% make data structure
data            = struct();
data.x          = x;
data.y          = y;
data.z          = z;
data.Values     = Values;
data.BG         = Background;
data.Cell_Type  = Cell_Type;
data.Pixels     = Pixels;
data.Image_Size = all_sz;
data.ANMs       = ANMs;
data.info       = info_all;
data.rawInfo    = rawInfo_all;
name            = ['MaskData_MECP2_3D_' datestr(now, 'yyyy-mm-dd_HH-MM-SS')];
% sace and cleanup
save(name, 'data')
fprintf('Saved: %s\n', name);
%%
clear
load('MaskData_MECP2_3D_2020-06-23_20-14-16','data');
load('MaskData_MECP2_3D_2020-06-26_14-38-09','data'); % sox10 - 66
%%
configuration = '880_40x_newLaser';
[Slope, Blank] = getCalibration(configuration);
%%
ch=2;
lims = [300,300,300,600,600,500,600];
for i = 1:length(data.x)
    f1 = figure(i);
    f1.Name = data.ANMs{i};
    lim = lims(i);
    clf
    vals = data.Values{i};
    bg = data.BG{i};
    for j = 1:5
       
        subplot(2,3,j)
        scatter(vals(:,j), bg(:,j))
%         xlim([0,lim])
%         ylim([0,lim]);
%         hold on;
%         plot([0, lim],[0 lim], 'k:', 'linewidth',3)
    end
end
%%
means = [];
for i = 6:length(data.ANMs)
    f1 = figure(i);
    clf
    f1.Color = 'w';
    titles = {'DAPI','JF608 (P)','GFP','JF669 (I)', 'JF552 (I)'};
    dyes = [0, 608,0, 669,552];
    val_all = data.Values{i};
    bg_all = data.BG{i};
    for c = 1:5
        subplot(2,3,c)
        current = val_all(:,c);
        bg = bg_all(:,c);
        dye = dyes(c);
        if dye > 0
            current = (current - Blank(dye)) ./ Slope(dye);
            current = current .* 1000;
            bg  = (bg - Blank(dye)) ./ Slope(dye);
            bg  = bg .* 1000 ;
        end
        histogram(current-bg,20);
        hold on;
        me =nanmedian( current-bg)
        plot([me, me],[0,205], 'k:', 'linewidth',3)
%         ylim([0,25])
        title(titles{c})
        means(c) = mean(current);
        box off
        if c > 2
            xlabel('F (AU)');
        end
        if c == 1 || c == 3
            ylabel('#Masks');
        end
        if c ==1
            legend({'Masks','BG'})
        end
        
    end
end
%%
fractions_all1 = {};
fractions_all2 = {};
fractions_all3 = {};
fractions_all1_g = [];
fractions_all2_g = [];
fractions_all3_g = [];
g1 = [];
g2 = [];
g3 = [];
ANM1 = {};
th=1;


titles = {'JF552 (I) of In vivo','Invivo of All'};
dyes = [608,669,552];
chs = [2,4,5];
celltype = 1;
for i = 6:length(data.ANMs)
    f1 = figure(i);
    clf
    f1.Color = 'w';
    f1.Name = data.ANMs{i};
    val_all = data.Values{i};
    bg_all = data.BG{i};
    after_all = zeros(size(val_all,1),3);
    for c_index = 1:3
        c = chs(c_index);
        current = val_all(:,c);
        bg = bg_all(:,c);
        dye = dyes(c_index);
        current = (current - Blank(dye)) ./ Slope(dye);
        current = current .* 1000;
        bg  = (bg - Blank(dye)) ./ Slope(dye);
        bg  = bg .* 1000 ;
        after_all(:,c_index) = current-bg;
    end
    ylim1 = 50;
    % 552 out of 552 + 669
    subplot(3,1,1)
    sum1 = after_all(:,2) + after_all(:,3);
    fraction = after_all(:,2) ./ sum1;
    types = data.Cell_Type{i};
    fraction(fraction<0) = 0;
    fraction(fraction> 10) = 10;
    
    fraction = fraction(types==celltype);
    fractions_all1(i) = {fraction};
    fractions_all1_g = [fractions_all1_g;  fraction];
    g1 = [g1 ones(1,length(fraction))*i];
    ANM1{i} = data.ANMs{i};
   
    histogram(fraction, linspace(0,1,50));hold on;
    me =nanmedian( fraction);
    plot([me, me],[0,ylim1], 'k:', 'linewidth',3)
    ylim([0,ylim1]);
    title(titles{1})
    
    subplot(3,1,2)
    sum1 = after_all(:,1) + after_all(:,2) + after_all(:,3);
    fraction = (after_all(:,3) + after_all(:,2)) ./ sum1;
    fraction(fraction<0) = 0;
    fraction(fraction>10) = 10;
    fraction = fraction(types==celltype);
    histogram(fraction, linspace(0,1,50));hold on;
    me =nanmedian( fraction);
    plot([me, me],[0,ylim1], 'k:', 'linewidth',3)
    ylim([0,ylim1]);
    title(titles{2})
    fractions_all2(i) = {fraction};
    fractions_all2_g = [fractions_all2_g;  fraction];
    g2 = [g2 ones(1,length(fraction))*i]; 
    
    subplot(3,1,3)
    sum1 = after_all(:,1) + after_all(:,2) + after_all(:,3);
    fraction = after_all(:,2) ./ sum1;
    fraction(fraction<0) = 0;
    fraction(fraction>10) = 10;
    fraction = fraction(types==celltype);
    histogram(fraction, linspace(0,1,50));hold on;
    me =nanmedian( fraction);
    plot([me, me],[0,ylim1], 'k:', 'linewidth',3)
    ylim([0,ylim1]);
    title(titles{2})
    fractions_all3(i) = {fraction};
    fractions_all3_g = [fractions_all3_g;  fraction];
    g3 = [g3 ones(1,length(fraction))*i];
end
%% make table
tbl = table();
tbl.ANM = [ANM1 ANM1 ANM1]';
tbl.Fraction = [fractions_all1 fractions_all2 fractions_all3]';
tbl.Interval = [1,2,10,53,22,8*24, 3*24,60, 96, 96, 8*24+1,3*24+2,70,53+96, 22+96]';
tbl.FractionMedian = cellfun(@nanmean, tbl.Fraction);
tbl.std = cellfun(@nanstd, tbl.Fraction);
tbl.count =  cellfun(@length, tbl.Fraction);
tbl.SE = tbl.std ./ sqrt(tbl.count)
%%
f1=figure(11);
f1.Color = 'w';
clf
% validTbl = logical([1,1,1,1,1,1,1,0,0,0,0,0]);
% validTbl2 = logical([0,0,0,0,0,0,0,1,0,0,0,0]);
% errorbar(tbl.Interval(validTbl)*60+rand(sum(validTbl),1)*5, tbl.FractionMedian(validTbl),...
%     tbl.SE(validTbl), 'ok')
% hold on
errorbar(tbl.Interval, tbl.FractionMedian, tbl.SE, 'ok')
hold on


errorbar(tbl.Interval(validTbl2)*60, tbl.FractionMedian(validTbl2),...
    tbl.SE(validTbl2), 'xk')
xlabel('\DeltaT between injections (min)')
xticks([10,60,120])
xlim([0, 130])
ylim([0.9, 1])
ylabel('Fraction Pulse')
legend({'After 200nmol dye','After 400nmol dye'},'box','off')
box off

% cftool(tbl.Interval, tbl.FractionMedian)
%%
tbl2 = tbl(:,{'Interval','FractionMedian','std','count','SE'});
statarray = grpstats(tbl2,'Interval');
f1 = figure(33);
clf
f1.Color='w';
x = statarray.Interval;
y = statarray.mean_FractionMedian;
[xData, yData] = prepareCurveData( x, y );
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = 0;
opts.StartPoint = 300;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
h = plot( fitresult, xData, yData);
h(2).LineWidth = 2;
h(1).MarkerSize = 15;
ylim([0,1])
xlabel('Time from pulse (h)', 'fontsize',16)
ylabel('Fraction pulse', 'fontsize',16);
set(gca,'FontSize',16);
l = legend;
l.Box='off';
l.String = {'Data','Fit: y=e^{-x/\tau}'};
box off
ci = confint(fitresult);
t = sprintf('%.0f [%.0f-%.0f]',coeffvalues(fitresult),...
    ci(1),ci(2));
text(20,0.4,['$\tau$ = ' t], 'Interpreter','latex', 'fontsize',16)
%%
i = 6;
dyes = [608,669,552];
chs = [2,4,5];
celltype = 1;
val_all = data.Values{i};
bg_all = data.BG{i};
after_all = zeros(size(val_all,1),3);
for c_index = 1:3
    c = chs(c_index);
    current = val_all(:,c);
    bg = bg_all(:,c);
    dye = dyes(c_index);
    current = (current - Blank(dye)) ./ Slope(dye);
    current = current .* 1000;
    bg  = (bg - Blank(dye)) ./ Slope(dye);
    bg  = bg .* 1000 ;
    after_all(:,c_index) = current-bg;
end
sum1 = after_all(:,1) + after_all(:,2) + after_all(:,3);
fraction = (after_all(:,3) + after_all(:,2)) ./ sum1;
x = data.x{i};
y = data.y{i};
index = data.Cell_Type{i} == 1;
data_ = fraction(index);
min_max = prctile(data_, [0.3, 99.7]);
%% overlay with tif file
in = data.rawInfo{i};
tif_file = in.Filename;
img = getData(tif_file, in);
img_max = max(squeeze(img(:, : , 3, :)), [], 3);
%%
f1 = figure(1);
clf
f1.Color='w';
ax1 = axes;
imshow(img_max',[300, 20000],'Parent',ax1)
hold on;
ax2 = axes;
ax = scatter(ax2,y(index), x(index), 30, data_, 'fill',...
    'MarkerFaceAlpha',0.8);%%Link them together
set(gca, 'ydir', 'reverse')
c=colorbar();
c.Label.String = 'Fraction Pulse';
c.FontSize = 20;
caxis(min_max)
%%Hide the top axes
ax2.Visible = 'off';
ax1.Visible = 'off';
% ax2.XTick = [];
% ax2.YTick = [];
%%Give each one its own colormap
colormap(ax2,'jet')
% colormap(ax1,'grey')
%%Then add colorbars and get everything lined up
P = get(ax1,'Position');
XLIM = get(ax1,'XLim');
YLIM = get(ax1,'YLim');
PA = get(ax1,'PlotBoxAspectRatio');
set(ax2,'Position',P,'XLim',XLIM,'YLim',YLIM,'PlotBoxAspectRatio',PA)
% plot(ax1, [1500,2500],[500 500], 'w', 'linewidth',3)
% text(ax1, 2000, 280, '250um', 'color','w', 'HorizontalAlignment','center', 'FontSize',20)
% export_fig 'File1.eps' -eps -nocrop
% export_fig 'File1.png' -png -nocrop

%% Total MECP2
f1 = figure(2);
clf
f1.Color='w';
ax1 = axes;
imshow(img_max',[300, 20000],'Parent',ax1)
hold on;
ax2 = axes;
ax = scatter(ax2,y(index), x(index), 30, sum1(index)./1000, 'fill',...
    'MarkerFaceAlpha',0.8);%%Link them together
set(gca, 'ydir', 'reverse')
c=colorbar();
c.Label.String = 'Total MeCP2 (uM)';
c.FontSize = 20;
min_max = prctile( sum1(index)./1000, [0.3, 99.7]);
caxis(min_max)
%%Hide the top axes
ax2.Visible = 'off';
ax1.Visible = 'off';
% ax2.XTick = [];
% ax2.YTick = [];
%%Give each one its own colormap
colormap(ax2,'jet')
% colormap(ax1,'grey')
%%Then add colorbars and get everything lined up
P = get(ax1,'Position');
XLIM = get(ax1,'XLim');
YLIM = get(ax1,'YLim');
PA = get(ax1,'PlotBoxAspectRatio');
set(ax2,'Position',P,'XLim',XLIM,'YLim',YLIM,'PlotBoxAspectRatio',PA)
% plot(ax1, [500,1500],[6000 6000], 'w', 'linewidth',3)
% text(ax1, 1000, 5780, '250um', 'color','w', 'HorizontalAlignment','center', 'FontSize',20)
% export_fig 'File4Total.eps' -eps -nocrop
% export_fig 'File4Total.png' -png -nocrop
%%
yReg = fraction(index);
x1 = ones(size(x(index),1),1);
xReg = [x1 y(index)  x(index)];
[b,bint,r,rint,stats] = regress(yReg,xReg)