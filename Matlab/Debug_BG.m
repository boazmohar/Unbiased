%%
titles = {'1-cell', '2-bright large', '3-black bg', '4-neuropil1',...
    '5-neuropil2', '6-neuropil strong', '7-dendrite', '8-small bright', ...
    '9-blood', '10-bg1','11-bg2', '12-bg3', '13- red fibers'};
px2 = px(:, y-50:y+50, x-50:x+50);
bw_not2 = bw_not(x-50:x+50, y-50:y+50);
bw_not_d2 = bw_not_d(x-50:x+50, y-50:y+50);
figure(2);
clf()
for kk = 1:13
    subplot(4,4, kk)
    imshow(squeeze( px2(kk, :, :))', [0, 0.5])
    title(titles{kk})
end
subplot(4, 4, 14)
imshow(bw_not2)
subplot(4, 4, 15)
imshow(~bw_not2)
subplot(4, 4, 16)
imshow(bw_not_d2)
figure(3)
clf();
ks = [1, 2, 7, 8, 9];
for k = 1:5
    c = ks(k);
    subplot(2,3, k)
    imshow(squeeze(px2(c, :, :))' > 0.1)
     title(titles{c})
end
