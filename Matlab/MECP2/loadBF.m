function data = loadBF(file, seriesNum)
%data = loadBF(file, seriesNum = 0)
if nargin < 2
    seriesNum=0;
end
%% Construct a Bio-Formats reader decorated with the Memoizer wrapper and get file sizes
    
bfInitLogging('INFO');
r = loci.formats.Memoizer(bfGetReader(), 0);
r.setId(file);
r.setSeries(seriesNum);
numImages = r.getImageCount();
sizeX = r.getSizeX();
sizeY = r.getSizeY();
sizeC = r.getSizeC();
sizeZ = r.getSizeZ();
data = zeros(sizeY,sizeX, sizeZ, sizeC, 'uint16');
fprintf('Reading matrix (%dX x %dY x %dC x %dZ) total %d images \n',sizeY,sizeX,sizeC,sizeZ, numImages);
for i = 1 : numImages
    fprintf('%d,', i)
    zct = r.getZCTCoords(i-1);
    data(:,:,zct(1) + 1, zct(2) + 1) = bfGetPlane(r,i);
end
fprintf('Done\n')
%% reshape output
r.close()
end

