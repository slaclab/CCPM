%% <man_InitialBeamDef2D.m, Create field with arbitrary gaussian beams.>
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
% This function takes a single input is called with dot notation. This
% input needs to be a MATLAB struct with fieldnames that are the same as
% the property names of this class (can be generated with 
% obj.outputProperties2D('man')). These fields are copied directly with
% inputProperties2D.m into the object then the field is generated. This
% function has no returns but sets internal properties of the object.
% 
% This is the most general way of building a field to propagate in
% the class. For each beam placed this function allows you to define: size,
% center, aperture, amplitude, phase curvature, and phase offset. This has
% been added to allow for the creation of any odd field that can be
% imagined. The only sanity check that might be added to the code is to
% make sure that each aperture doesn't overlap but doesn't have it right
% now.
%
% Defining a beam in this way with the GUI will take a good amount of time
% to go through each of the above parameters. It recommended to output the
% properties and, as long as the number of beams doesn't change, edit them
% outside and import them after.

function man_InitialBeamDef2D(this,inputParams)

if nargin == 1
    
    % Retrieve number of user defined beams
    prompt = {'Number of beams:'};
    title = 'Manual Beam Definition';
    dims = [1 60];
    definput = {'0'};
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,title,dims,definput,opts);
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    this.man_NBeams = str2double(userInput{1});
    
    for ii = 1:this.man_NBeams
        
        % Get user input to set up each beam
        prompt = {'Center in x:',...
            'Center in y:',...
            'Aperture in x (mm):',...
            'Aperture in y (mm):',...
            'Waist in x (mm):',...
            'Waist in y (mm):',...
            'Amplitude:',...
            'Phase offset:',...
            'Phase curvature:',...
            };
        title = sprintf('Beam %d Definition',ii);
        dims = [1 60];
        definput = {'0',...
            '0',...
            num2str(this.grid_xSize/5),...
            num2str(this.grid_ySize/5),...
            num2str( (this.grid_xSize/10) / 1.224),...
            num2str( (this.grid_xSize/10) / 1.224),...
            '1',...
            '0',...
            '0',...
            };
        opts.Interpreter = 'tex';
        userInput = inputdlg(prompt,title,dims,definput,opts);
        
        % Check if user input something (avoids NaN)
        if ~size(userInput)
            error('Dialog Box Closed. No user input.');
        end
        
        
        % Set user parameters
        this.field_beamPos(ii,:) =...
            [str2double(userInput{1}) str2double(userInput{2})];
        this.man_AperX(ii) = str2double(userInput{3});
        this.man_AperY(ii) = str2double(userInput{4});
        this.man_Wx(ii) = str2double(userInput{5});
        this.man_Wy(ii) = str2double(userInput{6});
        this.man_AmpBeams(ii) = str2double(userInput{7});
        this.man_PhaseOffset(ii) = str2num(userInput{8});
        if userInput{9} == '0'
            this.man_PhaseCurve(ii) = inf;
        else
            this.man_PhaseCurve(ii) = str2num(userInput{9}); %#ok<*ST2NM>
        end
        
    end
    
    
elseif nargin == 2
    
    % Feed in predefined values
    this.inputProperties2D(inputParams);
    
    % Reset the field
    this.field_fList = complex(zeros(this.grid_npts));
    this.field_fList(1,1) = 0 + (4.9407e-324)*1i;
    %     this.field_FList = this.field_fList;
    
end


% Create indices for the beam centers in the large grid
indXY = zeros(size(this.field_beamPos));
for kk = 1:this.man_NBeams
    [~,indX] = min(abs( (this.grid_xList - this.field_beamPos(kk,1))'));
    [~,indY] = min(abs( (this.grid_yList - this.field_beamPos(kk,2))));
    indXY(kk,:) = [indX,indY];
end



for kk = 1:this.man_NBeams
    
    % Create smaller grid for the beams sized to the aperture
    [x,y] = meshgrid(...
        -this.man_AperX(kk)/2:this.grid_dx:this.man_AperX(kk)/2-this.grid_dx,...
        -this.man_AperY(kk)/2:this.grid_dy:this.man_AperY(kk)/2-this.grid_dy);
    sG = zeros(size(x)); %#ok<PREALL>
    
    
    % Standard gaussian beam %% MAYBE: Expand to different beam types
    sG = exp( - (x./this.man_Wx(kk)).^2 ) .* exp( - (y./this.man_Wy(kk)).^2 );
    
    % Scale the current beam to defined amplitude
    sG = sG .* this.man_AmpBeams(kk);    
    
    % Add the defined phase offset for the current beam
    sG = sG .* exp(1i * this.man_PhaseOffset(kk));    
    
    % Add the defined phase curvature for the current beam
    sG = sG .* exp( -1i * (2*pi/this.grid_lambda) * (x.^2 + y.^2) /...
        (2 * this.man_PhaseCurve(kk)) );
    
    
    %%% This is the magic of making the beams circular %%%
    
    % Create the circular mask
    disk = false(size(x,1),size(y,2));
    disk( (x/(this.man_AperX(kk)/2)).^2 + (y/(this.man_AperY(kk)/2)).^2 <= 1 ) = 1;
    sG = sG .* disk;
    
    %%% New version with indexing. Significantly faster now.
    this.field_fList(...
        indXY(kk,2)-round(size(sG,1)/2)+mod(size(sG,1),2):indXY(kk,2)-1+round(size(sG,1)/2),...
        indXY(kk,1)-round(size(sG,2)/2)+mod(size(sG,2),2):indXY(kk,1)-1+round(size(sG,2)/2)...
        ) = this.field_fList(...
        indXY(kk,2)-round(size(sG,1)/2)+mod(size(sG,1),2):indXY(kk,2)-1+round(size(sG,1)/2),...
        indXY(kk,1)-round(size(sG,2)/2)+mod(size(sG,2),2):indXY(kk,1)-1+round(size(sG,2)/2)...
        ) + sG;
    
    
end

% Normalize the field
this.field_fList = this.field_fList./max(max(this.field_fList));

end