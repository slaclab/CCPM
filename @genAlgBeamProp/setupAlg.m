%% <setupAlg.m, Condition and setup input parameters for GA.>
%     Copyright (C) <2020>  <Randy Lemons, Sergio Carbajo>
% 
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License along
%     with this program; if not, write to the Free Software Foundation, Inc.,
%     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%     
% This function takes no inputs and returns no ouputs. It just defines the
% values for properties of the class. 
%
% It requires the initGUI.m to be run or for the class to have been called
% with a struct that sets all the values that initGUI does. It then runs
% through and sets the type of solve, the initial beam properties to use,
% the image to solve for, where to save things, and lastly initializes the
% arrays for final values as it runs inorder to save time.

function setupAlg(this)

% Make sure each changing variable has proper size and values
for ii = 1:numel(this.init_propsTest)
    if length(this.init_propsTest{ii}) == 2
        this.init_propsTest{ii}{3} = 0.1; % assign mutation factor of 0.1
    end
    if length(this.init_propsTest{ii}) == 3
        this.init_propsTest{ii}{4} = []; % make it proper size but of no value
    end
end

% Setup variables to use as genes for genetic algorithm. Mash strings
% together to generate full variable names for use with beamPropagation2D.
% ie if beamtype = 'hex' and propTest = 'AmpBeams' ==> 'hex_AmpBeams'
for ii = 1:numel(this.init_propsTest)
    this.init_propList{ii,1} =...
        [this.init_beamType, '_', this.init_propsTest{ii}{1}];
end

% Setup the initial beam profile to use
if isempty(this.file_beamFile) % Only run if beam file not given
    
    [fileName,filePath] = uiputfile('*.mat','Save Initial Beam Properties');
    
    if sum(fileName == 0) && sum(filePath == 0)
        error('Dialog Box Closed. No user input.');
    end
    
    fileName = fullfile(filePath,fileName);
    this.file_beamFile = fileName;
    
    beam_init = beamPropagation2D(this.init_lambda,...
        this.init_gridSize,this.init_gridSize,...
        this.const_npts,this.init_beamType);
    this.beam_props = beam_init.outputProperties2D('');
    this.herd_props = repmat(...
        beam_init.outputProperties2D(this.init_beamType),...
        this.herd_numHerd,1);
    this.beam_init = beam_init;
    
    save(this.file_beamFile,'beam_init');
    clear beam_init
    
else
    
    % load the file and extra beamPropagation2D object
    this.beam_init = load(this.file_beamFile);
    tmp = fieldnames(this.beam_init);
    this.beam_init = this.beam_init.(tmp{1});
    
    % make sure input beam type char string and saved beam are same
    if any(structfun(@isempty,this.beam_init.outputProperties2D(this.init_beamType)))
        error('Beam type used is different than the beam file loaded.');
    end
    
    % copy all the properties over to this object
    this.beam_props = this.beam_init.outputProperties2D('');
    this.herd_props = repmat(...
        this.beam_init.outputProperties2D(this.init_beamType),...
        this.herd_numHerd,1);
    
    clear tmp
end

% Setup the solve type and ideal performance
if isempty(this.file_solFile)
    
    % generate far field to solve for
    this.beam_init.field_fList =...
        this.beam_init.forwardProp_FreeSpace2D(this.init_zProp);
    
    % make image out of it.
    this.sol_Image = abs(this.beam_init.field_fList).^2;
    this.sol_Image = this.sol_Image/max(max(this.sol_Image));
    
    this.gen_minColorVal = min(min(this.sol_Image));
    this.gen_maxColorVal = max(max(this.sol_Image));
    
    this.sol_Type = 'beam';
    
elseif contains(this.file_solFile,'.mat')
    
    % extension for images in .mat files. No need yet but I can see why it
    % might be wanted.
    error('Haven''t coded this yet... My B');
    
else
    
    % Load image
    this.importImage();
    
    % Generate coloring data
    this.gen_minColorVal = min(min(this.sol_Image));
    this.gen_maxColorVal = max(max(this.sol_Image));
        
    % Generate number of points to equal real size on our grid
    this.sol_simPoints{1} = floor(this.sol_realSize(1) / this.beam_init.grid_dy);
    this.sol_simPoints{2} = floor(this.sol_realSize(2) / this.beam_init.grid_dx);
    
    % generate list of those number of points centered on the middle of the
    % computational grid
    centSim = this.beam_init.grid_npts/2;
    this.sol_simPoints{1} = centSim + (-floor(this.sol_simPoints{1}/2):floor(this.sol_simPoints{1}/2));
    this.sol_simPoints{2} = centSim + (-floor(this.sol_simPoints{2}/2):floor(this.sol_simPoints{2}/2));
    
    this.sol_Type = 'image';
    
end

if ~isempty(this.file_fitFile)
    
    % find user defined function
    [movDir,func] = fileparts(this.file_fitFile);
    
    % cd to that directory, generate function handle, and cd back
    if ~isempty(movDir)
        curDir = pwd;
        cd(movDir);
        this.file_fitFile = str2func(func);
        cd(curDir);
    else
        this.file_fitFile = str2func(func);
    end
    
end

if isempty(this.sol_stopCond) % always need to compare to a value to stop
    this.sol_stopCond = inf; % this makes it so it stops by generation not value
end

if this.gen_makeGif == 1
    
    if ischar(this.file_gifFile) || isstring(this.file_gifFile) % if a single name is given in char or string
        
        % make a full path out of it
        [strPath,strName,strType] = fileparts(this.file_gifFile);
        this.file_gifFile = cell(this.herd_numRuns,1);
        
        % if the number of runs is greater than 1...
        if this.herd_numRuns > 1
            % ... generate a bunch of names by appending run numbers
            for ii = 1:this.herd_numRuns
                this.file_gifFile{ii} = fullfile(strPath,[strName num2str(ii) strType]);
            end
        else
            % ... else just turn it into a cell
            this.file_gifFile{ii} = fullfile(strPath,[strName strType]);
        end
        
    elseif iscell(this.file_gifFile) && (numel(this.file_gifFile) == 1) % if its a single name in a cell
        
        % All the same as above
        [strPath,strName,strType] = this.file_gifFile{1};
        this.file_gifFile = [];
        
        if this.herd_numRuns > 1
            for ii = 1:this.herd_numRuns
                this.file_gifFile{ii} = fullfile(strPath,[strName num2str(ii) strType]);
            end
        else
            this.file_gifFile{ii} = fullfile(strPath,[strName strType]);
        end
        
    elseif iscell(this.file_gifFile) && (numel(this.file_gifFile) ~= 1 && numel(this.file_gifFile) ~= this.herd_numHerd)
        
        % Mainly only used if the number of names is the wrong amount
        error('Not enough file_gifFile names provided for the number of runs');
        
    end
end
    
    
%%% Setup the matricies to hold final parameters. Speed optimization
this.final_fitness = zeros(this.herd_numGens,2,this.herd_numRuns); % save the fitness
for ii = 1:numel(this.init_propList)
    % this is a bad setup. It should be rework to work with field that don't have _NBeams properties
    % right now just works for hex, rect, and man.
    
    this.final_props.(this.init_propList{ii}) = zeros(... % save the property values for all beams
        this.herd_numGens,...
        this.beam_init.([this.init_beamType,'_NBeams']),...
        this.herd_numRuns);
end
this.final_timeG = zeros(this.herd_numGens,1,this.herd_numRuns); % save time to get through each generation
this.final_timeZ = zeros(1,1,this.herd_numRuns); % save time to get through each run

end