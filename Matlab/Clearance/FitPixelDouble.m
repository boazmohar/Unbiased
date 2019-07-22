function [data_a, data_b, data_c, data_d, data_e] = FitPixelDouble(imageSize, ...
    groupNumber, aligned, x, BW, fit_res)
newSize = [imageSize(1)/2, imageSize(2)/2];
data_ds = zeros(newSize(1), newSize(2), groupNumber);
for i = 1:groupNumber
    current = squeeze(aligned( :, :, i+1) - aligned( :, :, 1)) .* BW;
    data_ds(:, :, i) = imresize(current,0.5);
end
%%
ft = fittype( 'a*exp(-1/b*x)+ c+ d*exp(-1/e*x)', 'independent', 'x', 'dependent', 'y' );
data_a = zeros(newSize(1), newSize(2));
data_b = zeros(newSize(1), newSize(2));
data_c = zeros(newSize(1), newSize(2));
data_d = zeros(newSize(1), newSize(2));
data_e = zeros(newSize(1), newSize(2));
a = fit_res.a
b = fit_res.b
c = fit_res.c
d = fit_res.d
e = fit_res.e
size2 = newSize(2);
parfor i = 1:newSize(1)
    for j = 1:size2
        current = squeeze(data_ds(i, j, :));
        if sum(current) == 0 || sum(isnan(current))
            continue
        end
        [temp, ~] = fit( x,current, ft,...
            'Display','Off' ,...
            'Lower',[0 0 -200 0 0],...
            'Upper',[100000 10000 200 10000 10000],...
            'StartPoint',[a b c d e]);
        data_a(i, j) = temp.a;
        data_b(i, j) = temp.b;
        data_c(i, j) = temp.c;
        data_d(i, j) = temp.d;
        data_e(i, j) = temp.e;
    end
    disp([i, data_b(i, j), data_e(i, j)]);
end