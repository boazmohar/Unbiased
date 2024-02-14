%% course layers
figure(1)
clf
set(gcf,'Color','w')
set(gcf,'Position',[ 385         507        1075         470])
tbl_stats = grpstats(tbl_all3, {'groupName', 'layer'}, {'mean', 'std'}, 'DataVars','tau');
vals = reshape(tbl_stats.mean_tau, 9,4);
errors = reshape(tbl_stats.std_tau, 9,4);
barweb(vals, errors,[],...
    {'Layer 1','Layer 2/3','Layer 4','Layer 5','Layer 6','CA1','CA2','CA3','Other'},...
    [],'Cortical layer / HC subfield','GluA2 lifetime (days)',...
    parula,[],unique(tbl_stats.groupName, 'stable'));
legend(unique(tbl_stats.groupName, 'stable'), 'NumColumns',2,'Location','northwest')
%%
figure(2)
clf
set(gcf,'Color','w')
set(gcf,'Position',[ 385         507        1075         470])
tbl_stats = grpstats(tbl_all3, {'groupName', 'new_names'}, {'mean', 'std'}, 'DataVars','tau');
vals = reshape(tbl_stats.mean_tau, 12,4);
errors = reshape(tbl_stats.std_tau, 12,4);
barweb(vals, errors,[],unique(tbl_stats.new_names, 'stable'),[],'Brain region',...
    'GluA2 lifetime (days)',...
    parula,[],unique(tbl_stats.groupName, 'stable'))
legend(unique(tbl_stats.groupName, 'stable'), 'NumColumns',2,'Location','northeast')

set(gcf,'Color','w')
%% AP
figure(3)
clf
set(gcf,'Color','w')
set(gcf,'Position',[ 385         44        462         913])
subplot(5,1,1)
l1 = tbl_all3.layer == 1;
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2 > 2,:);
tbl_stats = tbl_stats(tbl_stats.AP2 < 10,:);
vals = reshape(tbl_stats.mean_tau, 7,4);
errors = reshape(tbl_stats.std_tau, 7,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'Layer 1',[],...
    {'GluA2 lifetime' '(days)'},cool)

subplot(5,1,2)
l1 = tbl_all3.layer == 2;
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2 > 2,:);
tbl_stats = tbl_stats(tbl_stats.AP2 < 10,:);
vals = reshape(tbl_stats.mean_tau, 7,4);
errors = reshape(tbl_stats.std_tau, 7,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'Layer 2/3',[],...
    {'GluA2 lifetime' '(days)'},cool)
subplot(5,1,3)
l1 = tbl_all3.layer == 4;
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
vals = reshape(tbl_stats.mean_tau, 6,4);
errors = reshape(tbl_stats.std_tau, 6,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'Layer 4',[],...
    {'GluA2 lifetime' '(days)'},cool)
subplot(5,1,4)
l1 = tbl_all3.layer == 5;
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2 > 2,:);
tbl_stats = tbl_stats(tbl_stats.AP2 < 10,:);
vals = reshape(tbl_stats.mean_tau, 7,4);
errors = reshape(tbl_stats.std_tau, 7,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'Layer 5',[],...
    {'GluA2 lifetime' '(days)'},cool)
subplot(5,1,5)
l1 = tbl_all3.layer == 6;
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2 > 3,:);
tbl_stats = tbl_stats(tbl_stats.AP2 < 10,:);
vals = reshape(tbl_stats.mean_tau, 6,4);
errors = reshape(tbl_stats.std_tau,6,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'Layer 6','Group',...
    {'GluA2 lifetime' '(days)'},cool)
