%% <initGUI.m, Runs all of the GUI input boxes to setup a run.>
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
% This funtion has no inputs or outputs.
%
% This function is run in the contructor when called with the 'GUI'. It
% will propmpt the user with all of the question necessary to setup any run
% of their choice.

function initGui(this)

% Get user input to set up beam for GA
prompt = {'Distance to Propagate:',...
    'Wavelength of Light:',...
    'Grid Size of Beams:',...
    'Type of Beam Propagation ie. ''hex'', ''rect'' etc.:',...
    'Properties to Test (comma sep list):'
    };
inputTitle = 'Initial Beam Definition';
dims = [1 100];
defInput = {'25*(10^3)',...
    '1.55*(10^-3)',...
    '6*(10^1)',...
    'hex',...
    'PhaseOffset',...
    };
opts.Interpreter = 'tex';
userInput = inputdlg(prompt,inputTitle,dims,defInput,opts);

% Check if user input something (avoids NaN)
if ~size(userInput)
    error('Dialog Box Closed. No user input.');
end

this.init_zProp = str2num(userInput{1}); %#ok<*ST2NM>
this.init_lambda = str2num(userInput{2});
this.init_gridSize = str2num(userInput{3});
this.init_beamType = userInput{4};

props(:,1) = erase(strsplit(userInput{5},',')',' ');

% Get user input for definition of each varring property
for ii = 1:size(props,1)
    prompt = {['Range for ', props{ii,1},'(ie ''[0,pi]'' or ''[0,10000]''):'],...
        ['Mutation rate for ', props{ii,1},' (0-1):']...
        };
    inputTitle = ['GA Parameter Definition, ' num2str(props{ii,1})];
    dims = [1 100];
    defInput = {'',...
        '0.1'...
        };
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,inputTitle,dims,defInput,opts);
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    if isempty(userInput{1}) || isempty(userInput{2})
        error('You need to provide these parameters')
    end
    
    props(ii,2:3) = {str2num(userInput{1}),str2num(userInput{2})};
    
end
this.init_propsTest = props;

% Default values for inds and gens based on num props. Gens could be lower
% but eh
numInds = 30 + size(this.init_propsTest,1)*14;
numGens = numInds * 2;

% Get user input for definition of the GA run size
prompt = {'Number of Individuals:',...
    'Number of Generations:',...
    'Number of Runs:',...
    };
inputTitle = 'Initial Genetic Algorithm Definition';
dims = [1 100];
defInput = {num2str(numInds),...
    num2str(numGens),...
    '5',...
    };
opts.Interpreter = 'tex';
userInput = inputdlg(prompt,inputTitle,dims,defInput,opts);

% Check if user input something (avoids NaN)
if ~size(userInput)
    error('Dialog Box Closed. No user input.');
end

this.herd_numHerd = str2num(userInput{1});
this.herd_numGens = str2num(userInput{2});
this.herd_numRuns = str2num(userInput{3});

% Get file to save the final vals to
[fileName,filePath] =...
    uiputfile('*.mat','File Name for Saving/Loading Final Values');
if sum(fileName == 0) && sum(filePath == 0)
    this.file_finalFile = [];
else
    this.file_finalFile = fullfile(filePath,fileName);
end

% Get file to load the initial beam definition from
[fileName,filePath] =...
    uigetfile('*.mat','File Name for Saving/Loading Beam Definition');
if sum(fileName == 0) && sum(filePath == 0)
    this.file_beamFile = [];
else
    this.file_beamFile = fullfile(filePath,fileName);
end

% Get user input to see if they want to watch the GA work
prompt = {'Use real data? (y/n):'};
inputTitle = 'Genetic Algorithm Definition';
dims = [1 100];
defInput = {'n'};
opts.Interpreter = 'tex';
userInput = inputdlg(prompt,inputTitle,dims,defInput,opts);

if strcmpi(userInput{1},'y')
    
    [fileName,filePath] =...
        uigetfile('*.*','File of real data');
    if sum(fileName == 0) && sum(filePath == 0)
        error('You need to provide path to real data');
    else
        this.file_solFile = fullfile(filePath,fileName);
    end
    
    
    [fileName,filePath] =...
        uigetfile('*.*','File of real data fitness function');
    if sum(fileName == 0) && sum(filePath == 0)
        error('You need to provide path to fitness function');
    else
        this.file_fitFile = fullfile(filePath,fileName);
    end
    
    % Get user input for real world size of camera image
    prompt = {'Real size of image in x:',...
        'Real size of image in y:'
        };
    inputTitle = 'Image Size Definition';
    dims = [1 100];
    defInput = {'',...
        ''
        };
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,inputTitle,dims,defInput,opts);
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    this.sol_realSize = [str2num(userInput{2}) str2num(userInput{1})];
    
end


% Get user input to see if they want to watch the GA work
prompt = {'See the GA in action? (y/n):'};
inputTitle = 'Genetic Algorithm Plotting Definition';
dims = [1 100];
defInput = {'n'};
opts.Interpreter = 'tex';
userInput = inputdlg(prompt,inputTitle,dims,defInput,opts);

if strcmpi(userInput{1},'y')
    this.gen_plotFlag = 1;
    
    % Get user input to see if they want to watch the GA work
    prompt = {'Make a gif of the action? (y/n):'};
    inputTitle = 'Genetic Algorithm Gif Definition';
    dims = [1 100];
    defInput = {'y'};
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,inputTitle,dims,defInput,opts);
    
    if strcmpi(userInput{1},'y')
        this.gen_makeGif = 1;
        
        [fileName,filePath] =...
            uiputfile('*.gif','File for saving .gif');
        if sum(fileName == 0) && sum(filePath == 0)
            error('You need to provide path to real data');
        else
            this.file_gifFile = fullfile(filePath,fileName);
        end
        
    end
    
end




end