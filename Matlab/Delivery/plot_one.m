function ax = plot_one(plotTotal, plotNum, x,y,z,data, label, clipping)
% ax = plot_one(plotTotal, plotNum, data, label, clipping)
if nargin < 8
    clipping = [5, 95];
end
ax=subplot(1,plotTotal,plotNum);
vals = prctile(data, clipping);
JF_vals2 = data;
JF_vals2(JF_vals2 < vals(1)) = vals(1);
JF_vals2(JF_vals2 > vals(2)) = vals(2);
% z = (z+rand(length(z),1)*0.8)*2000;
pcshow([x, y, z], JF_vals2,'MarkerSize', 35);
caxis([0, 1]);
colormap(jet(128))
c = colorbar('location','south');
c.Color='w';
c.Label.String = label;
c.Label.FontSize=26;
axis off
axis manual
end