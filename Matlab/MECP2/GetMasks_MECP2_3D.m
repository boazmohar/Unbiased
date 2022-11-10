function GetMasks_MECP2_3D(filename, ncores)
%% GetMasks_MECP2_3D(filename, ncores)
% Pixel: 1-nuclei, 2-bg, 3-AutoFlu, 4-Border, 5-NoSignal, 6-Artifact (hole)
% Object: 1-NeuN, 2-Merge, 3-Negative, 4-Split
%% set defaults
if nargin <2
    ncores = 1;
end
n_ch        = 5;
seriesNum   = 0;
SE          = strel('cuboid',[25,25,3]);
SE2         = strel('cuboid',[3,3,1]);  
k           = strfind(filename,' ');
baseName    = filename(1:k(end)-8);
objIdent    = [baseName '_Object Identities.h5'];
rawFile     = [baseName(1:end-4) '.ims'];
pixelName   = [baseName '_Probabilities.h5']; 
%% read pixel prob
[sizeX,sizeY, sizeZ, ~] = getInfoBF(rawFile);
fprintf('Reading %s\n', pixelName)
px1         = h5read(pixelName, '/exported_data', [1 1 1 1], [sizeY, sizeX, 1, sizeZ]);
px1         = squeeze(px1 > 0.2);
fprintf('Done px1, ')
px3         = h5read(pixelName, '/exported_data', [1 1 3 1], [sizeY, sizeX, 1, sizeZ]);
px3         = squeeze(px3 > 0.2);
fprintf('Done px3, ')
px6         = h5read(pixelName, '/exported_data', [1 1 6 1], [sizeY, sizeX, 1, sizeZ]);
px6         = squeeze(px6 > 0.2);
fprintf('Done px6, ')
bw_not      = px1 | px3 | px6;
clear px1 px3 px6
% Pixels      = (sum(~px3, 'all'))^(1.0/3.0);
% clear px3
bw_not_d    = ~imdilate(bw_not, SE2); % exclude from neuropil other nuclei AutoFlu, Artifact & dilate
clear bw_not
fprintf('Have background pixels\n')
%% read prob image if tiff or open h5 if h5
[~,~,ext] = fileparts(filename);
fprintf('Got ext: %s\n', ext);
if strcmpi(ext, '.tiff')
    info        = imfinfo(filename);
    Zs          = length(info);
    info        = info(1);
    fprintf('Loading: %s, Zs: %d\n', filename, Zs);
    predections = zeros(info.Width, info.Height, Zs, 'uint16');
    for z_ = 1:Zs
        predections(:,:,z_) = imread(filename, z_)';
        fprintf('%d,',z_);
    end
    fprintf('Done loading tiff\n')
elseif strcmpi(ext, '.h5')
    predections = squeeze(h5read(filename, '/exported_data'));
    info = struct();
    info.filename = filename;
    info.size = size(predections);
    fprintf('Loaded .h5\n')
end
sz          = size(predections);
bw_Pos      = predections == 1;
bw_Merge    = predections == 2; 
bw_Neg      = predections == 3; 
bw_Split    = predections == 4; 
clear predections
fprintf('Got obj prediciton\n')
%% get labels

fprintf('Loading label image: %s\n', objIdent)
labelAll    = uint32(squeeze(h5read(objIdent, '/exported_data')));
fprintf('Done loading\n')
labelPos    = uint32(bw_Pos) .* labelAll;
labelMerge  = uint32(bw_Merge) .* labelAll;
labelNeg    = uint32(bw_Neg) .* labelAll;
labelSplit  = uint32(bw_Split) .* labelAll;
clear bw_NeuN bw_Neg bw_Split bw_Merge  
fprintf('Done labels\n')
% fget Ids
Ids_Pos     = unique(labelPos);
Ids_Merge   = unique(labelMerge);
Ids_Neg     = unique(labelNeg);
Ids_Split   = unique(labelSplit);
Ids_Pos     = Ids_Pos(2:end);
Ids_Merge   = Ids_Merge(2:end);
Ids_Neg     = Ids_Neg(2:end);
Ids_Split   = Ids_Split(2:end);
fprintf('Positive:%d,Merge:%d, Neg:%d, Split:%d\n', length(Ids_Pos), ...
    length(Ids_Merge), length(Ids_Neg),length(Ids_Split));
clear labelSplit labelNeuN labelMerge labelNeg
numLabelsAll        = max(labelAll, [],'all');
forground           = zeros(numLabelsAll, n_ch);
background          = zeros(numLabelsAll, n_ch);
xyz                 = regionprops(labelAll,'Centroid');
xyz                 = round(cell2mat({xyz.Centroid}'));
%% getting label min and max
minX                = xyz(:, 2) - 50;
maxX                = xyz(:, 2) + 50;
minX(minX<1)        = 1;
maxX(maxX>sz(1))    = sz(1);
minY                = xyz(:, 1) - 50;
maxY                = xyz(:, 1) + 50;
minY(minY<1)        = 1;
maxY(maxY>sz(2))    = sz(2);
minZ                = xyz(:, 3) - 5;
maxZ                = xyz(:, 3) + 5;
minZ(minZ<1)        = 1;
maxZ(maxZ>sz(3))    = sz(3);
fprintf('Starting masks: %d\n', numLabelsAll)
%% get raw data
fprintf('Getting raw data (cores:%d) %s\n', ncores, rawFile)
for ch = 1:5
    if ncores > 1
        bfInitLogging();
        all_channels    = loadBF_ch_par(rawFile, seriesNum, ch, ncores);
    else  
        all_channels    = loadBF_ch(rawFile, seriesNum, ch);
    end
    fprintf('Done reading ch: %d\n', ch)


    %% compute forground and background for each label
    for l = 1:numLabelsAll
        current         = labelAll(minX(l):maxX(l), minY(l):maxY(l), minZ(l):maxZ(l));
        current2        = current == l;
        bw_not_d2       = bw_not_d(minX(l):maxX(l), minY(l):maxY(l), minZ(l):maxZ(l));
        sz2             = size(current2);
        blank           = zeros(sz2(1), sz2(2), sz2(3), 'logical');
        blank(current2) = true;
        blank           = logical(imdilate(blank, SE) - current2);
        blank           = blank & bw_not_d2;
        ch_current      = squeeze(all_channels(minX(l):maxX(l), minY(l):maxY(l), minZ(l):maxZ(l)));
        forground(l,ch) = mean(ch_current(current2), 'all');
        background(l,ch)= mean(ch_current(blank), 'all');
        if mod(l, 50) == 0
            fprintf('.')
        end
        if mod(l, 2000) == 0
            fprintf('\n')
        end
    end
    fprintf('Done masks ch: %d\n', ch)
end
types                   = zeros(numLabelsAll,1);
types(int32(Ids_Pos))   = 1;
types(int32(Ids_Merge)) = 2;
types(int32(Ids_Neg))   = 3;
types(int32(Ids_Split)) = 4;
fprintf('Done masks\n')
%% save values
data            = struct();
data.x          = xyz(:, 1);
data.y          = xyz(:, 2);
data.z          = xyz(:, 3);
data.BG         = background;
data.Values     = forground;
data.info       = info;
data.ANM        = baseName(4:9);
data.rawFile    = rawFile;
data.Cell_Type  = types;
% data.Pixels     = Pixels;
data.Image_Size = sz;
name            = [baseName(1:end-3) datestr(now, 'yyyy-mm-dd_HH-MM-SS')];
save(name, 'data')
fprintf('Saved: %s\n', name);



