function [CCF_tbl, CCF_ids] = getCCF_ids(data, plotFlag, useCheckpoint, LabelTables)
%% input things
if nargin < 2
    plotFlag = 0;
end
if nargin < 3
    useCheckpoint = 0;
end
if nargin < 4
    [~, LabelTables] = getLabelTables();
end
%% load label image and resize
filename = data.filename{1};
[sizeX, sizeY, ~, ~] = getInfoBF(filename);
checkpointFilename = [filename(1:end-4) '_label.mat'];
if isfile(checkpointFilename) && useCheckpoint
    temp12 = load(checkpointFilename, 'labelsRGB');
    labelsRGB = temp12.labelsRGB;
else
    labelImg = imread([filename(1:end-4) '_label.png']);
    labelImg2 = imresize(labelImg, [sizeY, sizeX],'method','nearest');
    %%
    x = data.x{1};
    y = data.y{1};
    index = sub2ind([sizeY, sizeX], y, x);
    R = labelImg2(:,:,1);
    G = labelImg2(:,:,2);
    B = labelImg2(:,:,3);
    labelsRGB = [ R(index) G(index) B(index)];
    save(checkpointFilename, 'labelsRGB')
end
%% plot?
if plotFlag && ~useCheckpoint
    figure();
    clf
    scatter(y, x,8,single(labelsRGB)./255.0,'filled')
end
%% convert to hex to comapare as unique 6 char vector

CCF_tbl = LabelTables;
hexData= reshape(sprintf('%02X',labelsRGB.'),6,[]).';
RGBLegend = [CCF_tbl.R CCF_tbl.G CCF_tbl.B];
hexLegend = reshape(sprintf('%02X',RGBLegend.'),6,[]).';
[~, iLoc] = ismember(hexData,hexLegend, 'rows');
zeroLoc = iLoc == 0;
iLoc(zeroLoc) = 1;
CCF_ids = LabelTables.ID(iLoc);
CCF_ids(zeroLoc) = 0;