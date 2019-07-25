function debug_registration(image1, image2, opts)
ptsOriginal  = detectORBFeatures(image1, 'ScaleFactor', opts.ScaleFactor, ...
    'NumLevels', opts.NumLevels);
ptsDistorted = detectORBFeatures(image2, 'ScaleFactor', opts.ScaleFactor, ...
    'NumLevels', opts.NumLevels);
[featuresOriginal,  validPtsOriginal]  = extractFeatures(image1,  ptsOriginal, ...
    'FeatureSize', opts.FeatureSize, 'BlockSize', opts.BlockSize);
[featuresDistorted, validPtsDistorted] = extractFeatures(image2, ptsDistorted, ...
    'FeatureSize', opts.FeatureSize, 'BlockSize', opts.BlockSize);
indexPairs = matchFeatures(featuresOriginal, featuresDistorted, ...
    'MaxRatio', opts.MaxRatio, 'MatchThreshold', opts.MatchThreshold);
disp(size(indexPairs));
matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));
figure;
showMatchedFeatures(image1,image2,...
    matchedOriginal,matchedDistorted, 'montage');
title('Matched SURF points,including outliers');
pause();
[tform, inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform( matchedDistorted, ...
    matchedOriginal, opts.transform,  'MaxNumTrials',opts.MaxNumTrials, ...
    'MaxDistance', opts.MaxDistance, 'Confidence', opts.Confidence);
outputView = imref2d(size(image1));
figure; 

showMatchedFeatures(image1,image2,...
    inlierPtsOriginal,inlierPtsDistorted);
title('Matched inlier points');
pause
output = imwarp(image2,tform,'OutputView',outputView);
