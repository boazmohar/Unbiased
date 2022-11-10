% function GetMasks_MECP2_Controls(n_ch)r
%%GetMasks_par_files_v3(cores, ch_names)
% cores: namber of paralilizaiton to do < 1 ==> none
% ch_names: raw file endings to read, defulats to : 'FITC','Texas','Cy5'

% Pixel: 1-nuclei, 2-bg, 3-no tissue
% Object: 1-cell, 2-border, 3-small
clear; close all; clc
n_ch=4;
objProb     = dir('*Object*.tif');
probFiles   = sort_nat({objProb.name})';
numFiles    = length(probFiles);
fprintf('found %d probFiles\n', numFiles)
x           = cell(numFiles,1);
y           = cell(numFiles,1);
z           = cell(numFiles,1);
Values      = cell(numFiles, n_ch);
Background  = cell(numFiles, n_ch);
Cell_Type   = cell(numFiles,1);
Pixels      = zeros(numFiles,1);
SE          = strel('square',25);
SE2         = strel('square',3);
all_sz      = zeros(numFiles,2);
ANMs        = cell(numFiles,1);
for i =1:numFiles
    % read prob image
    filename    = probFiles{i};
    try
        fprintf('Loading i: %d, file: %s\n',i, filename);
        prob        = imread(filename);
    catch
        pause(0.1);
        fprintf('Loading i2: %d, file: %s\n',i, filename);
        prob        = imread(filename);
    end
    sz          = size(prob);
    all_sz(i, :)= sz;
    bw_1        = prob == 1; % good
    bw_2        = prob == 2; % border
    bw_3        = prob == 3; % small
    if sum(bw_1(:)) + sum(bw_2(:)) + sum(bw_3(:)) == 0
        fprintf('Skipping: %d', i);
        continue
    end
    % read nuropil from h5
    k           = strfind(filename,' ');
    baseName    = filename(1:k(1)-1);
    ANMs{i}     = baseName(5:10);
 
    pixelName   = [baseName(1:end-3) 'h5'];
    px          = h5read(pixelName, '/exported_data');
    bw_not      = px(1, :, :) > 0.2 | px(3, :, :) > 0.2;
    bw_not      = squeeze(bw_not)'; % exclude from neuropil cells and no tissue
    bw_not_d    = ~imdilate(bw_not, SE2); % avoid border pixels by dilating
    Pixels(i)   = sqrt(sum(px(3, :, :) < 0.2, 'all'));
    % get raw data crop to match RGB version
    all_channels = zeros(sz(1), sz(2), n_ch, 'uint16');
    for ch = 1:n_ch
        if (contains(baseName,'468893') || contains(baseName,'473362')) && ch==4
            continue
        end
        all_channels(:, :, ch) =  imread(baseName,ch);
    end
    % get labels
    label1              = bwlabel(bw_1); % cell
    label2              = bwlabel(bw_2); % saturated
    label3              = bwlabel(bw_3); % small
    numLabels1          = max(label1(:));
    numLabels2          = max(label2(:));
    numLabels3          = max(label3(:));
    numLabelsAll        = numLabels1 + numLabels2 + numLabels3;
    fprintf('i: %d, Found %d good, %d border, %d small\n', ...
        i, numLabels1, numLabels2, numLabels3);
    forground           = zeros(numLabelsAll, n_ch);
    background          = zeros(numLabelsAll, n_ch);
    xy_1 = regionprops(label1,all_channels(:, :, 1),'Centroid');
    xy_1 = cell2mat({xy_1.Centroid}');
    xy_2 = regionprops(label2,all_channels(:, :, 1),'Centroid');
    xy_2 = cell2mat({xy_2.Centroid}');
    xy_3 = regionprops(label3,all_channels(:, :, 1),'Centroid');
    xy_3 = cell2mat({xy_3.Centroid}');
    xy_all = round([xy_1; xy_2; xy_3]);
    minX = xy_all(:, 2) - 50;
    maxX = xy_all(:, 2) + 50;
    minX(minX<1) = 1;
    maxX(maxX>sz(1)) = sz(1);
    minY = xy_all(:, 1) - 50;
    maxY = xy_all(:, 1) + 50;
    minY(minY<1) = 1;
    maxY(maxY>sz(2)) = sz(2);
    % compute forground and background for each label
    for l = 1:numLabelsAll
        if l <= numLabels1
            % cell
            current     = label1==l;
        elseif l <= numLabels1 + numLabels2 && numLabels2 > 0
            % saturated
            current     = label2==(l-numLabels1);
        else
            % small
            current     = label3==(l-(numLabels1 + numLabels2));
        end
        current2        = current(minX(l):maxX(l), minY(l):maxY(l));
        bw_not_d2       = bw_not_d(minX(l):maxX(l), minY(l):maxY(l));
        sz2             = size(current2);
        blank           = zeros(sz2(1), sz2(2), 'logical');
        blank(current2) = true;
        blank           = logical(imdilate(blank, SE) - current2);
        blank           = blank & bw_not_d2;
        for ch = 1:n_ch
            if (contains(baseName,'468893') || contains(baseName,'473362')) && ch==4
                continue
            end
            ch_current          = all_channels(minX(l):maxX(l), minY(l):maxY(l), ch);
            forground(l, ch)    = mean(ch_current(current2), 'all');
            background(l, ch)   = mean(ch_current(blank), 'all');
        end
    end
    % store values
    % for now align to center x, y
    x{i}            = xy_all(:, 1)-sz(1)/2;
    y{i}            = xy_all(:, 2)-sz(2)/2;
    z{i}            = ones(numLabelsAll, 1).*i;
    Background{i}   = background;
    Values{i}       = forground;
    Cell_Type{i}    = [ones(numLabels1, 1); ones(numLabels2, 1)*2; ...
        ones(numLabels3, 1)*3];
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
name            = ['MaskData_MECP2_' datestr(now, 'yyyy-mm-dd_HH-MM-SS')];
% sace and cleanup
save(name, 'data')
fprintf('Saved: %s\n', name);
%%
clear
load  MaskData_MECP2_2020-05-31_15-56-09

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
    for j = 1:4
        if (strcmpi(data.ANMs{i},'468893') || strcmpi(data.ANMs{i},'473362')) && j ==4
            continue
        end
        subplot(2,2,j)
        scatter(vals(:,j), bg(:,j))
        xlim([0,lim])
        ylim([0,lim]);
        hold on;
        plot([0, lim],[0 lim], 'k:', 'linewidth',3)
    end
end
%%
configuration = '880Upright2Tracks';
[Slope, Blank] = getCalibration(configuration);
%%
means = []
for i = 1:length(data.ANMs)
    f1 = figure(i);
    clf
    f1.Color = 'w';
    if strcmpi(data.ANMs{i},'468893') || strcmpi(data.ANMs{i},'473362')
        titles = {'DAPI','JF669 (I)','JF608 (P)'};
        dyes = [669,608];
    else
        titles = {'DAPI','JF552 (I)','JF669 (I)','JF608 (P)'};
        dyes = [552,669,608];
    end
    val_all = data.Values{i};
    bg_all = data.BG{i};
    for c = 1:4
        if (strcmpi(data.ANMs{i},'468893') || strcmpi(data.ANMs{i},'473362')) && c ==4
            continue
        end
        subplot(2,2,c)
        current = val_all(:,c);
        bg = bg_all(:,c);
        if c > 1
            dye = dyes(c-1)
            current = (current - Blank(dye)) ./ Slope(dye);
            current = current .* 1000;
            bg  = (bg - Blank(dye)) ./ Slope(dye);
            bg  = bg .* 1000 ;
        end
        histogram(current-bg,100);
        hold on;
        me =nanmedian( current-bg)
        plot([me, me],[0,200], 'k:', 'linewidth',3)
        ylim([0,200])
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
fractions_all1_g = [];
g1 = [];
fractions_all2_g = [];
g2 = [];
ANM1 = {};
ANM2 = {};
Dyes1_1 = [];
Dyes2_1 = [];
Dyes1_2 = [];
Dyes2_2 = [];
th=1;
for i = 1:length(data.ANMs)
    f1 = figure(i);
    clf
    f1.Color = 'w';
    if strcmpi(data.ANMs{i},'468893') || strcmpi(data.ANMs{i},'473362')
        titles = {'JF669 of Sum'};
        dyes = [669,608];
    else
        titles = {'JF552 (I) of In vivo','Invivo of All'};
        dyes = [552,669,608];
    end
    val_all = data.Values{i};
    bg_all = data.BG{i};
%     SumValue =  Values(:,2) +Values(:,4)+Values(:,5);
%     SumBGs = BGs(:,2) +BGs(:,4)+BGs(:,5);
%     valid = SumValue > (mean(SumBGs) + std(SumBGs)*th);
    after_all = zeros(size(val_all,1),size(val_all,2)-1);
    for c = 2:4
        if (strcmpi(data.ANMs{i},'468893') || strcmpi(data.ANMs{i},'473362') )&& c ==4
            continue
        end
        current = val_all(:,c);
        bg = bg_all(:,c);
        
        dye = dyes(c-1);
        current = (current - Blank(dye)) ./ Slope(dye);
        current = current .* 1000;
        bg  = (bg - Blank(dye)) ./ Slope(dye);
        bg  = bg .* 1000 ;
        after_all(:,c-1) = current-bg;
        
        
    end
    ylim1 = 500;
    subplot(2,1,1)
    sum1 = after_all(:,1) + after_all(:,2);
    if strcmpi(data.ANMs{i},'468893') || strcmpi(data.ANMs{i},'473362')
        fraction = after_all(:,1) ./ sum1;
    else
         fraction = after_all(:,2) ./ sum1;
    end
    
    fraction(fraction<0) = 0;
    fraction(fraction> 10) = 10;
    fractions_all1(i) = {fraction};
    fractions_all1_g = [fractions_all1_g;  fraction];
    g1 = [g1 ones(1,length(fraction))*i];
    Dyes1_1(i) = dyes(1);
    Dyes1_2(i) = dyes(2);
    ANM1{i} = data.ANMs{i};
    if strcmpi(data.ANMs{i},'468893') ||  strcmpi(data.ANMs{i},'473362')
        
        histogram(fraction, linspace(0.5,1,50))
        hold on;
        me =nanmedian( fraction);
        plot([me, me],[0,ylim1], 'k:', 'linewidth',3)
        ylim([0,ylim1]);
        title(titles{1})
        continue
    end
    histogram(fraction, linspace(0,0.1,50));hold on;
    me =nanmedian( fraction);
    plot([me, me],[0,ylim1], 'k:', 'linewidth',3)
    ylim([0,ylim1]);
    title(titles{1})
    
    subplot(2,1,2)
    sum1 = after_all(:,1) + after_all(:,2) + after_all(:,3);
    fraction = (after_all(:,1) + after_all(:,2)) ./ sum1;
    fraction(fraction<0) = 0;
    fraction(fraction>10) = 10;
    histogram(fraction, linspace(0.5,1,50));hold on;
    me =nanmedian( fraction);
    plot([me, me],[0,ylim1], 'k:', 'linewidth',3)
    ylim([0,ylim1]);
    title(titles{2})
    fractions_all2(i) = {fraction};
    fractions_all2_g = [fractions_all2_g;  fraction];
    g2 = [g2 ones(1,length(fraction))*i];
    Dyes2_1(i) = dyes(2);
    
    Dyes2_2(i) = dyes(3);
    ANM2{i} = data.ANMs{i};
end
%% make table
tbl = table();
tbl.ANM = [ANM1 ANM2]';
tbl.Dye1 = [Dyes1_1 Dyes2_1]';
tbl.Dye2 = [Dyes1_2 Dyes2_2]';
tbl.Fraction = [fractions_all1 fractions_all2]';
tbl.Interval = [1,2,2,1,1,1.0/6.0,1.0/6.0,1,8*24,3*24,1,1]';
tbl.FractionMedian = cellfun(@nanmean, tbl.Fraction);
tbl.std = cellfun(@nanstd, tbl.Fraction);
tbl.count =  cellfun(@length, tbl.Fraction);
tbl.SE = tbl.std ./ sqrt(tbl.count)
%%
f1=figure(11);
f1.Color = 'w';
clf
validTbl = logical([1,1,1,1,1,1,1,0,0,0,0,0]);
validTbl2 = logical([0,0,0,0,0,0,0,1,0,0,0,0]);
errorbar(tbl.Interval(validTbl)*60+rand(sum(validTbl),1)*5, tbl.FractionMedian(validTbl),...
    tbl.SE(validTbl), 'ok')
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

valid1 = ~isnan(fractions_all1_g) & fractions_all1_g>0 & fractions_all1_g<2; 
[p,tbl2,stats]  = kruskalwallis( fractions_all1_g(valid1),g1(valid1));
multcompare(stats)
ax = gca();
ax.YTickLabel = data.ANMs;
%%


valid2 = ~isnan(fractions_all2_g) & fractions_all2_g>0 & fractions_all2_g<2; 
[p,tbl1,stats]  = anova1( fractions_all2_g(valid2),g2(valid2));
multcompare(stats)

%%
close all
violinplot(fractions_all1_g(valid1),g1(valid1),'ShowData',false,...
    'ViolinAlpha',0,'EdgeColor',[1,1,1], 'Width',1);
ylim([0.9,1.08])
ylabel('Fraction JF552');
% xticklabels({'1H','2H','1H','1H'}
% xticklabels(tbl.)r
xlabel('Interval of first injection (669) to second (552)')
%%
close all
f = figure();
f.Color='w';
violinplot(fractions_all2_g(valid2),g2(valid2),'ShowData',false,...
    'ViolinAlpha',0,'EdgeColor',[1,1,1], 'Width',1);
ylim([0,1.1])
ylabel('Fraction In-vivo');
xticklabels({'2H','8Days', '3Days','2H','2H'})
xlabel('Interval of first injection to perfusion (608)')
