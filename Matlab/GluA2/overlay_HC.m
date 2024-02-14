%% try to resegment HC.
%% load data
tbl_all = load_data_glua2('D:\',1,true,false);
%% filter to HC only
index_hc = strcmpi(tbl_all.Name, 'Field CA1');
tbl_hc = tbl_all(index_hc,:);
index2 = ~contains(tbl_hc.groupName, 'negative');
tbl_hc = tbl_hc(index2,:);
tbl_files = grpstats(tbl_hc,{'ANM','File'},'mean', 'DataVars','AP');
tbl_files = sortrows(tbl_files,"mean_AP","ascend");
%% get the folder from ANM name
folders = cell(1,height(tbl_files));
for i = 1:height(tbl_files)
    ANM = tbl_files{i,"ANM"};
    folder = get_folder_anm(ANM);
    folders{i} = folder;
end
tbl_files.folder = folders';
%%
f = figure(1);
clf
f.Units= "centimeters";
f.Position = [0    1.0583   50.8000   25.4794];
for i = 1:height(tbl_files)
    current = tbl_files(i,:);
    filepath = strcat(current.folder ,'\' ,current.File);
    img = imread(filepath);
    overlay = imread([filepath{1}(1:end-4) '_nl.png']);
    [gx,gy] = gradient(single(overlay));
    overlay((gx.^2+gy.^2)==0) = 0;
    outline = rgb2gray(overlay)>0;
    sz = size(img);
    region_borders2 = imresize(outline,sz(1:2),"nearest");
    region_borders2 = imerode(region_borders2, ones(2,2));
    region_borders3 = uint8(repmat(region_borders2,1,1,3))*255;
    transparent = imlincomb(0.5, region_borders3, 0.5, img);
    outfile = permute(transparent,[2,1,3]);
    imwrite(outfile, [filepath{1}(1:end-4), '_overlay.png'])

end
%% label HC per round and save
imageLabeler
%% for each round
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
CCF_names = {'Field CA1, oriens', 'Field CA1, pyramidal', ...
    'Field CA1, radiatum', 'Field CA1, slm'};
CCF_ids = [382001, 382002, 382003, 382004];
t = 128;
for i = 1:1
    %% load jt
    switch i
        case 1
            directory = 'GluA2_round1_try1\';
            gt = load([directory 'CA1_gt.mat']);
            gt = gt.CA1;
        case 2
            directory = 'GluA2_round2\';
            gt = load([directory 'CA1_gt.mat']);
            gt = gt.gTruth;
        case 3
            directory = 'GluA2_round3\';
            gt = load([directory 'CA1_gt.mat']);
            gt = gt.gTruth;
        case 4
            directory = 'GluA2_round4\';
            gt = load([directory 'CA1_gt.mat']);
            gt = gt.gTruth;
        case 5
            directory = 'GluA2_round5\';
            gt = load([directory 'CA1_gt.mat']);
            gt = gt.gTruth;
        case 6
            directory = 'GluA2_round6\';
            gt = load([directory 'CA1_gt.mat']);
            gt = gt.gTruth;
    end
    %% load table and hemi polygons
    tbl = load_data_glua2('D:\',i, false,false);
    files = gt.DataSource.Source;
    new_tables = cell(1,numel(files));
    gt_hemi = load([directory 'hemi.mat']);
    gt_hemi = gt_hemi.gTruth;
    %%
    wb = waitbar(0, 'Starting');
    nn = numel(files);
    for kk = 1:nn
        f = files(kk);
        % find parent CA1
        [d, name, ~] = fileparts(f{1});
        name2 = [name(1:end-8) '.png'];
        index = find(contains(tbl.File, name2));
        ca1 = find(contains(tbl.Name, 'CA1'));
        both = intersect(index, ca1);
        current = tbl(both,:);
        if height(current) == 0
            continue
        end
        %         assert(height(current) == 1);

        %% add   oriens, pyramidal, radiatum, slm
        % newIds:382001, 382002,    382003,   382004)
        png = permute(imread(gt.LabelData.PixelLabelData{kk}), [2,1]);

        if numel(unique(png)) < 4
            continue
        end
        mask_name = [directory name2(1:end-4) '_Probabilities.tif'];
        mask = imread(mask_name);

        bin_mask = uint16(mask > t);
        try
            pulse_name = [directory name2(1:end-4) '_CY5.tiff'];
            chase_name = [directory name2(1:end-4) '_CY3.tiff'];
            rawPulse = imread(pulse_name);
            rawChase = imread(chase_name);
        catch
            pulse_name = [directory name2(1:end-4) '-CY5.tiff'];
            chase_name = [directory name2(1:end-4) '-CY3.tiff'];
            rawPulse = imread(pulse_name);
            rawChase = imread(chase_name);
        end
        raw_size = size(rawPulse);
        bin_mask2 = single(imresize(bin_mask,raw_size(1:2), 'nearest'));
        rawPulse = single(rawPulse) .* bin_mask2;
        rawPulse(rawPulse==0) = nan;
        rawChase = single(rawChase).* bin_mask2;
        rawChase(rawChase==0) = nan;
        png2 = imresize(png, raw_size(1:2), 'nearest');
        %% hemi
        label_size = size(mask);
        gt_index = find(contains(gt_hemi.DataSource.Source,name(1:end-8)), 1);
        if ~isempty(gt_hemi.LabelData{gt_index,1}{1})
            %% masks
            right_poly = gt_hemi.LabelData{gt_index,1}{1};
            if iscell(right_poly)
                right_poly = cell2mat(right_poly);
            end
            left_poly = gt_hemi.LabelData{gt_index,2}{1};
            if iscell(left_poly)
                left_poly = cell2mat(left_poly);
            end
            right_mask = poly2mask(right_poly(:,1),right_poly(:,2),...
                label_size(1),label_size(2));
            left_mask = poly2mask(left_poly(:,1),left_poly(:,2),...
                label_size(1),label_size(2));
            %% right
            r_hemi =  png2 .* uint8(imresize(right_mask,raw_size(1:2), 'nearest'));
            if numel(unique(r_hemi)) < 4
                continue
            end
            pulse = regionprops( r_hemi, rawPulse, {'PixelValues', 'Centroid'});
            chase = regionprops( r_hemi, rawChase, {'PixelValues'});
            numObj = numel(pulse);
            assert(numObj == 4);
            current_r = current(contains(current.Hemi, "right"),:);
            current2 = repmat(current_r, 4, 1);
            for k = 1:numObj
                p = (double(pulse(k).PixelValues) - Blank(673)) ./ Calibration(673);
                c = (double(chase(k).PixelValues) -  Blank(552)) ./  Calibration(552);
                s = p+c;
                current2.P_Mean(k) = median(p, 'omitnan');
                current2.P_STD(k) = std(p, 'omitnan');
                current2.N(k) = sum(pulse(k).PixelValues > 0, 'omitnan');
                current2.C_Mean(k) = median(c, 'omitnan');
                current2.C_STD(k) = std(c, 'omitnan');
                current2.Name(k) = CCF_names(k);
                current2.CCF_ID(k) = CCF_ids(k);
                current2.fraction(k) = current2.P_Mean(k) ./ ...
                    (current2.P_Mean(k) + current2.C_Mean(k));
                current2.sum_sd(k) = std(s, 'omitnan');
                current2.tau(k) = abs(3./log(1./current2.fraction(k)));
                f = p./s;
                f = f(isfinite(f));
                current2.tau_values{k} = abs(3./log(1./f));
                current2.Centroid{k} = pulse(k).Centroid;
                current2.fp{k} = f;
            end
            tbl_r = current2;
            %% left hemi
            l_hemi =  png2 .* uint8(imresize(left_mask,raw_size(1:2), 'nearest'));
            if numel(unique(l_hemi)) < 4
                continue
            end
            pulse = regionprops( l_hemi, rawPulse, {'PixelValues', 'Centroid'});
            chase = regionprops( l_hemi, rawChase, {'PixelValues'});
            numObj = numel(pulse);
            assert(numObj == 4);
            current_l = current(contains(current.Hemi, "left"),:);
            current2 = repmat(current_l, 4, 1);
            for k = 1:numObj
                p = (double(pulse(k).PixelValues) - Blank(673)) ./ Calibration(673);
                c = (double(chase(k).PixelValues) -  Blank(552)) ./  Calibration(552);
                s = p+c;
                current2.P_Mean(k) = median(p, 'omitnan');
                current2.P_STD(k) = std(p, 'omitnan');
                current2.N(k) = sum(pulse(k).PixelValues > 0, 'omitnan');
                current2.C_Mean(k) = median(c, 'omitnan');
                current2.C_STD(k) = std(c, 'omitnan');
                current2.Name(k) = CCF_names(k);
                current2.CCF_ID(k) = CCF_ids(k);
                current2.fraction(k) = current2.P_Mean(k) ./ ...
                    (current2.P_Mean(k) + current2.C_Mean(k));
                current2.sum_sd(k) = std(s, 'omitnan');
                current2.tau(k) = abs(3./log(1./current2.fraction(k)));
                f = p./s;
                f = f(isfinite(f));
                current2.tau_values{k} = abs(3./log(1./f));
                current2.Centroid{k} = pulse(k).Centroid;
                current2.fp{k} = f;
            end
            new_tables(kk) = {[ tbl_r ; current2 ]};
        else
            pulse = regionprops( png2, rawPulse, {'PixelValues'});
            chase = regionprops( png2, rawChase, {'PixelValues'});
            numObj = numel(pulse);
            assert(numObj == 4);
            current2 = repmat(current, 4, 1);
            for k = 1:numObj
                p = (double(pulse(k).PixelValues) - Blank(673)) ./ Calibration(673);
                c = (double(chase(k).PixelValues) -  Blank(552)) ./  Calibration(552);
                s = p+c;
                current2.P_Mean(k) = median(p, 'omitnan');
                current2.P_STD(k) = std(p, 'omitnan');
                current2.N(k) = sum(pulse(k).PixelValues > 0, 'omitnan');
                current2.C_Mean(k) = median(c, 'omitnan');
                current2.C_STD(k) = std(c, 'omitnan');
                current2.Name(k) = CCF_names(k);
                current2.CCF_ID(k) = CCF_ids(k);
                current2.fraction(k) = current2.P_Mean(k) ./ ...
                    (current2.P_Mean(k) + current2.C_Mean(k));
                current2.sum_sd(k) = std(s, 'omitnan');
                current2.tau(k) = abs(3./log(1./current2.fraction(k)));
                f = pulse(k).PixelValues ./ (pulse(k).PixelValues + chase(k).PixelValues);
                f = f(isfinite(f));
                current2.tau_values{k} = abs(3./log(1./f));
                current2.fp{k} = f;
            end
            new_tables(kk) = {current2};
        end


        waitbar(kk/nn, wb, sprintf('Progress: %d %%', floor(kk/nn*100)));
        pause(0.1);
    end
    tbl_hc = vertcat(new_tables{:});
    save(sprintf('CA1_tbl_round%d.mat', i), 'tbl_hc','-v7.3')
    fprintf('Done round %d\n', i);
    close(wb)
end
