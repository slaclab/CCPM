%% <FWHM.m, Returns the Full Width Half Maximum of a given list.>
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
% This function is a static method of the genAlgBeamProp class. It takes
% one input but can be called via 'obj.FWHM(lst)' or
% 'genAlgBeamProp.FHWM(lst)'. In either case the input is a singular
% dimensioned array. It will return the number of indicies between the
% first occurance of a value greater than half the maximum in the list and
% the last occurance. It is then up to you to know the spaceing between
% indicies.

function fwhm = FWHM(lst)

if ~isreal(lst)
    lst = abs(lst).^2; % This won't work on complex data so get intensity
end

halfMax = max(lst)/2;
logicMat = find(lst > halfMax); % Finds all locations greater than half
fwhm = (logicMat(end)-logicMat(1))+1;

end