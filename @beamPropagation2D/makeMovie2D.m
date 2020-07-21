%% <makeMovie2D.m,  Generate a gif of the field propagating.>
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
% This function takes a variable number of input arguments. The minimum is
% a single char string input when called via dot notation that follows the
% same restrictions as plotField2D.m. Otherwise the inputs are: plot type,
% initial location, final location, number of steps, file name to save
% with.
% This function has no output.
%
% Ideally the field input to this should be 2^10 by 2^10 or so. This is
% because the function generates a single matrix where the third
% diminesion holds the frames. As such, keeping the number of points
% small is key for avoiding running out of memory.

function makeMovie2D(this,plotType,d0,dF,nSteps,fileName)

if nargin == 1
    
    error('Must give plot type, ''abs'' or ''angle'''); 

elseif nargin == 2
    
    % Get the other values if not given
    prompt = {'Distance to start at:',...
        'Distance to finish at:',...
        'Number of steps:',...
        'File Name:',...
        };
    title = 'Movie Setup';
    dims = [1 60];
    definput = {'0',...
        '15000',...
        '30',...
        '',...
        };
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,title,dims,definput,opts);
    
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    
    d0 = str2num(userInput{1}); %#ok<*ST2NM>
    dF = str2num(userInput{2});
    nSteps = str2num(userInput{3});
    fileName = userInput{4};
    
    
    if isempty(fileName) % Cheeky setting of the file name
        rng('shuffle');
        tmp = round(rand*10^8);
        filename = ['I_Didnt_Give_A_FileName_',num2str(tmp),'.gif'];
    end
    if ~contains(fileName,'.gif')
        fileName = [fileName,'.gif'];
    end
    
elseif narargin == 6
    
    if ~isnumeric(d0) || ~isnumeric(dF) || ~isnumeric(nSteps) || (~ischar() || ~isstring(fileName))
        error('Improper inputs given');
    end
    if dF < d0
        error('Final position must be greater than initial');
    end
    if mod(nSteps,1) ~= 0 
        error('nSteps must be an integer');
    end    
    
else
    error('Improper inputs given');
end



% Generate the steps to take and the matrix to hold the final
propList = linspace(d0,dF,nSteps);
gifMat = zeros(this.grid_npts,this.grid_npts,nSteps);


reverseStr = '';
if strcmpi('abs',plotType)
    
    for ii = 1:nSteps
        
        % Propagate then normallize for the images
        gifMat(:,:,ii) = this.forwardProp_FreeSpace2D(propList(ii));
        gifMat(:,:,ii) = abs(gifMat(:,:,ii)).^2;
        gifMat(:,:,ii) = normForImg(gifMat(:,:,ii));
        
        % Display the progress because it takes a while
        percentDone = 100 * ii / (nSteps+1);
        msg = sprintf('Percent done: %3.1f', percentDone);
        
        % I don't remember what is happening here. Oops.
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    
    
elseif strcmpi('angle',plotType)
    
    for ii = 1:nSteps
        
        % Propagate then normallize for the images
        gifMat(:,:,ii) = this.forwardProp_FreeSpace2D(propList(ii));
        gifMat(:,:,ii) = angle(gifMat(:,:,ii));
        gifMat(:,:,ii) = normForImg(gifMat(:,:,ii));
        
        % Display the progress because it takes a while
        percentDone = 100 * ii / (nSteps+1);
        msg = sprintf('Percent done: %3.1f', percentDone);
        
        % I don't remember what is happening here. Oops.
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
    end
    
    
else
    
    error('Unrecognized type, use either ''abs'' or ''angle''');
    
end

if this.grid_npts > 2^10 % Force use of 2^10 plotting points, gotcha
    div = this.grid_npts / 2^10;
    gifMat = gifMat(1:div:end,1:div:end,:);
end

% Create the gif. Squeeze because imwrite needs 2D matricies
cmap = parula(256);
imwrite(squeeze(gifMat(:,:,1)),cmap,...
    fileName,'gif','WriteMode','overwrite',...
    'DelayTime',0.1,'LoopCount',Inf);
for ii = 2:nSteps
    imwrite(squeeze(gifMat(:,:,ii)),cmap,...
        fileName,'gif','WriteMode','append','DelayTime',0.1);
end



% Display the progress
msg = 'Percent done: 100%'; %Don't forget this semicolon
fprintf([reverseStr, msg]);
fprintf('\n');

    function mat = normForImg(mat)
        
        mat = mat - min(mat,[],'all'); % subtract the min
        mat = mat./max(mat,[],'all'); % make the max one
        mat = mat.*255 + 1; % make the max 255 and reset values between 1 and 256
        
    end


end