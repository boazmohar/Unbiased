function tbl = do_both_glua2(png, LabelTables, rawPulse, rawChase, ANM, ...
        sex, group, age, line, AP, index, name, round)
%% parse allen
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

%% right hemi
pulse = regionprops( ic2_s2, rawPulse, {'PixelValues', 'Centroid'}); 
chase = regionprops( ic2_s2, rawChase, {'PixelValues'});
numObj = numel(pulse);
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
for k = 1:numObj
    p = (double(pulse(k).PixelValues) - Blank(673)) ./ Calibration(673);
    c = (double(chase(k).PixelValues) -  Blank(552)) ./  Calibration(552);
    s = p+c;
    pulse(k).P_Mean = median(p, 'omitnan');
    pulse(k).P_STD = std(p, 'omitnan');
    pulse(k).N = sum(pulse(k).PixelValues > 0, 'omitnan');
    pulse(k).C_Mean = median(c, 'omitnan');
    pulse(k).C_STD = std(c, 'omitnan');
    pulse(k).Name = CCF_names(k);
    pulse(k).CCF_ID = CCF_ids(k);
    pulse(k).fraction = pulse(k).P_Mean ./ (pulse(k).P_Mean + pulse(k).C_Mean);
    pulse(k).sum_sd = std(s, 'omitnan');
    pulse(k).ANM = string(ANM);
    pulse(k).Sex = string(sex);
    pulse(k).groupName = string(group);
    pulse(k).AP = AP;    
    pulse(k).Slice = index;
    pulse(k).File = name;
    pulse(k).tau = abs(3./log(1./pulse(k).fraction));
    f = pulse(k).PixelValues ./ (pulse(k).PixelValues + chase(k).PixelValues);
    f = f(isfinite(f));
    pulse(k).tau_values = abs(3./log(1./f));
    pulse(k).fp = f;
    pulse(k).Age = age;
    pulse(k).Line = line;
    pulse(k).SizeX = S2(1);
    pulse(k).SizeY = S2(2);
    pulse(k).Hemi = 'both';
    pulse(k).Centroid = {pulse(k).Centroid};
    pulse(k).Round = round;
end
bbox = regionprops( isfinite(rawPulse), {'BoundingBox'});  
if length(bbox) > 1
    bbox = bbox(1);
end
bb = {bbox.BoundingBox};
tbl = struct2table(pulse);
tbl = tbl(:,[12:16, 8:9, 18:20,3:7,17,10,11, 21:23,1,24:end]);
tbl.bbox = repmat(bb, height(tbl), 1);

end
