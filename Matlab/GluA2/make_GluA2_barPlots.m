function make_GluA2_barPlots(tbl_all3, index)
%% Brain Regions 
G_region = groupsummary(tbl_all3,"new_names",@(x,y,z) tau_values(x, y, z, 10000),...
    {["tau_values"],["groupName"],["ANM"]});
G_region.means = cellfun(@(x) x.Coefficients.Estimate, G_region.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false);
G_region.SE = cellfun(@(x) x.Coefficients.SE, G_region.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false);
%% Brain Regions plot
output_folder = 'D:\OneDrive - Howard Hughes Medical Institute\DELTA_submissions\Nature Neuroscience\NN_Revision\';
means = cat(2, G_region.means{:});
SEs = cat(2, G_region.SE{:});
names = G_region.new_names;
f =  GluA2_barPlots(1,names(index), means(:,index)', SEs(:,index)', [2.1535 ,3.1663 ]);

% Use region indices
selectedMeans = means(:, index);     % 4 x N_selected
selectedSEs = SEs(:, index);         % 4 x N_selected
selectedNames = names(index);        % 1 x N_selected

% Define condition labels
conditionLabels = {'Control','EE','Baseline','NewRule'};
numConditions = length(conditionLabels);
numRegions = numel(selectedNames);

% Build table components
Region = repmat(selectedNames(:)', numConditions, 1);  % 4 x N_selected
Region = Region(:);                                    % column vector

Condition = repmat(conditionLabels', numRegions, 1);   % 4 x N_selected
Condition = Condition(:);                              % column vector

Mean = selectedMeans(:);   % 4*N_selected x 1
SE = selectedSEs(:);       % 4*N_selected x 1

% Assemble table
tbl1 = table(Region, Condition, Mean, SE);
tblName = [output_folder 'regions_tbl.csv'];
writetable(tbl1, tblName, "FileType","text")
xlim([3,6.5])
figname = 'regions_newCalib.png';
set(gcf, 'PaperPositionMode', 'auto');
tightfig(f);
exportgraphics(f, [output_folder figname], 'Resolution', 600, 'BackgroundColor', 'w', 'ContentType', 'image');
%% Layers
tbl_layer = tbl_all3(tbl_all3.layer>0,:);
CCF_ids = [382001, 382002, 382003, 382004];
% Exclude rows with specified CCF IDs
tbl_layer2 = tbl_layer(~ismember(tbl_layer.CCF_ID, CCF_ids), :);
G_layer = groupsummary(tbl_layer2,"layer",@(x,y,z) tau_values(x, y, z, 1000),...
    {["tau_values"],["groupName"],["ANM"]});
G_layer.means = cellfun(@(x) x.Coefficients.Estimate, G_layer.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
G_layer.SE = cellfun(@(x) x.Coefficients.SE, G_layer.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
%% Layers plot
means = cat(2, G_layer.means{:});
SEs = cat(2, G_layer.SE{:});
names ={'Layer 1','Layer 2/3','Layer 4','Layer 5','Layer 6','HC CA1','HC CA2','HC CA3'};
f = GluA2_barPlots(2,names, means', SEs', [2.1112  ,2.376 ]);
figname = 'layers_newCalib.png';
set(gcf, 'PaperPositionMode', 'auto');

xlim([3,6.5])
tightfig(f);
exportgraphics(f, [output_folder figname], 'Resolution', 600, 'BackgroundColor', 'w', 'ContentType', 'image');
% Use region indices
selectedMeans = means;     % 4 x N_selected
selectedSEs = SEs;         % 4 x N_selected
selectedNames = names;        % 1 x N_selected

% Define condition labels
conditionLabels = {'Control','EE','Baseline','NewRule'};
numConditions = length(conditionLabels);
numRegions = numel(selectedNames);

% Build table components
Region = repmat(selectedNames(:)', numConditions, 1);  % 4 x N_selected
Region = Region(:);                                    % column vector

Condition = repmat(conditionLabels', numRegions, 1);   % 4 x N_selected
Condition = Condition(:);                              % column vector

Mean = selectedMeans(:);   % 4*N_selected x 1
SE = selectedSEs(:);       % 4*N_selected x 1

% Assemble table
tbl2 = table(Region, Condition, Mean, SE);
tblName = [output_folder 'layer_tbl.csv'];
writetable(tbl2, tblName, "FileType","text")
%% CA1
l1 = contains(tbl_all3.Name, 'Field CA1,');
tbl_l1 = tbl_all3(l1,:);
G_CA1 = groupsummary(tbl_l1,"Name",@(x,y,z) tau_values(x, y, z, 1000),...
    {["tau_values"],["groupName"],["ANM"]});
G_CA1.means = cellfun(@(x) x.Coefficients.Estimate, G_CA1.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
G_CA1.SE = cellfun(@(x) x.Coefficients.SE, G_CA1.fun1_tau_values_groupName_ANM,...
    "UniformOutput",false)
%% CA1 plot
means = cat(2, G_CA1.means{:});
SEs = cat(2, G_CA1.SE{:});
names ={{'CA1','oriens'},{'CA1','pyramidal'},{'CA1','radiatum'},{'CA1','slm'}};
f = GluA2_barPlots(3, [' ',' ',' ',' '], means', SEs', [1.6908   ,2.1747  ]);
figname = 'CA1_newCalib_large.png';
set(gcf, 'PaperPositionMode', 'auto');
ax = gca;
ax.YTickLabels = {'                  '};
for i = 1:numel(names)
    text( 2.5, i-0.29, names{i}, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Rotation', 0, 'FontSize', 6);
end
xlim([3,10.5])
tightfig(f);
% exportgraphics(f, [output_folder figname], 'Resolution', 600, 'BackgroundColor', 'w', 'ContentType', 'image');
 exportgraphics(f, [output_folder figname], 'Resolution', 2400, 'BackgroundColor', 'w', 'ContentType', 'image');

 selectedMeans = means;     % 4 x N_selected
selectedSEs = SEs;         % 4 x N_selected
selectedNames = {{'CA1 oriens'},{'CA1 pyramidal'},{'CA1 radiatum'},{'CA1 slm'}};  % 1 x N_selected

% Define condition labels
conditionLabels = {'Control','EE','Baseline','NewRule'};
numConditions = length(conditionLabels);
numRegions = numel(selectedNames);

% Build table components
Region = repmat(selectedNames(:)', numConditions, 1);  % 4 x N_selected
Region = Region(:);                                    % column vector

Condition = repmat(conditionLabels', numRegions, 1);   % 4 x N_selected
Condition = Condition(:);                              % column vector

Mean = selectedMeans(:);   % 4*N_selected x 1
SE = selectedSEs(:);       % 4*N_selected x 1

% Assemble table
tbl3 = table(Region, Condition, Mean, SE);
tblName = [output_folder 'HC_tbl.csv'];
writetable(tbl3, tblName, "FileType","text")
 %% Region diff plot 
means = cat(2, G_region.means{:});
SEs = cat(2, G_region.SE{:});
rations = [ means(1,:) ./ means(2,:) ; means(3,:) ./ means(4,:)] * 100 - 100;
rations = rations(:,index);
SE2 = [SEs(1,:) ./ means(1,:); SEs(3,:) ./ means(3,:)];
SE2 = SE2(:,index) * 100;
names = G_region.new_names(index);
names{1} = 'HC';
f = GluA2_barPlots_diff(4, names,rations', SE2', [2.1, 1.7833  ]);
figname = 'Region_diff_newCalib.png';
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(f, [output_folder figname], 'Resolution', 600, 'BackgroundColor', 'w', 'ContentType', 'image');

 selectedMeans = rations;     % 4 x N_selected
selectedSEs = SE2;         % 4 x N_selected
selectedNames = names;  % 1 x N_selected

% Define condition labels
conditionLabels = {'Control vs EE','Baseline vs. NewRule'};
numConditions = length(conditionLabels);
numRegions = numel(selectedNames);

% Build table components
Region = repmat(selectedNames(:)', numConditions, 1);  % 4 x N_selected
Region = Region(:);                                    % column vector

Condition = repmat(conditionLabels', numRegions, 1);   % 4 x N_selected
Condition = Condition(:);                              % column vector

Mean = selectedMeans(:);   % 4*N_selected x 1
SE = selectedSEs(:);       % 4*N_selected x 1

% Assemble table
tbl4 = table(Region, Condition, Mean, SE);
tblName = [output_folder 'RegionDiff_tbl.csv'];
writetable(tbl4, tblName, "FileType","text")
%% Layer diff plot
means = cat(2, G_layer.means{:});
SEs = cat(2, G_layer.SE{:});
rations = [ means(1,:) ./ means(2,:) ; means(3,:) ./ means(4,:)] * 100 - 100;
SEs = [SEs(1,:) ./ means(1,:) ; ...
    SEs(3,:) ./ means(3,:) ]*100;
names ={'Layer 1','Layer 2/3','Layer 4','Layer 5','Layer 6','HC CA1','HC CA2','HC CA3'};
f = GluA2_barPlots_diff(5, names,rations', SEs', [2.1, 1.7833  ]);
figname = 'Layer_diff_newCalib.png';
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(f, [output_folder figname], 'Resolution', 600, 'BackgroundColor', 'w', 'ContentType', 'image');
 selectedMeans = rations;     % 4 x N_selected
selectedSEs = SEs;         % 4 x N_selected
selectedNames = names;  % 1 x N_selected

% Define condition labels
conditionLabels = {'Control vs EE','Baseline vs. NewRule'};
numConditions = length(conditionLabels);
numRegions = numel(selectedNames);

% Build table components
Region = repmat(selectedNames(:)', numConditions, 1);  % 4 x N_selected
Region = Region(:);                                    % column vector

Condition = repmat(conditionLabels', numRegions, 1);   % 4 x N_selected
Condition = Condition(:);                              % column vector

Mean = selectedMeans(:);   % 4*N_selected x 1
SE = selectedSEs(:);       % 4*N_selected x 1

% Assemble table
tbl5 = table(Region, Condition, Mean, SE);
tblName = [output_folder 'LayerDiff_tbl.csv'];
writetable(tbl5, tblName, "FileType","text")

%% CA1 diff plot
means = cat(2, G_CA1.means{:});
SEs = cat(2, G_CA1.SE{:});
rations = [ means(1,:) ./ means(2,:) ; means(3,:) ./ means(4,:)] * 100 - 100;
SEs = [SEs(1,:) ./ means(1,:) ; ...
    SEs(3,:) ./ means(3,:) ]*100;
names ={{'CA1','oriens'},{'CA1','pyramidal'},{'CA1','radiatum'},{'CA1','slm'}};
f = GluA2_barPlots_diff(6, [' ',' ',' ',' '],rations', SEs', [1.7468 , 1.6833  ]);
figname = 'CA1_diff_newCalib.png';
set(gcf, 'PaperPositionMode', 'auto');
ax = gca;
ax.XTickLabels = {'                  '};
for i = 1:numel(names)
    text(i-.30, -0.5, names{i}, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Rotation', 90, 'FontSize', 6);
end
yticks([0,15,30,45,60])
tightfig(f);
exportgraphics(f, [output_folder figname], 'Resolution', 2400, 'BackgroundColor', 'w', 'ContentType', 'image');
 selectedMeans = rations;     % 4 x N_selected
selectedSEs = SEs;         % 4 x N_selected
selectedNames = {{'CA1 oriens'},{'CA1 pyramidal'},{'CA1 radiatum'},{'CA1 slm'}};  % 1 x N_selected

% Define condition labels
conditionLabels = {'Control vs EE','Baseline vs. NewRule'};
numConditions = length(conditionLabels);
numRegions = numel(selectedNames);

% Build table components
Region = repmat(selectedNames(:)', numConditions, 1);  % 4 x N_selected
Region = Region(:);                                    % column vector

Condition = repmat(conditionLabels', numRegions, 1);   % 4 x N_selected
Condition = Condition(:);                              % column vector

Mean = selectedMeans(:);   % 4*N_selected x 1
SE = selectedSEs(:);       % 4*N_selected x 1

% Assemble table
tbl6 = table(Region, Condition, Mean, SE);
tblName = [output_folder 'HCDiff_tbl.csv'];
writetable(tbl6, tblName, "FileType","text")