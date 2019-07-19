function GetMasks_par_files(cores)
current_dir = pwd();
p=parpool(cores);
disp('Started');
objProb     = dir('*Object*.tif');
probFiles   = sort_nat({objProb.name});
numFiles    = length(probFiles);
fprintf('found %d probFiles', numFiles)
x           = cell(numFiles,1);
y           = cell(numFiles,1);
z           = cell(numFiles,1);
GFP         = cell(numFiles,1);
JF585       = cell(numFiles,1);
JF669       = cell(numFiles,1);
GFP_bg      = cell(numFiles,1);
JF585_bg    = cell(numFiles,1);
JF669_bg    = cell(numFiles,1);
Cell_Type   = cell(numFiles,1);
SE          = strel('square',25);
SE2          = strel('square',3);
pp = ParforProgress; 
parfor i =1:numFiles
    cd(current_dir)
    % read prob image
    filename    = probFiles{i};
%     fprintf('Loading i: %d, file: %s\n',i, filename);
    prob        = imread(filename);
    sz          = size(prob);
    bw_1        = prob == 1; % cell
    bw_2        = prob == 3; % saturated cell
    bw_3        = prob == 4; % small cell
    if sum(bw_1(:)) + sum(bw_2(:)) + sum(bw_3(:)) == 0
        fprintf('Skipping: %d', i);
        continue
    end
    % read nuropil from h5
    k           = strfind(filename,'_');
    baseName    = filename(1:k(end));
    pixelName   = [baseName 'Probabilities.h5'];
    px          = h5read(pixelName, '/exported_data');
    bw_not      = px(1, :, :) > 0.2 | px(2, :, :) > 0.2 | px(7, :, :) > 0.4 |...
        px(8, :, :) > 0.2 | px(9, :, :) > 0.2;
    bw_not      = squeeze(bw_not)'; % exclude from neuropil
    bw_not_d      = ~imdilate(bw_not, SE2);
    % get raw data crop to match RGB version
    cd('raw');
    GFP_ds      = imread([baseName 'FITC.tiff']);
    JF585_ds    = imread([baseName 'Texas.tiff']);
    JF669_ds    = imread([baseName 'Cy5.tiff']);
    cd(current_dir);
    GFP_ds      = GFP_ds(1:sz(1), 1:sz(2));
    JF585_ds    = JF585_ds(1:sz(1), 1:sz(2));
    JF669_ds    = JF669_ds(1:sz(1), 1:sz(2));
    % get labels
    label1              = bwlabel(bw_1); % cell
    label2              = bwlabel(bw_2); % saturated
    label3              = bwlabel(bw_3); % small
    numLabels1          = max(label1(:));
    numLabels2          = max(label2(:));
    numLabels3          = max(label3(:));
    numLabelsAll        = numLabels1 + numLabels2 + numLabels3;
    nimLabels10         = round(numLabelsAll/10)-1;
