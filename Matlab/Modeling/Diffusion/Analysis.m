close all;
clc;
clear;
rates = linspace(2, 10, 20);
widths = [];
for i = 1:length(rates)
    widths(i) = Diffusion_1D_BM_fun(rates(i), 0, 0);
end
f=figure()
f.Units = 'centimeters';
f.Position = [10, 20, 6, 6];
f.Color = 'w';
plot(rates, widths, '-*')
xlabel('Injecation rate (AU/dt)');
text(6,260,{'Constant clearance' 'rate 1AU/dt'}, 'fontsize',8)
ylabel('Dye saturation width (dx)');
title('1D diffusion model')
ax=gca();
ax.FontSize=8;
box off
% saveas(f,'Model.eps');
%%
 Diffusion_1D_BM_fun(2, 1, 1);
 
 %%
 Diffusion_1D_BM_fun(5, 1, 1);