function [rawPulse,rawChase] = get_masked_data(name)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
mask_name = [name(1:end-4) '_Probabilities.tif'];
mask = imread(mask_name);
t = 128; % 0-256 mask that was exported from ilastik to segment tissue 
bin_mask = uint16(mask > t);
try % different export software from slide scanner makes different names
    pulse_name = [name(1:end-4) '_CY5.tiff'];
    chase_name = [name(1:end-4) '_CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
catch
    pulse_name = [name(1:end-4) '-CY5.tiff'];
    chase_name = [name(1:end-4) '-CY3.tiff'];
    rawPulse = imread(pulse_name);
    rawChase = imread(chase_name);
end
raw_size = size(rawPulse);
bin_mask2 = single(imresize(bin_mask,raw_size(1:2), 'nearest'));
rawPulse = single(rawPulse) .* bin_mask2;
rawPulse(rawPulse==0) = nan;
rawChase = single(rawChase).* bin_mask2;
rawChase(rawChase==0) = nan;
end