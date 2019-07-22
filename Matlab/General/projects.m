%PROJECTS Project manager for MATLAB
%   PROJECTS(cmd, projectName) manages current working directory and files
%   that are opened in MATLAB editor (but not the workspace). 
%   Available commands are: 
%     'list', 'show', 'save', 'load', 'close', 'rename', 'delete', 'active'
% 
%   PROJECTS or
%   PROJECTS('list') shows all stored projects. Arrow marks active project.
% 
%   PROJECTS('active') returns the name of the active project
% 
%   PROJECTS('show') shows information about the current project
%   PROJECTS('show', project_name) shows information about the project
% 
%   PROJECTS('close') closes all opened files
% 
%   PROJECTS('save') saves current working directory and editor state under
%   the active project 
%   PROJECTS('save', projectName) saves current working directory and
%   editor state under the specified project name
% 
%   PROJECTS('load') restores the project "default" 
%   PROJECTS('load', projectName) restores the project with specified name
% 
%   PROJECTS('open') is synonym for PROJECTS('load')
% 
%   PROJECTS('rename', newName) renames the active project
%   PROJECTS('rename', projectName, newName) renames the project
%
%   PROJECTS('delete') deletes the active project
%   PROJECTS('delete', projectName) deletes the project with specified name
% 
%   Examples:
%       projects list
%       projects save myProject
%       projects close
%       projects load default
%       projects rename myProject myLibrary
% 
%   All projects are stored in the %userpath%/projects.mat. This file with
%   empty "default" project is created at the first run of the script. If
%   %userpath% is empty, the script will execute: 
%   userpath(fullfile(dropboxPath,'matlab')). For dropbox sync to work
%   userpath must be on Dropbox path.
%   
%   Requires http://www.mathworks.com/matlabcentral/fileexchange/47644-dropboxpath-m to function.
%
%   First project always has name "default"

% Copyright 2012-2013, Vladimir Filimonov (ETH Zurich).
% $Date: 12-May-2012 $ 

function varargout = projects(cmd, varargin)

if verLessThan('matlab','7.12')
    error('Projects: MATLAB versions older than R2011a (7.12) are not supported')
end

if isempty(userpath)
    userpath(fullfile(dropboxPath,'matlab'))
end

fpath = userpath;
fpath = fullfile(fpath, 'projects.mat');

if ~exist(fpath, 'file')    % first time run
    openDocuments = matlab.desktop.editor.getAll;
    filenames = {openDocuments.Filename};
    
    projectsList = [];
    projectsList(1).ProjectName = 'default';
    projectsList(1).OpenedFiles = {};
    projectsList(1).ActiveDir = fullfileparts(strrep(userpath, dropboxPath, '%dropboxpath%'));
    projectsList(1).ActiveDir(end) = [];
    
    activeProject = 1;
    save(fpath, 'projectsList', 'activeProject');
end

load(fpath)

if nargin==0
    cmd = 'list';
end

switch lower(cmd)
    case 'close'
        if projects('modified')
            name = projectsList(activeProject).ProjectName;
            choice = questdlg(['Save active project "' name '" before closing?'], ...
                              'Closing active project...', ...
                              'Yes','No','Cancel', 'No');
            switch choice
                case 'Yes'
                    projects('save');
                case 'No'
                case 'Cancel'
                    varargout = {false};
                    return
            end
        end
        varargout = {true};
        openDocuments = matlab.desktop.editor.getAll;
        openDocuments.close;
        
        load(fpath)
        activeProject = 1;
        save(fpath, 'projectsList', 'activeProject');
        
    %=========================================    
    case 'list'
        disp('List of available projects:')
        for ii = 1:length(projectsList)
            if ii == activeProject
                str = '-> ';
            else
                str = '   ';
            end
            disp([str num2str(ii) ': ' projectsList(ii).ProjectName])
        end
        varargout = {projectsList.ProjectName};
        
    %=========================================    
    case {'show', 'info'}
        if nargin==1
            ind = activeProject;
        else
            prjname = varargin{1};
            ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
            if isempty(ind)
                error('Projects: unknown project name')
            end
        end
        projectsList(ind)
        varargout{1} = projectsList(activeProject);
        
    %=========================================    
    case 'active'
        varargout{1} = projectsList(activeProject).ProjectName;
        disp(['Active project is "' varargout{1} '"'])
        
    %=========================================    
    case 'save'
        if nargin==1
            ind = activeProject;
            prjname = projectsList(ind).ProjectName;
        else
            prjname = varargin{1};
            ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
            if isempty(ind)
                ind = length(projectsList) + 1;
            end
        end
        
        openDocuments = matlab.desktop.editor.getAll;
        filenames = {openDocuments.Filename};
        
        filenames=strrep(filenames, dropboxPath, '%dropboxpath%');
        filenames=fullfileparts(filenames);
        
        projectsList(ind).ProjectName = prjname;
        projectsList(ind).OpenedFiles = filenames;
        projectsList(ind).ActiveDir = fullfileparts(strrep(pwd, dropboxPath, '%dropboxpath%'));
        activeProject = ind;
        
        save(fpath, 'projectsList', 'activeProject');
        disp(['Project "' prjname '" was saved'])
        
    %=========================================    
    case {'open', 'load'}
        if nargin==1
            prjname = 'default';
        else
            prjname = varargin{1};
        end
        ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
        if isempty(ind)
            error('Projects: unknown project name')
        end
                
        if projects('close')
            load(fpath)
        else
            return
        end
        
        filenames_cellform = projectsList(ind).OpenedFiles;
        for i=1:length(filenames_cellform)
            filenames{i}=fullfile(filenames_cellform{i}{:});
        end         
        filenames=strrep(filenames,'%dropboxpath%',dropboxPath);
               
        for ii = 1:length(filenames)
            if exist(filenames{ii}, 'file')
                matlab.desktop.editor.openDocument(filenames{ii});
            else
                warning(['File "' filenames{ii} '" was not found'])
            end
        end
        
        try 
            ActiveDir=strrep(fullfile(projectsList(ind).ActiveDir{:}),'%dropboxpath%',dropboxPath);
            cd(ActiveDir);
        catch
            warning(['Directory "' ActiveDir '" does not exist'])
        end
        
        activeProject = ind;
        save(fpath, 'projectsList', 'activeProject');
        disp(['Project "' prjname '" was restored'])

