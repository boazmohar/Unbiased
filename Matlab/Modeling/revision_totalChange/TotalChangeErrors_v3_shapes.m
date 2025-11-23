% Parameters for synthesis rate changes
synthesis_type = 'half_step'; % Options: 'step', 'ramp', 'half_step'
deltaT_initial = 0.2; % Initial change in total protein (for 'step' and 'half_step')
tau = 14; % tau is tau_decay
t = 0:0.01:tau*6; % time to simulate

% Define synthesis rate changes based on the selected type
switch synthesis_type
    case 'step'
        % Original step function (20% increase in total protein)
        deltaT = deltaT_initial;
        Tee_inf = 1 + deltaT;
    case 'ramp'
        % Ramp increase over time, reaching deltaT_initial at the end of tau*6
        deltaT = linspace(0, deltaT_initial, length(t));
        Tee_inf = 1 + deltaT;
    case 'half_step'
        % Larger step occupying half the time
        deltaT = deltaT_initial * 2;
        Tee_inf = 1 + deltaT * (t <= (max(t) / 2));
    otherwise
        error('Invalid synthesis type. Choose ''step'', ''ramp'', or ''half_step''.')
end

% Calculations
A = exp(-t/tau); % Exponential decay
pulse_ee = 1 * A; % Pulse in uneffec
chase_ee = Tee_inf .* (1 - A); % Left over to inf
chase_control = 1 - A;
equil = 1 * ones(size(A));
nonequil = (Tee_inf - 1) .* (1 - A);
total_ee = equil + nonequil;

% Mean age calculation
tau_age_equil = tau * ones(size(A));
tau_age_nonequil = tau * (1 - A) - t .* A;
fraction_equil = equil ./ total_ee;
fraction_nonequil = nonequil ./ total_ee;
tau_age = fraction_equil .* tau_age_equil + fraction_nonequil .* tau_age_nonequil;

% Plotting
figure(5)
clf
t2 = t / tau;
plot(t2, A, 'm', 'DisplayName', "Pulse EE");
hold on
plot(t2, A, 'm-.', 'DisplayName', "Pulse Control");
plot(t2, chase_ee, 'r', 'DisplayName', "Chase EE");
plot(t2, chase_control, 'r-.', 'DisplayName', "Chase Control");
plot(t2, total_ee, 'k', 'DisplayName', "Total EE");
plot(t2, equil, 'k-.', 'DisplayName', "Total Control");
legend("Box", "off", "Location", 'bestoutside');
box off
ylabel('Abundance (AU)');
xlabel('Time (\tau)');

fill([t2, fliplr(t2)], [chase_control, zeros(size(chase_control))],...
    [0.8 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'DisplayName', 'Equilibrium population');

fill([t2, fliplr(t2)], [chase_control, fliplr(chase_ee)],...
    [1 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'DisplayName', 'Non-equilibrium population');

% Mean Age Plot
figure(6)
clf
plot(t2, tau_age / tau, 'k', 'DisplayName', "Mean age EE");
hold on
plot(t2, ones(1, numel(tau_age)), 'k-.', 'DisplayName', "Mean age Control");
xline(1, 'k:', 'DisplayName', "Pulse-Chase interval");
ylim([0.7, 1.05]);
box off
ylabel('Mean age / \tau');
xlabel('Time (\tau)');
legend("Box", "off", "Location", 'best');
