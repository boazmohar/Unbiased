function f = GluA2_barPlots(fignum, YTickLabels,values, errors, fig_size)

y = 1:numel(YTickLabels); % Example y-axis data (12 categories)
% values = [1 2 3 4; 4 5 6 7; 7 8 9 10; 10 11 12 13; 13 14 15 16; 16 17 18 19; 19 20 21 22; 22 23 24 25; 25 26 27 28; 28 29 30 31; 31 32 33 34; 34 35 36 37]; % Bar heights
% errors = [0.2 0.3 0.4 0.5; 0.3 0.4 0.5 0.6; 0.4 0.5 0.6 0.7; 0.5 0.6 0.7 0.8; 0.6 0.7 0.8 0.9; 0.7 0.8 0.9 1.0; 0.8 0.9 1.0 1.1; 0.9 1.0 1.1 1.2; 1.0 1.1 1.2 1.3; 1.1 1.2 1.3 1.4; 1.2 1.3 1.4 1.5; 1.3 1.4 1.5 1.6]; % Error values

% Create horizontal bar plot
f=figure(fignum);
clf
b = barh(y, values, 'grouped', 'FaceColor', 'flat');
hold on;

% Define colors and transparency
colors = [1 0 1; 1 0 1; 0 0.39 0.49; 0 0.39 0.49]; % Magenta and teal
alphas = [ 0.3 1 0.3 1]; % Opacity levels

% Apply colors and transparency
for k = 1:length(b)
    b(k).FaceColor = colors(k, :);
    b(k).FaceAlpha = alphas(k);
end

% Add error bars
ngroups = size(values, 1);
nbars = size(values, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    yPos = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(values(:,i), yPos, errors(:,i), 'horizontal', 'k',...
        'linestyle', 'none', 'LineWidth', .65, 'CapSize', 2.5);
end

% Customize axes
ax = gca;
ax.YTick = 1:ngroups;
ax.YTickLabels = YTickLabels;
ax.YDir = 'reverse'; % To match the order in your example
xlabel('GluA2 lifetime (days)', 'FontWeight', 'bold');
ylabel('Brain region', 'FontWeight', 'bold');
ax.Box = 'off';
ax.XGrid = 'on';
ax.YColor = [0 0 0];
ax.XColor = [0 0 0];

set(gca,'LineWidth',.65)
set(gca, 'XAxisLocation', 'top');
% Add title
set(gca, 'FontSize', 6)
% Adjust figure properties
set(gca, 'TickLength', [0 0]);

% Adjust figure size
set(gcf, 'Units', 'inches', 'Position', ...
    [1, 1, fig_size(1) , fig_size(2)]);

hold off;


end