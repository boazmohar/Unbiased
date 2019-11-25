function [Calibration, Blank] = getCalibration(configuration)
% [Calibration, Blank] = getCalibration(configuration)
% configuration of the slide scanner old = weaker light engine and different filters
if nargin == 0
    configuration = 'old';
end
if strcmp(configuration, 'old')
    Calibration = containers.Map('KeyType','uint32', 'ValueType', 'double');
    Calibration(669) = 1.855;
    Calibration(585) = 2.099;
    Calibration(552) = 2.369;
    Calibration(612) = 2.0;
    Calibration(608) = 2.0;
    Calibration(609) = 2.0;
    Calibration(541) = 2.0;
    Calibration(533) = 2.0;
    Calibration(559) = 2.0;
    Calibration(646) = 2.0;
    Calibration(570) = 2.0;
    Calibration(0)   = 2.0;
    Blank = containers.Map('KeyType','uint32', 'ValueType', 'double');
    Blank(669) = 207.8;
    Blank(585) = 155.0;
    Blank(552) = 152.0;
    Blank(612) = 150.0;
    Blank(608) = 150.0;
    Blank(609) = 150.0;
    Blank(541) = 150.0;
    Blank(533) = 150.0;
    Blank(559) = 150.0;
    Blank(646) = 150.0;
    Blank(570) = 150.0;
    Blank(0)   = 150.0;
else
    