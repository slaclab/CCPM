%% <createHerd.m, Generate the intial herd for the GA.>
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
% This function takes no inputs and returns no ouputs. It just defines the
% values for properties of the class.
%
% There is not a lot going on here but it makes heavy use of accessing
% properties from strings ==> obj.('hex_AmpBeams') = obj.hex_AmpBeams.

function createHerd(this)

% Use for loop to create numHerd seperate objects. 
% this.herd(1:numHerd) = beamPropagation2D(this.beam_init) sets them all to
% reference the same memory locations
for ii = 1:this.herd_numHerd %#ok<*FXUP>
    this.herd(ii) = beamPropagation2D(this.beam_init);
end

% Create the proper size list of properties
for jj = 1:numel(this.init_propList)
    
    % For each property creat numHerd copies
    herd_props.(this.init_propList{jj}) =...
        repmat(this.beam_init.(this.init_propList{jj}),this.herd_numHerd,1);
    
    % For each individuals property generate the initial values
    for ii = 1:this.herd_numHerd
        herd_props.(this.init_propList{jj})(ii,:) = this.createInd(...
            this.init_propsTest{jj}{2},...
            numel(herd_props.(this.init_propList{jj})(ii,:)),...
            this.beam_props.(this.init_propList{jj}),...
            this.init_propsTest{jj}{4}...
            );
    end
    
end

% Convert it to the proper format to throw back into beamPropagation2D deam
% definition functions
this.herd_props = importProps(this.herd_props,herd_props);


for ii = 1:this.herd_numHerd
    
    % Create the fields
    this.herd(ii).([this.init_beamType,'_InitialBeamDef2D'])(this.herd_props(ii));
    
end


end


% Turns a struct of arrays into an array of structs. Uses more memory but
% is needed for beamPropagation2D's inputProperties2D.m.
function params = importProps(params,props)

list = fieldnames(props);

for ii = 1:numel(list)
    for jj = 1:numel(params)
        params(jj).(list{ii}) = props.(list{ii})(jj,:);
    end
end

end