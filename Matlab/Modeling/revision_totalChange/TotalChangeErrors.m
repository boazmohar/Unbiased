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
imagesc(flipud(N_error_range), fraction_pulse_range, delta_tau_percent_matrix);

set(gca, 'YDir', 'normal'); % Reverse the y-axis
caxis([-60, 60]); % Set color bar limits
custom_cmap = [linspace(0, 1, 128)', linspace(0, 1, 128)', ones(128, 1); ...
               ones(128, 1), linspace(1, 0, 128)', linspace(1, 0, 128)'];
colormap(custom_cmap); % Divergent color map
cb = colorbar;
cb.Label.String = '% error of \tau';

xlabel('% change in total protein');
ylabel('Fraction Pulse');
%%
% Main heatmap
h_main = subplot(3, 3, [2 3 5 6 8 9]);
imagesc(N_error_range, flip(fraction_pulse_range), delta_tau_percent_matrix);
set(gca, 'YDir', 'normal'); % Set the y-axis direction to normal
colormap(custom_cmap); % Apply custom colormap
caxis([-60, 60]); % Set color bar limits
xlabel('% N\_error');
ylabel('Fraction Pulse');
title('Heatmap of \Delta\tau (%) as a function of N\_error and Fraction Pulse');
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 12);
axis tight; % Make axis limits tight around the data

% X-axis histogram
h_xhist = subplot(3, 3, [1 4]);
histogram(N_error_range, 'FaceColor', 'b');
axis off
% set(gca, 'XAxisLocation', 'top', 'Box', 'off', 'FontSize', 12);
% ylabel('Count');
set(gca, 'Position', [0.1 0.7 0.6 0.2]);

% Y-axis histogram
h_yhist = subplot(3, 3, [7]);
histogram(flip(fraction_pulse_range), 'FaceColor', 'b');
axis on
% set(gca, 'YAxisLocation', 'right', 'Box', 'off', 'FontSize', 12);
% xlabel('Count');
view([90 -90]); % Rotate the histogram to align with the y-axis
set(gca, 'Position', [0.75 0.1 0.1 0.6]);

% Adjust positions to align plots
set(h_main, 'Position', [0.1 0.1 0.6 0.6]);