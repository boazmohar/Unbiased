function tbl = get_table_psd(name, LabelTables)
% parse animal ID, Sex, EE
[ANM, Sex, EE] = parse_name(name);
% find AP location
[AP, index] =  get_AP2(name);
% load allen png
if nargin < 2
    [~, LabelTables] = getLabelTables();
end
png_name = [name(1:end-4) '_rgb_nl.png'];
if ~isfile(png_name)
    tbl = table;
    return
end
png = imread(png_name);

% raw data (nan < threshold)
mask_name = [name(1:end-4) '_rgb_Probabilities.tif'];
mask = imread(mask_name);
t = graythresh(mask);
bin_mask = uint16(mask > t);
rawPulse = imread(name, 2) .* bin_mask;
rawChase = imread(name, 1) .* bin_mask;
rawPulse = single(rawPulse);
rawPulse(rawPulse==0) = nan;
rawChase = single(rawChase);
rawChase(rawChase==0) = nan;
zPulse = (rawPulse - mean(rawPulse, 'omitnan')) ./ std(rawPulse, 'omitnan');
zChase = (rawChase - mean(rawChase, 'omitnan')) ./ std(rawChase, 'omitnan');
% parse allen
%%
[U, ~, ic] = unique(reshape(permute(png,[3,1,2]),3,[]).','rows');
hexData= reshape(sprintf('%02X',U.'),6,[]).';
RGBLegend = [LabelTables.R LabelTables.G LabelTables.B];
hexLegend = reshape(sprintf('%02X',RGBLegend.'),6,[]).';
[~, iLoc] = ismember(hexData,hexLegend, 'rows');
zeroLoc = iLoc == 0;
iLoc(zeroLoc) = 1;
CCF_ids = LabelTables.ID(iLoc);
CCF_ids(zeroLoc) = 0;
CCF_names = LabelTables.Name(iLoc);
CCF_names(zeroLoc) = 'root';
S = size(png);
S2 = size(rawPulse);
ic2 = reshape(ic,S(1),S(2));
ic2_s2 = imresize(ic2,S2(1:2), 'nearest'); 
% compute stats per region
pulse = regionprops( ic2_s2, rawPulse, {'PixelValues'});
chase = regionprops( ic2_s2, rawChase, {'PixelValues'});
pulse_z = regionprops( ic2_s2, zPulse, {'PixelValues'});
chase_z = regionprops( ic2_s2, zChase, {'PixelValues'});
numObj = numel(pulse);
[Calibration, Blank] = getCalibration('10x_SlideScanner_WF');
for k = 1:numObj
    pulse(k).P_Mean = mean(double(pulse(k).PixelValues), 'omitnan') -  Blank(673);
    pulse(k).P_Mean = pulse(k).P_Mean ./ Calibration(673);
    pulse(k).P_STD = std(double(pulse(k).PixelValues), 'omitnan');
    pulse(k).N = sum(pulse(k).PixelValues > 0, 'omitnan');
    pulse(k).C_Mean = mean(double(chase(k).PixelValues), 'omitnan') -  Blank(552);
    pulse(k).C_Mean =  pulse(k).C_Mean ./ Calibration(552);
    pulse(k).C_STD = std(double(chase(k).PixelValues), 'omitnan');
    pulse(k).P_MeanZ = mean(double(pulse_z(k).PixelValues), 'omitnan');
    pulse(k).C_MeanZ = mean(double(chase_z(k).PixelValues), 'omitnan');
    pulse(k).Name = CCF_names(k);
    pulse(k).CCF_ID = CCF_ids(k);
    pulse(k).fraction = pulse(k).P_Mean ./ (pulse(k).P_Mean + pulse(k).C_Mean);
    pulse(k).fraction_z = pulse(k).P_MeanZ ./ (pulse(k).P_MeanZ + pulse(k).C_MeanZ);
    pulse(k).ANM = string(ANM);
    pulse(k).Sex = string(Sex);
    pulse(k).EE = EE;
    pulse(k).AP = AP;    
    pulse(k).Slice = index;
    pulse(k).File = name;
    pulse(k).tau = abs(14./log(1./pulse(k).fraction));
    f = pulse(k).PixelValues ./ (pulse(k).PixelValues + chase(k).PixelValues);
    f = f(isfinite(f));
    pulse(k).tau_values = abs(14./log(1./f));

end
tbl = struct2table(pulse);
tbl = tbl(:,[13:17, 9:10, 19,20,2:8,18,11,12]);

end