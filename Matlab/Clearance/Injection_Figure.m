%% for injection load raw data
cd('E:\Dropbox (HHMI)\Projects\Unbised\Injection');
files = dir('*.tif');
files = {files.name}';
first = imread(files{1}, 1);
figure(1);
h=imshow(first);
e = imellipse(gca, [   47.0000   41.0000  785.0000  775.0000]);
BW = createMask(e,h);
n_pix = sum(BW(:));
norm_f = sqrt(n_pix);
close;
imageSize = size(first);
n_files = length(files);
mean_all = cell(n_files,1);
ste_all = cell(n_files,1);
ft = fittype( 'poly1' );
slopes = zeros(n_files,1);

for i = 1:n_files
   fname = files{i};
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
   [fitresult, gof] = fit(x', median_middle, ft );
   slopes(i) = fitresult.p1;
end
%%

%%
f = figure(6);
clf
f.Units = 'centimeters';
f.Position = [10, 10, 6, 5];
f.Color = 'w';
h1=errorbar(mean_all{1}, ste_all{1});
hold on;
h2=errorbar(mean_all{2}, ste_all{2});
text(170,105,sprintf('%.1fAU/min', slopes(1)*60),'color',h1(1).Color, 'fontsize',8)
text(170,125,sprintf('%.1fAU/min', slopes(2)*60),'color',h2(1).Color, 'fontsize',8)
xlabel('Time (s)', 'fontsize',8);
ylabel('F (AU)', 'fontsize',8);
ylim([100, 135])
ax = gca;
ax.FontSize=8;

resizeLegend('LegendEntries',{'20ul/min','40ul/min'},...
    'LegendProperties',struct('location','northwest','fontsize',8));
box off
export_fig 'Injection1.eps' -depsc
f = figure(7);
clf
f.Units = 'centimeters';
f.Position = [10, 20, 6, 5];
f.Color = 'w';
h1=errorbar(mean_all{3}, ste_all{3});
hold on;
h2=errorbar(mean_all{4}, ste_all{4});
h3 = errorbar(mean_all{5}, ste_all{5});
ax = gca;
ax.FontSize=8;
box off
text(60,103,sprintf('%.1fAU/min', slopes(3)*60),'color',h1(1).Color, 'fontsize',8)
text(60,118,sprintf('%.1fAU/min', slopes(4)*60),'color',h2(1).Color, 'fontsize',8)
text(60,131,sprintf('%.1fAU/min', slopes(5)*60),'color',h3(1).Color, 'fontsize',8)
xlabel('Time (s)', 'fontsize',8);
ylabel('F (AU)', 'fontsize',8);
ylim([100, 135])
% legend({'20ul/min','40ul/min', '80ul/min'}, 'box','off', 'location',...
%     'northwest', 'fontsize',8);
[HLeg,HLegBack,HAxBack] = resizeLegend('LegendEntries',{'20ul/min','40ul/min', '80ul/min'},...
    'LegendProperties',struct('location','northwest','fontsize',8));
export_fig 'Injection2.eps' -depsc