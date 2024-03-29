%%
clc;
close all;
clear;
basePath = 'Y:\ImagingArchive\Unbised\SlideScanner\Round17Other';
cd (basePath);
%% organ list
% Slide1c1 =  muscle
% slide1c2 = GI track
% slide2C1 = kidney adrenal
% slide2C2 = heart
% slide3c1, 1-6 =liver
% slide3c1, 7 = spleen
% 
% slide 5-6 669
% slide 8-9 673 20x
%%
name ='Slide 5 from cassette 2-Region 004';
dapi = imread([name '_DAPI.tiff']);
figure()
imshow(dapi,[])
set(gca(), 'clim',[0,2000])
[xrefout,yrefout,crop_dapi, x] = imcrop() ;
%% muscle

name ='Slide 1 from cassette 1-Region 005';
fov1 = [4545, 3265 ];
[f, f2] = ExmpleOrgan(name, fov1, 'muscle') 
%% GI

name ='Slide 1 from cassette 2-Region 004';
% fov1 = [5890, 5980 ];
fov1 = [ 5120 ,6430];
[f, f2] = ExmpleOrgan(name, fov1, 'GI') 
%% kidney
name ='Slide 2 from cassette 1-Region 001';
fov1 = [8600, 8550 ];
[f, f2] = ExmpleOrgan(name, fov1, 'kidney') ;
%% heart
name ='Slide 2 from cassette 2-Region 001';
fov1 = [740, 6540 ];
[f, f2] = ExmpleOrgan(name, fov1,'heart') ;
%% liver
name ='Slide 3 from cassette 1-Region 002';
fov1 = [6071,1559];
[f, f2] = ExmpleOrgan(name, fov1, 'liver', 1) ;

%% kidney
name ='Slide 3 from cassette 1-Region 007';
fov1 = [4800,1550];
[f, f2] = ExmpleOrgan(name, fov1, 'spleen') ;

%% brain 669 good
basePath = 'Y:\ImagingArchive\Unbised\MECP2_ANM468893_10Min_Control\10x\';
cd(basePath);
name = 'Slide1_Section2.tif';
dapi = imread(name, 1);
cy3 = imread(name,3);
cy5 = imread(name,2);
filename = 'ExampleBrain';
%%
fov1 = [6645,6033];
size1=200;
dapi_ds = imresize(dapi, 0.1);
cy3_ds =  imresize(cy3, 0.1);
cy5_ds =  imresize(cy5, 0.1);

dapi_fov1 = dapi(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);
cy3_fov1 = cy3(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);
cy5_fov1 = cy5(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);
%%
um_per_px = 6.7;
scalebar_um = 1000;
scalebar_px = scalebar_um/um_per_px;
x_offset = 4;
y_offest = 58;
%%
f =figure(1);
clf
J = imadjust(dapi_ds);
J2 =cat(3, J, J, J);
J2(:, :, 1) = 0;
J2(:, :, 2) = 0;
imshow(J2);
hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')

