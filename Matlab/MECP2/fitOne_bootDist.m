function [outputArg1,outputArg2] = fitOne_bootDist(tbl, data,edges, ft, opts, bootNum)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
results = zeros(height(data), length(edges)-1, 3); % anm, group, interval
ci = 
intervals = zeros(height(data), 3);
for anm = 1:height(data)% to for loop
    current = data(anm,:);
    dist = current.dist{1};
    groups = discretize(dist, edges);
    ANM = data.ANM{anm};
    IHC = 'NeuN';
    cellType = 1;
    intervalType = 0;
    current_tbl = getOneEntry(tbl, ANM, IHC, cellType, intervalType);
    intervals(anm,:) = current_tbl.interval;
    for g = 1:length(edges)-1  % for each group
        index = find(groups == g);
        for int = 1:3
            frac = current_tbl.fraction{int};
            frac = frac(index);
            ci = bootci(bootNum,@mean,frac)
            results(anm, g, int) = mean(frac);
        end
    end
end
%

typeTexts = {'0-300','300-1200','>1200'};
symbols = {'or', '*b', '^g'};
%
figure(1);
b = axes;
clf;
l = {};
for g = 1:3
    
    frac = squeeze(  results(:,g,:));
    y1 = frac(:);
    x1 = intervals(:);
    [xData, yData] = prepareCurveData( x1, y1 );
    [res, gof] = fit( xData, yData, ft, opts )
    ci = confint(res);
    t = sprintf('%.0f [%.0f-%.0f]',coeffvalues(res),ci(1),ci(2));
    legText = [typeText ': \tau=' t];
    l{g} = legText;
    b(g) = scatter(x1, y1, symbol);
    hold on;
    a = plot(res);
    a.Color = symbol(2);
end
legend(b, l)
end

