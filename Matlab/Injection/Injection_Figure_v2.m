% for injection load raw data
%% init
cd('E:\Dropbox (HHMI)\Projects\Unbised\Injection');
files = dir('*_Clear*.tif');
files = {files.name}';
%% get mask and size
first = imread(files{1}, 1);
figure(1);
clf
h=imshow(first, []);
e = imellipse(gca, [   47.0000   41.0000  785.0000  775.0000]);
BW = createMask(e,h);
close;
n_pix = sum(BW(:));
norm_f = sqrt(n_pix);
imageSize = size(first);
n_files = length(files);
%% read data
mean_all = cell(n_files,1);
ste_all = cell(n_files,1);
ft = fittype( 'poly1' );
slopes = zeros(n_files,1);
mat_files =  cell(n_files,1);
for i = 1:n_files
   fname = files{i};
   mat_files(i) = {load([fname(1:end-4) '.mat'], 'data')};
   info = imfinfo(fname);
   num_images = numel(info);
   x = 1:num_images;
   movie = zeros(imageSize(1), imageSize(2), num_images);
   median_middle = zeros(num_images ,1 ) ;
   std_middle =  zeros(num_images ,1 ) ;
   for k = 1:num_images
       current =  imread(fname, k, 'Info', info);
       movie(:,:,k) = current;
       temp =  single(current).*BW;
       temp(temp==0) = nan;
       median_middle(k) =nanmean(temp(:));
       std_middle(k) =nanstd(temp(:));
   end
   ste = std_middle ./ norm_f;
   f=figure(i);
   clf
   f.Units = 'centimeters';
    f.Position = [i, i, 6, 5];
    f.Color = 'w';
   errorbar(median_middle, ste);
   mean_all(i) = {median_middle};
   ste_all(i) = {ste};
