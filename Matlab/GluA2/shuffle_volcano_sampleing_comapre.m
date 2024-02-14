%%
tbl3 = pairwise_compare_shuffleGroup(tbl_all, 'subsample', "uniform");
f=figure(1);
clf;
f.Units = "centimeters";
f.Position = [8, 8, 12, 8];
f.Color='w';
p_all2 = tbl3.p;
p_all2(p_all2==0) = 1/5000;
gscatter(tbl3.ratio*100-100, -log10(p_all2),tbl3.new_names, [], [], 20);
l = legend();
l.NumColumns = 2;
l.Location = 'north';
box off
xlabel({'% Change' 'Random vs Rule'})
ylabel('-log_{10} p')
title('Uniform')
%%
tbl4 = pairwise_compare_shuffleGroup(tbl_all, 'subsample', "random");
f=figure(2);
clf;
f.Units = "centimeters";
f.Position = [8, 8, 12, 8];
f.Color='w';
p_all2 = tbl4.p;
p_all2(p_all2==0) = 1/5000;
gscatter(tbl4.ratio*100-100, -log10(p_all2),tbl4.new_names, [], [], 20);
l = legend();
l.NumColumns = 2;
l.Location = 'north';
box off
xlabel({'% Change' 'Random vs Rule'})
ylabel('-log_{10} p')
title('random')
%%
tbl5 = pairwise_compare_shuffleGroup(tbl_all, 'subsample', "first");
f=figure(3);
clf;
f.Units = "centimeters";
f.Position = [8, 8, 12, 8];
f.Color='w';
p_all2 = tbl5.p;
p_all2(p_all2==0) = 1/5000;
gscatter(tbl5.ratio*100-100, -log10(p_all2),tbl5.new_names, [], [], 20);
l = legend();
l.NumColumns = 2;
l.Location = 'north';
box off
xlabel({'% Change' 'Random vs Rule'})
ylabel('-log_{10} p')
title('first')