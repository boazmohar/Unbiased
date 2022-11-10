function MakeChMaxProj(maxNWorkers)
if nargin == 0
    maxNWorkers = 48;
end
files = dir('*.ims');
files = {files.name}';
seriesNum=0;
for i = 1:length(files)
    filename = files{i};
    
    new_filename = [filename(1:end-4) '_max_ch3.tif'];
    if isfile(new_filename)
        continue
    end
    [~,~, sizeZ, ~] = getInfoBF(filename, seriesNum);
    nWorkers = min([sizeZ, maxNWorkers]);
    data = loadBF_ch_par(filename, 0, 3, nWorkers);
    max_data = squeeze(max(data,[],3));
    saveastiff(max_data, new_filename)

end