%     fprintf('i: %d, Found %d cells, %d saturated, %d small\n', ...
%         i, numLabels1, numLabels2, numLabels3);
    GFP_current         = zeros(numLabelsAll, 1);
    JF585_current       = zeros(numLabelsAll, 1);
    JF669_current       = zeros(numLabelsAll, 1);
    GFP_bg_current      = zeros(numLabelsAll, 1);
    JF585_bg_current    = zeros(numLabelsAll, 1);
    JF669_bg_current    = zeros(numLabelsAll, 1);
    % compute forground and background for each label
    for l = 1:numLabelsAll
        blank               = zeros(sz(1), sz(2), 'logical');
        if l <= numLabels1                  % cell
            current         = label1==l;
        elseif l <= numLabels1 + numLabels2 && numLabels2 > 0 % saturated
            current         = label2==(l-numLabels1);
        else                                % small
            current         = label3==(l-(numLabels1 + numLabels2));
        end
        blank(current)      = true;
        blank               = logical(imdilate(blank, SE) - current);
        blank               = blank & bw_not_d;
        GFP_current(l)      = mean(GFP_ds(current), 'all');
        JF585_current(l)    = mean(JF585_ds(current), 'all');
        JF669_current(l)    = mean(JF669_ds(current), 'all');
        GFP_bg_current(l)   = mean(GFP_ds(blank), 'all');
        JF585_bg_current(l) = mean(JF585_ds(blank), 'all');
        JF669_bg_current(l) = mean(JF669_ds(blank), 'all');
        stats_temp = regionprops(current,GFP_ds,'Centroid');
        x1 = round(stats_temp.Centroid(2));
        y1 = round(stats_temp.Centroid(1));
        if mod(l, nimLabels10) == 0 && x1 > 51 && y1 > 51 && ...
                x1 < sz(1) - 51 && y1 < sz(2) - 51
            
            GFP_ds2 = GFP_ds(x1-50:x1+50, y1-50:y1+50);
            JF585_ds2 = JF585_ds(x1-50:x1+50, y1-50:y1+50);
            JF669_ds2 = JF669_ds(x1-50:x1+50, y1-50:y1+50);
            current2 = current(x1-50:x1+50, y1-50:y1+50);
            blank2 = blank(x1-50:x1+50, y1-50:y1+50);
            bw_not2 = bw_not_d(x1-50:x1+50, y1-50:y1+50);
            JF585_m = round(JF585_current(l));
            JF585_b = round(JF585_bg_current(l));
            JF669_m = round(JF669_current(l));
            JF669_b = round(JF669_bg_current(l));
            JF585_s = JF585_m - JF585_b;
            JF669_s = JF669_m - JF669_b;
            JF585_r = JF585_s / (JF585_s + JF669_s);
            JF669_r = JF669_s / (JF585_s + JF669_s);
            f=figure('visible','off');
            clf;
            subplot(2,2,1)
            J = imadjust(GFP_ds2);
            B = imoverlay(J, current2, 'red');
            imshow(B);
            title(sprintf('%dpx', sum(current2, 'all')));
            subplot(2,2,2)
            B = imoverlay(J, blank2, 'red');
            imshow(B, []);
            title(sprintf('%dpx', sum(blank2, 'all')));
            subplot(2,2,3)
            imshow(JF585_ds2, [150, 600]);
            colormap(parula)
            colorbar();
            title(sprintf('%d-%d=%d,%.2f', JF585_m, JF585_b, JF585_s, JF585_r))
       
            subplot(2,2,4)
            imshow(JF669_ds2, [150, 600]);
            title(sprintf('%d-%d=%d,%.2f', JF669_m, JF669_b,  JF669_s,JF669_r))
            colormap(parula)
            colorbar();
            
            cd('png');
            saveas(f, sprintf('%s_%d.png', filename, l))
            cd(current_dir);
        end
    end
    % store values
    stats1      = regionprops(bw_1,GFP_ds,'Centroid');
    xys1        = cell2mat({stats1.Centroid}');
    stats2      = regionprops(bw_2,GFP_ds,'Centroid');
    xys2        = cell2mat({stats2.Centroid}');
    stats3      = regionprops(bw_3,GFP_ds,'Centroid');
    xys3        = cell2mat({stats3.Centroid}');
    x_temp = [];
    y_temp = [];
    if numLabels1 > 0
        x_temp = [x_temp; xys1(:,1)];
        y_temp = [y_temp; xys1(:,2)];
    end
    if numLabels2 > 0
        x_temp = [x_temp; xys2(:,1)];
        y_temp = [y_temp; xys2(:,2)];
    end
    if numLabels3 > 0
        x_temp = [x_temp; xys3(:,1)];
        y_temp = [y_temp; xys3(:,2)];
    end
    x{i}        = x_temp-size(GFP_ds,2)/2;
    y{i}        = y_temp-size(GFP_ds,1)/2;
    z{i}        = ones(numLabelsAll, 1).*i;
    GFP{i}      = GFP_current;
    JF585{i}    = JF585_current;
    JF669{i}    = JF669_current;
    GFP_bg{i}   = GFP_bg_current;
    JF669_bg{i} = JF669_bg_current;
    JF585_bg{i} = JF585_bg_current;
    Cell_Type{i}= [ones(numLabels1, 1); ones(numLabels2, 1)*2; ...
        ones(numLabels3, 1)*3];
    iteration_number = step(pp, i); 
    fprintf('Finished iteration %d of %d\n', iteration_number, numFiles); 
end
data            = struct();
data.x          = x;
data.y          = y;
data.z          = z;
data.GFP        = GFP;
data.JF585      = JF585;
data.JF669      = JF669;
data.GFP_bg     = GFP_bg;
data.JF585_bg   = JF585_bg;
data.JF669_bg   = JF669_bg;
data.Cell_Type  = Cell_Type;
name = ['MaskData ' datestr(datetime())];
save(name, 'data')
fprintf('Saved: %s', name);
delete(p);
end

