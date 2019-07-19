function GetMasks_par_files_v2(cores)
%%GetMasks_par_files_v2(cores)
% Pixel: 1-cell, 2-bright large, 3-black bg, 4-neuropil1,5-neuropil2
% 6-neuropil strong, 7-dendrite, 8-small bright, 9-blood, 10-bg1,
% 11-bg2, 12-bg3, 13- red fibers
% Object: 1-cell, 2-dendrtie, 3-saturated cell, 4 small cell, 
% 5-small not cell, 6-artifact, 7- not sure, 8- big not cell,
% 9- saturated not cell

debug = 0;
current_dir = pwd();
p = gcp('nocreate');
if isempty(p)
    p=parpool(cores);
end
disp('Started');
objProb     = dir('*Object*.tif');
probFiles   = sort_nat({objProb.name});
numFiles    = length(probFiles);
fprintf('found %d probFiles', numFiles)
x           = cell(numFiles,1);
y           = cell(numFiles,1);
z           = cell(numFiles,1);
FITC         = cell(numFiles,1);
Texas       = cell(numFiles,1);
Cy5       = cell(numFiles,1);
FITC_bg      = cell(numFiles,1);
Texas_bg    = cell(numFiles,1);
Cy5_bg    = cell(numFiles,1);
Cell_Type   = cell(numFiles,1);
Pixels      = zeros(numFiles,1);
SE          = strel('square',25);
SE2          = strel('square',3);
pp = ParforProgress; 
parfor i =1:numFiles
    cd(current_dir)
    % read prob image
    filename    = probFiles{i};
%     fprintf('Loading i: %d, file: %s\n',i, filename);
    prob        = imread(filename);
    sz          = size(prob);
    bw_1        = prob == 1; % cell
    bw_2        = prob == 3; % saturated cell
    bw_3        = prob == 4; % small cell
    if sum(bw_1(:)) + sum(bw_2(:)) + sum(bw_3(:)) == 0
        fprintf('Skipping: %d', i);
        continue
    end
    % read nuropil from h5
    k           = strfind(filename,'_');
    baseName    = filename(1:k(end));
    pixelName   = [baseName 'Probabilities.h5'];
    px          = h5read(pixelName, '/exported_data');
    bw_not      = px(1, :, :) > 0.2 | px(2, :, :) > 0.2 | px(7, :, :) > 0.4 |...
        px(8, :, :) > 0.2 | px(9, :, :) > 0.2;
    bw_not      = squeeze(bw_not)'; % exclude from neuropil
    bw_not_d    = ~imdilate(bw_not, SE2);
    Pixels(i)   = sqrt(sum(px(3, :, :) < 0.2, 'all'));
    % get raw data crop to match RGB version
    cd('raw');
    FITC_ds      = imread([baseName 'FITC.tiff']);
    Texas_ds    = imread([baseName 'Texas.tiff']);
    Cy5_ds    = imread([baseName 'Cy5.tiff']);
    cd(current_dir);
    FITC_ds      = FITC_ds(1:sz(1), 1:sz(2));
    Texas_ds    = Texas_ds(1:sz(1), 1:sz(2));
    Cy5_ds    = Cy5_ds(1:sz(1), 1:sz(2));
    % get labels
    label1              = bwlabel(bw_1); % cell
    label2              = bwlabel(bw_2); % saturated
    label3              = bwlabel(bw_3); % small
    numLabels1          = max(label1(:));
    numLabels2          = max(label2(:));
    numLabels3          = max(label3(:));
    numLabelsAll        = numLabels1 + numLabels2 + numLabels3;
    nimLabels10         = round(numLabelsAll/10)-1;
    fprintf('i: %d, Found %d cells, %d saturated, %d small\n', ...
        i, numLabels1, numLabels2, numLabels3);
    FITC_current         = zeros(numLabelsAll, 1);
    Texas_current       = zeros(numLabelsAll, 1);
    Cy5_current       = zeros(numLabelsAll, 1);
    FITC_bg_current      = zeros(numLabelsAll, 1);
    Texas_bg_current    = zeros(numLabelsAll, 1);
    Cy5_bg_current    = zeros(numLabelsAll, 1);
    % compute forground and background for each label
    for l = 1:numLabelsAll
        if l <= numLabels1                  % cell
            current         = label1==l;
        elseif l <= numLabels1 + numLabels2 && numLabels2 > 0 % saturated
            current         = label2==(l-numLabels1);
        else                                % small
            current         = label3==(l-(numLabels1 + numLabels2));
        end
        stats_temp = regionprops(current,FITC_ds,'Centroid');
        x1 = round(stats_temp.Centroid(2));
        y1 = round(stats_temp.Centroid(1));
        minX = max(x1-50, 1);
        minY = max(y1-50, 1);
        maxX = min(x1+50, sz(1));
        maxY = min(y1+50, sz(2));
        FITC_ds2 = FITC_ds(minX:maxX, minY:maxY);
        Texas_ds2 = Texas_ds(minX:maxX, minY:maxY);
        Cy5_ds2 = Cy5_ds(minX:maxX, minY:maxY);
        current2 = current(minX:maxX, minY:maxY);
        bw_not_d2 = bw_not_d(minX:maxX, minY:maxY);
        sz2 = size(current2);
        blank               = zeros(sz2(1), sz2(2), 'logical');
        blank(current2)      = true;
        blank               = logical(imdilate(blank, SE) - current2);
        blank               = blank & bw_not_d2;
        FITC_current(l)      = mean(FITC_ds2(current2), 'all');
        Texas_current(l)    = mean(Texas_ds2(current2), 'all');
        Cy5_current(l)    = mean(Cy5_ds2(current2), 'all');
        FITC_bg_current(l)   = mean(FITC_ds2(blank), 'all');
        Texas_bg_current(l) = mean(Texas_ds2(blank), 'all');
        Cy5_bg_current(l) = mean(Cy5_ds2(blank), 'all');
        if debug && mod(l, nimLabels10) == 0 
            Texas_m = round(Texas_current(l));
            Texas_b = round(Texas_bg_current(l));
            Cy5_m = round(Cy5_current(l));
            Cy5_b = round(Cy5_bg_current(l));
            Texas_s = Texas_m - Texas_b;
            Cy5_s = Cy5_m - Cy5_b;
            Texas_r = Texas_s / (Texas_s + Cy5_s);
            Cy5_r = Cy5_s / (Texas_s + Cy5_s);
            f=figure('visible','off');
            clf;
            subplot(2,2,1)
            J = imadjust(FITC_ds2);
            B = imoverlay(J, current2, 'red');
            imshow(B);
            title(sprintf('%dpx', sum(current2, 'all')));
            subplot(2,2,2)
            B = imoverlay(J, blank, 'red');
            imshow(B, []);
            title(sprintf('%dpx', sum(blank, 'all')));
            subplot(2,2,3)
            imshow(Texas_ds2, [150, 600]);
            colormap(parula)
            colorbar();
            title(sprintf('%d-%d=%d,%.2f', Texas_m, Texas_b, Texas_s, Texas_r))
       
            subplot(2,2,4)
            imshow(Cy5_ds2, [150, 600]);
            title(sprintf('%d-%d=%d,%.2f', Cy5_m, Cy5_b,  Cy5_s,Cy5_r))
            colormap(parula)
            colorbar();
            
            cd('png');
