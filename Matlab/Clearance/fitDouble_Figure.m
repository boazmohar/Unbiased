function [fit_res, gof, x, opts] = fitDouble_Figure(sortedTimes, median_middle, imageName)
x = minutes(sortedTimes - sortedTimes(1));
x=x';
x = x+0.1;
start1 = median(median_middle);
ft = fittype( 'a*exp(-1/b*x)+c*exp(-1/d*x)+e', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'final';
opts.Lower = [0 0  0 0 -100];
opts.Upper = [100000 50 100000 1500 100];
opts.StartPoint = [start1 20 start1 200 0];
[fit_res, gof] = fit( x,median_middle, ft,opts);
%%
f1 = figure(1);
f1.Color='w';
f1.Units = 'Centimeters';
f1.Position = [10 10 6 4.7];
clf
p = plot(fit_res,x,median_middle);
p(1).MarkerSize = 4;
p(1).Marker = 'o';
p(1).MarkerFaceColor = 'b';
p(2).LineWidth = 1;
text(200,0.52, ...
    sprintf('$$ \\tau_{1}=%.1f,\\tau_{2}=%.1f $$', ...
    fit_res.b, fit_res.d),'Interpreter','latex');
text(200, 0.4, sprintf('$$ a/b=%.1f,c=%.2f$$ ' , ...
    fit_res.a / fit_res.c, fit_res.e),'Interpreter','latex');
ylabel('Normalized F')
xlabel('Time (Min)')
legend off
box off
legend({'Data','a*e^{1/ \tau_{1}} + b*e^{1/ \tau_{2}} + c'},...
    'Location','northeast','Box','off')

export_fig([imageName '_LinX'],'-eps');
f1 = figure(2);

f1.Color='w';
f1.Units = 'Centimeters';
f1.Position = [10 10 6 4.7];
p = plot(fit_res,x,median_middle);
p(1).MarkerSize = 4;
p(1).Marker = 'o';
p(1).MarkerFaceColor = 'b';
p(2).LineWidth = 1;
set(gca,'xscale','log');
xlabel('Time (Min)')
ylabel('');
legend off
box off

export_fig([imageName '_LogX'],'-eps');
% print([imageName 'LogX'],'-r300','-dpng')
% close();