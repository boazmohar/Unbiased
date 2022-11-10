function outImg = changeLUT(inImg,LUT)
%outImg = changeLUT(inImg,color)
%   Detailed explanation goes here
lh = stretchlim(inImg, [0.01 0.999]);
J = imadjust(inImg, lh);
outImg =cat(3, J, J, J);
switch lower(LUT)
    case 'red'
        outImg(:, :, 2) = 0;
        outImg(:, :, 3) = 0;
    case 'green'
        outImg(:, :, 1) = 0;
        outImg(:, :, 3) = 0;
    case 'blue'
        outImg(:, :, 1) = 0;
        outImg(:, :, 2) = 0;
    case 'orange'
        outImg(:, :, 2) = outImg(:, :, 2)/255*165;
        outImg(:, :, 3) = 0;
    case 'yellow'
        outImg(:, :, 2) = outImg(:, :, 2)/255*165;
        outImg(:, :, 3) = 0;
    case 'magenta'
        outImg(:, :, 2) = 0;
    otherwise
        error('No LUT found') 
end
end

