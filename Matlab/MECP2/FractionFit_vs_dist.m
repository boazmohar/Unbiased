%% get decay as function of distance from pia NeuN Only
clear;
tbl = load_tbl();
ANM = 0;
IHC = 'NeuN';
cellType = 1;
intervalType = 0;
data_allInterval = getOneEntry(tbl, ANM, IHC, cellType, intervalType);
intervalType = 1;
data = getOneEntry(tbl, ANM, IHC, cellType, intervalType)
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 200;
edges = [-100,200,1100, 15000];
%%
results = zeros(height(data), length(edges)-1, 3); % anm, group, interval
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
            results(anm, g, int) = mean(frac);
        end
    end
end
%
ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 200;
typeTexts = {'0-300','300-1200','>1200'};
symbols = {'or', '*b', '^g'};
%
figure(1);
b = axes;
clf;
l = {};
for g = 1:3
    typeText = typeTexts{g};
    symbol = symbols{g};
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

