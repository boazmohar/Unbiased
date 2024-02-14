%% Figure 4b - Example FOV from ANM 
close all;
clc;
clear;
cd('Z:\moharb\MECP2')
%% find files
files = dir('ANM473364_*_Slide1_Section3*.ims');
files = {files.name}';
Names = {'Iba1','NeuN','SOX10'};
%% get data
allImages = {};
X =2910; Y = 2330; Size = 180;
FOV = 0; writeFile = 0;
satRange = [0.02, 99.85];
for i =1:3
    file = files{i};
    if i ~= 2
        continue
    end
    img = get_subField_ims(file, X, Y, Size, Size, FOV, writeFile, satRange);
    maxImg = permute(nanmax(img(1:end,1:end,1:end,2:end-2), [], 4), [2,1,3]);
%     for ch = 1:5
%         tmp = squeeze(maxImg(:,:,ch));
%         tmp = uint16(tmp*65536);
%         imwrite(tmp, sprintf('MeCP2_ExampleFOV_%s_%d.tif', Names{i}, ch))
%     end
    allImages{i} = maxImg;
end
%%
% for i =1:3
%     current = allImages{i};
%     fig = figure(i);
%     fig.Units = 'Centimeters';
%     fig.Position = [5, 5, 12, 3];
%     fig.Color = 'w';
%     clf;
%     ha = tight_subplot(1,5, 0.005, 0,0);
%     chOrder = [4,5,2,3,1];
%     LUTOrder = {'magenta','yellow','red','green','blue'};
%     for ii = 1:5
%         axes(ha(ii))
%         ch = chOrder(ii);
%         LUT = LUTOrder{ii};
%         tmp = changeLUT(squeeze(current(:,:,ch)), LUT);
%         imshow(tmp)
%     end
%     outName = sprintf('MeCP2_FOV_%s_2.png',Names{i}) ;
%     export_fig(outName, '-png', '-r300');
% end
%%
tbl = compute_tbl(0);
%% getting the fraction pulse
cellType = 1;
ANM = '473364';
IHC = 'NeuN';
intervalType = 2;
Section = 3;
Slide =1;
% AP = -2;
Large = 1;
data = getOneEntry(tbl, ANM, IHC, cellType, intervalType, Slide, Section);
% f = showFractionXY(data);
% axis('on')
% xlim([X, X+Size])
% ylim([Y, Y+Size])

%% gettitng the mask
file = files{2};
file = file(1:end-3);
new_file = dir([file(1:end-4)  '*Obj*.h5']).name;
h5disp(new_file)
d = squeeze(h5read(new_file,'/exported_data',[Y X 1, 1] ,[Size, Size, 1, 31]));
d2 = bwlabeln(d);
d_flat = d2(:);
x = data.x{1} - X;
y = data.y{1} - Y;
z = data.z{1} ;
include = find(x>0 & x <= Size & y > 0 & y <= Size);
x= x(include);
y = y(include);
z = z(include);
ind = sub2ind([Size,Size, 31], y, x, z);
vals = d_flat(ind);
%% check positions

d3 = max(d2,[], 3, 'omitnan');
figure(333);
clf;
imshow(d3', [])
colormap('jet');
hold on;

ax = scatter(y, x , 50, 1:length(x), "filled");
colorbar(gca)
d4 = d3(:);
labelpoints(y, x,vals );
%%
fraction = data.fraction{1}(include);
t = data.interval ./ log(1./fraction) ./ 24;
d_tau = d2;
for i = 1: length(t)
    val = vals(i);
    d_tau(d_tau == val) = t(i);
end
non_vals = setdiff(1:max(d4), vals);
for i = 1: length(non_vals)
    val = non_vals(i);
    d_tau(d_tau == val) = 0;
end
%%

d_tau2 = max(d_tau, [], 3, 'omitnan');

i=2;
current = allImages{i};
fig = figure(444);
fig.Units = 'Centimeters';
fig.Position = [5, 5, 32, 7];
fig.Color = 'w';
clf;
ha = tight_subplot(1,6, 0.005, 0,0);
chOrder = [4,5,2,3,1];
LUTOrder = {'magenta','yellow','red','green','gray'};
for ii = 1:5
    axes(ha(ii))
    ch = chOrder(ii);
    LUT = LUTOrder{ii};
    tmp = changeLUT(squeeze(current(:,:,ch)), LUT);
    imshow(tmp)
end
axes(ha(6));
imshow(d_tau2',[5,13]);
colormap('viridis')
% cb = colorbar();
% cb.Label.String = '\tau (days)';
% cb.Label.FontSize = 16;
outName = sprintf('MeCP2_FOV_%s_NewNM.eps',Names{i}) ;
 export_fig(outName, '-eps');
 %%
f = figure();
f.Color = 'w';
imshow(d_tau2',[5,13]);
colormap('viridis')
cb = colorbar();
cb.Label.String = '\tau (days)';
cb.Label.FontSize = 16;
outName = sprintf('MeCP2_FOV_%s_cb_NewNM.eps',Names{i}) ;
export_fig(outName, '-eps');