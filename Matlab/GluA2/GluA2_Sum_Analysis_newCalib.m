%% load data
tbl_all = load_data_glua2('D:\', 1:6,true, true);
%% filter
r = strcmp(tbl_all.groupName, 'rule2');
tbl_all3 = tbl_all(~r,:);
r = strcmp(tbl_all3.groupName, 'negative');
tbl_all3 = tbl_all3(~r,:);
%% make a sum stats table by region name
tbl_all3.Sum = tbl_all3.C_Mean + tbl_all3.P_Mean;
tbl_all3.ANM = categorical(tbl_all3.ANM);
tbl_all3.groupName = categorical(tbl_all3.groupName);
tbl4 = grpstats(tbl_all3, ["groupName", 'Name', 'ANM'], "median", "DataVars","Sum");
selectedCategories = {'control', 'EE'};
% Filter rows based on selected categories
tbl_EE = tbl4(ismember(tbl4.groupName, selectedCategories), :);
tbl_EE.groupName = categorical(tbl_EE.groupName);
tbl_EE.ANM = categorical(tbl_EE.ANM);
x = tbl_EE.median_Sum;
g = string(tbl_EE.groupName);
a = string(tbl_EE.ANM);
tbl_EE = table;
tbl_EE.x = x;
tbl_EE.g = g;
tbl_EE.a = a;
% [p,tbl,stats] = anova1(x,g)

formula = 'x ~ g + (1|a) ';
% Fit the linear mixed-effects model
lme_ee = fitlme(tbl_EE, formula);
anova(lme_ee)
f = figure(1);
clf;
f.Color='w';
subplot(1,2,1)
boxplot(x, g)
ylim([0,4000])
ylabel('Pulse + Chase (AU)')
box off
%
selectedCategories = {'random', 'rule'};
% Filter rows based on selected categories
tbl_EE = tbl4(ismember(tbl4.groupName, selectedCategories), :);
tbl_EE.groupName = categorical(tbl_EE.groupName);
tbl_EE.ANM = categorical(tbl_EE.ANM);
x = tbl_EE.median_Sum;
g = string(tbl_EE.groupName);
a = string(tbl_EE.ANM);
tbl_EE = table;
tbl_EE.x = x;
tbl_EE.g = g;
tbl_EE.a = a;
% [p,tbl,stats] = anova1(x,g)

formula = 'x ~ g + (1|a) ';
% Fit the linear mixed-effects model
lme_learning = fitlme(tbl_EE, formula);
anova(lme_learning)
subplot(1,2,2)
boxplot(x, g)
ylim([0,4000])
yticklabels([''])
box off
%%
tbl6 = grpstats(tbl_all3, ["groupName", 'Name', 'ANM'], "median", "DataVars",["Sum", "tau"]);
f2 = figure(2);
clf
f2.Color='w';
hold on
x =  tbl6.median_tau;
y = tbl6.median_Sum;
group = tbl6.groupName;

% Define colors for each group
uniqueGroups = categories(group);
colors = lines(numel(uniqueGroups));

% Set the alpha value
alphaValue = 0.3; % Adjust this value as needed (0 to 1)
legendEntries = cell(numel(uniqueGroups), 1);
% Plot each group with transparency
for g = 1:numel(uniqueGroups)
    idx = group == uniqueGroups{g};
    scatter(x(idx), y(idx), 8, 'MarkerFaceColor', colors(g, :), ...
        'MarkerEdgeColor', colors(g, :), 'MarkerFaceAlpha',...
        alphaValue, 'MarkerEdgeAlpha', alphaValue);
    lm = fitlm(x(idx), y(idx), 'RobustOpts', 'on');
     pValue = lm.Coefficients.pValue(2);
    % Get the R^2 value
    R2 = lm.Rsquared.Adjusted;
     
    % Store legend entry with group name, R^2 value, and p-value
    legendEntries{g} = sprintf('%s (R^2 = %.2f, p = %.2g)', uniqueGroups{g}, R2, pValue);
    % Annotate the plot with the R^2 value
  
end
box off;
ylabel('Pulse + Chase (AU)');
xlabel('GluA2 lifetime (days)')
xlim([0 15])
ylim([0 4000])
lgd = legend(legendEntries, 'Location', 'south', NumColumns=2);
lgd.Box = 'off';
%%
% Group data and compute the median
% Group data and compute the median and standard deviation
T_median = grpstats(tbl_all3, {'new_names', 'groupName'}, {'median'}, 'DataVars', 'Sum');
T_std = grpstats(tbl_all3, {'new_names', 'groupName'}, {'std'}, 'DataVars', 'Sum');

% Remove 'GroupCount' column
T_median = removevars(T_median, 'GroupCount');
T_std = removevars(T_std, 'GroupCount');

% Pivot the tables to get the appropriate format for bar plotting
T_median_pivot = unstack(T_median, 'median_Sum', 'groupName');
T_std_pivot = unstack(T_std, 'std_Sum', 'groupName');

% Extract the data for plotting
mainIndex = T_median_pivot.new_names;
subIndex = T_median_pivot.Properties.VariableNames(2:end); % Exclude the first column which is new_names
data = T_median_pivot{:, 2:end};
std_data = T_std_pivot{:, 2:end};

% Normalize the data by the control group
controlGroupIdx = strcmp(subIndex, 'control');
controlValues = data(:, controlGroupIdx);
normalizedData = data ./ controlValues * 100;
normalizedStdData = std_data ./ controlValues * 100;

% Create the bar plot with error bars
f3 = figure(3);
clf
b = bar(normalizedData);
hold on;

% Add error bars
[ngroups, nbars] = size(normalizedData);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, normalizedData(:,i), normalizedStdData(:,i), 'k', 'linestyle', 'none');
end

