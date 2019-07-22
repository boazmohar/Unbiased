function [fit_res, gof, x] = fitDouble(sortedTimes, median_middle, imageName)
x = minutes(sortedTimes - sortedTimes(1));
x=x';
max_median = max(median_middle);
ft = fittype( 'a*exp(-1/b*x)+ c+d*exp(-1/e*x)', 'independent', 'x', 'dependent', 'y' );
[fit_res, gof] = fit( x,median_middle, ft,...
    'Display','final' ,...
    'Lower',[0 10  -100 0 50],...
    'Upper',[100000 50 100 100000 500],...
    'StartPoint',[max_median 20 0 max_median/3 200]);
%%
figure()
plot(fit_res,x,median_middle);
text(50, median_middle(7), sprintf('tau_1 = %dMin, tau_2 = %dMin',int16(fit_res.b), ...
    int16(fit_res.e)))
ylabel('F (AU)')
xlabel('Time (Min)')
print(imageName,'-r300','-dpng')
set(gca, 'xScale','log');
print([imageName 'LogX'],'-r300','-dpng')
% close();