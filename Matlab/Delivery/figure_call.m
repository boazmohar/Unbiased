function figure_call(A, B)
disp('WORKING');
path        = pwd();
offset      = 150;
data        = A.UserData.data;
image_i     = A.UserData.i;
basePath    = ['W:\moharb\Unbiased\Round' num2str(data.Round) '\raw\'];
cd(basePath)
Pos         = B.IntersectionPoint(1:2);
x           = Pos(2);
y           = Pos(1);
imageSize   = data.Image_Size(image_i, :);
x           = x+imageSize(1)/2;
y           = y+imageSize(2)/2;
baseName    = data.filenames{image_i};
f = figure('units','normalized', 'position', [0.1, 0, 0.8, 0.8], ...
    'Name',baseName);
chs = length(data.Ch_Names);
% all_axs(1:2*chs) = axes(f);
all_axs(1:chs) = axes(f);
for i = 1:chs
    all_axs(i) = subaxis(1, chs,i, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
    name = [baseName data.Ch_Names{i} '.tiff'];
    image = imread(name);
    xmin = round(max(x-offset, 1));
    ymin = round(max(y-offset, 1));
    xmax = round(min(x+offset, imageSize(1)));
    ymax = round(min(y+offset, imageSize(2)));
    currnet = single(image(ymin:ymax, xmin:xmax));
    currnet(currnet==0) = nan;
    vmin = prctile(currnet, 0.3, 'all');
    vmax = prctile(currnet, 99.7, 'all');
    if isnan(vmin)
        vmin = 150;
    end
    if isnan(vmax)
        vmax = 600;
    end
    imshow( image, [vmin vmax]);
    hold on;
    plot(x, y, 'ks');
    colormap(viridis(256));
    colorbar;
    switch i
        case data.virus_index
            title1 = sprintf('Virus: %s', data.virus_name);
        case data.invivo_index
            title1 = sprintf('Invivo: %d', data.invivo_dye);
        case data.exvivo_index
            title1 = sprintf('Exvivo: %d', data.exvivo_dye);
    end
    title(title1, 'units','normalized','position',[0.5, 0.9, 0], ...
        'color','white');
%     all_axs(i+chs) =subaxis(2, chs,i+chs, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
%     imshow( currnet, [vmin vmax]);
%     colormap(viridis(256));
%     hold on;
%     plot(offset, offset, 'ys');
end
linkaxes(all_axs(1:chs), 'xy')
cd(path);
% linkaxes(all_axs(chs+1:end), 'xy')