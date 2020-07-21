%% <forwardProp_FreeSpace2D.m, Propagates a field forward in z.>
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
% This function takes the distance to propagate as the singluar input when
% called with dot notation. It outputs the propagated field. It is NOT an
% inplace computation.

function fList_Output = forwardProp_FreeSpace2D(this,z)

% Phase aquired by traveling a distance z forward in time
if isempty(this.field_phaseVec)
    phaseVec = this.genPropPhase(z);
else
    phaseVec = this.field_phaseVec;
end

% This whole transform takes us to the far field in real space
% dx and dy are for normalization. Shifts are to keep zero freq in the
% right place
fList_Output =...
    (1 / (this.grid_dx .* this.grid_dy) ).*fftshift(ifft2(ifftshift(...
    this.grid_dx .* this.grid_dy .*fftshift(fft2(ifftshift(this.field_fList))).* phaseVec...
    )))...
    ;

end