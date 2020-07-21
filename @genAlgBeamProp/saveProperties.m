%% <saveProperties.m, Save properties of the calling object.>
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
% This function takes several optional inputs and returns no ouputs.
%
% First is varName which is a cell array with a single property per cell
% used as the input to inputProperties2D.m. Could probably be string array
% but eh.
% 
% Second is the fileName which is a char string that is the name of the
% file to save (can be a full path). 
%
% Third is a char string of either 'pattern' which is to use matching with
% inputProperties2D or 'exact' which is when varName is explicitly calling
% properties to save.
%
% Fourth and final is override which controls whether the full beam
% definitions in herd and beam_init are saved or if they are empty copies
% of the beamPropagation2D class. If this is set to 1 then they are save
% and this file can quickly exceed GiB of data. YOU SHOULD KNOW WHAT YOU
% ARE DOING OR WHY YOU NEED THIS INFO BEFORE YOU SAVE. If you want to
% recreate beams later, parseSols.m has a function to recreate final beams
% from the final parameters.

function saveProperties(this,varName,fileName,matchType,override)

% If no varName is give assume save all and pattern matching
if ~exist('varName','var') || isempty(varName)
    varName = {''};
    matchType = {'pattern'};
end

% If not fileName is given set it to a empty value
if ~exist('fileName','var')
    fileName = [];
end

% Generate place to save to
if (isempty(fileName) && isempty(this.file_finalFile)) % GUI if all places are empty values
    [fileName,filePath] = uiputfile('*.mat','Save Genetic Algorithm Run Properties');
    
    if sum(fileName == 0) && sum(filePath == 0)
        error('Dialog Box Closed. No user input.');
    end
    
    fileName = fullfile(filePath,fileName);
    this.file_finalFile = fileName;
elseif isempty(fileName) && ~isempty(this.file_finalFile) % Else just use the predefined place
    fileName = this.file_finalFile;
end

% If you gave varName and NOT matchType, set it to exact matching
if ~exist('matchType','var') || isempty(matchType)
    matchType = 'exact';
end

% If override doesn't exist make sure it does and set it to zero
if ~exist('override','var') || isempty(override)
    override = 0;
end

% Generate struct of info to save
if length(varName) == 1 % varName is a single cell
    
    if strcmpi(matchType,'pattern') % if we are pattern matching
        
        % generate property list and trim for matching values
        varList = properties(this);
        varList = varList(contains(varList,varName));
        
        % extract values
        for ii = 1:length(varList)
            
            if (strcmpi(varList{ii},'herd') || strcmpi(varList{ii},'beam_init')) && ~override % save either blank info or full info
                data.(varList{ii}) = beamPropagation2D();
            else
                data.(varList{ii}) = this.(varList{ii});
            end
            
        end
        
    else
        
        data.(varName{1}) = this.(varName{1}); % if we are not pattern matching then save the singular property with exact name varName
        
    end
    
else % If the cell array varName is multiple entries
    
    varList = properties(this); % generate property list
    
    % Pull out varName properties that line up with real ones
    varsExist = false(length(varList),1);
    for ii = 1:length(varName)
        varsExist = or(varsExist,strcmpi(varList,varName{ii}));
    end
    varList = varList(varsExist);
    
    % Build the output struct with same override rules as before
    for ii = 1:length(varList)
        if (strcmpi(varList{ii},'herd') || strcmpi(varList{ii},'beam_init')) && ~override
            data.(varList{ii}) = beamPropagation2D();
        else
            data.(varList{ii}) = this.(varList{ii});
        end
    end
end


% Save it in modern .mat format and tell matlab it is a struct. Save the
% fields of data as seperate variables rather than just data struct.
save(fileName,'-struct','data');


end