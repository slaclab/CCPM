%% <plotImage.m, Plot either solution or best generation field>
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
% This function takes a single input of which field to plot if called with
% dot notation and returns nothing.
%
% Right now this function only plots the intensity imformation of any given
% field. Can be extended to optionally plot angle if wanted.

function plotImage(this,img)

if strcmpi(this.sol_Type,'image') % real data plotting
    
    % use the generated indexes of points corresponding to real image size
    simY = this.sol_simPoints{1};
    simX = this.sol_simPoints{2};
    
    if strcmpi(img,'sol') % plot solution image
        
        img = this.sol_Image;
        
    elseif strcmpi(img,'best') % plot best of current generation
        
        % normalize the image
        img = abs(this.herd(1).field_fList(simY,simX)).^2/...
            max(max(abs(this.herd(1).field_fList(simY,simX)).^2));
        
    else % if img is the actual image
        
        if ~isreal(img) % if the field is complex generate intensty
            img = abs(img).^2;
        end
        
        img = img / max(max(img)); % normalize
        
    end
    
    
elseif ~strcmpi(this.sol_Image,'beam')
    
    if strcmpi(img,'sol') % plot solution image
        
        img = this.sol_Image;
        
    elseif strcmpi(img,'best')% plot best of current generation
        
        % normalize the image        
        img = abs(this.herd(1).field_fList).^2/...
            max(max(abs(this.herd(1).field_fList).^2));
        
    else% if img is the actual image
        
        if ~isreal(img)% if the field is complex generate intensty
            img = abs(img).^2;
        end
        
        img = img / max(max(img)); % normalize
    end
    
end

% actually plot the thing with established color scaling
imagesc(img);
caxis([this.gen_minColorVal this.gen_maxColorVal]);
axis image off

end