% Set x-axis labels
set(gca, 'XTickLabel', mainIndex);
xlabel('Brain regions');
ylabel('Normalized Pulse + Chase (%)');
lgn = legend(subIndex, 'Location', 'North', NumColumns=4);
lgn.Box='off';
hold off;
box off
f3.Color='w';
%%
[p, tbl, stats] = anovan(tbl_all3.Sum, {tbl_all3.new_names, tbl_all3.groupName}, ...
    'model', 'interaction', 'varnames', {'NewNames', 'GroupName'});
results = multcompare(stats, 'Dimension', [2]);

%% histogram 
tbl6 = grpstats(tbl_all3, ["groupName", 'Name'], "median", "DataVars",["Sum", "fraction", "tau"]);
% Separate the data into EE and control groups
EE_data = tbl6(ismember(tbl6.groupName, 'EE'), :);
control_data = tbl6(ismember(tbl6.groupName, 'control'), :);

% Initialize a table to store the results
results = table();

% Get unique 'Name' values
uniqueNames = unique(EE_data.Name);

% Loop through each unique 'Name'
for i = 1:length(uniqueNames)
    name = uniqueNames{i};
    
    % Extract rows corresponding to the current name for EE and control
    EE_row = EE_data(strcmp(EE_data.Name, name), :);
    control_row = control_data(strcmp(control_data.Name, name), :);
    
    if ~isempty(EE_row) && ~isempty(control_row)
        % Calculate the differences
        change = (1-control_row.median_Sum ./ EE_row.median_Sum) *100;
        fp = mean([EE_row.median_fraction, control_row.median_fraction]);
        fp_change = (1-control_row.median_fraction ./ EE_row.median_fraction) *100;
        
        % Append the results to the results table
        results = [results; table({name}, change, fp,fp_change, ...
            'VariableNames', {'Name', 'change', 'fp', 'fp_change'})];
    end
end

% Display the results
figure(1)
clf
subplot(1,2,1)
histogram(results.change, -20:20)
subplot(1,2,2)
histogram(results.fp, 0.2:0.025:0.8)
%%
% Separate the data into EE and control groups
EE_data = tbl6(ismember(tbl6.groupName, 'random'), :);
control_data = tbl6(ismember(tbl6.groupName, 'rule'), :);

% Initialize a table to store the results
results = table();

% Get unique 'Name' values
uniqueNames = unique(EE_data.Name);

% Loop through each unique 'Name'
for i = 1:length(uniqueNames)
    name = uniqueNames{i};
    
    % Extract rows corresponding to the current name for EE and control
    EE_row = EE_data(strcmp(EE_data.Name, name), :);
    control_row = control_data(strcmp(control_data.Name, name), :);
    
    if ~isempty(EE_row) && ~isempty(control_row)
        % Calculate the differences
        change = (1-control_row.median_Sum ./ EE_row.median_Sum) *100;
        fp = mean([EE_row.median_fraction, control_row.median_fraction]);
        fp_change = (1-control_row.median_fraction ./ EE_row.median_fraction) *100;
        
        % Append the results to the results table
        results = [results; table({name}, change, fp,fp_change, ...
            'VariableNames', {'Name', 'change', 'fp', 'fp_change'})];
    end
end

% Display the results
figure(1)
clf
subplot(1,2,1)
histogram(results.change, -20:20)
subplot(1,2,2)
histogram(results.fp, 0.2:0.025:0.8)

%%
% Define parameters
t = 3;  % days
initial_total = 100;  % Initial total population

% Define ranges for N_error and Fraction Pulse
N_error_range = linspace(-10, 10, 200);
fraction_pulse_range = linspace(0.8, 0.2, 200);

