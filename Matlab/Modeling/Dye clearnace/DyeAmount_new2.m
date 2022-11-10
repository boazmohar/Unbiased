function args  = DyeAmount_new2()
args_in = load('DyeAmount_new2.mat');
args_in = args_in.args;
model = args_in{1};
cs= args_in{2};
variantsStruct = args_in{3};
dosesStruct = args_in{4};
% dosesStruct.modelStep(1).Amount= 1.2;
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
% Generate samples.
samples1 = SimBiology.Scenarios();
taus = [5, 10, 20, 40, 80, 160, 320, 640];
add(samples1, 'elementwise', 'Tau', taus);
add(samples1, 'elementwise', 'C_time', taus+5);

samples2 = SimBiology.Scenarios();
As = linspace(0.1,3,31);
add(samples2, 'elementwise', 'A', As);

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
total = length(As)*length(taus);
e3 = reshape(e2,length(taus),total/length(taus));
%%
x =  repmat(As, length(taus), 1);
f = figure(1);
clf
f.Units = 'centimeters';
f.Position = [10,10,6,6];
f.Color = 'w';
colororder(spring(7))
ax1 = plot(x',e3');
xlabel('Fold dye over protein')
ylabel('% Error of lifetime')


leg = legend({'5','10','20','40','80', '160','320','640'}, "NumColumns",2,"Box", "off",'Location','south');
set(leg,'AutoUpdate','off')
box('off')
ylim([-80, 80])
xline(1, 'k:', 'LineWidth',1)
yline(0, 'k:', 'LineWidth', 1)
text(2.5, -10,'\tau', 'FontSize',20)
exportgraphics(f,'SuppFigure1B.pdf','ContentType','vector')
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