%     %=========================================    
%     case 'saveload'
%         projects('save');
%         projects('load',varargin{:});
        
    %=========================================    
    case 'rename'
        if nargin==1
            error('Projects: project name was not specified')
        elseif nargin==2
            prjold = projectsList(activeProject).ProjectName;
            prjnew = varargin{1};
        elseif nargin==3
            prjold = varargin{1};
            prjnew = varargin{2};
        end
        ind = find(strcmpi(prjold, {projectsList.ProjectName}), 1);
        if isempty(ind)
            error('Projects: unknown project name')
        end
        
        projectsList(ind).ProjectName = prjnew;
        
        save(fpath, 'projectsList', 'activeProject');
        disp(['Project "' prjold '" was renamed to "' prjnew '"'])
        
        
    %=========================================    
    case 'delete'
        if nargin==1
            ind = activeProject;
            new_prj = 'default';
        else
            prjname = varargin{1};
            ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
            if isempty(ind)
                error('Projects: required project was not found')
            end
            if ind == activeProject
                new_prj = 'default';
            else
                new_prj = projectsList(activeProject).ProjectName;
            end
        end
        if ind==1
            error('Projects: could not delete "default" project')
        end
        
        prjname = projectsList(ind).ProjectName;
        projectsList(ind) = [];
        activeProject = find(strcmpi(new_prj, {projectsList.ProjectName}), 1);
        
        save(fpath, 'projectsList', 'activeProject');
        disp(['Project "' prjname '" was deleted'])
        if activeProject==1
            disp('Current project was changed to "default"')
        end

    %=========================================    
    case 'modified'
        fn_saved = projectsList(activeProject).OpenedFiles;

        openDocuments = matlab.desktop.editor.getAll;
        fn_opened = {openDocuments.Filename};
        
        varargout = {false};
        if length(fn_saved) ~= length(fn_opened)
            varargout = {true};
        else
            for ii=1:length(fn_saved)
                if ~strcmpi(fn_saved{ii},fn_opened{ii})
                    varargout = {true};
                end
            end
        end
        if nargout==0
            str = ['Project "' projectsList(activeProject).ProjectName '" '];
            disp(vif(varargout{1}, [str 'was modified'], ...
                                   [str 'was not modified']))
        end
        
    %=========================================    
    otherwise 
        error('Projects: unknown command.')
end

if nargout==0
    varargout = cell(0,0);
end

function filepartsarray=fullfileparts(filepathfile)
%fullfileparts(pwd);fullfile(ans{:});strcmp(ans,pwd)
    
if ~iscell(filepathfile)
    filepathfile=cellstr(filepathfile);
end
for i=1:length(filepathfile)
    filepartsarray{1,i}=strsplit(filepathfile{i},filesep);
    if ~ispc && isempty(filepartsarray{1,i}{1})
        filepartsarray{1,i}(1)={filesep};
    end
end
if length(filepartsarray)==1
    filepartsarray=filepartsarray{:};
end