% Initialize matrix for Δτ values
delta_tau_matrix = zeros(length(fraction_pulse_range), length(N_error_range));

% Calculate Δτ for each combination of N_error and Fraction Pulse
for i = 1:length(N_error_range)
    N_error = N_error_range(i);
    for j = 1:length(fraction_pulse_range)
        fraction_pulse = fraction_pulse_range(j);
        
        % Calculate the total number of proteins including the Error fraction
        N_total = initial_total + N_error;
        
        % Calculate the Pulse population using the Fraction Pulse
        N_pulse = fraction_pulse * N_total;
        
        % Calculate FP_0 based on N_pulse and initial_total
        FP_0 = N_pulse / initial_total;
        
        % Calculate τ_0
        tau_0 = -t / log(FP_0);
        
        % Calculate τ_E
        tau_E = -t / log(fraction_pulse);
        
        % Calculate Δτ
        delta_tau = tau_E - tau_0;
        
        % Store Δτ in the matrix
        delta_tau_matrix(j, i) = delta_tau;
    end
end

% Convert Δτ to percentage error
tau_0 = -t ./ log(fraction_pulse_range);  % Calculate tau_0 for the given range
tau_0_matrix = repmat(tau_0', 1, length(N_error_range));
delta_tau_percent_matrix = (delta_tau_matrix ./ tau_0_matrix) * 100;

%% Create heatmap with percentage error
f = figure(1);
clf
f.Color = 'w';
imagesc(N_error_range, fraction_pulse_range, delta_tau_percent_matrix);

set(gca, 'YDir', 'normal'); % Reverse the y-axis
caxis([-40, 40]); % Set color bar limits
custom_cmap = [linspace(0, 1, 128)', linspace(0, 1, 128)', ones(128, 1); ...
               ones(128, 1), linspace(1, 0, 128)', linspace(1, 0, 128)'];
colormap(custom_cmap); % Divergent color map
cb = colorbar;
cb.Label.String = '% error of \tau';

xlabel('% change in total protein');
ylabel('Fraction Pulse');
%%
% Main heatmap
f = figure(2)
clf
f.Color='w'
h_main = subplot(3, 3, [2 3 5 6 8 9]);
imagesc(N_error_range, flip(fraction_pulse_range), delta_tau_percent_matrix);
set(gca, 'YDir', 'normal'); % Set the y-axis direction to normal
colormap(custom_cmap); % Apply custom colormap
caxis([-40, 40]); % Set color bar limits
xlabel('% Change in total protein');
ylabel('Fraction Pulse');

set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 10);
axis tight; % Make axis limits tight around the data

% X-axis histogram
h_xhist = subplot(3, 3, [1 4]);
% histogram(results.change,-20:20, 'FaceColor', 'k');
x = -20:0.1:20;
y = ksdensity(results.change, x);
plot(x, y./max(y), 'k');
% ylim([0 0.2])
box off
set(gca, 'XColor', 'none');
% Optionally, set the x-ticks to an empty array to remove the ticks
set(gca, 'XTick', []);
yticks([0,1])
% set(gca, 'XAxisLocation', 'top', 'Box', 'off', 'FontSize', 12);
% ylabel('Count');
set(gca, 'Position', [0.1 0.71 0.6 0.2]);
l = legend('Data')
l.Box = "off";
ylabel('Density')
% Y-axis histogram
h_yhist = subplot(3, 3, [7]);
x = 0.2:0.02:0.8;
y = ksdensity(results.fp, x);
plot(x, y./max(y), 'k');
xlim([0.2,0.8])
% histogram(results.fp, 0.2:0.02:0.8, 'FaceColor', 'k');
box off
set(gca, 'XColor', 'none');
% Optionally, set the x-ticks to an empty array to remove the ticks
set(gca, 'XTick', []);
yticks([0,1])
set(gca, 'YAxisLocation', 'right');
% set(gca, 'YAxisLocation', 'right', 'Box', 'off', 'FontSize', 12);
% xlabel('Count');
view([90 -90]); % Rotate the histogram to align with the y-axis
set(gca, 'Position', [0.71,0.1,0.2,0.6]);

% Adjust positions to align plots
set(h_main, 'Position', [0.1 0.1 0.6 0.6]);
print('SumChanges.eps')
%%
c = median(results.change);
fp = median(results.fp);
prctile(results.change, [25,50, 75]);
prctile(results.fp, [25, 50, 75])
interp2(N_error_range, fraction_pulse_range, delta_tau_percent_matrix, c, fp)
%%
set(0, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontName', 'Arial');
set(0, 'DefaultUIControlFontName', 'Arial');

set(0, 'DefaultAxesFontSize', 10);
set(0, 'DefaultTextFontSize', 10);
set(0, 'DefaultUIControlFontSize', 10);
