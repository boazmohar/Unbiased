function tbl = load_tbl(filename, directory)
%tbl = load_tbl(filename, directory)
%   deafults to: 'TurnoverTable.mat', 'X:\Svoboda Lab\Boaz\ReImage_40x\New561Laser\Shading_Stitching'
if nargin < 1
    filename = 'TurnoverTable.mat';
end
if nargin < 2
    directory = 'W:\moharb\MECP2';
end
cd(directory);
if isfile(filename)
    temp = load(filename,'tbl');
    tbl = temp.tbl;
else
    error("Didn't find file %s in dir %s", filename, directory)
end