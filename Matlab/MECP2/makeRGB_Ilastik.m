function RGB = makeRGB_Ilastik(file, useMulticore, series, writeH5, satRange, largeBlank)
%RGB = makeRGB_Ilastik(file, useMulticore, series, writeH5, satRange)
%  reads data with parfor, normalize and write a hdf5 file
if nargin < 2
    useMulticore = 0;
end
if nargin < 3
    series = 0;
end
if nargin < 4
    writeH5 = 1;
end

if nargin < 5
    satRange = [0.3, 99.7];
end

if nargin < 6
    largeBlank = 0;
end

[sizeY, sizeX, ~, sizeZ] = getInfoBF(file, series);
sizeC = 5;

if useMulticore
    c = parcluster('local');
    ncores = c.NumWorkers;
    nWorkers = min([sizeZ, ncores, useMulticore]);
    fprintf('size Z: %d, cores: %d using: %d\n\n', sizeZ, ncores, nWorkers);
end
%%
RGB = zeros(sizeX,sizeY,3, sizeZ, 'single');
for c = 1:sizeC
    % load
    fprintf('Loading Ch: %d \n', c)
    if nWorkers > 1
        data = loadBF_ch_par(file, series, c, nWorkers);
    else
        data = loadBF_ch(file, series, c);
    end
    data = single(data);
    fprintf('To single done\n')
    poolobj = gcp('nocreate');
    delete(poolobj);
    if largeBlank
        % using a lower res version to get the right sat values by
        % converting 0s to NaNs
        fprintf('Using large Blank\n')
        dataS5 = loadBF_ch(file, 5, c);
        fprintf('loaded series 5\n')
        dataS5 = single(dataS5);
        dataS5(dataS5==0) = nan;
        
        p = prctile(dataS5, satRange,'all');
        p_low = p(1);
        p_high =p(2);
        
        fprintf('plow %.2f, phigh %.2f\n', p_low, p_high)
    else
        
        % clip and norm to 1 per channel
        p = prctile(data, satRange,'all');
        p_low = p(1);
        p_high =p(2);
    end
    data(data<p_low) = p_low;
    data(data>p_high) = p_high;
    data = data - p_low;
    data = data ./ p_high;
    %     data = min(max(data, p_low), p_high);
%         data = data - p_low;
    fprintf('Done norm\n')
    % add to RGB
    if c == 1
        RGB(:,:,1, :) =data;
    elseif c==2 || c == 4 || c == 5
        RGB(:,:,3, :)  = squeeze(RGB(:,:,3, :)) + data;
    elseif c == 3
        RGB(:,:,2, :) = data;
    end
    fprintf('Added to RGB\n\n')
    
    java.lang.System.gc();
    pause(1);
end

pause(1);
clear data
poolobj = gcp('nocreate');
delete(poolobj);
java.lang.System.gc();
pause(1);

%% write hdf5 file
if writeH5
    out_filename = sprintf('%s_rgb.h5',file(1:end-4));
    fprintf('Done RGB, writing to %s\n', out_filename);
    h5create(out_filename, '/rgb', size(RGB), 'ChunkSize', [20,20, 3, sizeZ], 'Datatype', 'single');
    h5write(out_filename, '/rgb', RGB);
    fprintf('Done h5\n');
end
end

