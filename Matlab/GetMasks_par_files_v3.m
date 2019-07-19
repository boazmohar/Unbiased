function GetMasks_par_files_v3(cores, ch_names)
%%GetMasks_par_files_v3(cores, ch_names)
% cores: namber of paralilizaiton to do < 1 ==> none
% ch_names: raw file endings to read, defulats to : 'FITC','Texas','Cy5'

% Pixel: 1-cell, 2-bright large, 3-black bg, 4-neuropil1,5-neuropil2
% 6-neuropil strong, 7-dendrite, 8-small bright, 9-blood, 10-bg1,
% 11-bg2, 12-bg3, 13- red fibers
% Object: 1-cell, 2-dendrtie, 3-saturated cell, 4 small cell, 
% 5-small not cell, 6-artifact, 7- not sure, 8- big not cell,
% 9- saturated not cell
if nargin < 2
    ch_names= {'FITC','Texas','Cy5'};
end
n_ch        = length(ch_names);
current_dir = pwd();
p           = gcp('nocreate');
if isempty(p)
    p       = parpool(cores);
end
disp('Started');
objProb     = dir('*Object*.tif');
probFiles   = sort_nat({objProb.name});
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
SE2          = strel('square',3);
pp = ParforProgress; 
parfor i =1:numFiles
    cd(current_dir)
    % read prob image
    filename    = probFiles{i};
    fprintf('Loading i: %d, file: %s\n',i, filename);
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
    bw_not_d    = ~imdilate(bw_not, SE2); % avoid border pixels by dilating
    Pixels(i)   = sqrt(sum(px(3, :, :) < 0.2, 'all'));
    % get raw data crop to match RGB version
    cd('raw');
    all_channels = zeros(sz(1), sz(2), n_ch, 'uint16');
    for ch = 1: length(ch_names)
        ch_name = ch_names{ch};
        curernt_ch = imread([baseName ch_name '.tiff']);
        all_channels(:, :, ch) = curernt_ch(1:sz(1), 1:sz(2));
    end
    cd(current_dir);
    % get labels
    label1              = bwlabel(bw_1); % cell
    label2              = bwlabel(bw_2); % saturated
    label3              = bwlabel(bw_3); % small
    numLabels1          = max(label1(:));
    numLabels2          = max(label2(:));
    numLabels3          = max(label3(:));
    numLabelsAll        = numLabels1 + numLabels2 + numLabels3;
    fprintf('i: %d, Found %d cells, %d saturated, %d small\n', ...
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
    iteration_number = step(pp, i); 
    fprintf('Finished iteration %d of %d\n', iteration_number, numFiles);
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
data.Ch_Names   = ch_names;
name            = ['MaskData_v3_' datestr(now, 'yyyy-mm-dd_HH-MM-SS')];
% sace and cleanup
save(name, 'data')
fprintf('Saved: %s', name);
delete(p);
end

