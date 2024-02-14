%%  mat files
function tbl = compute_tbl(boot_num)
if nargin < 1
    boot_num = 300;
end
cd('E:\MECP2')
files = dir('ANM*.mat');
files = {files.name}';
%%  intervals of pulse and chanse
% map each animals to the interval of injections:
% first is 552 out of 552 + 669
% Second is 552+669 out of 552+669+608
% third is 669 out of 552+669+608
Intervals = getIntervals();
configuration = '880_40x_newLaser';
[Slope, Blank] = getCalibration(configuration);
%% get shading correction
DataCache.VerboseDisable();
DataCache.SetDir('E:\MECP2\');
read_func = @(file)getShading(file);
DataCache.AddReader('.ims', read_func);
%%
warning('off','MATLAB:table:RowsAddedExistingVars')
tbl = table;
k=1;
for i = 1:length(files)
    filename = files{i};
    l = load(filename,'data');
    if ~isfield(l,'data')
        continue
    end
    data = l.data;
    shadingData = 1;%DataCache.Load(data.rawFile,'.');
    [SectionAP, Large] = getMetaByFilename(data.rawFile);
    for c = 1:4
        [fraction1, fraction2, fraction3, after_all] = getFractionFromData(data, c, Slope, Blank, shadingData);
        fractions_all = {fraction1, fraction2, fraction3};
        index = data.Cell_Type == c;
        for j = 1:3
            if strcmp(data.ANM, '66_Neu')
                data.ANM = '473366';
            end
            tbl.ANM{k} = data.ANM;
            tbl.filename{k} = data.rawFile;
            [IHC, Slide, Section] = getNameParts(filename);
            
            tbl.IHC{k} = IHC;
            if length(Slide) == 1
                tbl.Slide(k) = Slide;
                tbl.Round(k) = 1;
            else 
                tbl.Slide(k) = 1;
                tbl.Round(k) = 2;
            end
            tbl.Section(k) = Section;
           
            tbl.x{k} = data.x(index);
            tbl.y{k} = data.y(index);
            tbl.z{k} = data.z(index);
            tbl.rawData{k} = after_all;
            tbl.cellType(k) = c;
            %             tbl.volume(k) = data.Pixels;
            tbl.sz{k} = data.Image_Size;
            
            tbl.voxels(k) = prod(data.Image_Size);
            
            inter = Intervals(data.ANM);
            tbl.interval(k) = inter(j);
            tbl.intervalType(k) = j;
            tbl.fraction{k} = fractions_all{j};
            tbl.AP(k) = SectionAP;
            tbl.Large(k) = Large;
            tbl.shadingData(k) = {shadingData};
            k=k+1;
        end
    end
end
tbl.index = [1:height(tbl)]';
tbl = [tbl(:,end) tbl(:, 1:end-1)];
warning('on','MATLAB:table:RowsAddedExistingVars')
%% basic stats
tbl.median = cellfun(@nanmedian, tbl.fraction);
tbl.mean = cellfun(@nanmean, tbl.fraction);
tbl.std = cellfun(@nanstd, tbl.fraction);
tbl.count =  cellfun(@length, tbl.fraction);
tbl.se = tbl.std ./ sqrt(tbl.count);
if boot_num > 0
    func = @(x)(bootci(boot_num, @mean, x));
    tbl.ci = cellfun(func, tbl.fraction, 'UniformOutput', false);
end
%%
