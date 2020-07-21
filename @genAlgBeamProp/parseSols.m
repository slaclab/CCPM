%% <parseSols.m, Analysis and reconstruction of GA runs>
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
% This function has no input and an optional two outputs. The first output
% is the table that is generated with results and the second is handles to
% the figures that are generated.
%
% The main purpose of this program is to gather all analysis that would
% need to be done across all runs outside of the main GA loop to save
% computation time there. Since all properties and fitness values needed to
% reconstruct a run are saved as it progresses, the run can effectively be
% recreated later. The bulk of the work is in the reconBeams sub function
% which recreates the best beam in each run in a single indexed variable.

function varargout = parseSols(this)


bestBeams = reconBeams(this); % Reconstruction of Beams



%%%% General Informational Items %%%%
genTime = mean(this.final_timeG(:));
runTime = mean(this.final_timeZ);
totTime = sum(this.final_timeZ);
props = [this.init_propsTest{:}];

fprintf(' \n')
disp(['>> Problem solved with ', upper(this.init_beamType), ' beam type'])
disp(['>> There were ', num2str(this.herd_numGens), ' generations',...
    ' with ', num2str(this.herd_numHerd), ' individuals over ',...
    num2str(this.herd_numRuns), ' runs.'])
disp(['>> The variable properties were: ', strjoin(props(1:4:end),', '),'.'])
disp(['>> Each generation took ~', num2str(round(genTime)),' s.'])
disp(['>> Each run took ~', num2str(round(runTime/60)),' min.'])
disp(['>> The total time taken was ', num2str(totTime/60/60),' h.'])
fprintf(' \n')


%%%% Sort fitness by best runs %%%%
fitList = fliplr(permute(this.final_fitness,[3 1 2])); % size = [nRuns, nGens, 2].
% ^^^ (:,:,1) = Best fitness of each gen for each run, (:,:,2) = Avg fitness of each gen for each run

finalFit = permute(this.final_fitness(end,1,:),[1 3 2]); % 1D end of run best fitness

[~,bestRuns(:,1)] = sortrows(fitList(:,:,1),'descend'); % Order of runs by highest best fitness first
[~,bestRuns(:,2)] = sortrows(fitList(:,:,2),'descend'); % Order of runs by highest avg fitness first


%%%% Tabulate the Data %%%%
runNames = cell(this.herd_numRuns,1);
Rank = zeros(this.herd_numRuns,1);
for ii = 1:this.herd_numRuns
    runNames{ii} = ['Run ' num2str(ii)]; % Auto run name generation
    Rank(bestRuns(ii,1)) = ii; % Rank for each run. Index using sortted order and assign ii.
end

NormalizedFitness = finalFit'/max(finalFit)*100; % Percentage of best overall run
AbsoluteFitness = finalFit'; % Need another, more descriptive, variable for matlab tables

T = table(Rank,AbsoluteFitness,NormalizedFitness);
T.Properties.RowNames = runNames;

for ii = 1:length(this.init_propsTest)
    tmp{1} = matlab.lang.makeValidName(this.init_propsTest{ii}{1}); % make variable name out of props under test
    tmp{2} = this.init_propList{ii,1};
    
    % This just creates variables from the props under test and fills them
    % with prop vals of best individual of each run
    for jj = 1:this.herd_numRuns
        
        % I know. Eval statements. But if you've got here then either it
        % ran properly or you are really interested in exploiting it.
        eval([tmp{1} '(' num2str(jj) ',:) = this.final_props.' tmp{2} '(end,:,' num2str(jj) ');'])
    end
    eval(['T.' tmp{1} ' = ' tmp{1} ';']); % Assign to table
    
end

disp(T)


%%%% Plot the Solution %%%%
f(1) = figure(1);
clf;
set(f(1), 'Name', 'Beam to solve for','NumberTitle','off');

% sol plot
subplot(1,2,1);
this.plotImage('sol');
title('Attempted Solution');
set(gca,'Fontsize',40);

% approx plot
subplot(1,2,2);
if strcmpi(this.sol_Type,'image') % real data
    
    % rare example of feading a matrix to plotImage
    this.plotImage(bestBeams(bestRuns(1,1)).field_fList(this.sol_simPoints{1},this.sol_simPoints{2}));
    
else % sim data
    
    imagesc(abs(bestBeams(bestRuns(1,1)).field_fList).^2);
    axis off square
    
end

title(sprintf('Run #%i',bestRuns(1,1)));
set(gca,'Fontsize',40);


%%%% Plot the Fitness Lists %%%%
f(2) = figure(2);
clf
set(f(2), 'Name', 'Fitness Lists','NumberTitle','off');
clear linecolors

% Set Params
colorScale = 1.3; % how many more colors to generate in the colorMap. We only use the back nRuns.
colorBack = {'k','w'}; % Set background color of outer and inner plots
fontSize = [40,20];

lineColors(:,:,1) = colormap(parula(this.herd_numRuns*colorScale)); % Colors for best
lineColors(:,:,2) = colormap(gray(this.herd_numRuns*colorScale)); % Colors for avg

% Delete unused colors and flip the direction. Makes
lineColors(1:end-this.herd_numRuns,:,:) = [];
lineColors = flipud(lineColors);

