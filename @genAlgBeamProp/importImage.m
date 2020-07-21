%% <importImage.m, Conditions image from file path for run.>
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
% This function takes no imput and has no output.
%
% This is a simple helper function that reades the image in solFile and
% makes it greyscaled and normalized. This is necessary because the GA has
% to be a comparison.

function importImage(this)

[this.sol_Image,cmap,~] = imread(this.file_solFile);

if ~isempty(cmap)
    this.sol_Image = rgb2gray(ind2rgb(this.sol_Image,cmap));
elseif size(this.sol_Image,3) == 3
    this.sol_Image = rgb2gray(this.sol_Image);
end

this.sol_Image = double(this.sol_Image)./max(max(double(this.sol_Image)));

end