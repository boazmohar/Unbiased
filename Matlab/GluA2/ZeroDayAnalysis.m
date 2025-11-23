%% load data
% tbl3 = load_data_glua2('D:\', 8:9,true, false);
%%
f=figure(1);
clf
f.Color='w';
gscatter(tbl3.P_Mean,tbl3.C_Mean,tbl3.groupName,['m','r'],'o' )
xlabel('Pulse')
ylabel('Chase')
legend({'Pulse only','Chase only'}, "Box","off")
box off;
%%
figure(2)
clf
[group, id] = findgroups(tbl3(:,'Name'));
all_ratios = [];
all_indexs = [];
all_tbls = {};
for i = 1:height(id)

    if ~mod(i,10)
        disp(i./height(id))
    end
    current = tbl3(group==i,:);
    dye = current.groupName;
    if length(unique(dye)) < 2 || length(unique(current.ANM)) < 4
        continue
    end
    Pulse_552 =  current.P_Mean(find(dye == 'zero552'));
    Pulse_673 = current.P_Mean(find(dye == 'zero673'));
    Chase_552 =  current.C_Mean(find(dye == 'zero552'));
    Chase_673 = current.C_Mean(find(dye == 'zero673'));
    N_Pulse =  current.N(find(dye == 'zero673'));
    N_Chase =  current.N(find(dye == 'zero552'));
    p552 = sum(Pulse_552 .* N_Chase, 'omitnan') / sum(N_Chase, 'omitnan');
    p673 = sum(Pulse_673 .* N_Pulse, 'omitnan') / sum(N_Pulse, 'omitnan');
    c552 = sum(Chase_552 .* N_Chase, 'omitnan') / sum(N_Chase, 'omitnan');
    c673 = sum(Chase_673 .* N_Pulse, 'omitnan') / sum(N_Pulse, 'omitnan');
    if sum(N_Pulse) + sum(N_Chase) < 10000
        disp('small')
        continue
    end
    current = current(1,{'Name','CCF_ID','new_names'});
    current.index = {group==i};
    current.bg_552 = p552;
    current.bg_673 = c673;
    current.sum_552 = c552;
    current.sum_673 = p673;
    ratio = (p673 - p552) ./ (c552 - c673);
    current.ratio = (p673 - p552) ./ (c552 - c673);
    scatter(i, ratio)
    all_ratios = [all_ratios ratio];
    hold on
    all_indexs = [all_indexs i];
    all_tbls{end+1} = current;
end
%%

figure(3)
clf
subplot(1,2,1)
histogram(all_ratios, 30)
xlabel('slope ratio')
ylabel('# brain regions')
tbl4 = vertcat(all_tbls{:});
tbl4 = sortrows(tbl4,"ratio","descend");
subplot(1,2,2)
boxplot(tbl4.ratio,tbl4.new_names)

ylabel('slope ratio')
xlabel('brain region')
%%
x = tbl4.sum_673;
y = tbl4.sum_552;
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'LAR';

% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 2' );
h = plot( fitresult, xData, yData );
legend( h, 'y vs. x', 'untitled fit 2', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'x', 'Interpreter', 'none' );
ylabel( 'y', 'Interpreter', 'none' );
grid on
%%
% Fit a robust linear model
% Fit a robust linear model using a table

x = tbl4.sum_673;
y = tbl4.sum_552;
tbl = table(x, y, 'VariableNames', {'x', 'y'});
lm = fitlm(tbl, 'y ~ x', 'RobustOpts', 'on');

% Get predicted values and confidence intervals
[x_pred, ~] = sort(x);  % Sorting x values for plotting
tbl_pred = table(x_pred, 'VariableNames', {'x'});  % Ensure the table has the correct variable name
[y_pred, ci] = predict(lm, tbl_pred);

% Plot the data
figure;
scatter(x, y, 'filled');
hold on;

% Plot the regression line
plot(x_pred, y_pred, 'b-', 'LineWidth', 2);

% Add confidence interval as a patch
patch([x_pred; flipud(x_pred)], [ci(:,1); flipud(ci(:,2))], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none');

% Enhancing the plot
xlabel('JF673 - Pulse');
ylabel('JF552 - Chase');
all_vals_for_print = [lm.Coefficients{2,1}, lm.Coefficients{2,2}, ...
    lm.Coefficients{1,1}, lm.Coefficients{1,2}, lm.Rsquared.Adjusted];
title(sprintf('Slope = %.2f +- %.2f; Intercept = %.0f +- %.0f; Adj. R^2: %.2f',...
    all_vals_for_print));
legend({'Data', 'Fitted Line', '95% Confidence Interval'}, 'Location', 'best');
grid on;
hold off;
%%
calibration = struct();
calibration.bg_552 = median(tbl4.bg_552);
calibration.bg_673 = median(tbl4.bg_673);
calibration.slope_ratio = lm.Coefficients{2,1};
calibration.slope_se = lm.Coefficients{2,2};
calibration.offset = lm.Coefficients{1,1};
calibration.offset_se = lm.Coefficients{1,2};
save('Calibration_0day_GluA2.mat','calibration')
save('Calibration_0day_table_GluA2.mat', 'tbl4')