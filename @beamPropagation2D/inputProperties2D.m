%% <inputProperties2D.m, Inputs properties into beamPropagation2D objects.>
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
% This function takes a struct as input when called with dot notation. This
% struct needs to have all fields have the same names as properties of the
% calling object. The values are then copied from the struct to the like
% names properties.
%
% This function along with outputProperties2D.m allows for quick copying
% between beamPropagation2D objects or creation of identical objects while
% avoiding the MATLAB habit of making obj2 = obj1 create a reference to the
% same memory locations rather than generate new memory values.

function inputProperties2D(this,structIn)

% Grabs the field names from the vec struct
fieldList = fieldnames(structIn);

% This will throw an error if there is not a property of this that is set
for ii = 1:length(fieldList)
    this.(fieldList{ii}) = structIn.(fieldList{ii});
end


end