function [opts] = Reg_args(varargin)
%[opts] = Reg_args(varargin)
%   Detailed explanation goes here
opts.transform = 'affine';
opts.BlockSize = 3;
opts.MatchThreshold = 50;
opts.MaxRatio = 0.9;
opts.FeatureSize = 128;
opts.NumLevels = 8;
opts.ScaleFactor = 1.2;
opts.MaxNumTrials = 10000;
opts.MaxDistance = 10;
opts.Confidence = 99.9;
for i = 1:2:length(varargin)
    name = varargin{i};
    eval(sprintf('opts.%s = varargin{i+1}', name))
end

