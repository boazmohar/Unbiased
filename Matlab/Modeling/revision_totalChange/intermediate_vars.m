function tau_age = intermediate_vars(tau, deltaT, t, Tc_inf)
    exp_term = exp(-t ./ tau); % Exponential term
    delta_factor = deltaT .* (1 - exp_term); % Non-equilibrium factor
    total_ee = Tc_inf + delta_factor; % Total concentration

    tau_age_equil = tau; % Equilibrium tau
    % tau_age_nonequil = tau .* (1 - exp_term) - t .* exp_term; % Non-equilibrium tau
     tau_age_nonequil = tau  - ((t .* exp_term) / 1 - exp_term);
 

    fraction_equil = Tc_inf ./ total_ee; % Equilibrium fraction
    fraction_nonequil = delta_factor ./ total_ee; % Non-equilibrium fraction

    % Final tau age calculation
    tau_age = fraction_equil .* tau_age_equil + fraction_nonequil .* tau_age_nonequil;
end