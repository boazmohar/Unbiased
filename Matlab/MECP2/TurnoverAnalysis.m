%%  mat files
cd('X:\Svoboda Lab\Boaz\ReImage_40x\New561Laser\Shading_Stitching')
files = dir('ANM*.mat');
files = {files.name}'
%%  dye calibration
configuration = '880_40x_newLaser';
[Slope, Blank] = getCalibration(configuration);
%%  intervals of pulse and chanse 
% map each animals to the interval of injections: 
% first is 552 out of 552 + 669
% Second is 552+669 out of 552+669+608
% third is 669 out of 552+669+608
Intervals = containers.Map();
Intervals('460140') = [1,192,193];
Intervals('460141') = [2,72,74];
Intervals('473364') = [10,60,70];
Intervals('473365') = [53,96,149];
Intervals('473366') = [22,96,118];
%% 
warning('off','MATLAB:table:RowsAddedExistingVars')
tbl = table;
k=1;
for i = 1:length(files)
    filename = files{i};
    l = load(filename,'data');
    data = l.data;
    for c = 1:4
        [fraction1, fraction2, fraction3, after_all] = getFractionFromData(data, c);
        fractions_all = {fraction1, fraction2, fraction3};
        for j = 1:3
            tbl.ANM{k} = data.ANM;
            tbl.filename{k} = data.rawFile;
            tbl.IHC{k} = getIHCFromName(filename);
            tbl.x{k} = data.x;
            tbl.y{k} = data.y;
            tbl.z{k} = data.z;
            tbl.cellType(k) = c;
            tbl.volume(k) = data.Pixels;
            tbl.sz{k} = data.Image_Size;
            inter = Intervals(data.ANM);
            tbl.Interval(k) = inter(j);
            tbl.Fraction{k} = fractions_all{j};
            k=k+1;
        end
    end
end

warning('on','MATLAB:table:RowsAddedExistingVars')
%
tbl.FractionMedian = cellfun(@nanmean, tbl.Fraction);
tbl.std = cellfun(@nanstd, tbl.Fraction);
tbl.count =  cellfun(@length, tbl.Fraction);
tbl.SE = tbl.std ./ sqrt(tbl.count)
%%
f = plot_FrcationPulse(tbl,1);