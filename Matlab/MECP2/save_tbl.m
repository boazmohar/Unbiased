function save_tbl(tbl,filename, directory)
%save_tbl(tbl,filename, directory)
%   saves in directory, if present
if nargin < 2
    filename = 'TurnoverTable.mat';
end
if nargin < 3
    directory = 'W:\moharb\MECP2';
end
cd(directory);
if isfile(filename)
    if ~isfolder('old')
        mkdir('old')
        disp('Makeing directory "old"');
    end
    filename_old = ['old' filesep filename(1:end-4) datestr(now, 'yyyy-mm-dd_HH-MM-SS') '.mat'];
    copyfile(filename,filename_old);
    fprintf('Copy %s to %s\n', filename, filename_old)
end
save(filename,'tbl')
disp('saved')