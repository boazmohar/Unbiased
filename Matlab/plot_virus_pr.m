function f = plot_virus_pr(data)
%plot_virus_pr plots
%   Detailed explanation goes here
virus = data.virus_sub;
th2 =linspace(10, 90,9);
ths = prctile(virus, th2);
fractions_mean = zeros(1, length(ths));
fractions_std = zeros(1, length(ths));
fractions_n = zeros(1, length(ths));
for i = 1:length(ths)
    index = virus > ths(i);
    fractions_mean(i) = nanmedian(data.fraction_sub(index));
    fractions_std(i) = nanstd(data.fraction_sub(index));
    fractions_n(i) = sum(isfinite(data.fraction_sub(index)));
end
f=figure(2);
clf;
errorbar(th2, fractions_mean, fractions_std./fractions_n.^.5)
xlim([5, 95])
% ylim([0, 1]);
xlabel('virus percentile cutoff');
ylabel('Fracrtion in-vivo (mean +- se)');
title(sprintf('Round:%d, ANM:%d, Dye: %s',data.Round, data.ANM,...
    data.dye_name));
% saveas(f, sprintf('Round%d_ANM%d_virus_ths.png',data.Round, data.ANM))
end

