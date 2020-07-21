%% <genAlgBeamProp.m, Class definition for genAlgBeamProp>
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
% This class is designed to hold all of the relevent information to run a
% genetic algorithm (GA) using beamPropagation2D in order to reconstruct
% experimental data or explore the huge parameter space afforded by
% coherent synthesis. Description of the methods used can be found in:
%   Lemons & Carbajo, arXiv:2005.13671, https://arxiv.org/abs/2005.13671
%
% This class is more rigid in the implementation and definition than the
% beamPropagation2D class. Because it is using that class it naturally has
% some 'hard-coded' instructions specific to it. That being said, it should
% be able to use any of the beam definition functions no matter how trivial
% it might be (ie. find the intial size of a gaussian beam in simulation 
% compared to experimental size).

classdef genAlgBeamProp < handle
    
    properties
        
        %%% Herd Parameters %%%
        herd_numHerd
        herd_numGens
        herd_numRuns
        herd_props
        herd = beamPropagation2D();
        
        %%% Intitial Parameters %%%
        init_zProp
        init_lambda
        init_gridSize
        init_beamType
        init_propsTest
        init_propList
        
        %%% Beam Parameters %%%
        beam_init
        beam_props
        
        %%% File Save/Load Parameters %%%
        file_finalFile
        file_beamFile
        file_solFile
        file_gifFile
        file_fitFile
        
        %%% Solve Parameters %%%
        sol_Type
        sol_Image
        sol_stopCond
        sol_realSize
        sol_simPoints
        
        %%% Final Parameters %%%
        final_fitness
        final_props
        final_timeG
        final_timeZ
        
        %%% General Parameters %%%
        gen_plotFlag = 0;
        gen_minColorVal
        gen_maxColorVal
        gen_makeGif = 0;
        
        %%% Test Variables %%%
        % I use these to save a variable that is internal to the
        % calculation that I may want to look at after. SHOULDN'T HOLD
        % CRUCIAL/IMPORTANT INFO. Expected to be overwritten constanly
        test_varSave
        
        %%% Constants that shouldn't be set %%%
        
    end
    
    properties (GetAccess = public, SetAccess = private) %%% Constant Parameters %%%
        const_npts = 2^10;
    end
    
    methods
        
        function this  = genAlgBeamProp(varargin)
            
            % Shuffle the RNG so that each run is actually significant.
            rng('shuffle');
            
            % return empty class for property names mainly
            if nargin == 0
                return
            end
                
            if nargin == 1
                
                if isstruct(varargin{1}) % setup from struct
                    
                    this.inputProperties2D(varargin{1})
                    
                    if ~isempty(this.final_props) % used when initiallizing from saved data
                        return
                    end
                    
                elseif isa(varargin{1},'genAlgBeamProp') % setup from object
                    
                    this.inputProperties2D(varargin{1})
                    return;
                    
                elseif strcmpi(varargin{1},'gui') % use GUI to define intial conditions
                    
                    this.initGui();
                    
                end
              
            end
        
            this.setupAlg(); % setup intial internal parameters
                        
        end
        
        % public input/output and running functions
        
        setupAlg(this,setupVal)
        runAlg(this)
        plotImage(this,img)
        
        inputProperties2D(this,vec);
        output = outputProperties2D(this,strList);
        saveProperties(this,varName,fileName,matchType,override);
        
        nBytes = getSize(this);
        
        varargout = parseSols(this);
        
        
    end
    
    
    methods (Access = private)
       
        % internal helper functions
        
        initGui(this)
        
        importImage(this)
        
        createHerd(this)
        propHerd(this)
        
        [err,errAVG] = evalFit(this)
        this = cullHerd(this)
        
    end
    
    methods (Static, Access = public)
        
        % functions that don't need the class to function but are related
        % in practical use
    
        genes = createInd(range,nBeams,existVals,options)
        val = SSIM_Dist(im1,im2)
        fwhm = FWHM(lst);
        vals = discreteMap(vals,Range)
        outStruct = initStruct(varargin);
        
    end
    
end