%% <gauss_IntialBeamDef2D.m, Generates Gaussian field.>
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
% obj.outputProperties2D('gauss')). These fields are copied directly with
% inputProperties2D.m into the object then the field is generated. This
% function has no returns but sets internal properties of the object.
%
% This function allows you to generate a field that is a cenetered Gaussian
% profile. Additionally the phase curveature and offset of the total field
% can be defined.

function gauss_InitialBeamDef2D(this,inputParams)


% Check to see if predefined values were passed
if nargin == 1
    
    % Set up the user input box for size
    prompt = {'Enter waist in x (mm):',...
        'Enter waist in y (mm):',...
        'Enter phase offset',...
        'Enter phase curvature'};
    title = 'Gaussian Beam Def 2D';
    dims = [1 35];
    definput = {num2str(floor(this.grid_xSize/10)),...
        num2str(floor(this.grid_ySize/10)),...
        '0',...
        '0'};
    userInput = inputdlg(prompt,title,dims,definput);
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    % Set values
    this.gauss_Wx = str2double(userInput{1});
    this.gauss_Wy = str2double(userInput{2});
        
    this.gauss_PhaseOffset = str2num(userInput{3});
    if userInput{4} == '0'
        this.gauss_PhaseCurve = inf; % Avoids NaN errors when users really want no curvature
    else
        this.gauss_PhaseCurve = str2num(userInput{4}); %#ok<*ST2NM>
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

% Standard non-normalized Gaussian
this.field_fList = exp(- (...
    ( X ./ this.gauss_Wx).^2 +...
    ( Y ./ this.gauss_Wy).^2 ));

% PhaseOffset addition
this.field_fList = this.field_fList .*...
    exp(1i * this.gauss_PhaseOffset);

% PhaseCurvature addition
this.field_fList = this.field_fList .*...
    exp(-1i * (2*pi/this.grid_lambda) * (X.^2+Y.^2)/(2*this.gauss_PhaseCurve));

% Normalize the field
this.field_fList = this.field_fList./max(max(this.field_fList));

end