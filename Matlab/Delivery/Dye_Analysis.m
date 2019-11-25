cd('E:\Dropbox (HHMI)\Projects\Unbised\Dye_delivery\NewAnalysis')
close all; clear;
%% list all animals
files = dir('Round*.mat');
files = {files.name};
% good_files = find(~cellfun(@isempty, regexp(files,'Round\d_ANM\d\d_')));
% files = files(good_files);
%%
plot_virus(files);
plot_log_k_lz(files);
plot_z(files);
plot_wavelength(files);
plot_GFP_Invivo(files);
%%

for i = 2:6%length(files)
   
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    fig1 = plotFraction(data);
    fig2 = plot_virus_pr(data);
    fig3 = plot_k(data);
    fig4 = plot_coronal(data);
    figname =  sprintf('Round%d_ANM%d',data.Round, data.ANM);
    export_fig([figname '_Fraction'], fig1, '-png');
    export_fig([figname '_virus_pr'], fig2, '-png');
    export_fig([figname '_k'], fig3, '-png');
    export_fig([figname '_coronal'], fig4, '-png');
    export_fig(figname, fig1, '-pdf');
    export_fig(figname, fig2, '-pdf', '-append');
    export_fig(figname, fig3, '-pdf', '-append');
    export_fig(figname, fig4, '-pdf', '-append');
    close all;
    
   
end
%%
    close()
    fig = figure();
    hax = [];
    virus = data.virus;
    index = virus > 200;
    hax(1) = plot_one(3, 1, data.x(index), data.y(index), ...
        data.z(index)*10+rand(length(data.z(index)),1)*10, ...
        data.virus_sub(index), 'virus');
    hax(2) = plot_one(3, 2, data.x(index), data.y(index), ...
        data.z(index)*10+rand(length(data.z(index)),1)*10, ...
        data.invivo_sub(index), sprintf('JF%d',data.invivo_dye));
    hax(3) = plot_one(3, 3, data.x(index), data.y(index), ...
        data.z(index)*10+rand(length(data.z(index)),1)*10, ...
        data.exvivo_sub(index), sprintf('JF%d',data.exvivo_dye));
   
    linkprop(hax, 'CameraPosition');
    
    

%%
virus = data.virus_sub;
index = virus > median(virus);
x = data.x(index);
y = data.y(index);
z = data.z(index);
z = z+rand(length(z), 1);
z = z*500;
v = data.fraction_sub(index);
plot_one(1, 1,x, y, z, v, 'fraction sub')
F = scatteredInterpolant(x, y, z, v);
F.Method = 'natural';
F.ExtrapolationMethod = 'none';
[xi, yi, zi] = meshgrid(linspace(min(x), max(x), 100), ...
    linspace(min(y), max(y), 100), ...
    linspace(min(z), max(z), 100));
vi = F(xi, yi, zi);
%%

figure()
xslice = linspace(min(x), max(x), 20); 
yslice = linspace(min(y), max(y), 20); 
zslice = linspace(min(z), max(z), 20); 
h = slice(xi,yi,zi,vi,xslice,yslice,zslice);
for i =1:length(h)
    h(i).EdgeAlpha = 0;
    h(i).FaceAlpha=0.1;
end
ax = gca();
ax.DataAspectRatio = [1, 1, 1];
ax.DataAspectRatioMode = 'manual';
ax.PlotBoxAspectRatio = [1, 1, 1];
ax.PlotBoxAspectRatioMode = 'manual'
ax.Box = 'off';