function f = GluA2_barPlots_diff(fignum, names,y, e, fig_size)

x = 1:numel(names); % Example y-axis data (12 categories)
% values = [1 2 3 4; 4 5 6 7; 7 8 9 10; 10 11 12 13; 13 14 15 16; 16 17 18 19; 19 20 21 22; 22 23 24 25; 25 26 27 28; 28 29 30 31; 31 32 33 34; 34 35 36 37]; % Bar heights
% errors = [0.2 0.3 0.4 0.5; 0.3 0.4 0.5 0.6; 0.4 0.5 0.6 0.7; 0.5 0.6 0.7 0.8; 0.6 0.7 0.8 0.9; 0.7 0.8 0.9 1.0; 0.8 0.9 1.0 1.1; 0.9 1.0 1.1 1.2; 1.0 1.1 1.2 1.3; 1.1 1.2 1.3 1.4; 1.2 1.3 1.4 1.5; 1.3 1.4 1.5 1.6]; % Error values

% Create horizontal bar plot
f=figure(fignum);
clf
b = bar(x, y, 'grouped', 'FaceColor', 'flat');
hold on;

% Define colors and transparency
colors = [1 0 1; 0 0.39 0.49]; % Magenta and teal
alpha = 0.6; % 60% transparency

% Apply colors and transparency
for k = 1:length(b)
    b(k).FaceColor = colors(mod(k-1, 2) + 1, :);
    b(k).FaceAlpha = alpha;
end

% Add error bars
ngroups = size(y, 1);
nbars = size(y, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    xPos = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(xPos, y(:,i), e(:,i), 'k', 'linestyle', 'none', 'LineWidth', .65, 'CapSize', 2.5);
end

% Customize axes
ax = gca;
ax.XTick = 1:ngroups;
ax.XTickLabels = names;
ax.XTickLabelRotation = 90;
ylabel('% change GluA2 lifetime', 'FontWeight', 'bold');
xlabel('Brain region', 'FontWeight', 'bold');
ax.FontSize = 6;
ax.Box = 'off';
ax.YGrid = 'on';
ax.XColor = [0 0 0];
ax.YColor = [0 0 0];

set(gca,'LineWidth',.65)
% Add title
set(gca, 'FontSize', 6)
% Adjust figure properties
set(gca, 'TickLength', [0 0]);

% Adjust figure size
set(gcf, 'Units', 'inches', 'Position', ...
    [1, 1, fig_size(1) , fig_size(2)]);

hold off;


end