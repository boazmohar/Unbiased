function [res,gof,ci,legText] = fitOne_FractionPulse(tbl,index, symbol, typeText)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 200; 
%%
x1 = tbl.interval(index);
y1 = tbl.mean(index);
errorbar(x1,y1, tbl.std(index), symbol)
[xData, yData] = prepareCurveData( x1, y1 );
[res, gof] = fit( xData, yData, ft, opts );
ci = confint(res);
t = sprintf('%.0f [%.0f-%.0f]',coeffvalues(res),ci(1),ci(2));
legText = [typeText ': $\tau$=' t];
end