% OUTER PLOT
hold on
for jj = 1:2 % plot 
    for ii = this.herd_numRuns:-1:1
        if ii == 1 || ii == this.herd_numRuns % Make best and worst clear
            p(ii,jj) = plot(this.herd_numGens:-1:1,fitList(bestRuns(ii,1),:,jj),...
                'color',lineColors(ii,:,jj),...
                'LineWidth',6);
        else
            p(ii,jj) = plot(this.herd_numGens:-1:1,fitList(bestRuns(ii,1),:,jj),...
                'color',lineColors(ii,:,jj),...
                'LineWidth',3);
        end
    end
end

if this.sol_stopCond ~= inf
    pThres = plot(this.herd_numGens:-1:1,ones(1,this.herd_numGens)*this.sol_stopCond,...
        '--w',...
        'LineWidth',3);
end
hold off

ylabel('Fitness (Arb.)');
xlabel('Generation');

% Generate legend
if this.sol_stopCond ~= inf % if we have a threshold line to worry about
    if size(bestRuns,1) == 1 % only one run
        l = legend([p(1,1), pThres],...
            sprintf('Run #%i',bestRuns(1,1)),...
            'End Condition',...
            'Location','northwest');
    else
        l = legend([p(1,1) p(end,1), pThres],...
            sprintf('Run #%i',bestRuns(1,1)),...
            sprintf('Run #%i',bestRuns(end,1)),...
            'End Condition',...
            'Location','northwest');
    end
else
    if size(bestRuns,1) == 1% only one run
        l = legend([p(1,1)],...
            sprintf('Run #%i',bestRuns(1,1)),...
            'Location','northwest');
    else
        l = legend([p(1,1) p(end,1)],...
            sprintf('Run #%i',bestRuns(1,1)),...
            sprintf('Run #%i',bestRuns(end,1)),...
            'Location','northwest');
    end
end
xlim([1 this.herd_numGens])
set(gca,'FontSize',fontSize(1),'Color',colorBack{1});
set(l,'color',colorBack{1},'textcolor',colorBack{2});

% INNER PLOT
axes('Position' ,[.08 .6 .25 .25]); % upper left somewhere
box on
set(gca,'FontSize',fontSize(2),'Color',colorBack{1},...
    'XColor',colorBack{2},'YColor',colorBack{2});


smallVals = 20;
xlim([1 smallVals])

hold on
for jj = 1:2
    for ii = this.herd_numRuns:-1:1
        if ii == 1 || ii == this.herd_numRuns % Make best and worst clear
            plot(smallVals:-1:1,...
                fitList(bestRuns(ii,1),end-smallVals+1:end,jj),...
                'color',lineColors(ii,:,jj),...
                'LineWidth',2)
        else
            plot(smallVals:-1:1,...
                fitList(bestRuns(ii,1),end-smallVals+1:end,jj),...
                'color',lineColors(ii,:,jj))
        end
    end
end
hold off


%%%% Plot All Approximations %%%%
f(3) = figure(3);
clf;
set(f(3), 'Name', 'All approximation plots','NumberTitle','off');
clear plots I

p = numSubPlots(this.herd_numRuns); % subplot numbers

N = size(bestBeams(1).field_fList,1);
plots = zeros(N,N*2); % big enough to plot two side by side, Intensity and Phase

for ii = 1:this.herd_numRuns
    subplot(p(1),p(2),ii)
    
    
    plots(1:N,1:N) = abs(bestBeams(ii).field_fList).^2; % Intensity
    plots(1:N,N+1:end) = angle(bestBeams(ii).field_fList) + pi; % Phase
    plots(1:N,N+1:end) = max(max(plots(1:N,1:N))) .*...
        plots(1:N,N+1:end)./max(max(plots(1:N,N+1:end))); % Normalize so both are clear
    
    solRank = find(bestRuns(:,1) == ii);
    
    imagesc(plots)
    axis off
    daspect([1 1 1])
    title(['Run ', num2str(ii),', Rank ', num2str(solRank)])
    
    
end


%%%% Output Variables %%%%

if nargout == 1
    varargout{1} = T;
elseif nargout == 2
    varargout{1} = T;
    varargout{2} = f;
end

end


%% Helper Functions

function beams = reconBeams(this)

this.beam_init = beamPropagation2D(this.beam_props); % build representative beam object
this.beam_init.field_fList = ...
    this.beam_init.forwardProp_FreeSpace2D(this.init_zProp); % propagate it

for ii = 1:this.herd_numRuns % create all the beams
    beams(ii) = beamPropagation2D(this.beam_props);
end

beamParams = this.beam_init.outputProperties2D(this.init_beamType);

for ii = 1:this.herd_numRuns
    
    % Build changed property values
    for jj = 1:length(fieldnames(this.final_props))
        beamParams.(this.init_propList{jj}) = ...
            this.final_props.(this.init_propList{jj})(end,:,ii);
    end
    
    % build the new fields and propagate
    beams(ii).([this.init_beamType, '_', 'InitialBeamDef2D'])(beamParams);
    beams(ii).field_fList = ...
        beams(ii).forwardProp_FreeSpace2D(this.init_zProp);
    
end

end

function p = numSubPlots(n)
% Builds the numbers for plotting an arbitrary amount of subplots. The
% ceil(sqrt(n)) makes it so that we are always building at least a square
% of plots. Taking n/p(2) then makes it so that if we are just over the
% square number (ie. 17 plots) it centers it.

p(2) = ceil(sqrt(n));
p(1) = ceil(n/p(2));

end