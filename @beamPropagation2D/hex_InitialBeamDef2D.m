%% <hex_IntialBeamDef2D.m, Generates field with hexagonally arranged beams.>
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
% obj.outputProperties2D('hex')). These fields are copied directly with
% inputProperties2D.m into the object then the field is generated. This
% function has no returns but sets internal properties of the object.
%
% This function allows you to generate a field made up of smaller gaussian
% beams arranged hexagonally. The array is define from the center beam with
% an arbitrary amount of rings around it. The number of beams can be given
% with the centered hexagonal number. While each beams' properties can be
% defined at the end individually there are also methods that allow you to
% define a set curvature for all beams and phase offsets for each ring and
% along the ring in a CCW manor.

function hex_InitialBeamDef2D(this,inputParams)
warning('off', 'MATLAB:colon:nonIntegerIndex');

% Check to see if predefined values were passed
if nargin == 1
    
    % Get user input to set up beam positions
    prompt = {'Number of rings:',...
        'Aperture in x (mm):',...
        'Aperture in y (mm):',...
        'Waist in x (mm):',...
        'Waist in y (mm):',...
        'Distance between beams:',...
        };
    title = 'Beam Placement Definition';
    dims = [1 60];
    % Default values used in 130 lab
    definput = {'2',...
        '3',...
        '3',...
        '1',...
        '1',...
        '3.05',...
        };
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,title,dims,definput,opts);
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    % Set user defined input to stored properties
    this.hex_NRings = str2double(userInput{1});
    this.hex_AperX = str2double(userInput{2});
    this.hex_AperY = str2double(userInput{3});
    this.hex_Wx = str2double(userInput{4});
    this.hex_Wy = str2double(userInput{5});
    this.hex_DistBeams = str2double(userInput{6});
    
    % Generate beam Numbers
    this.hex_NBeams = numBeams(this.hex_NRings);
    
    
    phaseOffs = zeros(1,this.hex_NBeams);
    for ii = 1:this.hex_NRings %#ok<FXUP>
        
        % Get user input to set up beam phase
        prompt = {sprintf('Phase Change for Beams Around Ring %d:',ii),...
            sprintf('Modulo Change in Around Ring %d:',ii),...
            sprintf('Global Phase Offset for Ring %d',ii),...
            };
        prompt{3} = [prompt{3},' (0-2\pi):'];
        title = sprintf('Beam Phase Definition, Ring %d',ii);
        dims = [1 60];
        % Sets default values based on already entered data
        if ii == 1
            definput = {'0',...
                '0',...
                '0',...
                };
        else
            definput = {num2str(diffPhase),...
                num2str(modChange),...
                num2str(gPhaseOff),...
                };
        end
        opts.Interpreter = 'tex';
        userInput = inputdlg(prompt,title,dims,definput,opts);
        
        % Check if user input something (avoids NaN)
        if ~size(userInput)
            error('Dialog Box Closed. No user input.');
        end
        
        
        % set phase definition properties
        diffPhase = str2num(userInput{1}); %#ok<*ST2NM>
        modChange = str2num(userInput{2});
        gPhaseOff = str2num(userInput{3});
        
        
        if ii == 1
            % generate phase offsets for the center dot
            phaseOffs(1) =...
                regPhaseOffGen(1,diffPhase,gPhaseOff,modChange);
        else
            ringIndx = numBeams(ii):-1:numBeams(ii-1)+1;
            % generate phase offsets
            phaseOffs(ringIndx) =...
                regPhaseOffGen(6*(ii-1),diffPhase,gPhaseOff,modChange);
        end
        
        
        
    end
    
    % Set the phase offsets
    this.hex_PhaseOffset = phaseOffs;
    
    
    
    % Generate ordered hexagonal array of points
    xyList = xy_HexPoints(this.hex_NRings,this.hex_DistBeams);
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
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    % If/Else for different answers above
    if strcmpi(userInput{1},'y')
        this.hex_BeamsOn = finalBeamProps2D(this,'on');
    else
        this.hex_BeamsOn = ones(1,this.hex_NBeams);
    end
    if strcmpi(userInput{2},'y')
        this.hex_AmpBeams = finalBeamProps2D(this,'amp');
    else
        this.hex_AmpBeams = ones(1,this.hex_NBeams);
    end
    if strcmpi(userInput{3},'y')
        this.hex_PhaseCurve = finalBeamProps2D(this,'curve');
    else
        this.hex_PhaseCurve = ones(1,this.hex_NBeams).*Inf;
    end
    if strcmpi(userInput{4},'y')
        this.hex_PhaseOffset = this.hex_PhaseOffset + finalBeamProps2D(this,'phase')'; % Need to add phase rather than reset it
    end
    
