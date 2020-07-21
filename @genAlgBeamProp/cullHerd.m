%% <cullHerd.m, Remove bad individuals, cross them over, and mutate.>
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
% This function has no input or outputs.
%
% Besides the runAlg.m fucntion this one is where the real magic happens.
% This function works to sort the individuals by fitness, keep a certain
% amount of them based on elitism selection, and make a new herd used the
% kept ones as parents. The children have their properties defined by a mix
% of the parents' values. Lastly each of the childrens properties has a
% posibility of mutation where they are assigned random values in the
% range.
%
% For selection the top 10% and a randomly chosen 10% are kept. The
% remaining 80% of the herd is discarded.
%
% For crossover two distinct random individuals, mom and dad, are picked to
% create a new individual based on their genes. The child is initialized as
% a copy of the mom. Then approximately 50% of the genes are overwritten
% with information from the dad. For cases where all beams must have the
% same information this 50/50 chance determines which parents information
% is used.
%
% The last step is mutation. It works differently based on if properties
% are all the same or as set to not change beams from initial conditions.
% In general, however, the mutation chance determines how many of the
% properties change per calling of cullHerd. For all beams the whole
% property has the mutation chance to change. For inidividually changing
% beams each one has the mutation chance to change. Last note is that
% discrete and continous ranges are fully respected here like in
% createInd.m

function cullHerd(this)

% Generate change/keep integer numbers to use for indexing
N = numel(this.herd);
numBest = floor(N * .1);
numRand = ceil(N/5) - numBest;
numKeep = numBest+numRand;

randKeep = randperm(N-numBest,numRand)+numBest; % gen rand ones to keep
for ii = 1:length(randKeep)
    this.herd(numBest+ii) = beamPropagation2D(this.herd(randKeep(ii))); % assign to safe positions
end


count = 0;
while count < N - numKeep % while pop is low, fill
    
    % Choose mom and dad
    mom = randi(numKeep);
    dad = randi(numKeep);
    if mom ~= dad % make sure they are distinct
        
        % Crossover Baybeee!
        this.herd(numKeep+count+1) = breedParents(...
            this.herd(mom),this.herd(dad),...
            this.init_beamType,this.init_propsTest);
        
        count = count + 1; % keep track of how many we have made
    end
end

for ii = 1:N % rebuild herd from properties
    this.herd(ii).([this.init_beamType,'_InitialBeamDef2D'])...
        (this.herd(ii).outputProperties2D(this.init_beamType));
end


function baby = breedParents(mom,dad,beamType,propsTest)

baby = beamPropagation2D(mom); % gen baby template
    
for jj = 1:size(propsTest,1) % loop over properties
    
    % gen strings and values for indexing/use
    propStr = [beamType,'_',propsTest{jj}{1}];
    existVals = this.beam_props.(propStr); % Could probably find a better way than setting this as global
    
    if length(dad.(propStr)) > 1 % multibeam fields
        
        % Choose which props come from dad
        if rand > 0.5
            nCross = ceil(dad.([beamType,'_NBeams'])/2);
            allParent = dad;
        else
            nCross = floor(dad.([beamType,'_NBeams'])/2);
            allParent = mom;
        end
        
        % get dad props
        dadGenes = randperm(dad.([beamType,'_NBeams'])-1,nCross)+1;
        
        if strcmpi(propsTest{jj}{4},'all')
            baby.(propStr) = allParent.(propStr); % set all baby props from random parent
        else
            baby.(propStr)(dadGenes) = dad.(propStr)(dadGenes); % set respective props from dad
        end
        
    else % single beam fields
        if rand > 0.5
            baby.(propStr) = dad.(propStr);
        else
            baby.(propStr) = mom.(propStr);
        end
    end
    
    % Mutation block
    if length(propsTest{jj}{2}) > 2 % discrete
        
        if strcmpi(propsTest{jj}{4},'all') % all one value
            if propsTest{jj}{3} > rand
                baby.(propStr) = repmat(...
                    genAlgBeamProp.discreteMap(ones(1),propsTest{jj}{2}),...
                    length(baby.(propStr)),1);
            end
            
        elseif islogical(propsTest{jj}{4}) % certain beams retain initial conds
            for kk = 1:length(baby.(propStr))
                if propsTest{jj}{3} > rand
                    baby.(propStr)(kk) = genAlgBeamProp.discreteMap(ones(1),propsTest{jj}{2});
                end
            end
            baby.(propStr)(propsTest{jj}{4}) =...
                existVals(propsTest{jj}{4}); % set back to initial
            
        elseif isempty(propsTest{jj}{4}) % discrete but no special case
            for kk = 1:length(baby.(propStr))
                if propsTest{jj}{3} > rand
                    baby.(propStr)(kk) = genAlgBeamProp.discreteMap(ones(1),propsTest{jj}{2});
                end
            end
        end
        
    else % Continuous
        if strcmpi(propsTest{jj}{4},'binary') % I guess binary is a special case of discrete
            for kk = 1:length(baby.(propStr))
                if propsTest{jj}{3} > rand
                    baby.(propStr)(kk) = genAlgBeamProp.discreteMap(ones(1),propsTest{jj}{2});
                end
            end
            
        elseif strcmpi(propsTest{jj}{4},'all') % all one value
            if propsTest{jj}{3} > rand
                baby.(propStr) = repmat(...
                    rand.*(propsTest{jj}{2}(2)-propsTest{jj}{2}(1)) + propsTest{jj}{2}(1),...
                    length(baby.(propStr)),1);
            end
        elseif islogical(propsTest{jj}{4}) % certain beams retain initial conds
            for kk = 1:length(baby.(propStr))
                if propsTest{jj}{3} > rand
                    baby.(propStr)(kk) = ...
                        rand.*(propsTest{jj}{2}(2)-propsTest{jj}{2}(1)) + propsTest{jj}{2}(1);
                end
            end
            baby.(propStr)(propsTest{jj}{4}) =...
                existVals(propsTest{jj}{4}); % set back to initial
            
        elseif isempty(propsTest{jj}{4}) % Continuous but no special case
            for kk = 1:length(baby.(propStr))
                if propsTest{jj}{3} > rand
                    baby.(propStr)(kk) = ...
                        rand.*(propsTest{jj}{2}(2)-propsTest{jj}{2}(1)) + propsTest{jj}{2}(1);
                end
            end
        end
        
    end
    
end

end




end