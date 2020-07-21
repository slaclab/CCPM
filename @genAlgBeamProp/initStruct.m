%% <initStruct.m, Generates a struct with all of the fields for input.>
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
% This function has a variable amount of inputs and a single output. For
% input one can list the different types of runs that can be made ie.
% ('img','gif') to out put a struct with the properties for setting a run
% on real data and saving the gif. For the output it is a struct with all
% of the relevent properties needed to input into genAlgBeamProp in order
% to run with parameters asked.

function out = initStruct(varargin)

% If there is more than one input in the first input ie. {'img','gif'},
% put them in a higher level cell array
if length(varargin{1}) > 1
    tmp = cell(length(varargin{1}),1);
    for ii = 1:length(varargin{1})
        tmp(ii) = varargin{1}(ii);
    end
    varargin = tmp;
end


obj = genAlgBeamProp; % needed but it's empty properties

% Properties that are always needed
out = obj.outputProperties2D({'herd_','init_'});
out = rmfield(out,'herd_props');
out = rmfield(out,'init_propList');


% If the user asked for different run types
if nargin >= 1
    for ii = 1:length(varargin)
        switch varargin{ii}
            case 'img'
                % needed for using image data
                tmp = obj.outputProperties2D({'file_solFile','file_fitFile','sol_realSize'});
                for jj = fieldnames(tmp)'
                    out.(jj{1}) = tmp.(jj{1}); % assign to out
                end
            case 'gif'
                % needed to save and generate plots as gifs
                tmp = obj.outputProperties2D({'file_gifFile','gen_plotFlag','gen_makeGif'});
                tmp.gen_plotFlag = 1;
                tmp.gen_makeGif = 1;
                for jj = fieldnames(tmp)'
                    out.(jj{1}) = tmp.(jj{1});
                end
            otherwise
                error('Not regognized init type');
        end
        
    end
    
end