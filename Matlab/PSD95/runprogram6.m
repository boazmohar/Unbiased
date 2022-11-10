function args = runprogram6(model, cs, variantsStruct, dosesStruct)

% Initialize arguments.
args.input.model    = model;
args.input.cs       = cs;
args.input.variants = variantsStruct;
args.input.doses    = dosesStruct;

% Define StatesToLog cleanup code.
originalStatesToLog = get(cs.RuntimeOptions, 'StatesToLog');
cleanupStatesToLog  = onCleanup(@() restoreStatesToLog(cs, originalStatesToLog));

% Configure StatesToLog.
set(cs.RuntimeOptions, 'StatesToLog', {'Brain.Pulse', 'Brain.Chase', 'Brain.GluA1', 'Brain.GluA1_Pulse', 'Brain.GluA1_Chase', 'Lipids.Pulse_lipid', 'Lipids.Chase_lipid'});

% Generate samples.
args = runGenerateSamples(args);

% Run simulation.
args = runSimulation(args);


% -------------------------------------------------------------------------
function args = runGenerateSamples(args)

samples1 = SimBiology.Scenarios();
add(samples1, 'elementwise', 'GluRate', [12, 24, 36, 48]);

samples2 = SimBiology.Scenarios();
d1       = sbioselect(args.input.model, 'Type', {'repeatdose', 'scheduledose'}, 'Name', 'dose_pulse');
d2       = sbioselect(args.input.model, 'Type', {'repeatdose', 'scheduledose'}, 'Name', 'dose_pulse_1');
d3       = sbioselect(args.input.model, 'Type', {'repeatdose', 'scheduledose'}, 'Name', 'dose_pulse_2');
d4       = sbioselect(args.input.model, 'Type', {'repeatdose', 'scheduledose'}, 'Name', 'dose_pulse_3');
d5       = sbioselect(args.input.model, 'Type', {'repeatdose', 'scheduledose'}, 'Name', 'dose_pulse_4');
d6 = sbiodose('d6','schedule');
d6.Amount = 4;
d6.AmountUnits = 'milligram';
d6.TimeUnits = 'hour';
d6.Time=5;
d6.Active = true;
d6.TargetName='Brain.Pulse';
add(samples2, 'cartesian', 'PS3', [d1; d2; d3; d4; d5;d6]);

% Configure RandomSeed to a unique value to ensure reproducibility.
seeds = typecast(now, 'uint32');
samples1.RandomSeed = seeds(1);
generate(samples1);

samples2.RandomSeed = rng;
generate(samples2);

SD1 = add(copy(samples1), 'cartesian', samples2);

% Populate the output structure.
args.output.PS1     = samples1;
args.output.PS3     = samples2;
args.output.samples = SD1;

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
set(cs, 'StopTime', 21);
set(cs, 'TimeUnits', 'hour');

% Extract samples to simulate.
samples = args.output.samples;

% Turn off observables.
observables        = model.Observables;
activateState      = get(observables, {'Active'});
cleanupObservables = onCleanup(@() restoreObservables(observables, activateState));
set(observables, 'Active', false);

% Turn on observables.
obsNames    = {'Sum1', 'Fraction_Pulse', 'Pulse_end'};
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

% -------------------------------------------------------------------------
function restoreStatesToLog(cs, originalStatesToLog)

% Restore StatesToLog.
set(cs.RunTime, 'StatesToLog', originalStatesToLog);

% -------------------------------------------------------------------------
function restoreObservables(observables, active)

for i = 1:length(observables)
    set(observables(i), 'Active', active{i});
end

% -------------------------------------------------------------------------
function restoreStopTime(cs, originalStopTime, originalTimeUnits)

% Restore StopTime.
set(cs, 'StopTime', originalStopTime);
set(cs, 'TimeUnits', originalTimeUnits);

