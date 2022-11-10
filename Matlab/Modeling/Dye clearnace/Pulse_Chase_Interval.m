function args = Pulse_Chase_Interval()
args_in = load('PC_interval.mat');
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

% Generate samples.
samples1 = SimBiology.Scenarios();
sim_time = linspace(20,500,100);
add(samples1, 'cartesian', 'C_time', sim_time);
add(samples1, 'cartesian', 'Tau', [100]);
add(samples1, 'cartesian', 'A', [1.2]);

% Configure RandomSeed to a unique value.
seeds = typecast(now, 'uint32');
samples1.RandomSeed = seeds(1);
generate(samples1);

% Populate the output structure.
args.output.samples = samples1;

% Run simulation.
args = runSimulation(args);
res = args.output.results;
e = selectbyname(res,{'Error'}, 'Format','ts');
e2 = cellfun(@(x) x.data(end), e);


p = selectbyname(res,{'Pulse_end'}, 'Format','ts');
p2 = cellfun(@(x) x.data(end), p);
%%
f= figure(1);
clf
f.Units = 'centimeters';
f.Position = [10,10,9,4.5];
f.Color = 'w';
yyaxis left
plot(sim_time, p2)
ylabel('P @ \DeltaT (AU)')
box('off')

yyaxis right
plot(sim_time, e2)
hold on;
plot([100, 100], [0, 22], 'k--')
text(120,14, '\tau_{True} = 100h')
ylabel('Error (%)')
xlabel('\DeltaT')
box('off')

exportgraphics(f,'SuppNote_PulseChaseTime.pdf','ContentType','vector')


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
set(cs, 'StopTime', 501);
set(cs, 'TimeUnits', 'hour');

% Extract samples to simulate.
samples = args.output.samples;

% Turn off observables.
observables        = model.Observables;
activateState      = get(observables, {'Active'});
cleanupObservables = onCleanup(@() restoreObservables(observables, activateState));
set(observables, 'Active', false);

% Turn on observables.
obsNames    = {'Sum1', 'Fraction_Pulse', 'Pulse_end', 'Est_Tau', 'Error', 'GluEnd', 'c_time_end'};
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

