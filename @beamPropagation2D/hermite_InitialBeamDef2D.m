%% <hermite_IntialBeamDef2D.m, Generates Hermite-Gaussian field.>
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
% obj.outputProperties2D('hermite')). These fields are copied directly with
% inputProperties2D.m into the object then the field is generated. This
% function has no returns but sets internal properties of the object.
%
% This function allows you to generate a field that is defined by the
% Hermite-Gaussian polynomials of arbitrary x and y mode numbers.
% Additionally the phase curveature and offset of the total field can be
% defined.

function hermite_InitialBeamDef2D(this,inputParams)


% Check to see if predefined values were passed
if nargin == 1
    
    % Set up the user input box for size
    prompt = {'Enter waist (mm):',...
        'Enter horizontal mode number (m):',...
        'Enter vertical mode number (n)',...
        'Enter phase offset',...
        'Enter phase curvature'};
    title = 'Hermite Gaussian Beam Def';
    dims = [1 35];
    definput = {num2str(floor(this.grid_xSize/10)),...
        '0',...
        '1',...
        '0',...
        '0'};
    userInput = inputdlg(prompt,title,dims,definput);
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    % Set values
    this.hermite_Wo = str2double(userInput{1});
    if (mod(userInput{2},1) ~= 0) || (mod(userInput{3},1) ~= 0)
        error('Mode numbers must be integers');
    end
    if (userInput{2} < 0)
        error('Radial mode number must be positive')
    end
    
    this.hermite_Modes(1) = str2double(userInput{2}); % x mode number
    this.hermite_Modes(2) = str2double(userInput{3}); % y mode number
    
    this.hermite_PhaseOffset = str2num(userInput{4});
    if userInput{5} == '0'
        this.hermite_PhaseCurve = inf; % Avoids NaN errors when users really want no curvature
    else
        this.hermite_PhaseCurve = str2num(userInput{5}); %#ok<*ST2NM>
    end
    
elseif nargin == 2
    
    % Feed in predefined values
    this.inputProperties2D(inputParams)
    
    % Reset the field
    this.field_fList = complex(zeros(this.grid_npts));
    this.field_fList(1,1) = 0 + (4.9407e-324)*1i;
    
end


% Create meshgrid of points to avoid for-loop
[X,Y] = meshgrid(this.grid_xList,this.grid_yList);

% Non-normalized hermite gaussian mode
this.field_fList =...
    HGModes(this.hermite_Modes(1),...           % Hermite mode in the x
            (sqrt(2).*X)./(this.hermite_Wo)...
            ) .*...
    HGModes(this.hermite_Modes(2),...           % Hermite mode in the y
            (sqrt(2).*Y)./(this.hermite_Wo)...
            ) .*...
    exp(- ( (X.^2 + Y.^2)./(this.hermite_Wo.^2) )) ; % Gaussian mode

% PhaseOffset addition
this.field_fList = this.field_fList .*...
    exp(1i .* this.hermite_PhaseOffset);

% PhaseCurvature addition
this.field_fList = this.field_fList .*...
    exp(-1i * (2*pi./this.grid_lambda) .* (X.^2+Y.^2)./(2.*this.hermite_PhaseCurve));

% Normalize the field
this.field_fList = this.field_fList./max(max(this.field_fList));

end


function mat = HGModes(mode,mat)

% These are specifically the physicist define hermite modes ie. H(2) = 2*x

% If else for mode number because 1 and 2 are easy, and more is recursion
if mode == 0
    mat = ones(size(mat));
    return;
elseif mode == 1
    mat = 2.*mat;
    return;
else
    
    % Matrix to hold the mode weighting. L(:,:,3) holds the relevant mode 
    H = zeros(size(mat,1),size(mat,2),3);
    
    % Set case one and two to start recursion
    H(:,:,1) = 1;
    H(:,:,2) = 2.*mat;
    
    for ii = 2:mode
        
        % Recursion condition to generate the mode
        H(:,:,3) = (2.*mat.*H(:,:,2))-(2.*(mode-1).*H(:,:,1));
        
        % Move the old ones back to use next loop
        H(:,:,1) = H(:,:,2);
        H(:,:,2) = H(:,:,3);
        
    end
    
    % Set output as last one
    mat = H(:,:,3);
    
end

end