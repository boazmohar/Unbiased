%% Lifetime

Min_lifetime = 2;
Max_lifetime = 200;
num_lifetime = 50;
spacing = 0;
if spacing == 1
    lifetimes = linspace(Min_lifetime, Max_lifetime, num_lifetime)'
else
    lifetimes = logspace(log10(Min_lifetime), log10(Max_lifetime), num_lifetime)'
end
%% Signal

bg = 100;
Min_photons = 100;
Max_photons = 1000;
num_photons = 50;

spacing = 1;
if spacing == 1
    photons = linspace(Min_photons, Max_photons, num_photons)'
else
    photons = logspace(log10(Min_photons), log10(Max_photons), num_photons)'
end
%% calculate photon decay


%%
% t_start = 0;
% t_step = 0.1;
% t_end = 200;
% t = t_start:t_step:t_end;
t = [5, 10, 20];


% Fit model to data.

Pulse = zeros(num_lifetime, length(t));
Chase = zeros(num_lifetime, length(t));

for i = 1:num_lifetime
    Pulse(i,:) = exp(-1./lifetimes(i) .* t) ;
    Chase(i,:) = 1 - Pulse(i,:);
end
runs = 300;
error_pulse = zeros(runs, num_photons, num_lifetime);
error_fp = zeros(runs, num_photons, num_lifetime);
parfor b = 1:runs
    warning('off','all')
    ft = fittype( 'exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
    ft2 = fittype( 'b*exp(-1/a*x)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0];
%     opts.StartPoint = [1];
    opts2 = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts2.Display = 'Off';
    opts2.Lower = [0, -1000];
%     opts2.StartPoint = [1, 1];
    if mod(b,10) == 0
        disp(b)
    end
    for po = 1:num_photons
        Pulse_sim = random('Poisson', Pulse .* photons(po)+ bg) - bg+rand(1,1);
        Chase_sim = random('Poisson', Chase .* photons(po)+ bg) - bg+rand(1,1);

        FP = Pulse_sim ./ (Pulse_sim + Chase_sim);
        for i = 1:num_lifetime
            l = lifetimes(i);
            currnet = Pulse_sim(i,:)';
%             currnet = currnet ./ currnet(1);
           
                r_pulse = fit( t', currnet, ft2, opts2 );
                r_fp = fit( t', FP(i,:)', ft, opts );
                a_pulse = r_pulse.a;
                a_fp = r_fp.a;
            
            error_pulse(b, po, i) =  ((a_pulse - l) / l)*100 ;
            error_fp(b, po, i) =  ((a_fp - l) ./ l) *100;
        end
    end
end
%%
save('bootstrap_shotnoise_v2.mat',"error_fp", "error_pulse", '-v7.3')
%%

error_fp_mean = squeeze(median(error_fp,1, 'omitnan'));
error_pulse_mean = squeeze(median(error_pulse, 1, 'omitnan'));
%%
figure(1)
clf
cmax = min(min(error_fp_mean, error_pulse_mean),[],"all")
subplot(2,1,1)
heatmap(error_fp_mean)
c= colormap('jet');
colormap(flipud(c))
clim([ cmax 0])
ax = gca;
ax.YDisplayLabels = cellstr(num2str(photons./bg, 3));
ax.XDisplayLabels = cellstr(num2str(lifetimes, 3));
title('Pulse-Chase error')
ylabel('SNR')
subplot(2,1,2)
heatmap(error_pulse_mean)

colormap(flipud(c))
clim([ cmax 0])
ax = gca;
ax.YDisplayLabels = cellstr(num2str(photons./bg, 3));
ax.XDisplayLabels = cellstr(num2str(lifetimes, 3));
title('Pulse only error')
ylabel('SNR')
xlabel('Lifetime (days)')
%%
figure(2)
clf
d = error_pulse_mean-error_fp_mean;
heatmap(d)
colormap('parula')
ax = gca;
ax.YDisplayLabels = cellstr(num2str(photons./bg, 3));
ax.XDisplayLabels = cellstr(num2str(lifetimes, 3));
% clim([0,max(d, [], "all", "omitnan")])
title('Pulse-Chase Error difference' )

ylabel('SNR');
xlabel('Lifetime (days)');
%%
figure(3)
clf
snr  =photons./bg;
d_mean = mean(d,2);
d_std = std(d, [], 2);
errorbar(snr,d_mean, d_std)
%%
figure(4)
clf
errorbar(snr, mean(error_pulse_mean, 2),std(error_pulse_mean, [],2, "omitnan"));
hold on
errorbar(snr, mean(error_fp_mean,2, "omitnan"),std(error_fp_mean, [], 2, "omitnan"));
legend({'Pulse only','Chase-Pulse'})
ylabel('Error (%)');
xlabel('SNR')
%%
save('Shotnoise_v3.mat', '-v7.3')
%%
f= figure(5);
f.Color = 'w';
f.Units = 'Centimeters';
f.Position = [5, 5, 18, 7];
cmax=-80;
colorbar()
clf
img = error_fp_mean;
img2 = imgaussfilt(imresize(img, 8, "bilinear"), 12);
colormap("turbo")
subplot(1,2,1)
imshow(img2, [ cmax 0]);
axis on;
box off
xticks([1,200,400]);
xticklabels({num2str(Min_lifetime), '20', num2str(Max_lifetime)});
xlabel('Lifetime (days)')
yticks([1,200,400]);
yticklabels({num2str(snr(1)), '5', num2str(snr(end))});
ylabel('Signal/Background')
title('Pulse+Chase')
img = error_pulse_mean;
img2 = imgaussfilt(imresize(img, 8, "bilinear"), 12);
c = colorbar();
% c.Label.String = 'Error (%)';

for i = 1:length(t)
    if i == 3
        xline(t(i)*8, 'g:','Measurement times', 'LineWidth',2)
    else
        xline(t(i)*8, 'g:', 'LineWidth',2)
    end
end
subplot(1,2,2)
imshow(img2, [cmax, 0]);
c = colormap("turbo");
colormap(flipud(c))
c = colorbar();
c.Label.String = 'Error (%)';
axis on;
box off
xticks([1,200,400]);
xticklabels({num2str(Min_lifetime), '20', num2str(Max_lifetime)});
xlabel('Lifetime (days)')
yticks([1,200,400]);
yticklabels({num2str(snr(1)), '5', num2str(snr(end))});
% ylabel('SNR')
title('Pulse only')
xline(t*8, 'g:', 'LineWidth',2)

print('shotnoise.eps', '-depsc2');