set(f, 'Units','centimeters')
set(f,'Position', [12,12, 3, 2]);
set(f, 'Units','pixels')
exportgraphics(gcf,[filename, '_1_1.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy5_ds);
J2 =cat(3, J, J, J);
J2(:, :, 2) = 0;
J2(:, :, 3) = 0;
imshow(J2);
set(f, 'Units','centimeters')
set(f,'Position', [12,12, 3, 2]);
set(f, 'Units','pixels')
exportgraphics(gcf,[filename, '_1_2.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy3_ds);
J2 =cat(3, J, J, J);
J2(:, :, 2) = J2(:, :, 2)/255*165;
J2(:, :, 3) = 0;
imshow(J2);
set(f, 'Units','pixels')
set(gca, 'Units','pixels')
stop = [fov1(2)/10, fov1(1)/10];
a = rectangle("position",[stop(1)-45, stop(2)-45, 90,90], 'EdgeColor','w','LineWidth',1);

exportgraphics(gcf,[filename, '_1_3.pdf'],'BackgroundColor','none','ContentType','vector');

%%

um_per_px = 0.67;
scalebar_um = 50;
scalebar_px = scalebar_um/um_per_px;
x_offset = 4;
y_offest = 240;
f2 =figure(2);
clf
set(f2, 'Units','centimeters')
J = imadjust(dapi_fov1);
J2 =cat(3, J, J, J);
J2(:, :, 1) = 0;
J2(:, :, 2) = 0;
imshow(J2);

set(f, 'Units','centimeters')
set(f,'Position', [12,12, 3, 2]);
hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
exportgraphics(gcf,[filename, '_2_1.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy5_fov1);
J2 =cat(3, J, J, J);
J2(:, :, 2) = 0;
J2(:, :, 3) = 0;

hold off;
imshow(J2);
exportgraphics(gcf,[filename, '_2_2.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy3_fov1);
J2 =cat(3, J, J, J);
J2(:, :, 2) = J2(:, :, 2)/255*165;
J2(:, :, 3) = 0;
imshow(J2);
exportgraphics(gcf,[filename, '_2_3.pdf'],'BackgroundColor','none','ContentType','vector');
 %% brain 669 Bad
basePath = 'Y:\ImagingArchive\Unbised\MECP2_ANM468893_10Min_Control\10x\';
cd(basePath);
name = 'Slide1_Section5_2.tif';
dapi = imread(name, 1);
cy3 = imread(name,3);
cy5 = imread(name,2);
filename = 'ExampleBrain2';
%%
fov1 =[4109, 6226];         
size1=200;
dapi_ds = imresize(dapi, 0.1);
cy3_ds =  imresize(cy3, 0.1);
cy5_ds =  imresize(cy5, 0.1);

dapi_fov1 = dapi(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);
cy3_fov1 = cy3(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);
cy5_fov1 = cy5(fov1(1):fov1(1)+size1, fov1(2):fov1(2)+size1);
%%
%%
um_per_px = 6.7;
scalebar_um = 1000;
scalebar_px = scalebar_um/um_per_px;
x_offset = 4;
y_offest = 58;
%%
f =figure(1);
clf
J = imadjust(dapi_ds);
J2 =cat(3, J, J, J);
J2(:, :, 1) = 0;
J2(:, :, 2) = 0;
imshow(J2);
hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')

set(f, 'Units','centimeters')
set(f,'Position', [12,12, 3, 2]);
set(f, 'Units','pixels')
exportgraphics(gcf,[filename, '_1_1.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy5_ds);
J2 =cat(3, J, J, J);
J2(:, :, 2) = 0;
J2(:, :, 3) = 0;
imshow(J2);
set(f, 'Units','centimeters')
set(f,'Position', [12,12, 3, 2]);
set(f, 'Units','pixels')
exportgraphics(gcf,[filename, '_1_2.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy3_ds);
J2 =cat(3, J, J, J);
J2(:, :, 2) = J2(:, :, 2)/255*165;
J2(:, :, 3) = 0;
imshow(J2);
set(f, 'Units','pixels')
set(gca, 'Units','pixels')
stop = [fov1(2)/10, fov1(1)/10];
a = rectangle("position",[stop(1)-45, stop(2)-45, 90,90], 'EdgeColor','w','LineWidth',1);

exportgraphics(gcf,[filename, '_1_3.pdf'],'BackgroundColor','none','ContentType','vector');

%%

um_per_px = 0.67;
scalebar_um = 50;
scalebar_px = scalebar_um/um_per_px;
x_offset = 4;
y_offest = 240;
f2 =figure(2);
clf
set(f2, 'Units','centimeters')
J = imadjust(dapi_fov1);
J2 =cat(3, J, J, J);
J2(:, :, 1) = 0;
J2(:, :, 2) = 0;
imshow(J2);

set(f, 'Units','centimeters')
set(f,'Position', [12,12, 3, 2]);
hold on;
plot([x_offset, scalebar_px+x_offset], [y_offest, y_offest],'linewidth',3,'color','w')
exportgraphics(gcf,[filename, '_2_1.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy5_fov1);
J2 =cat(3, J, J, J);
J2(:, :, 2) = 0;
J2(:, :, 3) = 0;

hold off;
imshow(J2);
exportgraphics(gcf,[filename, '_2_2.pdf'],'BackgroundColor','none','ContentType','vector');
J = imadjust(cy3_fov1);
J2 =cat(3, J, J, J);
J2(:, :, 2) = J2(:, :, 2)/255*165;
J2(:, :, 3) = 0;
imshow(J2);
exportgraphics(gcf,[filename, '_2_3.pdf'],'BackgroundColor','none','ContentType','vector');