function im_frec = getFractionFromImage3D(im, sum_chs, fraction_chs, name)
%% im_frec = getFractionFromImage3D(im, sum_chs, fraction_chs, name)
% im: image x by y by channel
% sum_chs: single int (or list of ints) index of the channels to sum
% fraction_chs: single int (or list of ints) index of the channels to use for fraction
% name: file name if want to save as tif.
% pulse_frec: the image converted to fraction pulse (pulse / sum of pulse
% and chase
%% input things
if nargin < 3
    name = '';
end
im = single(im);
%% get the sum and pulse image
sum_image = sum(im(:, :, sum_chs), 3);
if length(fraction_chs) > 1
    pulse_im = sum(im(:, :, fraction_chs), 3);
else
    pulse_im = squeeze(im(:,:,fraction_chs));
end
sum_image(sum_image<0) = 0;
pulse_im(pulse_im<0) = 0;
im_frec = pulse_im ./ sum_image;
im_frec(im_frec > 2) = 2;
im_frec(sum_image < 30) = nan;
%% save to tif
if ~isempty(name)
    saveastiff(im_frec, name);
end