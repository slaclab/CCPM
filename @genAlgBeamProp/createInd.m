%% <createInd.m, Create initial gene values for changing properties.>
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
% This function has four inputs and one output. The first input is the
% range of values to creates the genes within. The second is the number of
% beams to create genes for (within on individual). The third is the
% initial values if certain beams are "off" in the simulation. The last
% determines the type of creation to use (beams off, all one value,
% binary). The output is then the generated values in a 1D array.

function genes = createInd(range,nBeams,existVals,options)

if length(range) > 2 % Discrete Case
    
    if strcmpi(options,'all') % All beams are one value
        
        genes = repmat(genAlgBeamProp.discreteMap(ones(1),range),nBeams,1);
        
    elseif islogical(options) % certain beams retain initial values
        
        genes = genAlgBeamProp.discreteMap(ones(nBeams,1),range);
        genes(options) = existVals(options);

    elseif isempty(options) % discrete but nothing special
        
        genes = genAlgBeamProp.discreteMap(ones(nBeams,1),range);
        
    end
    
else % Continuous Case
        
    if strcmpi(options,'binary') % I guess binary is discrete but it fits here instead
        
        genes = genAlgBeamProp.discreteMap(ones(nBeams,1),range);
        
    elseif strcmpi(options,'all') % All beams are one value
        
        genes = repmat(rand.*(range(2) - range(1)) + range(1),nBeams,1);
        
    elseif islogical(options) % certain beams retain initial values
        
        genes = rand(nBeams,1).*(range(2) - range(1)) + range(1);
        
        genes(options) = existVals(options);
        
    elseif isempty(options) % continuous but nothing special
        
        genes = rand(nBeams,1).*(range(2) - range(1)) + range(1);
        
    end
    
end

end