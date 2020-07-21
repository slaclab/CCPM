%% <evalFit.m, Calculates the fitness values of the individuals.>
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
% This function has no inputs but two outputs. The two outputs are first
% the fitness values of each individual in the current generation. The
% second output is the average fitness across all individuals.

function [err,errAVG] = evalFit(this)

if isempty(this.file_fitFile) % if the user defined their own. Run that
    
    % setup arrays
    err = zeros(this.herd_numHerd,2);
    err(:,1) = 1:this.herd_numHerd; % Number the fitness that is generated
    
    for ii = 1:this.herd_numHerd
        
        % Run the images through the adapted SSIM to generate fitness
        err(ii,2) = 1/(this.SSIM_Dist(...
            this.sol_Image,...
            abs(this.herd(ii).field_fList).^2/max(max(abs(this.herd(ii).field_fList).^2)) ...
            ));
               
    end
    
else
    
    % User defined and unsupported. The general structure can be foud in newEval_template.m
    err = this.file_fitFile(this);
    
end

err(isnan(err)) = 0; % Some infiities generate NaN's. Remove them.

err = sortrows(err,-2);
errAVG = mean(err(:,2));

end