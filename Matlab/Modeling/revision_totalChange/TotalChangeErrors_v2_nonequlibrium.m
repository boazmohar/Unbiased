deltaT = 0.2; % increase in chase for Control group
Tc_inf = 1; % steady state for control group
Tee_inf = Tc_inf + deltaT;  %steady state for EE group
tau = 14;%tau is tau_decay
t = 0:0.01:tau*6; % time to simulate
A = exp(-t/tau); % exp decay
pulse_ee = Tc_inf * A; % pulse in uneffec
chase_ee = Tee_inf*(1-A); % left over to inf
chase_control = 1-A;
equil = Tc_inf * ones(size(A));
nonequil = deltaT * (1-A);
total_ee = equil + nonequil;
tau_age_equil = tau * ones(size(A));
tau_age_nonequil = tau - ((t .* A) / 1 - A);
fraction_equil = equil ./ total_ee;
fraction_nonequil = nonequil ./ total_ee;
tau_age = fraction_equil .* tau_age_equil + fraction_nonequil .* tau_age_nonequil;
figure(1)
clf
% plot(t,tau_age,'b');
t2 = t/tau;
plot(t2,A,'m', 'DisplayName',"Pulse EE");
hold on
plot(t2,A,'m-.', 'DisplayName',"Pulse Control");
plot(t2, chase_ee, 'r', 'DisplayName',"Chase EE")
plot(t2, chase_control, 'r-.', 'DisplayName',"Chase Control")
plot(t2, total_ee, 'k', 'DisplayName',"Total EE")
plot(t2, equil, 'k-.', 'DisplayName',"Total Control")
legend("Box","off","Location",'bestoutside')
box off
ylabel('Abundance (AU)')
xlabel('Time (\tau)')

fill([t2, fliplr(t2)], [chase_control, zeros(size(chase_control))],...
    [0.8 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5, ...
    'DisplayName', 'Equlibrium population');


fill([t2, fliplr(t2)], [chase_control, fliplr(chase_ee)], ...
    [1 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5, ...
    'DisplayName', 'Non-equilibrium popultaion');
%% mean age
figure(2)
clf
% plot(t,,'b');
t2 = t/tau;
plot(t2,tau_age / tau,'k', 'DisplayName',"Mean age EE");
hold on
plot(t2,ones(1,numel(tau_age)),'k-.', 'DisplayName',"Mean age Control");
xline(1, 'k:', 'DisplayName', "Pulse-Chase interval")
ylim([0.7 , 1.05])
box off
ylabel('Mean age / \tau')
xlabel('Time (\tau)')
legend("Box","off","Location",'best')
%% Error
% Parameters
deltaT_values = linspace(-20, 20, 100); % DeltaT range
fraction_pulse_values = linspace(0.2, 0.8, 100); % Fraction Pulse range
t_14 = 14; % Time point to measure error
Tc_inf = 1; % Steady state for control group

% Function to convert fraction pulse to tau at t = 14
fraction_pulse_to_tau = @(fraction_pulse) -t_14 ./ log(fraction_pulse);

% Compute corresponding tau values for the fraction pulse range
Tau_for_fraction_pulse = fraction_pulse_to_tau(fraction_pulse_values);

% Create meshgrid for deltaT and fraction pulse
[DeltaT, Fraction_Pulse_Mesh] = meshgrid(deltaT_values, fraction_pulse_values);

% Initialize matrix to store tau age with non-equilibrium
tau_age_with_nonequil = zeros(size(DeltaT));

% Simplified compute_tau_age function with intermediate variables
compute_tau_age = @(deltaT, tau) ...
    intermediate_vars(tau, deltaT, t_14, Tc_inf);



% Loop through each element in the meshgrid to compute tau_age_with_nonequil
for i = 1:numel(DeltaT)
    tau_age_with_nonequil(i) = compute_tau_age(DeltaT(i)/100, Tau_for_fraction_pulse(mod(i-1, 100) + 1));
end

% Calculate signed percentage error (without absolute value)
tau_age_without_nonequil = Tau_for_fraction_pulse';
error_percentage = 100 * (tau_age_with_nonequil - tau_age_without_nonequil) ./ tau_age_without_nonequil;

% Custom BWR colormap (Blue-White-Red)
bwr = [linspace(0, 1, 50)', linspace(0, 1, 50)', ones(50, 1); % Blue to white
       ones(50, 1), linspace(1, 0, 50)', linspace(1, 0, 50)']; % White to red

% Plotting the signed error as a function of deltaT and fraction pulse
f = figure('Units', 'inches', 'Position', [0, 0, 1.65, 1.65], 'Color','w'); % Set figure size to ~2x2 inches
contourf(DeltaT, Fraction_Pulse_Mesh, reshape(error_percentage, size(DeltaT)), 100, 'LineColor', 'none');
colormap(bwr); % Apply the custom BWR colormap
font_size = 14;
% Customize the colorbar
c = colorbar;
c.Ticks = [-10, -5, 0, 5, 10];
% c.TickLabels = {'-6', '-3', '0', '+3', '+6'};
c.FontSize = font_size;
c.Color=[0,0,0];
ylabel(c, 'Lifetime error (%)', 'FontSize', font_size);
clim([-11 11])
% Customize labels and title
xlabel('Change in total protein (%)', 'FontSize', font_size, 'FontWeight','bold', Color=[0,0,0]);
ylabel('Fraction pulse', 'FontSize', font_size, 'FontWeight','bold', Color=[0,0,0]);

% Adjust axis tick fonts
set(gca, 'XColor', [0, 0, 0], 'YColor', [0, 0, 0], 'FontSize', font_size);

% Save the figure as PDF
% saveas(gcf, 'error_plot.pdf');
%%
