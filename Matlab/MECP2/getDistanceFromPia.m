function [l,l2, dist_all] = getDistanceFromPia(data)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
%%
figure()
tif_file        = data.filename{1};
img_max         = imread([tif_file(1:end-4) '_max_ch3.tif']);
min_max         = prctile(img_max, [0.1,99], 'all');
ax1 = axes;
imshow(img_max',min_max)
%% drew where the pia is
l = drawpolyline();
%%
[cx,cy,~] = improfile(img_max',l.Position(:,1),l.Position(:,2),1000); 
P           = [cx cy];
%% drew where the CC is
l2 = drawpolyline();
%%
[cx,cy,~] = improfile(img_max',l2.Position(:,1),l2.Position(:,2),1000); 
P2           = [cx cy];

%% https://www.mathworks.com/help/matlab/ref/dsearchn.html
dist_all = cell(height(data),1);
for i = 1: height(data)
    PQ          = [data.y{i}, data.x{i}];
    [~,dist]    = dsearchn(P,PQ);
    [~,dist2]   = dsearchn(P2,PQ);
    sum_dist = dist + dist2;
    min_dist = min(dist, dist2);
    dist_norm = min_dist ./ sum_dist;
    dist_all(i) = {dist_norm};
    if i == 1
        hold on;
        ax2 = axes;
        scatter(ax2,data.y{i}, data.x{i}, 30,dist_norm, 'fill',...
            'MarkerFaceAlpha',0.8);%%Link them together
        set(gca, 'ydir', 'reverse')
        caxis([0, 1])
        adjOverlayAxes(ax1,ax2)
        overlayColorbar('Distance from pia [0 1]')
        pause
        close all;
    end
end
%%

% %%
% figure()
% X = [fraction(index),dist];
% digit
% hist3(X,'CdataMode','auto')
% set(gca,'colorscale','log')
% xlabel('Fraction')
% ylabel('Distance from Line')
% colorbar
% view(2)
% %%
% figure()
% [Y,E] = discretize(dist,20);
% m_dist = grpstats(dist, Y, 'mean');
% m_frac = grpstats(fraction(index), Y, 'mean');
% se_frac = grpstats(fraction(index), Y, 'sem');
% valid = se_frac < 0.01;
% mseb(m_dist(valid)'.*0.25,m_frac(valid)', se_frac(valid)')
% % ylim([0.69 0.715])r
% xlabel('Distance from pia (um)')
% ylabel('Fraction pulse')
end