a = axes('position', [0.25 0.0 .5 .2], 'color', 'none', 'Visible','off');
cb = colorbar(a,"southoutside");
cb.Label.String = 'AP position';
cb.Ticks = [0,1];
cb.TickLabels = {'A','P'};
%% CA1_layers
figure(4)
clf
set(gcf,'Color','w')
set(gcf,'Position',[ 385         44        462         400])
l1 = contains(tbl_all3.Name, 'Field CA1,');
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'Name'}, {'mean', 'std'}, 'DataVars','tau');
vals = reshape(tbl_stats.mean_tau, 4,4);
errors = reshape(tbl_stats.std_tau, 4,4);
barweb(vals, errors,[],unique(tbl_stats.Name, 'stable'),[],[],...
    {'GluA2 lifetime' '(days)'},parula,[],unique(tbl_stats.groupName, 'stable'))
legend(unique(tbl_stats.Name, 'stable'), 'NumColumns',2,'Location','northoutside')
%%
figure(5)
clf
set(gcf,'Color','w')
l1 = contains(tbl_all3.Name,'CA1');
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'Name'}, {'mean', 'std'}, 'DataVars','tau');
vals = reshape(tbl_stats.mean_tau, 5,4);
errors = reshape(tbl_stats.std_tau, 5,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'CA1 layers','Group',...
    'GluA2 lifetime (days)', parula, [],    unique(tbl_stats.Name, 'stable'))
legend(unique(tbl_stats.Name, 'stable'), 'NumColumns',2,'Location','northeast')
%%
figure(6)

set(gcf,'Color','w')
set(gcf,'Position',[ 385         44        462         913])
subplot(4,1,1)
l1 = contains(tbl_all3.Name,'oriens');
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2 > 2,:);
tbl_stats = tbl_stats(tbl_stats.AP2 < 7,:);
vals = reshape(tbl_stats.mean_tau, 3,4);
errors = reshape(tbl_stats.std_tau, 3,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'oriens',[],...
    'GluA2 lifetime (days)',cool)
subplot(4,1,2)
l1 = contains(tbl_all3.Name,', pyramidal');
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2 < 7,:);
vals = reshape(tbl_stats.mean_tau, 3,4);
errors = reshape(tbl_stats.std_tau, 3,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'pyramidal',[],...
    'GluA2 lifetime (days)',cool)

subplot(4,1,3)
l1 = contains(tbl_all3.Name,', radiatum');
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2 > 2,:);
tbl_stats = tbl_stats(tbl_stats.AP2 < 7,:);
vals = reshape(tbl_stats.mean_tau, 3,4);
errors = reshape(tbl_stats.std_tau, 3,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'radiatum',[],...
    'GluA2 lifetime (days)',cool)
subplot(4,1,4)
l1 = contains(tbl_all3.Name,', slm');
tbl_l1 = tbl_all3(l1,:);
tbl_stats = grpstats(tbl_l1, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2 > 2,:);
tbl_stats = tbl_stats(tbl_stats.AP2< 7,:);
vals = reshape(tbl_stats.mean_tau, 3,4);
errors = reshape(tbl_stats.std_tau, 3,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'slm',[],...
    'GluA2 lifetime (days)',cool)

%% AP
figure(7)
set(gcf,'Color','w')
set(gcf,'Position',[ 385         44        462         400 ])
tbl_stats = grpstats(tbl_all3, {'groupName', 'AP2'}, {'mean', 'std'}, 'DataVars','tau');
tbl_stats = tbl_stats(tbl_stats.AP2< 11,:);
vals = reshape(tbl_stats.mean_tau, 10,4);
errors = reshape(tbl_stats.std_tau, 10,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'All regions',[],...
    'GluA2 lifetime (days)',cool)
cb = colorbar();
cb.Label.String = 'AP position';
cb.Ticks = [0,1];
cb.TickLabels = {'A','P'};
%% line
figure(7)
set(gcf,'Color','w')
set(gcf,'Position',[ 385         44        462         400 ])
tbl_stats = grpstats(tbl_all3, {'groupName', 'Line'}, {'mean', 'std'}, 'DataVars','tau');
vals = reshape(tbl_stats.mean_tau, 2,4);
errors = reshape(tbl_stats.std_tau, 2,4);
barweb(vals', errors',[],unique(tbl_stats.groupName, 'stable'),'All regions',[],...
    'GluA2 lifetime (days)',hot,[],{'Line 1','Line 4'})