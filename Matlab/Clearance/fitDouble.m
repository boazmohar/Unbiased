function [fit_res, gof, x, opts] = fitDouble(sortedTimes, median_middle, imageName)
x = minutes(sortedTimes - sortedTimes(1));
x=x';
x = x+0.1;
start1 = median(median_middle);
ft = fittype( 'a*exp(-1/b*x)+c*exp(-1/d*x)+e', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'final';
opts.Lower = [0 0  0 0 -100];
opts.Upper = [100000 50 100000 500 100];
opts.StartPoint = [start1 20 start1 200 0];
[fit_res, gof] = fit( x,median_middle, ft,opts);
%%
figure()
plot(fit_res,x,median_middle);
ci = confint(fit_res);
title(imageName);
text(1,0.3, ...
    sprintf(['a=%.2f(%.2f-%.2f), b=%d(%d-%d)\n,c=%.2f(%.2f-%.2f)' ...
    ',d=%d(%d-%d)\ne=%.2f(%.2f-%.2f)'], ...
    fit_res.a, ci(1, 1), ci(2,1), ...
    round(fit_res.b), round(ci(1, 2)), round(ci(2,2)),...
    fit_res.c, ci(1, 3), ci(2,3),...
    round(fit_res.d), round(ci(1, 4)), round(ci(2,4)),...
    fit_res.e, ci(1, 5), ci(2,5)));
% text(50, median_middle(7), sprintf('tau_1 = %dMin, tau_2 = %dMin',int16(fit_res.b), ...
%     int16(fit_res.e)))
ylabel('F (AU)')
xlabel('Time (Min)')
% print(imageName,'-r300','-dpng')
set(gca, 'xScale','log');
% print([imageName 'LogX'],'-r300','-dpng')
% close();