function [Calibration, Blank] = getCalibration(configuration)
% [Calibration, Blank] = getCalibration(configuration)
% configuration of the slide scanner old = weaker light engine and different filters
% 880 upright with 2 track configuration without 488 for control animals
% 880 upright with 3 tracks for less crosstalk and with IHC in the 488 Chz
if nargin == 0
    configuration = 'old';
end
Calibration = containers.Map('KeyType','uint32', 'ValueType', 'double');
Blank = containers.Map('KeyType','uint32', 'ValueType', 'double');
switch configuration
    case 'old'
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
        Calibration(525) = 2.0;
        Calibration(0)   = 2.0;
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
        Blank(525) = 150.0;
        Blank(0)   = 150.0;
    case '880Upright2Tracks'
        Calibration(669) = 79.2;
        Calibration(552) = 3164.0;
        Calibration(608) = 670.7;
        Blank(669) = 5.4;
        Blank(552) = 7.8;
        Blank(608) = 6.6;
    case '880Upright3Tracks'
        Calibration(669) = 284.6;
        Calibration(552) =  7214.4;
        Calibration(608) = 339.2;
        Blank(669) = 7.6;
        Blank(552) = 17.5;
        Blank(608) = 22.0;
    case '880_40x_newLaser'
        Calibration(669) = 2995.3;
        Calibration(552) =  53942.0;
        Calibration(608) = 8914.6;
        Blank(669) = 105.8;
        Blank(552) = 73.7;
        Blank(608) = 91.6;
    case '980_20x'
        Calibration(669) = 810.0;
        Calibration(552) =  4630.0;
        Blank(669) = 3.8;
        Blank(552) = 30.7;
    case '980_airy_40x'
        Calibration(669) = 1906.5;
        Calibration(673) = 2217.5;
        Calibration(552) = 1567.2;
        Blank(669) = 77.3;
        Blank(673) = 83.4;
        Blank(552) = 74.8;
    case '10x_SlideScanner'
        Calibration(669) = 1906.5;
        Calibration(673) = 2217.5;
        Calibration(552) = 1567.2;
        Blank(669) = 77.3;
        Blank(673) = 83.4;
        Blank(552) = 74.8;
    case '10x_SlideScanner_WF'
        Calibration(673) = 651.3;
        Calibration(552) = 1085.0;
        Blank(673) = 32.0;
        Blank(552) = 128.0;
        
    otherwise
        error('not calibrated')
end
