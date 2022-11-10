function [tau] = fit_exp_decay(times,p_mean)
    ft = fittype( 'exp(-1/tau*x)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = 10;
    [fitresult, ~] = fit( times', p_mean', ft, opts );
    tau = fitresult.tau;
end