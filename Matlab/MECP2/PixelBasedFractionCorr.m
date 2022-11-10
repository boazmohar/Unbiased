close all; clear; clc;
tbl = compute_tbl(0);
%%

uniqueFiles = [{'ANM460140_NeuN_Slide1a_Section1_Half_Shading Correction.ims' }
    {'OldANM460141_NeuN_Slide1a_Section3_Half_Shading Correction.ims'}
    {'ANM473364_NeuN_Slide1_Section4_Half_Shading Correction.ims'  }
    {'ANM473365_NeuN_Slide1_Section4_Shading Correction.ims'       }
    {'ANM66_NeuN_Slide1_Section4_Shading Correction.ims'           }];
data = cell(1,5);
seriesNum = 5;
for f = 1:5
    filename = uniqueFiles{f};
     data{f} = loadBF(filename, seriesNum);
end
%%
load('Series5Data.mat');

%% get shading correction
large = tbl.Large == 1;
rightAP = -2;
ap = tbl.AP == rightAP;
index = large & ap;
intervalType = 1;
cellType= 1;
index = index & tbl.intervalType==intervalType & tbl.cellType ==cellType;
tbl = tbl(index,:);
shading = cell2mat(tbl.shadingData([1,3,4,5,6])'); % ch x anm
dyes = [608,669,552];
chs = [2,4,5];
shading = shading(chs, :);
configuration = '880_40x_newLaser';
[Slope, Blank] = getCalibration(configuration);
%%
DAPI_max_all = {};
fraction_max_all = {};
do_plot=0;
Th = 1;
for anm = 1:5
    anm
    image =  single(data{anm});
    sz = size(image);
    after_all = zeros(sz(1), sz(2), sz(3), 3);
    for c_index = 1:3
        c = chs(c_index);
        current =image(:,:,:, c)./shading(c_index);
        current(current < Th) = nan;
        dye = dyes(c_index);
        current = (current - Blank(dye)) ./ Slope(dye);
        current = current .* 1000;
        after_all(:,:,:,c_index) = current;
    end
    sum1 = after_all(:,:,:,1) + after_all(:,:,:,2) + after_all(:,:,:,3);
    fraction = (after_all(:,:,:,3) + after_all(:,:,:,2)) ./ sum1;
    fraction(fraction<0) = 0;
    fraction(fraction> 2) = 2;
    fraction_max = max(fraction, [], 3);
    DAPI = image(:,:,:,1);
    DAPI(DAPI<Th) = nan;
    DAPI_max = max(DAPI, [], 3);
    DAPI_max_all{anm} =DAPI_max;
    fraction_max_all{anm} =fraction_max;
    if do_plot
        figure(anm);
        clf
        subplot(1,3,1)
        histogram(fraction(:), 100);
        subplot(1,3,2)
        imshow(fraction_max, [0,1]);
        subplot(1,3,3)
        imshow(DAPI_max, []);
        colorbar()
    end
end
%% get transformations
fixedIndex = 2;
Fixed = DAPI_max_all{fixedIndex};
reg_all = {};
k = 1;
for i = 1:5
    if i == fixedIndex
        continue
    end
    i
    Moving = DAPI_max_all{i};
    [MOVINGREG] = registerImages_ver1(Moving,Fixed);
    reg_all(k) = {MOVINGREG};
    k=k+1;
end
%%
tformed_all = {};
nonlReg_all = {};
k = 1;
for i = 1:5
    if i == fixedIndex
        continue
    end
    im = fraction_max_all{i};
    im(isnan(im)) = 0;
    im(im==Inf) = 1;
    im(im==-Inf) = 0;
    reg1 = reg_all{k};
    tform  = reg1.Transformation;
    field = reg1.DisplacementField;
    im1 = imwarp(im, tform);
    im2 = imwarp(im1, field);
    tformed_all(k) = {im1};
    nonlReg_all(k) = {im2};
    k=k+1;
end
%%
k=1;
for i = 1:5
    if i ==fixedIndex
        A = fraction_max_all{i};
        B = fraction_max_all{i};
    else
        A = nonlReg_all{k};
        B = tformed_all{k};
        k=k+1;
    end
    imwrite(A, sprintf('Fixed2_nonReg_%d.tif', i))
    imwrite(B, sprintf('Fixed2_tformed__%d.tif', i))
end
