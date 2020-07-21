%% <propherd.m, Propagate all herd fields in one function>
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
% This simple line just propagates all the fields to the plane we are
% curious about.

function propHerd(this)

for ii = 1:numHerd
    this.herd(ii).field_fList =...
        this.herd(ii).forwardProp_FreeSpace2D(this.init_zProp);
end

end