%    [fitresult, gof] = fit(x', median_middle, ft );
%    slopes(i) = fitresult.p1;
end
%% redo x axis
k=1;
times = sort(mat_files{k,1}.data.times);
time_sec =seconds( times-times(1));
len_all = length(mean_all{k});
time_sec = time_sec+len_all-length(time_sec);
clearance = length(time_sec);
x1 = [0:len_all-clearance time_sec(2:end)];
f = figure(10);
f.Units = 'centimeters';
f.Position = [10, 10, 14, 6];
f.Color = 'w';
f.Units = 'normalized';
clf;
axes1 = axes('Parent',f,...
    'Position',[0.13 0.21 0.45 0.7]);
hold(axes1,'on');

% Create plot
plot(x1(1:end-clearance),mean_all{k}(1:end-clearance),'Parent',axes1,'Marker','.','LineStyle','none');

% Create ylabel
ylabel('F (AU)');

% Create xlabel
xlabel('Time (s)');

% Uncomment the following line to preserve the X-limits of the axes
xlim(axes1,[0 520]);
% Create axes
axes2 = axes('Parent',f,...
    'Position',[0.6 0.21 0.31 0.7]);
hold(axes2,'on');

% Create semilogx
semilogx(x1(end-clearance+1:end), mean_all{k}(end-clearance+1:end),'Parent',axes2,...
    'MarkerFaceColor',[0 0.443137258291245 0.737254917621613],...
    'Marker','.',...
    'LineStyle','none');

% Create xlabel
xlabel('Time (s)');

% Set the remaining axes properties
set(axes2,'XMinorTick','on','XScale','log','YTickLabel',...
    {'','','','','','','','',''});
linkaxes([axes1, axes2], 'y');
annotation(f,'textarrow',[0.729583333333333 0.650208333333333],...
    [0.797368055555556 0.860104166666667],'String',{'Fit decay'},'fontsize',8);
annotation(f,'textarrow',[0.173958333333333 0.136160714285715],...
    [0.414722222222222 0.269201388888888],'String',{'20ul/min'},'fontsize',8);
annotation(f,'textarrow',[0.372395833333334 0.374285714285714],...
    [0.595520833333333 0.436770833333333],'String',{'40ul/min'},'fontsize',8);
annotation(f,'textarrow',[0.482008928571429 0.557604166666667],...
    [0.850284722222223 0.846875],'String',{'Stop'},'fontsize',8);
axes1.FontSize=8;
axes2.FontSize=8;
% export_fig 'Injection_v2_1.eps' -depsc
%%
k=2;
times = sort(mat_files{k,1}.data.times);
times = times(2:end);
time_sec =seconds( times-times(1));
len_all = length(mean_all{k});
time_sec = time_sec+len_all-length(time_sec);
clearance = length(time_sec);
x1 = [0:len_all-clearance time_sec(2:end)];
f = figure(11);
f.Units = 'centimeters';
f.Position = [10, 10, 14, 6];
f.Color = 'w';
f.Units = 'normalized';
clf;
axes1 = axes('Parent',f,...
    'Position',[0.13 0.21 0.45 0.7]);
hold(axes1,'on');

% Create plot
plot(x1(1:end-clearance),mean_all{k}(1:end-clearance),'Parent',axes1,'Marker','.','LineStyle','none');

% Create ylabel
ylabel('F (AU)');

% Create xlabel
xlabel('Time (s)');

% Uncomment the following line to preserve the X-limits of the axes
xlim(axes1,[0 220]);
% Create axes
axes2 = axes('Parent',f,...
    'Position',[0.6 0.21 0.31 0.7]);
hold(axes2,'on');

% Create semilogx
semilogx(x1(end-clearance+1:end), mean_all{k}(end-clearance+1:end),'Parent',axes2,...
    'MarkerFaceColor',[0 0.443137258291245 0.737254917621613],...
    'Marker','.',...
    'LineStyle','none');

% Create xlabel
xlabel('Time (s)');

% Set the remaining axes properties
set(axes2,'XMinorTick','on','XScale','log','YTickLabel',...
    {'','','','','','','','',''});

linkaxes([axes1, axes2], 'y');
% Create textarrows
annotation(f,'textarrow',[0.427202380952381 0.457440476190476],...
    [0.696944444444444 0.560243055555556],'String',{'80ul/min'},'fontsize',8);
annotation(f,'textarrow',[0.514136904761905 0.565163690476191],...
    [0.863513888888889 0.851284722222223],'String',{'Stop'},'fontsize',8);
annotation(f,'textarrow',[0.803288690476191 0.746592261904762],...
    [0.868923611111111 0.8865625],'String',{'Fit decay'},'fontsize',8);
annotation(f,'textarrow',[0.175848214285714 0.136160714285714],...
    [0.520555555555556 0.344166666666667],'String',{'20ul/min'},'fontsize',8);
annotation(f,'textarrow',[0.291130952380952 0.259002976190476],...
    [0.542604166666667 0.375034722222222],'String',{'40ul/min'},'fontsize',8);
axes1.FontSize=8;
axes2.FontSize=8;
export_fig 'Injection_v2_2.eps' -depsc
%% SLOPES AND DECAY
srations = [6.3/1.9,  4.7/1.3, 12.8/4.7];
x_labels = {'Ex1 40/20', 'Ex2 40/20','Ex2 80/40'};
f = figure(6);
clf;
f.Units = 'centimeters';
f.Position = [10, 10, 6, 6];
f.Color = 'w';
b = bar(srations);
ax = gca;
ax.XTickLabel = x_labels;
ax.XTickLabelRotation = 45;
ax.FontSize=8;
hold on;
plot(ax.XLim, [2, 2], 'k--', 'linewidth',2)
ylabel('Slope ratios', 'fontsize',8)
xlim([0.2, 4.3])
box off
annotation(f,'textarrow',[0.8 0.8],...
    [0.8 0.58],'TextRotation',0,...
    'String',{'Linear','expectation'},...
    'HorizontalAlignment','center', 'fontsize',8);
export_fig 'Injection_ratios.eps' -depsc


