function adjOverlayAxes(ax1,ax2)
%adjOverlayAxes(ax1,ax2)
%   Detailed explanation goes here
ax2.Visible = 'off';
ax1.Visible = 'off';
P = get(ax1,'Position');
XLIM = get(ax1,'XLim');
YLIM = get(ax1,'YLim');
PA = get(ax1,'PlotBoxAspectRatio');
set(ax2,'Position',P,'XLim',XLIM,'YLim',YLIM,'PlotBoxAspectRatio',PA)
end

