%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                            Constants                              %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Units %%%%
% All are controled by the 'm' factor, including the initial beam
% properties. Was coded with m = 10^3 so changing may produce odd results
% and should be checked first.
m = 10^3;
mm = 10^-3 * m;
cm = 10^-2 * m;
um = 10^-6 * m;
nm = 10^-9 * m;
km = 10^3 * m;

%%%% GA Run and Generation Parameters %%%%
initVals.herd_numHerd = 80; % Number of individuals in herd
initVals.herd_numGens = 100;
initVals.herd_numRuns = 5; % Number of times to start a sim from the very beginning with same parameters.

initVals.init_zProp =  2 * m; % Distance to Propagate
initVals.init_lambda = 1 * um; % Wavelength of light
initVals.init_gridSize = 4 * cm; % Real size of the comp window
initVals.init_beamType = 'hex'; % beamProp field definition to use (Beam type)

%%%% Properties to test %%%%
% The general structure of the propsTest is a cell array of cells. Each
% smaller cell control a single testable parameter. The structure for each
% smaller cell goes: { Sub-name, Range(continuous or list), Mutation factor [0,1], Options to use (look at createInd.m for idea) }
initVals.init_propsTest = {{'PhaseOffset',0:pi/20:2*pi,0.1,logical([1,0,0,0,0,0,0])};...
    {'AmpBeams',[0,1],0.1}};

%%%% This section controls the file saving and picture locations %%%%
% If the absolute path is not given it will search in the current folder
% then MATLAB path.
initVals.file_finalFile = 'finalVals_test.mat'; % Where to save run data
initVals.file_beamFile = 'genAlg_Beam_test.mat'; % Where to look for initial beam info
% initVals.file_solFile = ''; % Real image to converge to
% initVals.file_fitFile = ''; % Custom fitness function to use, look at newEval_template.m for an idea
% initVals.file_gifFile = 'testData.gif'; % Where to save gif of runs


%%%% Figure Flags %%%%
initVals.gen_plotFlag = 1; % 1 = Plots best of each gen, 0 = off
initVals.gen_makeGif = 0; % Needs above to be 1 and gifFile defined. Saves gif of each run

% initVals.sol_realSize = [ , ]; % This one is needed to say real space size of the picture being fed in to the GA ie [10*mm, 7*mm].

%%%% Intial Bema Definition %%%%
% For converging on simulated fields this beam is the ideal case that the
% GA will converge to. For all runs this beam is the initial conditions
% that are used to generate the individuals. Properties that are changing
% above can be set but will be changed as the GA runs
if ~(exist(initVals.file_beamFile,'file') == 2)
    beam = beamPropagation2D(...
        initVals.init_lambda,...
        initVals.init_gridSize,...
        initVals.init_gridSize,...
        2^10,... % any more than 2^10 and it will get really slow
        initVals.init_beamType);
    beam.field_phaseVec = beam.genPropPhase(initVals.init_zProp);
    save(initVals.file_beamFile,'beam');
end

%%%% Initialize the object from the class %%%%
genAlg = genAlgBeamProp(initVals);

%% Run the solver
genAlg.runAlg();

%% Analyze the run
genAlg.parseSols(); % Add any analysis to parseSols function

%% Save the run data
genAlg.saveProperties(); % Takes a few parameters to control what and where to save

%% Empty space because i hate looking at the bottom of my screen.
% I mean, really, who wants to have to look at multiple places on their
% screen instead of just being able to continue scrolling down even if
% those lines are empty. That is quite possibly the stupidest way of
% setting up your IDE that I am baffeled. They all seem to do it and I KNOW
% I can't be the only person who just wants to scroll down.
%
%
%
% Really I only need 10 extra lines you see. Nothing crazy. But NO, I'm the
% crazy one apparently.