elseif nargin == 2
    
    % Feed in predefined values
    this.inputProperties2D(inputParams);
    
    % Generate ordered hexagonal array of points
    xyList = xy_HexPoints(this.hex_NRings,this.hex_DistBeams);
    this.field_beamPos = xyList;
    
    this.field_fList = complex(zeros(this.grid_npts));
    this.field_fList(1,1) = 0 + (4.9407e-324)*1i;
    %     this.field_FList = this.field_fList;
    
end


% Create indices for the beam centers in the large grid
indXY = zeros(size(this.field_beamPos));
for kk = 1:this.hex_NBeams
    [~,indX] = min(abs( (this.grid_xList - this.field_beamPos(kk,1))'));
    [~,indY] = min(abs( (this.grid_yList - this.field_beamPos(kk,2))));
    indXY(kk,:) = [indX,indY];
end


% Create smaller grid for the beams sized to the aperture
[x,y] = meshgrid(-this.hex_AperX/2:this.grid_dx:this.hex_AperX/2-this.grid_dx,...
    -this.hex_AperY/2:this.grid_dy:this.hex_AperY/2-this.grid_dy);

if this.gen_dispText == 1
    for kk = 1:this.hex_NBeams
        
        
        
        % Turn the beam on (leave it alone) or off (set to 0 everywhere)
        if this.hex_BeamsOn(kk) == 0
            
            sG = zeros(size(x));
            
            disp(['Beam at x:', num2str(this.field_beamPos(kk,1)),...
                ' and y:', num2str(this.field_beamPos(kk,2)),...
                ' is OFF']);
            
        else
            disp(['Beam at x:', num2str(this.field_beamPos(kk,1)),...
                ' and y:', num2str(this.field_beamPos(kk,2)),...
                ' is ON']);
            
            % Standard gaussian beam %% MAYBE: Expand to different beam types
            sG = exp( - (x./this.hex_Wx).^2 ) .* exp( - (y./this.hex_Wy).^2 );
            
            % Scale the current beam to defined amplitude
            sG = sG .* this.hex_AmpBeams(kk);
            
            % Add the defined phase offset for the current beam
            sG = sG .* exp(1i * this.hex_PhaseOffset(kk));
            if this.hex_PhaseOffset(kk)~= 0
                disp(['Beam at x:', num2str(this.field_beamPos(kk,1)),...
                    ' and y:', num2str(this.field_beamPos(kk,2)),...
                    ' has a phase of:', num2str(this.hex_PhaseOffset(kk))]);
            end
            
            % Add the defined phase curvature for the current beam
            sG = sG .* exp( -1i * (2*pi/this.grid_lambda) * (x.^2 + y.^2) /...
                (2 * this.hex_PhaseCurve(kk)) );
            if this.hex_PhaseCurve(kk) ~= inf
                disp(['Beam at x:', num2str(this.field_beamPos(kk,1)),...
                    ' and y:', num2str(this.field_beamPos(kk,2)),...
                    ' has a ROC of:', num2str(this.hex_PhaseCurve(kk))]);
            end
            
        end
        
        
        
        %%% This is the magic of making the beams circular %%%
        
        % Create the circular mask
        disk = false(size(x,1),size(y,2));
        disk( (x/(this.hex_AperX/2)).^2 + (y/(this.hex_AperY/2)).^2 <= 1 ) = 1;
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
    
    this.field_fList = this.field_fList./max(max(this.field_fList));
    
else
    for kk = 1:this.hex_NBeams
        
        
        % Turn the beam on (leave it alone) or off (set to 0 everywhere)
        if this.hex_BeamsOn(kk) == 0
            
            sG = zeros(size(x));
            
        else
            
            % Standard gaussian beam %% MAYBE: Expand to different beam types
            sG = exp( - (x./this.hex_Wx).^2 ) .* exp( - (y./this.hex_Wy).^2 );
            
            % Scale the current beam to defined amplitude
            sG = sG .* this.hex_AmpBeams(kk);
            
            % Add the defined phase offset for the current beam
            sG = sG .* exp(1i * this.hex_PhaseOffset(kk));
            
            % Add the defined phase curvature for the current beam
            sG = sG .* exp( -1i * (2*pi/this.grid_lambda) * (x.^2 + y.^2) /...
                (2 * this.hex_PhaseCurve(kk)) );
            
        end
        
        
        %%% This is the magic of making the beams circular %%%
        
        % Create the circular mask
        disk = false(size(x,1),size(y,2));
        disk( (x/(this.hex_AperX/2)).^2 + (y/(this.hex_AperY/2)).^2 <= 1 ) = 1;
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



%  Generate the phase offsets based on the rings number
    function pOffs = regPhaseOffGen(nBeams, diffBeams, gPhaseOff, modNum)
        
        pOffs = zeros(1,nBeams); %#ok<PREALL>
        
        if nBeams == 1
            pOffs = mod(gPhaseOff, modNum);
        else
            pOffs = mod(diffBeams .* ((1:nBeams)-1) + gPhaseOff ,modNum);
        end
    end

% Generate the xy points of the hexagonal points
%%% Way harder than you originally think to do for an arbitrary number
%%% of beams AND do it so they are numbered in order. So basically it
%%% is stolen code.
    function xyList = xy_HexPoints(nRings,dist)
        
        % This code makes the last ring incompletely so just make one more
        % than you need. If nRings < 300 we should be good.
        nRingsMake = nRings + 1;
        nBeams = (3 * (nRings - 1)^2 ) + (3 * (nRings - 1) ) + 1;
        
        % Initialize our points
        xyList = zeros(nBeams,2);
        counter = 1+1;
        xHexPoints = 0;
        yHexPoints = 0;
        
        % Do some black magic that I haven't taken the time to run through
        for ii = 1:nRingsMake %#ok<FXUP>
            for jj = 1:ii
                xHexPoints = xHexPoints + dist;
                yHexPoints = yHexPoints; %#ok<*ASGSL>
                xyList(counter,:) = [xHexPoints,yHexPoints];
                counter = counter + 1;
            end
            for jj = 1:ii-1
                xHexPoints = xHexPoints;
                yHexPoints = yHexPoints + dist;
                xyList(counter,:) = [xHexPoints,yHexPoints];
                counter = counter + 1;
            end
            for jj = 1:ii
                xHexPoints = xHexPoints - dist;
                yHexPoints = yHexPoints + dist;
                xyList(counter,:) = [xHexPoints,yHexPoints];
                counter = counter + 1;
            end
            for jj = 1:ii
                xHexPoints = xHexPoints - dist;
                yHexPoints = yHexPoints;
                xyList(counter,:) = [xHexPoints,yHexPoints];
                counter = counter + 1;
            end
            for jj = 1:ii
                xHexPoints = xHexPoints;
                yHexPoints = yHexPoints - dist;
                xyList(counter,:) = [xHexPoints,yHexPoints];
                counter = counter + 1;
            end
            for jj = 1:ii
                xHexPoints = xHexPoints + dist;
                yHexPoints = yHexPoints - dist;
                xyList(counter,:) = [xHexPoints,yHexPoints];
                counter = counter + 1;
            end
            
        end
        
        % Scale the points to the hexagonal grid
        xyList(:,1) = xyList(:,1) + (xyList(:,2)./2);
        xyList(:,2) = (sqrt(3)/2) .* xyList(:,2);
        
        % Recover only the rings you need
        xyList = xyList(1:nBeams,:);
        
        % Reorder and swap xy to look more like our setup
        xyList = flip(xyList,2);
        xyList(:,2) = -xyList(:,2);
        
    end

% Outputs the number of beams based on the number of rings
    function nBeams = numBeams(nRings)
        
        nBeams = (3 * (nRings - 1)^2 ) + (3 * (nRings - 1) ) + 1;
        
    end

end