%% <genPropPhase.m, Calculates propagation phase matrix.>
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
% calculates the propagation phase matrix for the ASM for the given
% distance and returns this matirx.

function phaseVec = genPropPhase(this,z)

% Mesh generated specifically from spatial freq grid not real grid
[X,Y] = meshgrid(this.grid_fxList,this.grid_fyList);

% Copied function to mimic the Heaviside.m function from SymMath Toolbox without using it
hvsd = @(x)(0.5*(x == 0) + (x > 0));

% Propagation phase from Rayleigh-Sommarfeld solution in the angular spectrum method
phaseVec = exp( 1i * ( (2 * pi) / (this.grid_lambda) ) *...
        sqrt(1 - X.^2 * this.grid_lambda^2 - Y.^2 * this.grid_lambda^2) * z )...
        .* hvsd(1 - (X.^2 * this.grid_lambda^2 + Y.^2 * this.grid_lambda^2) );

end