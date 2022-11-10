function res = loadBF_par(file, nWorkers)
%data = loadBF_par(file, nWorkers)

%% Construct a Bio-Formats reader decorated with the Memoizer wrapper and get file sizes
r = loci.formats.Memoizer(bfGetReader(), 0);
r.setId(file);
numImages = r.getImageCount();
sizeX = r.getSizeX();
sizeY = r.getSizeY();
sizeC = r.getSizeC();
sizeZ = r.getSizeZ();

fprintf('Reading matrix (%dX x %dY x %dC x %dZ) using %d workers \n',sizeY,sizeX,sizeC,sizeZ, nWorkers);
r.close()
%% set indexs for parfor
indexs = cell(1,nWorkers);
start = 1;
interval = floor(numImages/nWorkers);
for i = 1:nWorkers
    e = start+interval;
    if e > numImages
        e = numImages;
    end
    indexs{i} = start:e;
    start = e+1;
end
%%
% Enter parallel loop
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
    r2.setSeries(0);
    localIdx = indexs{i};
    nPlanes = length(localIdx);
    arr = zeros(sizeY,sizeX,nPlanes, 'uint16');
    % Perform work
    for j = 1:nPlanes
        arr(:,:,j) = bfGetPlane(r2,localIdx(j));
    end
    % Close the reader
    r2.close()
    res{i} = arr;
end
%% reshape output
fprintf('Shuting down pool\n'); 
delete(p)
fprintf('Reshaping\n'); 
res = permute(reshape(cat(3, res{:}), sizeY,sizeX, sizeZ, sizeC), [1,2,4,3]);
fprintf('Done\n'); 
end

