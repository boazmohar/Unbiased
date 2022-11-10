function res = LoadFromFIJI_CSV(folder, filename, colors, th, plot)
%% [rawTable, ROIs] = LoadFromCSV(folder, filename, colors, plot)
%
currentFolder = pwd();
cd(folder)
opts = delimitedTextImportOptions("NumVariables", 9);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Index", "Area", "Mean","Std","Mode","X","Y","Ch","Z"];
opts.VariableTypes = ["double", "double", "double","double", "double",...
    "double","double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
rawTable = readtable(filename, opts);
n_masks = height(rawTable)/colors;
% need to make this a loop for n colors!
rawTable.ROI = repmat(1:n_masks,1,colors)';
ROIs = zeros(n_masks/2,colors);
Values = zeros(n_masks/2,colors);
BGs = zeros(n_masks/2,colors);
if plot
    figure()
end
for c = 1:colors
    current = rawTable.Mean(rawTable.Ch == c);
    Values(:,c) =  current(1:2:end);
    BGs(:,c) = current(2:2:end);
    ROIs(:,c) = current(1:2:end) - current(2:2:end);
    
    if plot
        subplot(5,1,c)
        histogram( ROIs(:,c),20);
    end
end
SumValue =  Values(:,2) +Values(:,4)+Values(:,5);
SumBGs = BGs(:,2) +BGs(:,4)+BGs(:,5);
valid = SumValue > (mean(SumBGs) + std(SumBGs)*th);

SumAll = ROIs(valid,2) +ROIs(valid,4)+ROIs(valid,5);
FractionPulse = (ROIs(valid,4)+ROIs(valid,5)) ./ SumAll;
% Th = mean
if plot
    f=figure();
    f.Name=filename;
    subplot(1,2,1)
    boxplot( SumAll)
    title('Sum')
    subplot(1,2,2)
     boxplot(FractionPulse)
    title('FractionPulse');
end
cd(currentFolder);
res = struct();
res.rawTable = rawTable;
res.Values = Values;
res.BGs = BGs;
res.ROIs = ROIs;
res.SumAll = SumAll;
res.FractionPulse = FractionPulse;
res.Valid = valid;
res.nMasks = size(Values,1);
res.nValid = sum(valid);
