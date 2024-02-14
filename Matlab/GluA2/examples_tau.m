%%
region = tbl_pair_ee(3,:);
index = contains(tbl_all3.Name, region.name{1});
current = tbl_all3(index,:);
conds = ["control","EE"];
index2 = [];
for cond = conds
    index2 = [index2; find(contains(current.groupName, cond))];
end
current2 = current(index2,:);
%%
index1 = 1;

example = current2(index1,:);
d = get_folder_anm(example.ANM);
name = [d filesep example.File{1}];
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
try % different export software from slide scanner makes different names
    pulse_name = [name(1:end-4) '_CY5.tiff'];
    chase_name = [name(1:end-4) '_CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
catch
    pulse_name = [name(1:end-4) '-CY5.tiff'];
    chase_name = [name(1:end-4) '-CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
end
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
img = ind2rgb(int16(t), viridis);
%
overlay = imread([name(1:end-4) '_nl.png']);
[gx,gy] = gradient(single(overlay));
overlay((gx.^2+gy.^2)==0) = 0;
outline = rgb2gray(overlay)>0;
sz = size(t);
region_borders2 = imresize(outline,sz(1:2),"nearest");
region_borders2 = double(imerode(region_borders2, ones(2,2))');
region_borders2(region_borders2 == 0) = nan;
%
figure(1);
clf;
hold on
imshow(t', [0,7] )
colormap(viridis)
hold on
hi = imshow(region_borders2*7, [0,7]);
set(hi,'AlphaData',0.21);
colorbar('eastoutside')
colormap(viridis)
set(gca,'YDir','normal')

px_size = 0.34 * 5;
bar_size = 1000;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [100,100],'w')
text(20+bar_px./2, 250,'1mm',HorizontalAlignment='center', Color='w')
export_fig('Example_C4_Frontal.eps')
%%
index1 = 6;

example = current2(index2,:);
d = get_folder_anm(example.ANM);
name = [d filesep example.File{1}];
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
try % different export software from slide scanner makes different names
    pulse_name = [name(1:end-4) '_CY5.tiff'];
    chase_name = [name(1:end-4) '_CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
catch
    pulse_name = [name(1:end-4) '-CY5.tiff'];
    chase_name = [name(1:end-4) '-CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
end
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
img = ind2rgb(int16(t), viridis);
%
overlay = imread([name(1:end-4) '_nl.png']);
[gx,gy] = gradient(single(overlay));
overlay((gx.^2+gy.^2)==0) = 0;
outline = rgb2gray(overlay)>0;
sz = size(t);
region_borders2 = imresize(outline,sz(1:2),"nearest");
region_borders2 = double(imerode(region_borders2, ones(2,2))');
region_borders2(region_borders2 == 0) = nan;
%
figure(2);
clf;
hold on
imshow(t', [0,7] )
colormap(viridis)
hold on
% hi = imshow(region_borders2*7, [0,7]);
% set(hi,'AlphaData',0.21);
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
px_size = 0.34 * 5;
bar_size = 1000;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [100,100],'w')
text(20+bar_px./2, 250,'1mm',HorizontalAlignment='center', Color='w')
export_fig('Example_EE2_Frontal.eps')
%% %%

region = tbl_pair_learn(1,:);
index = find(contains(tbl_all3.Name, region.name{1}));
current = tbl_all3(index,:);
conds = ["random","rule"];
index2 = [];
for cond = conds
    index2 = [index2; find(contains(current.groupName, cond))];
end
current2 = current(index2,:);
%%
index1 = 29;

example = current2(index1,:);
d = get_folder_anm(example.ANM);
name = [d filesep example.File{1}];
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
try % different export software from slide scanner makes different names
    pulse_name = [name(1:end-4) '_CY5.tiff'];
    chase_name = [name(1:end-4) '_CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
catch
    pulse_name = [name(1:end-4) '-CY5.tiff'];
    chase_name = [name(1:end-4) '-CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
end
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
img = ind2rgb(int16(t), viridis);
%
overlay = imread([name(1:end-4) '_nl.png']);
[gx,gy] = gradient(single(overlay));
overlay((gx.^2+gy.^2)==0) = 0;
outline = rgb2gray(overlay)>0;
sz = size(t);
region_borders2 = imresize(outline,sz(1:2),"nearest");
region_borders2 = double(imerode(region_borders2, ones(2,2))');
region_borders2(region_borders2 == 0) = nan;
%%
figure(1);
clf;
hold on
imshow(t', [0,5] )
colormap(viridis)
hold on
% hi = imshow(region_borders2*4, [0,5]);
% set(hi,'AlphaData',0.21);
colorbar('eastoutside')
colormap(viridis)
set(gca,'YDir','normal')

px_size = 0.34 * 5;
bar_size = 1000;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [100,100],'w')
text(20+bar_px./2, 250,'1mm',HorizontalAlignment='center', Color='w')
export_fig('Example_VH2_HC.eps')
%%
index2 = 41;

example = current2(index2,:);
d = get_folder_anm(example.ANM);
name = [d filesep example.File{1}];
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
try % different export software from slide scanner makes different names
    pulse_name = [name(1:end-4) '_CY5.tiff'];
    chase_name = [name(1:end-4) '_CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
catch
    pulse_name = [name(1:end-4) '-CY5.tiff'];
    chase_name = [name(1:end-4) '-CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
end
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
img = ind2rgb(int16(t), viridis);
%
overlay = imread([name(1:end-4) '_nl.png']);
[gx,gy] = gradient(single(overlay));
overlay((gx.^2+gy.^2)==0) = 0;
outline = rgb2gray(overlay)>0;
sz = size(t);
region_borders2 = imresize(outline,sz(1:2),"nearest");
region_borders2 = double(imerode(region_borders2, ones(2,2))');
region_borders2(region_borders2 == 0) = nan;
%
figure(2);
clf;
hold on
imshow(t', [0,5] )
colormap(viridis)
hold on
hi = imshow(region_borders2*5, [0,5]);
set(hi,'AlphaData',0.21);
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
px_size = 0.34 * 5;
bar_size = 1000;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [100,100],'w')
text(20+bar_px./2, 250,'1mm',HorizontalAlignment='center', Color='w')
export_fig('Example_BM8_HC.eps')
%%
figure(3);
clf;
hold on
imshow(t(1167:3100,2572:4100)', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 * 5;
bar_size = 500;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'w')
text(20+bar_px./2, 1450,'0.5 mm',HorizontalAlignment='center', Color='w')
export_fig('Example_BM8_HC_2.eps')
%% CA1_layers
name = 'GluA2_round3\fullres\Slide 14 from cassette 1-Region 001-CA1-1.tif';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
rawPulse = imread(name, 2);
rawChase = imread(name, 1);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%%
figure(3);
clf;
hold on
set(gcf,'Color','w')
imshow(t, [0,7] )
colorbar()
colormap(viridis)
% set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'k')
text(20+bar_px./2, 1450,'100 \mum',HorizontalAlignment='center', Color='k')
% export_fig('Example_HC_zoomin.eps')

%% BM6 example HC
name = 'GluA2_round1_try1\Slide 2 of 1-Region 001.png';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
pulse_name = [name(1:end-4) '_CY5.tiff'];
chase_name = [name(1:end-4) '_CY3.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%%
figure(5);
clf;
hold on
set(gcf,'Color','w')
imshow(t(180:3160, 1880:4127)', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'k')
text(20+bar_px./2, 1450,'100 \mum',HorizontalAlignment='center', Color='k')
export_fig('Example_HC_BM6.eps')
%% VH2 example HC
name = 'GluA2_round4\Slide 2 from cassette 1-Region 001.png';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
pulse_name = [name(1:end-4) '-CY5.tiff'];
chase_name = [name(1:end-4) '-CY3.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%%
figure(5);
clf;
hold on
set(gcf,'Color','w')
imshow(t(280:3160, 1980:4127)', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'k')
text(20+bar_px./2, 1450,'100 \mum',HorizontalAlignment='center', Color='k')
export_fig('Example_HC_VH2.eps')
%% BM8 example 
name = 'GluA2_round1_try1\Slide 8 of 1-Region 001.png';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
pulse_name = [name(1:end-4) '_CY5.tiff'];
chase_name = [name(1:end-4) '_CY3.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%%
figure(5);
clf;
hold on
set(gcf,'Color','w')
imshow(t(280:3160, 1980:4127)', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'k')
text(20+bar_px./2, 1450,'100 \mum',HorizontalAlignment='center', Color='k')
export_fig('Example_HC_BM8.eps')
%% VH3 example HC
name = 'GluA2_round4\Slide 5 from cassette 1-Region 001.png';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
pulse_name = [name(1:end-4) '-CY5.tiff'];
chase_name = [name(1:end-4) '-CY3.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%%
figure(5);
clf;
hold on
set(gcf,'Color','w')
imshow(t(280:3160, 1980:4127)', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'k')
text(20+bar_px./2, 1450,'100 \mum',HorizontalAlignment='center', Color='k')
export_fig('Example_HC_V3.eps')
%% VH1 example HC
name = 'GluA2_round3\Slide 14 from cassette 1-Region 001.png';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
pulse_name = [name(1:end-4) '_CY5.tiff'];
chase_name = [name(1:end-4) '_CY3.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%
figure(5);
clf;
hold on
set(gcf,'Color','w')
imshow(t(280:3160, 1980:4127)', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'k')
text(20+bar_px./2, 1450,'100 \mum',HorizontalAlignment='center', Color='k')
export_fig('Example_HC_VH1.eps')
%% VH4 example HC
name = 'GluA2_round3\Slide 17 from cassette 1-Region 001.png';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
pulse_name = [name(1:end-4) '_CY5.tiff'];
chase_name = [name(1:end-4) '_CY3.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%
figure(5);
clf;
hold on
set(gcf,'Color','w')
imshow(t(280:3160, 1980:4127)', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'k')
text(20+bar_px./2, 1450,'100 \mum',HorizontalAlignment='center', Color='k')
export_fig('Example_HC_VH4.eps')

%% EE2 example Frontal
name = 'GluA2_round2\Slide 1 of 1-Region 003.png';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
pulse_name = [name(1:end-4) '_CY5.tiff'];
chase_name = [name(1:end-4) '_CY3.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%
figure(5);
clf;
hold on
set(gcf,'Color','w')
imshow(t', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [1400,1400],'k')
text(20+bar_px./2, 1450,'100 \mum',HorizontalAlignment='center', Color='k')
export_fig('Example_F_C1.eps')
%%
name = 'GluA2_round5\Slide 4 from cassette 1-Region 003.png';
[Calibration, Blank] = getCalibration('20x_SlideScanner_0p5NA');
pulse_name = [name(1:end-4) '-CY5.tiff'];
chase_name = [name(1:end-4) '-CY3.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
p = (double(rawPulse) - Blank(673)) ./ Calibration(673);
c = (double(rawChase) -  Blank(552)) ./  Calibration(552);
s = p+c;
mask = s < 0.05;
f = p./s;
t = abs(3./log(1./f));
t = imgaussfilt(t,2);
t(mask) = nan;
t = medfilt2(t,[3,3]);
%
figure(5);
clf;
hold on
set(gcf,'Color','w')
imshow(t', [0,7] )
colorbar()
colormap(viridis)
set(gca,'YDir','normal')
hold on
px_size = 0.34 ;
bar_size = 100;
bar_px = bar_size / px_size;
plot([20,20+bar_px], [400, 400],'k')
text(20+bar_px./2, 450,'100 \mum',HorizontalAlignment='center', Color='k')
export_fig('Example_F_EE2.eps')