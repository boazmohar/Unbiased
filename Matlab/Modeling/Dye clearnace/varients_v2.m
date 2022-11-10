function args = varients_v2()
args_in = load('varients_v4_dye1p2.mat');
args_in = args_in.args;
model = args_in{1};
cs= args_in{2};
variantsStruct = args_in{3};
dosesStruct = args_in{4};
dosesStruct.modelStep(1).Amount= 1.5;
% Initialize arguments.
args.input.model    = model;
args.input.cs       = cs;
args.input.variants = variantsStruct;
args.input.doses    = dosesStruct;

% Define StatesToLog cleanup code.
originalStatesToLog = get(cs.RuntimeOptions, 'StatesToLog');
cleanupStatesToLog  = onCleanup(@() restoreStatesToLog(cs, originalStatesToLog));

% Configure StatesToLog.
set(cs.RuntimeOptions, 'StatesToLog', {'Brain.Pulse', 'Brain.Chase', 'Brain.Protein', 'Brain.P_Pulse', 'Brain.P_Chase', 'Lipids.Pulse_lipid', 'Lipids.Chase_lipid', 'Tau'});

% Generate samples.
samples1 = SimBiology.Scenarios();
taus = [ 10, 20, 40, 80, 160, 320, 640];
add(samples1, 'elementwise', 'Tau', taus);
add(samples1, 'elementwise', 'C_time', taus+7);

samples2 = SimBiology.Scenarios();
v1       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_1');
v2       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_2');
v3       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_3');
v4       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_4');
v5       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_5');
v6       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_6');
v7       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_7');
v8       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_8');
v9       = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_9');
v10      = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_10');
v11      = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_11');
v12      = sbioselect(args.input.model, 'Type', 'variant', 'Name', 'Fit_Group_12');
add(samples2, 'cartesian', 'PS2', [v1; v2; v3; v4; v5; v6; v7; v8; v9; v10; v11; v12]);

% Configure RandomSeed to a unique value.
seeds = typecast(now, 'uint32');
samples1.RandomSeed = seeds(1);
generate(samples1);

samples2.RandomSeed = rng;
generate(samples2);

SD1 = add(copy(samples1), 'cartesian', samples2);

% Populate the output structure.
args.output.PS1     = samples1;
args.output.PS2     = samples2;
args.output.samples = SD1;

% Run simulation.
args = runSimulation(args);

res = args.output.results;
e = selectbyname(res,{'Error'}, 'Format','ts');
e2 = cellfun(@(x) x.data(end), e);
n_taus = length(taus);
e3 = reshape(e2,n_taus,12);
m = mean(e3,2);
s = std(e3,[],2);

est = selectbyname(res,{'Est_Tau'}, 'Format','ts');
est2 = cellfun(@(x) x.data(end), est);
est3 = reshape(est2,n_taus,12);
%%

colororder(jet(2))

x = repmat(taus, 12, 1)';
f=figure(1);
clf
f.Units = 'centimeters';
f.Position = [10,10,12,7];
subplot(1,3,[1,2])
f.Color='w';
scatter(x, est3, 'ko','MarkerFaceAlpha',.3,'MarkerEdgeAlpha',.3)
hold on;
plot([2.5,1000], [2.5,1000],'k:')
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';
ax.PositionConstraint = 'outerposition';
xlim([2.5 ,1000])
ylim([2.5 ,1000])
box('off')
legend(['Dye clearnace', newline, 'parameters'], 'Location','northwest', 'box','off')
axis('square')
xlabel('True lifetime (h)')
ylabel('Estimated lifetime (h)')

subplot(2,3,3)
cc = 0.6;
ccc = [cc, cc, cc];
bar(m, 'FaceColor',ccc)
xticklabels(x(:,1))
ylabel('Mean error (%)')
% ylim([-2,3])
xxx = get(gca,'XLim');
box('off')
axis('tight')
subplot(2,3,6)
bar(s, 'FaceColor',ccc)
xticklabels(x(:,1))
xlabel('True lifetime (h)')
set(gca,'XLim', xxx);
ylabel('Std error (%)')
% ylim([0,2])
box('off')
[xData, yData] = prepareCurveData( x, est3 );
axis('tight')
% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Lower = [-Inf -10];
opts.Upper = [Inf 10];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
disp(gof)
%%


