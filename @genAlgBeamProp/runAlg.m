%% <runAlg.m, Run through GA steps and call helper functions.>
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
% This is the meat and potatos of the GA class. The overarching function
% that defines the flow of the GA. Not much work happens here but rather
% this function calls all the smaller bits.

function runAlg(this)

for zz = 1:this.herd_numRuns
    
    this.herd = beamPropagation2D(); % Reset the herd at the beginning of each run
    zTime = tic; % start timing for run
    
    this.createHerd(); % fill up this.herd property with initial fields
    
    if this.gen_plotFlag % plot the sol information on left of figure 1
        figure(1);
        clf
        subplot(1,2,1);
        this.plotImage('sol');
        title('Attempted Solution');
    end
    
    % reset ii and solfound
    ii = 1;
    solFound = 0;
    
    while ii <= this.herd_numGens
        
        gTime = tic; % start generation timing
        
        if ~solFound % if we are still generating new solutions
            
            % propagate each field to the position we are curious about
            this.propHerd();
            
            % generate error values and sort by best first
            [err,errAVG] = this.evalFit();
            this.herd = this.herd(err(:,1));
            
            % stop if the best solution is good enough
            if err(1,2) > this.sol_stopCond
                solFound = 1;
            end
            
        end
        
        % assign current generation fitness to outputs
        this.final_fitness(ii,1,zz) = err(1,2);
        this.final_fitness(ii,2,zz) = errAVG;
        
        % assign current generation properties to outputs
        for jj = 1:numel(this.init_propList)
            this.final_props.(this.init_propList{jj})(ii,:,zz) =...
                this.herd(1).(this.init_propList{jj});
        end
        
        if ~solFound % if we are still generating new solutions
            
            % display some quick reference info about generatuion fitness
            % (normally writing to command window is slow but this is a
            % drop in the bucket for this alg)
            disp(['>> Avg Fitness of Run ',num2str(zz),', Gen ',num2str(ii),...
                ' is: ',num2str(errAVG,'%.3f\n')])
            disp(['>> The best individual is: ',num2str(err(1,1)),' at ',...
                num2str(err(1,2),'%.3f\n')])
            
            if this.gen_plotFlag % Plot the current best solution on right
                figure(1);
                subplot(1,2,2);
                this.plotImage('best');
                title('Best Individual');
                drawnow;
                pause(0.25); % again a drop in the bucket. Makes sure you can see it
                
                
                if this.gen_makeGif == 1 % generate gif frame from figure(1)
                    
                    frame = getframe(1);
                    im = frame2im(frame);
                    del = 0.06; % time between frames
                    [imind,cm] = rgb2ind(im,256);
                    
                    if ii == 1
                        imwrite(imind,cm,this.file_gifFile{zz},'gif',...
                            'LoopCount',inf,'DelayTime',del);
                    else
                        imwrite(imind,cm,this.file_gifFile{zz},'gif',...
                            'WriteMode','append','DelayTime',del);
                    end
                end
                
                
            end
            
            
            if ii < this.herd_numGens
                this.cullHerd(); % trim and repopulate herd
            end
            
        end
        
        this.final_timeG(ii,1,zz) = toc(gTime); % save generation time
        
        ii = ii + 1; % increment generation
        
    end
    
    this.final_timeZ(1,1,zz) = toc(zTime); % save run time
    
    
    
end



end