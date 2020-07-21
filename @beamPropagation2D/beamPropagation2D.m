%% <beamPropagation2D.m, Class definition for beamPropagation2D>
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
% This program and class is designed to be able to model non-typical fields
% that are generated from the free space coherent combination of many
% others. It can be used to propagate these complex fields and generate 
% near and far field approximations to initial conditions using the 
% angular spectrum method of propagation. Description of the methods used
% can be found in:
%   Lemons & Carbajo, arXiv:2005.13671, https://arxiv.org/abs/2005.13671
% 
%
% This class holds all the creation and propagation functions and is
% designed to be fully extensible and give access to all neccessary
% functions and properties at any given time.

classdef beamPropagation2D < handle
    
    %% Properties %%
    properties
        
        %%% Gridding %%%
        grid_lambda;
        
        grid_xSize;
        grid_ySize;
        
        grid_npts;
        
        grid_dx;
        grid_dy;
        
        grid_xList;
        grid_yList;
        
        grid_dfx;
        grid_dfy;
        
        grid_fxList;
        grid_fyList;
        
        
        %%% Gaussian Parameters %%%
        
        gauss_Wx;
        gauss_Wy;
        
        gauss_PhaseOffset;
        
        gauss_PhaseCurve;
        
        
        %%% Laguerre Gaussian Parameters %%%
        
        laguerre_Wo;
        
        laguerre_Modes;
        
        laguerre_PhaseOffset;
        
        laguerre_PhaseCurve;
        
        
        %%% Hermite Gaussian Parameters %%%
        
        hermite_Wo;
        
        hermite_Modes;
        
        hermite_PhaseOffset;
        
        hermite_PhaseCurve;
        
        
        %%% xyz List Parameters %%%
        
        input_AperX;
        input_AperY;
        
        input_fileString;
        
        
        %%% Rectangular Parameters %%%
        
        rect_NRows;
        rect_NCols;
        
        rect_NBeams;
        
        rect_AperX;
        rect_AperY;
        
        rect_Wx;
        rect_Wy;
        
        rect_DistX;
        rect_DistY;
        
        rect_BeamsOn;
        
        rect_AmpBeams;
        
        rect_PhaseOffset;
        
        rect_PhaseCurve;
        
        
        %%% Hexangonal Parameters %%%
        
        hex_NRings;
        
        hex_NBeams;
        
        hex_AperX;
        hex_AperY;
        
        hex_Wx;
        hex_Wy;
        
        hex_DistBeams;
        
        hex_BeamsOn;
        
        hex_AmpBeams;
        
        hex_PhaseOffset;
        
        hex_PhaseCurve;
        
        
        %%% Manual Parameters %%%
        
        man_NBeams;
        
        man_AperX;
        man_AperY;
        
        man_Wx;
        man_Wy;
        
        man_AmpBeams;
        
        man_PhaseOffset;
        
        man_PhaseCurve;
        
        
        %%% Field Parameters %%%
        
        field_fList;
        field_beamPos;
        field_Polar;
        field_phaseVec
        
        
        %%% General Paratemeters %%%
        
        gen_nPlotPoints = 400;
        gen_runName;
        gen_savePlot;
        gen_dispText = 0;
        
    end
    
    
    %% Methods %%
    methods
        
        %%% Initialization Function %%%
        function this = beamPropagation2D(varargin)
            
            if nargin == 0 % Allows getting field names without doing anything
                return 
            elseif nargin == 1 % Primarily used to create a new object from and old one
                this.inputProperties2D(varargin{1});
                return
            elseif nargin == 4 % Setup gridding without field
                lambda = varargin{1};
                xLen = varargin{2};
                yLen = varargin{3};
                numPts = varargin{4};
            elseif nargin == 5 % Setup gridding and field with gui helpers
                lambda = varargin{1};
                xLen = varargin{2};
                yLen = varargin{3};
                numPts = varargin{4};
                shapeString = varargin{5};
            elseif nargin == 6 % Setup gridding and field programatically
                lambda = varargin{1};
                xLen = varargin{2};
                yLen = varargin{3};
                numPts = varargin{4};
                shapeString = varargin{5};
                inputParams = varargin{6};
            end
            
            if (numPts - 2^nextpow2(numPts)) ~= 0
                error('Error: numPts must be a factor of 2'); % For the FFT
            end
            
            this.grid_lambda = lambda;
            
            this.grid_xSize = xLen;
            this.grid_ySize = yLen;
            this.grid_npts = numPts;
            
            this.grid_dx = this.grid_xSize / this.grid_npts;
            this.grid_dy = this.grid_ySize / this.grid_npts;
            
            this.grid_xList = this.grid_dx*((-this.grid_npts/2):((this.grid_npts/2)-1)); % Build the x-grid
            this.grid_yList = this.grid_dy*((-this.grid_npts/2):((this.grid_npts/2)-1)); % Build the y-grid
            
            this.grid_dfx = 1/(this.grid_npts*this.grid_dx); % Frequency spacing based on real spaceing
            this.grid_dfy = 1/(this.grid_npts*this.grid_dy); % Frequency spacing based on real spaceing
            
            this.grid_fxList = this.grid_dfx*((-this.grid_npts/2):((this.grid_npts/2)-1)); % Build the fx-grid
            this.grid_fyList = this.grid_dfy*((-this.grid_npts/2):((this.grid_npts/2)-1)); % Build the fy-grid
            
            this.field_fList = complex(zeros(this.grid_npts));
            this.field_fList(1,1) = 0 + eps(0)*1i;
            

            if exist('shapeString','var') % Only set in 5 and 6 input scenarios
                shapeString = lower(shapeString);
                if exist('inputParams','var') % Only set in 6 input scenario
                    switch shapeString % Choose proper initialization method
                        case 'gauss'
                            gauss_InitialBeamDef2D(this,inputParams);
                        case 'laguerre'
                            laguerre_InitialBeamDef2D(this,inputParams);
                        case 'hermite'
                            hermite_InitialBeamDef2D(this,inputParams);
                        case 'input'
                            input_InitialBeamDef2D(this,inputParams);
                        case 'rect'
                            rect_InitialBeamDef2D(this,inputParams);
                        case 'hex'
                            hex_InitialBeamDef2D(this,inputParams);
                        case 'man'
                            man_InitialBeamDef2D(this,inputParams);
                        otherwise
                            error('Not a recognized input type');
                    end
                else
                    switch shapeString % Choose proper initialization method
                        case 'gauss'
                            gauss_InitialBeamDef2D(this);
                        case 'laguerre'
                            laguerre_InitialBeamDef2D(this);
                        case 'hermite'
                            hermite_InitialBeamDef2D(this);
                        case 'input'
                            input_InitialBeamDef2D(this);
                        case 'rect'
                            rect_InitialBeamDef2D(this);
                        case 'hex'
                            hex_InitialBeamDef2D(this);
                        case 'man'
                            man_InitialBeamDef2D(this);
                        otherwise
                            error('Not a recognized input type');
                    end
                end
            end
            
        end
        
        
        %%% Initial Beam Functions %%%
        gauss_InitialBeamDef2D(this,inputParams);
        laguerre_InitialBeamDef2D(this,inputParams);
        hermite_InitialBeamDef2D(this,inputParams);
        input_InitialBeamDef2D(this,inputParams);
        rect_InitialBeamDef2D(this,inputParams);
        hex_InitialBeamDef2D(this,inputParams);
        man_InitialBeamDef2D(this,inputParams);
        
        
        %%% Propagation Functions %%%
        
        f_propField = forwardProp_FreeSpace2D(this,z);
        f_propField = backwardProp_FreeSpace2D(this,z);
        
        phaseVec = genPropPhase(this,z)
        phaseVec = genLensPhase(this,f)
        
        
        %%% Input/Output Functions %%%
        inputProperties2D(this,vec);
        output = outputProperties2D(this,strList);
        nBytes = getSize(this);
        
        
        %%% Plotting & Manipulation Functions %%%
        h = plotField2D(this,field,plotType);
        makeMovie2D(this,plotType,d0,dF,nSteps,fileName);
        normPower(this,power);
        
    end
    
    methods (Access = private)
        
        % Used to get properties for multi-beam field definitions
        valArray = finalBeamProps2D(this,valType);
        
    end
    
    methods (Static)
        
        fwhm = FWHM(lst);
        
    end
    
    
    
end