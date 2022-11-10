function c = overlayColorbar(label, position)
% c = overlayColorbar(label)
%   Detailed explanation goes here
if nargin < 2
    position = 'southoutside'
end
c=colorbar(position);
c.Label.String = label;
c.FontSize = 12;
p = c.Position;
c.Position = [p(1), p(2)-0.05, p(3), p(4)];
end

