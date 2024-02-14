%% example layer 4 
cd('V:\moharb\GluA2\GluA2_round5');
name = 'Slide 1 from cassette 2-Region 002.png';
png = imread(name);
pulse_name = [name(1:end-4) '-CY5.tiff'];
chase_name = [name(1:end-4) '-CY3.tiff'];
dapi_name = [name(1:end-4) '-DAPI.tiff'];
rawPulse = imread(pulse_name);
rawChase = imread(chase_name);
rawDAPI = imread(dapi_name);
mask_name = [name(1:end-4) '_Probabilities.tif'];
mask = imread(mask_name);
t = 128;
bin_mask = uint16(mask > t);
raw_size = size(rawPulse);
bin_mask2 = single(imresize(bin_mask,raw_size(1:2), 'nearest'));

rawPulse = single(rawPulse) .* bin_mask2;
rawPulse(rawPulse==0) = nan;
rawChase = single(rawChase).* bin_mask2;
rawChase(rawChase==0) = nan;
rawDAPI = single(rawDAPI).* bin_mask2;
rawDAPI(rawDAPI==0) = nan;
%%
[Calibration, Blank] = getCalibration('10x_SlideScanner');
p = (rawPulse - Blank(673)) ./ Calibration(673);
c = (rawChase -  Blank(552)) ./  Calibration(552);
s = p+c;
f = p./s;
tau = abs(3./log(1./f));
%%
figure(1)
clf
ylim1 = [2259.2       3867.5];
xlim1 = [ 314.68         2478];
subplot(2,2,1);
imshow(rawDAPI',[200,1500])
set(gca,'YDir','normal')
xlim(xlim1);
ylim(ylim1);
colorbar();
subplot(2,2,2);
imshow(rawPulse',[400,1500])
set(gca,'YDir','normal')
xlim(xlim1);
ylim(ylim1);
colorbar()
subplot(2,2,3);
imshow(rawChase',[400,1500])
set(gca,'YDir','normal')
xlim(xlim1);
ylim(ylim1);
colorbar()
subplot(2,2,4);
imshow(f',[0,1])
set(gca,'YDir','normal')
xlim(xlim1);
ylim(ylim1);
colorbar()
