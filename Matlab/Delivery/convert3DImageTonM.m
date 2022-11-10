function im_out  = convert3DImageTonM(im, chs, configuration, name)
%% im_out  = convert3DImageTonM(im, chs, configuration, name)
% im: image x by y by channel
% chs: JF dye list in integers to get from calibration dict
% configuration: which calibration to take (string)
% name: file name if want to save as tif.
% im_out: the image converted to nM dye
%% deal with inputs
if nargin < 4
    name = '';
end
sz = size(im);
fprintf('Image shape: %d x %d x %d, calibration used: %s\n', ...
    sz(1), sz(2), sz(3),configuration);
assert(sz(3) == length(chs),'Wrong inputs check chs and image size (3)')
%% get calibration and convert to nM dye
im_out = single(im);
[Slope, Blank] = getCalibration(configuration);
for c = 1:length(chs)
    ch = chs(c);
    current = single(squeeze(im(:,:,c))) - Blank(ch);
    current = current ./ Slope(ch);
    im_out(:,:,c) = current;
end
im_out = im_out .* 1000;
%% save to tif
if ~isempty(name)
    saveastiff(im_out, name);
end