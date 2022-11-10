function args = simple_figure1_heatmap()
%% load inputs
args_in = load('simple_figure1.mat');
args_in = args_in.args;
model = args_in{1};
cs= args_in{2};
variantsStruct = args_in{3};
dosesStruct = args_in{4};
% Initialize arguments.
args.input.model    = model;
args.input.cs       = cs;
args.input.variants = variantsStruct;
args.input.doses    = dosesStruct;

% Define StatesToLog cleanup code.
originalStatesToLog = get(cs.RuntimeOptions, 'StatesToLog');
cleanupStatesToLog  = onCleanup(@() restoreStatesToLog(cs, originalStatesToLog));

% Configure StatesToLog.
set(cs.RuntimeOptions, 'StatesToLog', {'Brain.Pulse', 'Brain.Chase', 'Brain.Protein', 'Brain.P_Pulse', 'Brain.P_Chase', 'Lipids.Pulse_lipid', 'Lipids.Chase_lipid', 'ksyn', 'Tau', 'C_time'});

%% Generate samples.
samples1 = SimBiology.Scenarios();
n_dyes = 19;
A =  linspace(0.2, 2, n_dyes);
add(samples1, 'elementwise', 'A', linspace(0.2, 2, n_dyes));

samples2 = SimBiology.Scenarios();
n_taus = 21;
taus = logspace(0.5, 3, n_taus);%logspace(1, 3, 28);
add(samples2, 'elementwise', 'Tau', taus);
add(samples2, 'elementwise', 'C_time', taus+5);

% Configure RandomSeed to a unique value.
seeds = typecast(now, 'uint32');
samples1.RandomSeed = seeds(1);
generate(samples1);

samples2.RandomSeed = rng;
generate(samples2);

SD1 = add(copy(samples1), 'cartesian', samples2);

% Populate the output structure.
args.output.PulseAmount = samples1;
args.output.ChaseTime   = samples2;
args.output.samples     = SD1;
%% Run simulation.
args = runSimulation(args);
%% plot
res = args.output.results;
e = selectbyname(res,{'Error'}, 'Format','ts');
e2 = cellfun(@(x) x.data(end), e);
e3 = reshape(e2,n_dyes ,n_taus);
disp(e3)
e = selectbyname(res,{'P_Pulse','P_Chase','Protein'}, 'Format','ts');
Xq = linspace(0.2, 2, n_dyes*100);
Yq= logspace(0.5, 3, n_taus*100);%logspace(1, 3, 28);
[X, Y] = meshgrid(A, taus);
[Xq2, Yq2] = meshgrid(Xq, Yq);
Vq = interp2(X, Y, e3',Xq2,Yq2);
%%
f2 = figure(2);
clf
f2.Units = 'centimeters';
f2.Position = [10,10, 9.1, 13];

f2.Color='w';
% h = heatmap(A, taus, e3');
imshow(Vq, "Interpolation","bilinear")
YLabels = int16(taus);
% object 'h' to the custom x-axis tick labels
h.YDisplayLabels =string(YLabels);
rb = redblue(100);
clim([-60, 60]);
colormap(rb)
axis('on')
exportgraphics(f2,['Figure1_simple_heatmap2.pdf'],'ContentType','vector')
end

% -------------------------------------------------------------------------


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
set(cs, 'StopTime', 1006);
set(cs, 'TimeUnits', 'hour');

% Extract samples to simulate.
samples = args.output.samples;

% Turn off observables.
observables        = model.Observables;
activateState      = get(observables, {'Active'});
cleanupObservables = onCleanup(@() restoreObservables(observables, activateState));
set(observables, 'Active', false);

% Turn on observables.
obsNames    = {'Sum1', 'Fraction_Pulse', 'Pulse_end', 'Pulse_dye_end', 'Est_Tau', 'Error', 'GluEnd', 'c_time_end'};
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

