%%
n_boot = 32;
f=figure(3);
clf;
% tbl12 = [tbl1 ; tbl2];
f.Units = "centimeters";
f.Position = [8, 8, 15, 15];
f.Color='w';
ax1 =subplot(2,2,1);
tbl_pair = pairwise_compare(tbl_all, 'n_boot', n_boot, 'name1', 1, 'name2', 4,...
    'groupName',"Line", 'is_string',false, 'threshold_entries',8 );
p_all2 = tbl_pair.p;
p_all2(p_all2==0) = 0.0000001;
gscatter(tbl_pair.ratio*100-100, -log10(p_all2),tbl_pair.new_names, [], [], 20);
box off
legend off
xlabel('Line 1 vs. 4')
ylabel('-log_{10} p')

%%
ax2= subplot(2,2,2);
tbl_pair = pairwise_compare(tbl_all, 'n_boot', n_boot, 'name1', "male", 'name2', "female",...
    'groupName',"Sex", 'is_string',true, 'threshold_entries',8);
p_all2 = tbl_pair.p;
p_all2(p_all2==0) = 0.0000001;
gscatter(tbl_pair.ratio*100-100, -log10(p_all2),tbl_pair.new_names, [], [], 20);
xlabel('M vs. F')
ylabel('-log_{10} p')
box off
legend off
%%
ax3 = subplot(2,2,3);
tbl_pair = pairwise_compare(tbl_all, 'n_boot', n_boot, 'name1', "rule", 'name2', "random",...
    'groupName',"groupName", 'is_string',true);
p_all2 = tbl_pair.p;
p_all2(p_all2==0) = 1e-15;
p_all2(p_all2<1e-25) =1e-25;
gscatter(tbl_pair.ratio*100-100, -log10(p_all2),tbl_pair.new_names, [], [], 20);
% l = legend();
% l.NumColumns = 2;
% l.Location = 'north';
box off
legend off
xlabel('Rule vs. Random')
ylabel('-log_{10} p')
%%

ax4 = subplot(2,2,4);
tbl_pair = pairwise_compare(tbl_all, 'n_boot', n_boot, 'name1', ["rule", "Random"],...
    'name2', "control", 'groupName',"groupName", 'is_string',true,...
    'threshold_entries',8);
p_all2 = tbl_pair.p;
p_all2(p_all2==0) = 0.0000001;
gscatter(tbl_pair.ratio*100-100, -log10(p_all2),tbl_pair.new_names, [], [], 20);
% l = legend();
% l.NumColumns = 2;
% l.Location = 'north';
box off
legend off
xlabel('Task vs. Control')
ylabel('-log_{10} p')

%%
linkaxes([ax1,ax2,ax3, ax4],'xy')
%%
figure(2)
clf
tbl_pair = pairwise_compare(tbl_all, 'n_boot', n_boot, 'name1', "random", ...
    'name2', "control", 'groupName',"groupName", 'is_string',true, 'threshold_entries',4);
p_all2 = tbl_pair.p;
p_all2(p_all2==0) = 0.0000001;
gscatter(tbl_pair.ratio*100-100, -log10(p_all2),tbl_pair.new_names, [], [], 20);
box off
legend off
xlabel('Random vs. Control')
ylabel('-log_{10} p')