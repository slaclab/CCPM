%% <laguerre_IntialBeamDef2D.m, Generates Laguerre-Gaussian field.>
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
% obj.outputProperties2D('laguerre')). These fields are copied directly with
% inputProperties2D.m into the object then the field is generated. This
% function has no returns but sets internal properties of the object.
%
% This function allows you to generate a field that is defined by the
% Laguerre-Gaussian polynomials of arbitrary azimuthal and radial mode
% numbers. Additionally the phase curveature and offset of the total field 
% can be defined.

function laguerre_InitialBeamDef2D(this,inputParams)


% Check to see if predefined values were passed
if nargin == 1
    
    % Set up the user input box for size
    prompt = {'Enter waist (mm):',...
        'Enter radial mode number (p):',...
        'Enter azimuthal mode number (l)',...
        'Enter phase offset',...
        'Enter phase curvature'};
    title = 'Laguerre Gaussian Beam Def';
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
    this.laguerre_Wo = str2double(userInput{1});
    if (mod(userInput{2},1) ~= 0) || (mod(userInput{3},1) ~= 0)
        error('Mode numbers must be integers');
    end
    if (userInput{2} < 0)
        error('Radial mode number must be positive')
    end
    
    this.laguerre_Modes(1) = str2double(userInput{2});
    this.laguerre_Modes(2) = str2double(userInput{3});
    
    this.laguerre_PhaseOffset = str2num(userInput{4});
    if userInput{5} == '0'
        this.laguerre_PhaseCurve = inf;
    else
        this.laguerre_PhaseCurve = str2num(userInput{5}); %#ok<*ST2NM>
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

% Non-normalized Generalized Laguerre-Gauss. 
this.field_fList =...
    LGModes(abs(this.laguerre_Modes(1)),...
            this.laguerre_Modes(2),...
            (2.*(X.^2 + Y.^2))./(this.laguerre_Wo.^2)...
            ) .*...
    exp(- ( (X.^2 + Y.^2)./(this.laguerre_Wo.^2) )); % Normal Gaussian 

% Special weighting for the LG modes based on azimuthal mode
this.field_fList = this.field_fList .*...
    ((sqrt(2).*sqrt(X.^2 + Y.^2))./(this.laguerre_Wo)).^abs(this.laguerre_Modes(2));

% Special phase of the mode based on azimuthal mode
this.field_fList = this.field_fList .*...
    exp(-1i .* this.laguerre_Modes(2) .* (atan2(Y,X)) );

% Addition of the PhaseOffset
this.field_fList = this.field_fList .*...
    exp(1i .* this.laguerre_PhaseOffset);

% Addition of the PhaseCurvature
this.field_fList = this.field_fList .*...
    exp(-1i * (2*pi./this.grid_lambda) .* (X.^2+Y.^2)./(2.*this.laguerre_PhaseCurve));

% Normalize the field
this.field_fList = this.field_fList./max(max(this.field_fList));

end


function mat = LGModes(p,l,mat)

% If else for mode number because 1 and 2 are easy, and more is recursion
if p == 0
    mat = ones(size(mat));
    return;
elseif p == 1
    mat = 1 + l -mat;
    return;
else
    
    % Matrix to hold the mode weighting. H(:,:,3) holds the relevant mode
    L = zeros(size(mat,1),size(mat,2),3);
    
    % Set case one and two to start recursion
    L(:,:,1) = 1;
    L(:,:,2) = 1 + l - mat;
    
    for ii = 2:p
        
        % Recursion condition to generate the mode
        L(:,:,3) = ( ( ((2*p)+l-mat).*L(:,:,2)) - ( (p+l).*L(:,:,1) ))./p;
        
        % Move the old ones back to use next loop
        L(:,:,1) = L(:,:,2);
        L(:,:,2) = L(:,:,3);
        
    end
    
    mat = L(:,:,3);
    
end

end