function GetMasks_par_files_mRuby_V1(cores, ch_names)
%%GetMasks_par_files_v3(cores, ch_names)
% cores: namber of paralilizaiton to do < 1 ==> none
% ch_names: raw file endings to read, defulats to : 'FITC','RFP','CY5'

% Object: 1-cell, 2-double cell, 3-Error
disp('mRuby V1!!!');
if ischar(cores)
    cores = round(str2double(cores));
end
maxNumCompThreads(48)
if nargin < 2
    ch_names= {'FITC','RFP','CY5'};
end
n_ch        = length(ch_names);
current_dir = pwd();
p           = gcp('nocreate');
if isempty(p)
    p       = parpool(cores);
end
disp('Started');
cd('RFP')
objProb     = dir('*Object*.tif');
cd('..')
probFiles   = sort_nat({objProb.name});
numFiles    = length(probFiles);
fprintf('found %d probFiles\n', numFiles)
x           = cell(numFiles,1);
y           = cell(numFiles,1);
z           = cell(numFiles,1);
Values      = cell(numFiles, n_ch);
Background  = cell(numFiles, n_ch);
Cell_Type   = cell(numFiles,1);
Pixels      = cell(numFiles,1);
SE          = strel('square',25);
SE2         = strel('square',3);
all_sz      = zeros(numFiles,2);
pp = ParforProgress; 
parfor i =1:numFiles
    % read prob image
    filename    = probFiles{i};
    fprintf('Loading i: %d, file: %s\n',i, filename);
    cd('RFP')
    prob        = imread(filename);
    cd('..');
    sz          = size(prob);
    all_sz(i, :)= sz;
    bw_1        = prob == 1; % cell
    if sum(bw_1(:)) == 0
        fprintf('Skipping: %d', i);
        continue
    end
    % read nuropil from h5
    k           = strfind(filename,'_');
    baseName    = filename(1:k(end)-4);
    % get raw data crop to match RGB version
    all_channels = zeros(sz(1), sz(2), n_ch, 'uint16');
    for ch = 1: length(ch_names)
        ch_name = ch_names{ch};
        if strcmpi(ch_name, 'RFP')
            cd('RFP');
            curernt_ch = imread([baseName ch_name '.tiff']);
            cd('..');
        else
             curernt_ch = imread([baseName ch_name '.tiff']);
        end
        all_channels(:, :, ch) = curernt_ch(1:sz(1), 1:sz(2));
    end
    % get labels
    label1              = bwlabel(bw_1); % cell
    numLabels          = max(label1(:));
    fprintf('i: %d, Found %d cells\n', i, numLabels);
    forground           = zeros(numLabels, n_ch);
    background          = zeros(numLabels, n_ch);
    pixels              = zeros(numLabels,1);
    xy_1 = regionprops(label1,all_channels(:, :, 1),'Centroid');
    xy_1 = cell2mat({xy_1.Centroid}');
    xy_all = round(xy_1);
    minX = xy_all(:, 2) - 50;
    maxX = xy_all(:, 2) + 50;
    minX(minX<1) = 1;
    maxX(maxX>sz(1)) = sz(1);
    minY = xy_all(:, 1) - 50;
    maxY = xy_all(:, 1) + 50;
    minY(minY<1) = 1;
    maxY(maxY>sz(2)) = sz(2);
    % compute forground and background for each label
    for l = 1:numLabels
        current         = label1==l;
        current2        = current(minX(l):maxX(l), minY(l):maxY(l));
        pixels(l)       = sum(current2(:));
        sz2             = size(current2);
        blank           = zeros(sz2(1), sz2(2), 'logical');
        blank(current2) = true;
        blank           = logical(imdilate(blank, SE) - current2);
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
    z{i}            = ones(numLabels, 1).*i;
    Pixels{i}       = pixels;
    Background{i}   = background;
    Values{i}       = forground;
    Cell_Type{i}    = ones(numLabels, 1);
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
data.Image_Size = all_sz;
name            = ['MaskData_mRuby_' datestr(now, 'yyyy-mm-dd_HH-MM-SS')];
% sace and cleanup
save(name, 'data')
fprintf('Saved: %s', name);
delete(p);
end