%             export_fig(sprintf('%s_%d1.jpg', filename, l), f)
            saveas(f, sprintf('%s_%d2.jpg', filename, l))
            cd(current_dir);
        end
    end
    % store values
    stats1      = regionprops(bw_1,FITC_ds,'Centroid');
    xys1        = cell2mat({stats1.Centroid}');
    stats2      = regionprops(bw_2,FITC_ds,'Centroid');
    xys2        = cell2mat({stats2.Centroid}');
    stats3      = regionprops(bw_3,FITC_ds,'Centroid');
    xys3        = cell2mat({stats3.Centroid}');
    x_temp = [];
    y_temp = [];
    if numLabels1 > 0
        x_temp = [x_temp; xys1(:,1)];
        y_temp = [y_temp; xys1(:,2)];
    end
    if numLabels2 > 0
        x_temp = [x_temp; xys2(:,1)];
        y_temp = [y_temp; xys2(:,2)];
    end
    if numLabels3 > 0
        x_temp = [x_temp; xys3(:,1)];
        y_temp = [y_temp; xys3(:,2)];
    end
    x{i}        = x_temp-size(FITC_ds,2)/2;
    y{i}        = y_temp-size(FITC_ds,1)/2;
    z{i}        = ones(numLabelsAll, 1).*i;
    FITC{i}      = FITC_current;
    Texas{i}    = Texas_current;
    Cy5{i}    = Cy5_current;
    FITC_bg{i}   = FITC_bg_current;
    Cy5_bg{i} = Cy5_bg_current;
    Texas_bg{i} = Texas_bg_current;
    Cell_Type{i}= [ones(numLabels1, 1); ones(numLabels2, 1)*2; ...
        ones(numLabels3, 1)*3];
    iteration_number = step(pp, i); 
    fprintf('Finished iteration %d of %d\n', iteration_number, numFiles);
end
data            = struct();
data.x          = x;
data.y          = y;
data.z          = z;
data.FITC        = FITC;
data.Texas      = Texas;
data.Cy5      = Cy5;
data.FITC_bg     = FITC_bg;
data.Texas_bg   = Texas_bg;
data.Cy5_bg   = Cy5_bg;
data.Cell_Type  = Cell_Type;
data.Pixels     = Pixels;
name = ['MaskData2 ' datestr(datetime())];

save(name, 'data')
fprintf('Saved: %s', name);
delete(p);
end

