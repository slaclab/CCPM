%% <rect_IntialBeamDef2D.m, Generates field with rectangularlly arranged beams.>
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
% obj.outputProperties2D('rect')). These fields are copied directly with
% inputProperties2D.m into the object then the field is generated. This
% function has no returns but sets internal properties of the object.
%
% This function allows you to generate a field made up of an even number
% of smaller gaussian beams in a rectangularlly tiled array. While each
% beams' properties can be defined at the end individually there are also
% methods that allow you to define a set curvature for all beams and 
% column(row) phase offsets in the x(y) direction.


function rect_InitialBeamDef2D(this,inputParams)
warning('off', 'MATLAB:colon:nonIntegerIndex');


if nargin == 1
    % Get user input to set up beam positions
    prompt = {'Number of rows:',...
        'Number of colums:',...
        'Aperture in x (mm):',...
        'Aperture in y (mm):',...
        'Waist in x (mm):',...
        'Waist in y (mm):',...
        'Distance between beams in x (mm):',...
        'Distance between beams in y (mm):',...
        };
    title = 'Beam Placement Definition';
    dims = [1 60];
    definput = {'3',...
        '3',...
        num2str(this.grid_xSize/5),...
        num2str(this.grid_ySize/5),...
        num2str( (this.grid_xSize/10) / 1.224),...
        num2str( (this.grid_xSize/10) / 1.224),...
        num2str(this.grid_xSize/5+.1),...
        num2str(this.grid_xSize/5+.1),...
        };
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,title,dims,definput,opts);
    
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    % Set user defined input to stored properties
    this.rect_NRows = str2double(userInput{1});
    this.rect_NCols = str2double(userInput{2});
    this.rect_AperX = str2double(userInput{3});
    this.rect_AperY = str2double(userInput{4});
    this.rect_Wx = str2double(userInput{5});
    this.rect_Wy = str2double(userInput{6});
    this.rect_DistX = str2double(userInput{7});
    this.rect_DistY = str2double(userInput{8});
    
    % Get user input to set up beam phase
    prompt = {'Phase Change for Beams in X:',...
        'Phase Change for Beams in Y:',...
        'Modulo Change in X:',...
        'Modulo Change in Y:',...
        'Global Phase Offset (0-2\pi):',...
        };
    title = 'Beam Phase Definition';
    dims = [1 60];
    definput = {'0',...
        '0',...
        '0',...
        '0',...
        '0',...
        };
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,title,dims,definput,opts);
    
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    
    % set phase definition properties
    diffX = str2num(userInput{1}); %#ok<*ST2NM>
    diffY = str2num(userInput{2});
    modX = str2num(userInput{3});
    modY = str2num(userInput{4});
    gPhaseOff= str2num(userInput{5});
    
    % generate phase offsets
    this.rect_PhaseOffset =...
        regPhaseOffGen(this.rect_NRows,this.rect_NCols,...
        diffX,diffY,...
        gPhaseOff,modX,modY);
    
    
    % Generate beam positions
    this.rect_NBeams = this.rect_NRows * this.rect_NCols;
    
    xPoints = ( (1:this.rect_NCols) - 1) * this.rect_DistX;
    yPoints = ( (1:this.rect_NRows) - 1) * this.rect_DistY;
    
    xPoints = xPoints - xPoints(end)/2;
    yPoints = yPoints - yPoints(end)/2;
    
    xyList = zeros(this.rect_NBeams,2);
    xyList(:,1) = repmat(xPoints,1,this.rect_NRows);
    xyList(:,2) = sort(repmat(yPoints,1,this.rect_NCols));
    
    this.field_beamPos = xyList;
    
    % Ask for whether they want to change amplitude, phase curvature, or beams
    % being on
    prompt = {'Set Which Beams are On? (y or n):',...
        'Set Each Beams'' Amplitude? (y or n)',...
        'Set Phase Curvature? (y or n)',...
        'Set Individual Phase Offset? (y or n)',...
        };
    title = 'Array Overall Properties';
    dims = [1 60];
    definput = {'n',...
        'n',...
        'n',...
        'n',...
        };
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,title,dims,definput,opts);
    
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    % Call finalBeamProps to set the different properties of the fields
    if strcmpi(userInput{1},'y')
        this.rect_BeamsOn = finalBeamProps2D(this,'on');
    else
        this.rect_BeamsOn = ones(1,this.rect_NBeams);
    end
    if strcmpi(userInput{2},'y')
        this.rect_AmpBeams = finalBeamProps2D(this,'amp');
    else
        this.rect_AmpBeams = ones(1,this.rect_NBeams);
    end
    if strcmpi(userInput{3},'y')
        this.rect_PhaseCurve = finalBeamProps2D(this,'curve');
    else
        this.rect_PhaseCurve = ones(1,this.rect_NBeams).*Inf;
    end
    if strcmpi(userInput{4},'y')
        this.rect_PhaseOffset = this.rect_PhaseOffset + finalBeamProps2D(this,'phase');
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
for kk = 1:this.rect_NBeams
    [~,indX] = min(abs( (this.grid_xList - this.field_beamPos(kk,1))'));
    [~,indY] = min(abs( (this.grid_yList - this.field_beamPos(kk,2))));
    indXY(kk,:) = [indX,indY];
end




% Create smaller grid for the beams sized to the aperture
[x,y] = meshgrid(-this.rect_AperX/2:this.grid_dx:this.rect_AperX/2-this.grid_dx,...
    -this.rect_AperY/2:this.grid_dy:this.rect_AperY/2-this.grid_dy);

if this.gen_dispText == 1
    for kk = 1:this.rect_NBeams
        
        % Turn the beam on (leave it alone) or off (set to 0 everywhere)
        if this.rect_BeamsOn(kk) == 0
            
            sG = zeros(size(x)); 
            
            disp(['Beam at x:', num2str(this.field_beamPos(kk,1)),...
                ' and y:', num2str(this.field_beamPos(kk,2)),...
                ' is OFF']);
            
        else
            
            disp(['Beam at x:', num2str(this.field_beamPos(kk,1)),...
                ' and y:', num2str(this.field_beamPos(kk,2)),...
                ' is ON']);
            
            % Standard gaussian beam %% MAYBE: Expand to different beam types
            sG = exp( - (x./this.rect_Wx).^2 ) .* exp( - (y./this.rect_Wy).^2 );
            
            % Scale the current beam to defined amplitude
            sG = sG .* this.rect_AmpBeams(kk);
            
            % Add the defined phase offset for the current beam
            sG = sG .* exp(1i * this.rect_PhaseOffset(kk));
            if this.rect_PhaseOffset(kk)~= 0
                disp(['Beam at x:', num2str(this.field_beamPos(kk,1)),...
                    ' and y:', num2str(this.field_beamPos(kk,2)),...
                    ' has a phase of:', num2str(this.rect_PhaseOffset(kk))]);
            end
            
            % Add the defined phase curvature for the current beam
            sG = sG .* exp( -1i * (2*pi/this.grid_lambda) * (x.^2 + y.^2) / (2 * this.rect_PhaseCurve(kk)) );
            if this.rect_PhaseCurve(kk) ~= inf
                disp(['Beam at x:', num2str(this.field_beamPos(kk,1)),...
                    ' and y:', num2str(this.field_beamPos(kk,2)),...
                    ' has a ROC of:', num2str(this.rect_PhaseCurve(kk))]);
            end
            
        end
        
        
        %%% This is the magic of making the beams circular %%%
        
        % Create the circular mask
        disk = false(size(x,1),size(y,2));
        disk( (x/(this.rect_AperX/2)).^2 + (y/(this.rect_AperY/2)).^2 <= 1 ) = 1;
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
    
else
    for kk = 1:this.rect_NBeams
        
        % Turn the beam on (leave it alone) or off (set to 0 everywhere)
        if this.rect_BeamsOn(kk) == 0
            
            sG = zeros(size(x)); 
            
        else
            
            % Standard gaussian beam %% MAYBE: Expand to different beam types
            sG = exp( - (x./this.rect_Wx).^2 ) .* exp( - (y./this.rect_Wy).^2 );
            
            % Scale the current beam to defined amplitude
            sG = sG .* this.rect_AmpBeams(kk);
            
            % Add the defined phase offset for the current beam
            sG = sG .* exp(1i * this.rect_PhaseOffset(kk));
            
            % Add the defined phase curvature for the current beam
            sG = sG .* exp( -1i * (2*pi/this.grid_lambda) * (x.^2 + y.^2) / (2 * this.rect_PhaseCurve(kk)) );
            
        end
        
        %%% This is the magic of making the beams circular %%%
        
        % Create the circular mask
        disk = false(size(x,1),size(y,2));
        disk( (x/(this.rect_AperX/2)).^2 + (y/(this.rect_AperY/2)).^2 <= 1 ) = 1;
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



% Creates the phase offsets for the different beams
    function pOffs = regPhaseOffGen(nRows, nCols, diffX, diffY, gPhaseOff, modNumX, modNumY)
        
        % Create offsets in each direction
        pXDir = mod( diffX .* ((1:nCols)-1) + gPhaseOff, modNumX);
        pYDir = mod( diffY .* ((1:nRows)-1) + gPhaseOff, modNumY);
        
        % Makes the matricies to add them together
        pXDir = repmat(pXDir, nRows, 1);
        pYDir = repmat(pYDir, nCols, 1)';
        
        % Adds the matricies to get the final thing
        pOffs = (pXDir + pYDir)';
        pOffs = pOffs(:);
        
        
    end

end