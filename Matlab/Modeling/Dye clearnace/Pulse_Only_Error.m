%% Simulate error of pulse only exp
noise_levels = [.1, .2, .4, .8];
noise_levels = .1:.1:.8;

n_boot = 100;
animals = [1, 2, 4, 8];
res_all = zeros(length(noise_levels), length(animals), n_boot);
times = [0, 33, 100, 333];
for b = 1:n_boot
    fprintf('%d, ', b);
    if mod(n_boot, 10) == 0
        disp('');
    end
    for a = 1:length(animals)
        n_animal_per_time = animals(a);
        total_protein = ones(length(times), length(noise_levels), n_animal_per_time);
        noise = rand(size(total_protein)) .* noise_levels - noise_levels/2;
        protein_noise = total_protein + noise;
        protein_decay = protein_noise.*exp(-1./100.*times)';
        protein_decay_mean = mean(protein_decay, 3);
        parfor n = 1:length(noise_levels)
            ft = fittype( 'exp(-1/tau*x)', 'independent', 'x', 'dependent', 'y' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            opts.Display = 'Off';
            opts.StartPoint = 100;
            [fitresult, ~] = fit( times', protein_decay_mean(:,n), ft, opts );
            res_all(n, a, b) = fitresult.tau;
        end
    end
end
res_mean = mean(abs(100-res_all), 3);
res_mean = std(res_all, [],3);
f2 = figure(2);
clf;
f2.Units = 'centimeters';
f2.Position = [10,10,7,4];
f2.Color = 'w';

h = heatmap( animals.*4, noise_levels(end:-1:1)*100, flipud(res_mean))
r = linspace(244, 64, 50);
g = linspace(244, 148, 50);
b = linspace(244, 205, 50);
map = cat(1, r, g, b)
colormap(uint8(map)')

ylabel('CV')
xlabel('# animals used');
h.GridVisible = false;
h.CellLabelFormat= '%d';
h.FontName = 'Arial';
h.ColorLimits = [0,25];

exportgraphics(f2,'SuppNote_PulseOnlyError.pdf','ContentType','vector')





    %     cell_array = mat2cell(protein_decay_mean,  length(times),ones(1, length(noise_levels)));
%     cellfun
%%
% 
% 
% 
%     fprintf('animals: %d\n', n_animal_per_time)
%     res = zeros(length(noise_levels), n_boot);
%     for b = 1:n_boot
%         for n = 1:length(noise_levels)
%             noise_level = noise_levels(n);
%             noise = rand(length(times),n_animal_per_time)*noise_level - noise_level/2;
%             noise = noise.* perfect_p';
%             p_with_noise = repmat(perfect_p, n_animal_per_time,1)+noise';
%             
%             p_mean = mean(p_with_noise, 1);
%             [fitresult, ~] = fit( times', p_mean', ft, opts );
%             res(n, b) = fitresult.tau;
%         end
%     end
% %
%     
%     res_std = std(res, [], 2);
%     res_all(:, a) = res_std
% end
%%