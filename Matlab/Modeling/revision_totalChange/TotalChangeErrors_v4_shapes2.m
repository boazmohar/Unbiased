% Parameters for synthesis rate changes
synthesis_type = 'ramp_down'; % Options: 'constant_step', 'ramp_up', 'ramp_down'
deltaT_initial = 0.1; % Initial change in total protein (10% increase)
tau = 14; % tau is tau_decay
t = 0:0.01:tau*6; % time to simulate

% Define synthesis rate changes based on the selected type
switch synthesis_type
    case 'constant_step'
        % Step function (10% increase in total protein at time = tau)
        deltaT_infinite = deltaT_initial / (1 - exp(-1)); % Calculated deltaT at infinite to achieve 10% increase at t = tau
        Tee_inf = 1 + deltaT_infinite; % Constant step increase
        fig1 = 1;
        fig2 = 2;
        title1='Constant step';
    case 'ramp_up'
        % Ramp increase over time, reaching deltaT_infinite at time = tau
        deltaT_infinite = deltaT_initial *1.6; % Corrected deltaT at infinite to achieve 10% increase at t = tau
        deltaT = linspace(0, deltaT_infinite, find(t <= tau, 1, 'last'));
        deltaT = [deltaT, deltaT_infinite * ones(1, length(t) - length(deltaT))];
        Tee_inf = 1 + deltaT;
        fig1 = 3;
        fig2 = 4;
        title1='Ramp up';
    case 'ramp_down'
        % Ramp down over time, starting from deltaT_infinite at t = 0 and decreasing to 0 at t = tau
        deltaT_infinite = deltaT_initial * 3.2; % Starting point of the ramp down
        deltaT = linspace(deltaT_infinite, 0, find(t <= tau*2, 1, 'last'));
        deltaT = [deltaT, zeros(1, length(t) - length(deltaT))];
        Tee_inf = 1 + deltaT;
        fig1 = 5;
        fig2 = 6;
        title1='Ramp down';
    otherwise
        error('Invalid synthesis type. Choose ''constant_step'', ''ramp_up'', or ''ramp_down''.')
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
figure(fig1)
clf
title(sprintf('Protein Synthesis Rate Change: %s', synthesis_type))
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
xline(1, 'k:', 'DisplayName', 'Time = \tau');
title(title1)

fill([t2, fliplr(t2)], [chase_control, zeros(size(chase_control))],...
    [0.8 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'DisplayName', 'Equilibrium population');

fill([t2, fliplr(t2)], [chase_control, fliplr(chase_ee)],...
    [1 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'DisplayName', 'Non-equilibrium population');

% Mean Age Plot
figure(fig2)
clf
title(sprintf('Mean Age: %s', synthesis_type))
plot(t2, tau_age / tau, 'k', 'DisplayName', "Mean age EE");
hold on
plot(t2, ones(1, numel(tau_age)), 'k-.', 'DisplayName', "Mean age Control");
xline(1, 'k:', 'DisplayName', "Pulse-Chase interval");
ylim([0.7, 1.05]);
box off
ylabel('Mean age / \tau');
xlabel('Time (\tau)');
legend("Box", "off", "Location", 'best');
title(title1)