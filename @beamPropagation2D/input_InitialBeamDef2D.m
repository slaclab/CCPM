%% <input_IntialBeamDef2D.m, Generates field from file.>
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
% obj.outputProperties2D('input')). These fields are copied directly with
% inputProperties2D.m into the object then the field is generated. This
% function has no returns but sets internal properties of the object.
%
% This function allows you to generate a field from a comma seperated
% value file with three columns (x,y,z) or from an image. In either case
% the defined aperture controls the size on the computational grid. From
% there the image or csv values are scaled and interpolated to fit within
% this region of the grid. 
%
% Currently there is no way to define curvature or phase information
% because I am not sure how to do this in an inteligent way for input
% usually being time averaged intensity instead of instantaneous field
% amplitude.

function input_InitialBeamDef2D(this,inputParams)

if nargin == 1
    % Get the size that the user wants to fill in the grid
    prompt = {'Enter aperture in x (mm):','Enter aperture in y (mm):'};
    title = 'XYZ Point List Beam Def 2D';
    dims = [1 35];
    definput = {num2str(this.grid_xSize),num2str(this.grid_ySize)};
    userInput = inputdlg(prompt,title,dims,definput);
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    % Sets user input
    this.input_AperX = str2double(userInput{1});
    this.input_AperY = str2double(userInput{2});
    
    % Reads in the file
    [fileName,filePath] = uigetfile('*.*');
    
    if any(fileName == 0) && any(filePath == 0)
        error('Dialog Box Closed. No user input.');
    end
    
    % Create full string for future use
    this.input_fileString = fullfile(filePath,fileName);
    
elseif nargin == 2
    
    this.inputProperties2D(inputParams);
    
    % Reset the field
    this.field_fList = complex(zeros(this.grid_npts));
    this.field_fList(1,1) = 0 + (4.9407e-324)*1i;
        
    % Create full string for future use
    [filePath,fileName,fileExt] = fileparts(this.input_fileString);
    fileName = [fileName fileExt];
    this.input_fileString = fullfile(filePath,fileName);
    
end

if contains(fileName,'.csv')
    % Read file and get different axis
    T = csvread(this.input_fileString);
    x = T(:,1)';
    y = T(:,2)';
    z = T(:,3)';
    
    
    % Finds the unique values of x and y for gridding along with max value
    x = unique(x);
    I = x(end);
    
    y = unique(y);
    J = y(end);
    
    z = reshape(z,length(x),length(y));
    z = z./(max(max(z)));
    
    
elseif contains(fileName,'.png') || contains(fileName,'.jpg')
    
    % Loads the image and makes sure it is black and white
    [z,cmap,~] = imread(this.input_fileString);
    
    if ~isempty(cmap)
        z = rgb2gray(ind2rgb(z,cmap));
    elseif size(z,3) == 3
        z = rgb2gray(z);
    end
    
    % Create vectors for interpolation later
    I = size(z,2);
    x = 1:I;
    
    J = size(z,1);
    y = 1:J;
    
    z = double(z)./max(max(double(z)));
    
end
% Rescales the grid to the appropriate size for the grid
x = x .* (this.input_AperX / I);
xnew = x(1):this.grid_dx:x(end);

y = y .* (this.input_AperY / J);
ynew = y(1):this.grid_dy:y(end);

[x,y] = meshgrid(x,y);
[xnew,ynew] = meshgrid(xnew,ynew);


% Interpolates the input z to the new grid in x and y
znew = interp2(x,y,z,xnew,ynew,'cubic');

kpts = size(znew,1);
lpts = size(znew,2);


% If else statement to account for different sized grids (even and odd)
if mod(kpts,2) == 0 || mod(lpts,2) == 0
    
    this.field_fList( ( (this.grid_npts -kpts) / 2 ) + 1 : (this.grid_npts + kpts) / 2 ,...
        ( (this.grid_npts -lpts) / 2 ) + 1 : (this.grid_npts + lpts) / 2 ) = znew;
    
elseif mod(kpts,2) == 0 || mod(lpts,2) == 1
    
    this.field_fList( ( (this.grid_npts -kpts) / 2 ) + 1 : (this.grid_npts + kpts) / 2 ,...
        ((this.grid_npts -lpts + 1) / 2) + 1 : ((this.grid_npts + lpts -1) / 2) + 1 ) = znew;
    
elseif mod(kpts,2) == 1 || mod(lpts,2) == 0
    
    this.field_fList( ((this.grid_npts -kpts + 1) / 2) + 1 : ((this.grid_npts + kpts -1) / 2) + 1 ,...
        ( (this.grid_npts -lpts) / 2 ) + 1 : (this.grid_npts + lpts) / 2 ) = znew;
    
else
    
    this.field_fList( ((this.grid_npts -kpts + 1) / 2) + 1 : ((this.grid_npts + kpts -1) / 2) + 1 ,...
        ((this.grid_npts -lpts + 1) / 2) + 1 : ((this.grid_npts + lpts -1) / 2) + 1 ) = znew;
    
end

% Normalizing the field.
this.field_fList = this.field_fList./max(max(this.field_fList));

end