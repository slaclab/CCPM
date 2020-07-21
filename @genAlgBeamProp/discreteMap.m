%% <discreteMap.m, Generates discrete values in the established range.>
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
% This function has two inputs and a single output. The first input is a 1D
% array of the length of values you want to generate (often just a dummy
% ones() array). The second input is the discrete list of possible values.
%
% This generates a list with length the same as the 1D dummy variable vals
% of random integers between 1 and the length of the range variable. This
% list is then used to index into range and return that value in the vals
% variable. It's techically in place since vals needs to be a properly
% sized array but it's a silly point to make.

function vals = discreteMap(vals,range)

vals = range(randi(length(range),1,length(vals)));

end