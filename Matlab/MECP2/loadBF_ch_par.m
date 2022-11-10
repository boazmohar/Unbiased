function data = loadBF_ch_par(file, seriesNum, chNum, nWorkers)
%data = loadBF_ch_par(file, seriesNum, chNum, nWorkers) returns a single ch
% (x,y,z) uint16 matrix, series is 0 indexed, channel is 1 indexed !
if nargin < 2
    seriesNum=0;
end
if nargin < 3
    chNum=1;
end
if nargin < 4
    nWorkers = 1;
end
%% Construct a Bio-Formats reader decorated with the Memoizer wrapper and get file sizes
    
bfInitLogging('INFO');
r = loci.formats.Memoizer(bfGetReader(), 0);
r.setId(file);
r.setSeries(seriesNum);
numImages = r.getImageCount();
sizeX = r.getSizeX();
sizeY = r.getSizeY();
sizeZ = r.getSizeZ();
%% getting indexs to read

fprintf('Reading matrix (%d x %d x %d):\n',sizeY,sizeX,sizeZ);
k =1;
indexs_ch1 = [];
for i = 1 : numImages
    zct = r.getZCTCoords(i-1);
    if zct(2) == chNum-1
        indexs_ch1(k) = i;
        k=k+1;
    end
end
numImagesNew = length(indexs_ch1);
%%
r.close()
indexs = cell(1,nWorkers);
start = 1;
interval = floor(numImagesNew/nWorkers);
for i = 1:nWorkers
    e = start+interval;
    if e > numImagesNew
        e = numImagesNew;
    end
    indexs{i} = start:e;
    start = e+1;
end
%%
res = cell(1,nWorkers);
p = gcp('nocreate');
if isempty(p)
    parpool(nWorkers);
end
parfor i = 1 : nWorkers
    % Initialize logging at INFO level
    bfInitLogging('INFO');
    % Initialize a new reader per worker as Bio-Formats is not thread safe
    r2 = javaObject('loci.formats.Memoizer', bfGetReader(), 0);
    % Initialization should use the memo file cached before entering the
    % parallel loop
    r2.setId(file);
    r2.setSeries(seriesNum);
    localIdx = indexs{i};
    localIdx_ch1 = indexs_ch1(localIdx)
    nPlanes = length(localIdx);
    arr = zeros(sizeY,sizeX,nPlanes, 'uint16');
    % Perform work
    for j = 1:nPlanes
        arr(:,:,j) = bfGetPlane(r2,localIdx_ch1(j));
    end
    % Close the reader
    r2.close()
    res{i} = arr;
end
%% reshape output
fprintf('Reshaping\n'); 
data = cat(3, res{:});
fprintf('Done\n');
%% reshape output
r.close()
end

