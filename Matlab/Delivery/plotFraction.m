function  fig = plotFraction(data)
    virus = data.virus_sub;
    index = virus > median(virus);
    bins = linspace(-0.5, 1.5, 201);
    fig = figure();
    subplot(2,1,1)
    histogram(data.fraction(index), bins);
    title(sprintf('Round:%d, ANM:%d, dye:JF%d, cond:%s', data.Round, data.ANM,...
        data.invivo_dye, data.cond))
    ylabel '# cells'
    xlabel 'Fraction in-vivo'
    set(gca, 'YScale', 'log')
    subplot(2,1,2)
    histogram(data.fraction_sub(index), bins);
    title(sprintf('Round:%d, ANM:%d, dye:JF%d, cond:%s bg', data.Round, data.ANM,...
        data.invivo_dye, data.cond))
    ylabel '# cells'
    xlabel 'Fraction in-vivo'
    set(gca, 'YScale', 'log')
%     saveas(fig, sprintf('Round%d_ANM%d_Hist.png',data.Round, data.ANM))

end
