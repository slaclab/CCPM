%% <outputProperties2D.m, Outputs properties genAlgBeamProp objects.>
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
% This function takes a single char string as input when called with dot
% notation. This char is of the form: '', 'all', or 'pattern'. If '' or
% 'all' are used then a struct with every property of the calling object
% assigned to a similarly name field. If the input is 'pattern' then the
% properties are searched for the char string 'pattern' and any that
% contain this char string are copied over to similarly named fields of the
% output struct.
%
% This function along with inputProperties2D.m allows for quick copying
% between genAlgBeamProp objects or creation of identical objects while
% avoiding the MATLAB habit of making obj2 = obj1 create a reference to the
% same memory locations rather than generate new memory values.


function output = outputProperties2D(this,str)

% Checks for the properties in this that match 'str'
propList = properties(this);
if ~strcmpi(str,'all')
    propList = propList(contains(propList,str));
end

% Creates a struct to hold the output fields
output = struct;

for ii = 1:length(propList)
    output.(propList{ii}) = this.(propList{ii});
end


end