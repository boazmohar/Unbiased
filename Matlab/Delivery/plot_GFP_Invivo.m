function plot_GFP_Invivo(files)
close all
for i = 1:length(files)
    file = files{i};
    data = load(file, 'current');
    data = data.current;
    if data.invivo_dye == 552 
        fig1 = figure(1);
    elseif data.invivo_dye == 669
        fig2 = figure(2);
    else
        continue
    end
    x = nanmedian(data.fraction_sub);
    y = nanmedian(data.invivo_sub) ./ ...
        nanmedian(data.virus_sub);
    hold on;
    plot(x, y , '*', 'DisplayName', sprintf('%d:R%d,ANM%d,%s,%s', ...
        i, data.Round, data.ANM, data.dye_name, data.cond))
    hold on;
    text(x,y+0.02, sprintf('%d', i))
    xlabel('Fraction in-vivo')
    ylabel('In-vivo / GFP')
    title(sprintf('JF%d-HTL', data.invivo_dye))
    
end
figure(1)
legend('Location','southeast');
saveas(fig1, 'GFP_vs_fraction_552.png')
 figure(2)
legend('Location','southeast');

saveas(fig2, 'GFP_vs_fraction_669.png')
