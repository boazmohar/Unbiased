function [f,f2] = ExmpleOrgan(name, fov1, filename, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% basePath = 'E:\ImagingArchive\Unbised\SlideScanner\Round17Other';
% cd (basePath);
name2 = sprintf('%s_dapi_fov_%d_%d.tif', name, fov1(1), fov1(2));
if ~isfile(name2)
    dapi = imread([name '_DAPI.tiff']);
    cy3 = imread([name '_CY3.tiff']);
    cy5 = imread([name '_CY5.tiff']);
    if nargin >=4 && varargin{1}
        dapi =dapi';
        cy3 = cy3';
        cy5 = cy5';
        fov1 = fov1(end:-1:1);
    end
    
    if nargin >=5 
        basePath =  varargin{2};
    end
    % fov1 = [5700, 5960 ];
    
    dapi_ds = imresize(dapi, 0.1);
    cy3_ds =  imresize(cy3, 0.1);
    cy5_ds =  imresize(cy5, 0.1);
    imwrite(dapi_ds, [name '_dapi_ds.tif'])
    imwrite(cy3_ds, [name '_cy3_ds.tif'])
    imwrite(cy5_ds, [name '_cy5_ds.tif'])
    size1=100;

    dapi_fov1 = dapi(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);
    cy3_fov1 = cy3(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);
    cy5_fov1 = cy5(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);

    imwrite(dapi_fov1, sprintf('%s_dapi_fov_%d_%d.tif', name, fov1(1), fov1(2)))
    imwrite(cy3_fov1,sprintf('%s_cy3_fov_%d_%d.tif', name, fov1(1), fov1(2)))
    imwrite(cy5_fov1, sprintf('%s_cy5_fov_%d_%d.tif', name, fov1(1), fov1(2)))
else
    dapi_ds = imread([name '_dapi_ds.tif']);
    cy3_ds = imread( [name '_cy3_ds.tif']);
    cy5_ds = imread([name '_cy5_ds.tif']);
    dapi_fov1 = imread(sprintf('%s_dapi_fov_%d_%d.tif', name, fov1(1), fov1(2)));
    cy3_fov1 = imread(sprintf('%s_cy3_fov_%d_%d.tif', name, fov1(1), fov1(2)));
    cy5_fov1 = imread(sprintf('%s_cy5_fov_%d_%d.tif', name, fov1(1), fov1(2)));
end

%%
um_per_px = 6.7;
scalebar_um = 1000;
scalebar_px = scalebar_um/um_per_px;
x_offset = 4;
y_offest = 58;
%%
f =figure(1);
clf
set(f, 'Units','centimeters')
set(f,'Position', [12,12, 3, 2]);
set(f,'Color','none');
J = imadjust(dapi_ds);
J2 =cat(3, J, J, J);
J2(:, :, 1) = 0;
J2(:, :, 2) = 0;
imshow(J2)%, [200, 500]);
set(f,'Position', [12,12, 3, 2]);
hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
exportgraphics(gcf,[filename, '_1_1.pdf'],'BackgroundColor','none','ContentType','vector');
hold off;
J = imadjust(cy5_ds);
J2 =cat(3, J, J, J);
J2(:, :, 2) = 0;
J2(:, :, 3) = 0;
imshow(J2)%, [200, 500]);
set(f,'Position', [12,12, 3, 2]);
exportgraphics(gcf,[filename, '_1_2.pdf'],'BackgroundColor','none','ContentType','vector');
hold off;
J = imadjust(cy3_ds);
J2 =cat(3, J, J, J);
J2(:, :, 2) = J2(:, :, 2)/255*165;
J2(:, :, 3) = 0;
imshow(J2)%, [200, 500]);
set(f,'Position', [12,12, 3, 2]);
set(f, 'Units','pixels')
set(gca, 'Units','pixels')
stop = [fov1(2)/10, fov1(1)/10];
start = stop - 100;
hold on
a = rectangle("position",[stop(1)-25, stop(2)-25, 50,50], 'EdgeColor','w','LineWidth',.5)

exportgraphics(gcf,[filename, '_1_3.pdf'],'BackgroundColor','none','ContentType','vector');
hold off
% draw_arrow(start, stop,'FaceColor','w', 'edgecolor','w', 'Length', 10)0
% if nargin >= 3
%     
% %     exportgraphics(f, [filename, '_1.png'],'Resolution', 200)
% %     export_fig([filename, '_1.pdf'], '-depsc')
% end
%%

um_per_px = 0.67;
scalebar_um = 50;
scalebar_px = scalebar_um/um_per_px;
x_offset = 4;
y_offest = 240;
f2 =figure(2);
clf
set(f2, 'Units','centimeters')
set(f2,'Position', [12,12, 18, 5]);
set(f2,'Color','none');
J = imadjust(dapi_fov1, stretchlim(dapi_fov1, [0.001, 0.999]));
J2 =cat(3, J, J, J);
J2(:, :, 1) = 0;
J2(:, :, 2) = 0;
imshow(J2);
set(f,'Position', [12,12, 3, 2]);

hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
exportgraphics(gcf,[filename, '_2_1.pdf'],'BackgroundColor','none','ContentType','vector');
hold off
J = imadjust(cy5_fov1 ,stretchlim(cy5_fov1, [0.001, 0.999]));
J2 =cat(3, J, J, J);
J2(:, :, 2) = 0;
J2(:, :, 3) = 0;
imshow(J2);
set(f,'Position', [12,12, 3, 2]);
exportgraphics(gcf,[filename, '_2_2.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy3_fov1, stretchlim(cy3_fov1, [0.001, 0.999]));
J2 =cat(3, J, J, J);
J2(:, :, 2) = J2(:, :, 2)/255*165;
J2(:, :, 3) = 0;
imshow(J2);

set(f,'Position', [12,12, 3, 2]);
exportgraphics(gcf,[filename, '_2_3.pdf'],'BackgroundColor','none','ContentType','vector');
end

