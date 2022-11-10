% function GetMasks_MECP2_V1(ch_names)
%%GetMasks_par_files_v3(cores, ch_names)
% cores: namber of paralilizaiton to do < 1 ==> none
% ch_names: raw file endings to read, defulats to : 'FITC','Texas','Cy5'

% Pixel: 1-neclui, 2-no tissue, 3-bg, 4-autoflou ,5-dense red
% 6-dense blue 

% Object: 1-good, 2-narrow, 3-small 
% cd('E:\ImagingDM11\MECP2_ANM460139\Tiffs')
disp('MECP2!!!');
% if ischar(cores)
%     cores = round(str2double(cores));
% end
% if nargin < 1
ch_names= {'FITC','RFP','Cy5'};
% end
n_ch        = length(ch_names);
current_dir = pwd();
% p           = gcp('nocreate');
% if isempty(p)
%     p       = parpool(cores);
% end
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
SE2         = strel('square',3);
all_sz      = zeros(numFiles,2);
for i =1:numFiles
    % read prob image
    filename    = probFiles{i};
    try
        fprintf('Loading i: %d, file: %s\n',i, filename);
        Obj_predection        = imread(filename);
    catch
        pause(0.1);
        fprintf('Loading i2: %d, file: %s\n',i, filename);
        Obj_predection        = imread(filename);
    end
    sz          = size(Obj_predection);
    all_sz(i, :)= sz;
    bw_1        = Obj_predection == 1; % nuclei
    bw_2        = Obj_predection == 2; % long nuclei
    bw_3        = Obj_predection == 3; % small nuclei
    if sum(bw_1(:)) == 0 && sum(bw_2(:)) == 0 && sum(bw_3(:)) == 0
        fprintf('Skipping: %d', i);
        continue
    end
    % read nuropil from h5
    k           = strfind(filename,'_');
    baseName    = filename(1:k(end));
    pixelName   = [baseName 'Probabilities.h5'];
    px          = h5read(pixelName, '/exported_data');
    bw_not      = px(:, :, 1) > 0.2 | px(:, :, 4) > 0.2 | px(:, :, 5) > 0.1 |...
        px(:, :, 6) > 0.2;
    bw_not      = squeeze(bw_not)'; % exclude from neuropil
    bw_not_d    = ~imdilate(bw_not, SE2); % avoid border pixels by dilating
    Pixels(i)   = sqrt(sum(px(2, :, :) < 0.2, 'all'));
    % get raw data crop to match RGB version
    all_channels = zeros(sz(1), sz(2), n_ch, 'uint16');
    for ch = 1: length(ch_names)
        ch_name = ch_names{ch};
        curernt_ch = imread([current_dir filesep 'raw' filesep ...
            baseName ch_name '.tiff']);
        all_channels(:, :, ch) = curernt_ch(1:sz(1), 1:sz(2));
    end
    % get labels
    label1              = bwlabel(bw_1); % nuclei
    label2              = bwlabel(bw_2); % long narrow nuclei
    label3              = bwlabel(bw_3); % small nuclei
    numLabels1          = max(label1(:));
    numLabels2          = max(label2(:));
    numLabels3          = max(label3(:));
    numLabelsAll        = numLabels1 + numLabels2 + numLabels3;
    fprintf('i: %d, Found %d nuclei, %d narrow, %d small\n', ...
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
data.Ch_Names   = ch_names;
data.Image_Size = all_sz;
name            = ['MaskData_v3_' datestr(now, 'yyyy-mm-dd_HH-MM-SS')];
% sace and cleanup
save(name, 'data')
fprintf('Saved: %s', name);
% delete(p);
% end

