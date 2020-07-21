%% <genLensPhase.m, Calculates phase curvature matrix for an ideal lens.>
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
% This function takes a single input when called with dot notation. It then
% calculates the phase curvature matrix for an ideal spherical lens and
% returns this matirx.

function phaseVec = genLensPhase(this,f)

% Mesh generated specifically from real grid not spatial freq grid
[X,Y] = meshgrid(this.grid_xList,this.grid_yList);

% Spherical phase generated from a lens. Not a fresnel approximation
phaseVec = exp(-1i .* ((2 * pi) / (this.grid_lambda))...
    .* sqrt(f.^2 + X.^2 + Y.^2));

end