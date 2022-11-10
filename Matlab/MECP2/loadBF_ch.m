function data = loadBF_ch(file, seriesNum, chNum)
%data = loadB_ch F(file, seriesNum = 0, chNum = 1) returns a single ch
% (x,y,z) uint16 matrix, series is 0 indexed, channel is 1 indexed !
if nargin < 2
    seriesNum=0;
end
if nargin < 3
    chNum=1;
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
data = zeros(sizeY,sizeX,sizeZ, 'uint16');
fprintf('Reading matrix (%d x %d x %d):\n',sizeY,sizeX,sizeZ);
k =1;
for i = 1 : numImages
    zct = r.getZCTCoords(i-1);
    if zct(2) == chNum-1
        fprintf('%d,', k);
        data(:,:,k) = bfGetPlane(r,i);
        k=k+1;
    end
end
fprintf('Done\n');
%% reshape output
r.close()
end

