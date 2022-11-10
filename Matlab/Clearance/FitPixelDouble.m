function [data_a, data_b, data_c, data_d, data_e] = FitPixelDouble(imageSize, ...
    groupNumber, registered, x, BW, fit_res, offset)
if nargin < 7
    offset = 1;
end
newSize = [imageSize(1)/2, imageSize(2)/2];
data_ds = zeros(newSize(1), newSize(2), groupNumber-1);
for i = 1:groupNumber-1
    current = squeeze(registered( :, :, i+1) - registered( :, :, 1)) .* BW;
    data_ds(:, :, i) = imresize(current,0.5);
end
%%
ft = fittype( 'a*exp(-1/b*x)+ c+ d*exp(-1/e*x)', 'independent', 'x', 'dependent', 'y' );
data_a = zeros(newSize(1), newSize(2));
data_b = zeros(newSize(1), newSize(2));
data_c = zeros(newSize(1), newSize(2));
data_d = zeros(newSize(1), newSize(2));
data_e = zeros(newSize(1), newSize(2));
fprintf('a=%.1f, b=%.1f, c=%.1f, d=%.1f, e=%.1f', ...
    fit_res.a, fit_res.b, fit_res.c, fit_res.d, fit_res.e);
a = fit_res.a;
b = fit_res.b;
c = fit_res.c;
d = fit_res.d;
e = fit_res.e;
pp = ParforProgress;
size_i = newSize(1);
size_j = newSize(2);
parfor i = 1:size_i
    for j = 1:size_j
        current = squeeze(data_ds(i, j, offset-1:end));
        if sum(current) < 10 || sum(isnan(current))
            continue
        end
        [temp, ~] = fit( x,current, ft,...
            'Display','Off' ,...
            'Lower',[0 0 -200 0 0],...
            'Upper',[500000 50000 200 50000 50000],...
            'StartPoint',[a b c d e]);
        data_a(i, j) = temp.a;
        data_b(i, j) = temp.b;
        data_c(i, j) = temp.c;
        data_d(i, j) = temp.d;
        data_e(i, j) = temp.e;
    end
    fprintf('Finished iteration %d of %d\n', step(pp, i), size_i);
end