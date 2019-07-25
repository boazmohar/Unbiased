function [target,registered] = Register_ORB(imageSize,groupNumber, mean2, ...
    target, normalized, opts)
%[target,registered] = Register_ORB(imageSize,groupNumber, mean2)
%   register using ORB Features
registered = zeros(imageSize(1), imageSize(2), groupNumber, 'single');
parfor i = 1:groupNumber
   distorted = normalized(:, :, i);
   ptsOriginal  = detectORBFeatures(target, 'ScaleFactor', opts.ScaleFactor, ...
        'NumLevels', opts.NumLevels);
    ptsDistorted = detectORBFeatures(distorted, 'ScaleFactor', opts.ScaleFactor, ...
        'NumLevels', opts.NumLevels);
    [featuresOriginal,  validPtsOriginal]  = extractFeatures(target,  ptsOriginal, ...
        'FeatureSize', opts.FeatureSize, 'BlockSize', opts.BlockSize);
    [featuresDistorted, validPtsDistorted] = extractFeatures(distorted, ptsDistorted, ...
        'FeatureSize', opts.FeatureSize, 'BlockSize', opts.BlockSize);
    indexPairs = matchFeatures(featuresOriginal, featuresDistorted, ...
        'MaxRatio', opts.MaxRatio, 'MatchThreshold', opts.MatchThreshold);
    disp(size(indexPairs));
    matchedOriginal  = validPtsOriginal(indexPairs(:,1));
    matchedDistorted = validPtsDistorted(indexPairs(:,2));
    [tform, ~, ~] = estimateGeometricTransform( matchedDistorted, ...
        matchedOriginal, opts.transform,  'MaxNumTrials',opts.MaxNumTrials, ...
        'MaxDistance', opts.MaxDistance, 'Confidence', opts.Confidence);
    outputView = imref2d(size(target));
    registered(:, :, i)  = imwarp(mean2(:, :, i),tform,...
        'OutputView',outputView);
end
%
for i= 1:groupNumber
    if i == 1
        imwrite(uint16(registered(:, :, i)),'registered.tif')
    else
        imwrite(uint16(registered(:, :, i)),'registered.tif','WriteMode','append')
    end
end
%
figure()
subplot(1,2,1)
imshow(mean(mean2, 3), [])
title('Raw')
subplot(1,2,2)
imshow(mean(registered, 3), [])
title('Registered')
end