e = selectbyname(res,{'P_Pulse','P_Chase','Protein'}, 'Format','ts');
tbl = generate(SD1);
[G, ID] = findgroups(tbl.Tau);
ids = length(ID);
colors = ['gmk'];
%%
f2 = figure(2);
clf
f2.Units = 'centimeters';
f2.Position = [10,10,7,10];

f2.Color='w';
names = {'P','C','Protein'};
for i =1:ids
    tau = ID(i);
    indexs = find(G==i);
    subplot(ids,1,i)
    for j =1:length(indexs)
        pos = indexs(j);
        current = e{pos};
        for k = 1:3
            d = getsampleusingtime(current{k}, 0, tau+6);
            plot(d,colors(k), 'DisplayName', names{k})
            hold on
        end

        ylabel('')
        xlabel('')
        title('')
        set(gca, 'XScale', 'log')
        xlim([4,1000])
        box('off')
        yticks([0,1])
%         if i==1 && j==1
%             disp([i,j])
%             leg = legend('AutoUpdate','off', 'Box','off','NumColumns',3, 'LineWidth',1.5);
%             leg.ItemTokenSize = [10,9];
%         end
        if j == 1
            xline(tau+6,':k', 'LineWidth',1.5)
        end
    end
end
xlabel('Time (h)')
exportgraphics(f,'Figure1D.pdf','ContentType','vector')
exportgraphics(f2,'Figure1C.pdf','ContentType','vector')
end
% -------------------------------------------------------------------------
function args = runSimulation(args)

% Extract the input arguments.
input    = args.input;
model    = input.model;
cs       = input.cs;
variants = input.variants.modelStep;
doses    = input.doses.modelStep;

% Define StopTime cleanup code.
originalStopTime  = get(cs, 'StopTime');
originalTimeUnits = get(cs, 'TimeUnits');
cleanupStopTime   = onCleanup(@() restoreStopTime(cs, originalStopTime, originalTimeUnits));

% Configure StopTime.
set(cs, 'StopTime', 646);
set(cs, 'TimeUnits', 'hour');

% Extract samples to simulate.
samples = args.output.samples;

% Turn off observables.
observables        = model.Observables;
activateState      = get(observables, {'Active'});
cleanupObservables = onCleanup(@() restoreObservables(observables, activateState));
set(observables, 'Active', false);

% Turn on observables.
obsNames    = {'Sum1', 'Fraction_Pulse', 'Pulse_end', 'Pulse_dye_end', 'Est_Tau', 'Error', 'GluEnd'};
observables = sbioselect(model.Observables, 'Name', obsNames);
set(observables, 'Active', true);

% Get list of observables.
states          = cs.RuntimeOptions.StatesToLog;
observables     = sbioselect(model.Observables, 'Active', true);
observableNames = cell(1, length(states)+length(observables));
for i = 1:length(states)
    observableNames{i} = states(i).PartiallyQualifiedName;
end
for i = 1:length(observables)
    observableNames{i+length(states)} = observables(i).Name;
end

% Convert doses.
if ~isempty(doses)
    dosesTable = getTable(doses);
else
    dosesTable = [];
end

% Simulate the model. 
f    = createSimFunction(model, samples, observableNames, doses, variants, 'AutoAccelerate', false);
data = f(samples, cs.StopTime, dosesTable);

% Populate the output structure.
args.output.results = data;

end

% -------------------------------------------------------------------------
function restoreStatesToLog(cs, originalStatesToLog)

% Restore StatesToLog.
set(cs.RunTime, 'StatesToLog', originalStatesToLog);

end

% -------------------------------------------------------------------------
function restoreObservables(observables, active)

for i = 1:length(observables)
    set(observables(i), 'Active', active{i});
end

end

% -------------------------------------------------------------------------
function restoreStopTime(cs, originalStopTime, originalTimeUnits)

% Restore StopTime.
set(cs, 'StopTime', originalStopTime);
set(cs, 'TimeUnits', originalTimeUnits);

end

