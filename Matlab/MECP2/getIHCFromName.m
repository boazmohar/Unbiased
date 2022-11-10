function [IHC, Slide, Section] = getIHCFromName(filename)
%[IHC] = getIHCFromName(filename)
%   Detailed explanation goes here
parts = split(filename, '_');
IHC = parts{2};
Slide = str2num(parts{3}(end));
Section = str2num(parts{4}(end));
end

