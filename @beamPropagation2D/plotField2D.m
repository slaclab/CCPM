%% <plotField2D.m, Plots various properties of the field.>
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
% This function has two input when called with dot notation. The first
% controls the type of manipulation the data goes through for plotting.
% Possible parameters are 'abs' which generates a plot of the intensity of
% the field and 'ang' which generates a wrapped phase plot. The second
% input is the matrix to be plotted and is optional. If this is given then
% the axes are still generated from the object but the given matrix is
% plotted agaisn't them. If the number of points in the given matrix is
% less than gen_nPlotPoints of the calling object it will either fail or
% plot odd things.
% There is an optional output of the handle to the generated plot.

%% Plotting function for any 2D input field
function varargout = plotField2D(this,plotType,field)

% Catch statement to make it easier/quicker to plot the internal field
if nargin == 2
    field = this.field_fList;
end

% Generate the lists for plotting
xList = pltPoints(this.grid_xList,this.gen_nPlotPoints);
yList = pltPoints(this.grid_yList,this.gen_nPlotPoints);
plotList = pltPoints(field,this.gen_nPlotPoints);


if strcmpi('abs',plotType)
    % For abs it's easy to plot
    h = pcolor(xList,yList,abs(plotList).^2);
elseif strcmpi('angle',plotType)
    % For angle we need to do more to add a helpful colorbar
    h = pcolor(xList,yList,angle(plotList));
    c = colorbar;
    c.Limits = [-pi,pi];
    c.Ticks = [-pi,0,pi];
    c.TickLabels = {'-pi','0','pi'};
else
    error('Unrecognized type, use either ''abs'' or ''angle''');
end


shading interp; % Needed because of pcolor being flat surf. Could change to imagesc in the future

% Axis setting and labeling
xlim([this.grid_xList(1),-this.grid_xList(1)]);
ylim([this.grid_yList(1),-this.grid_yList(1)]);
xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', xt);
yt = get(gca, 'YTick');
set(gca, 'YTick', yt, 'YTickLabel', yt);
xlabel('mm');
ylabel('mm');
set(gca, 'FontSize',16);
pbaspect([1 1 1]); % Make each pixel square sized

if nargout == 1
    varargout{1} = h; % Return 
end


%    To recover the electric field take the real part of input TODO


    function fList = pltPoints(fList,nPlotPoints)
        
        % In this function linspace is used to make sure the number of
        % points is constant. round is to make sure they can be used as
        % indicies.
        
        [xPts,yPts] = size(fList);
        
        if xPts == 1 || yPts == 1 % Case for vectors
            fList = fList(round(linspace(1,length(fList),nPlotPoints)));
        else % Case for matricies
            fList = fList(...
                round(linspace(1,size(fList,1),nPlotPoints)),...
                round(linspace(1,size(fList,2),nPlotPoints))...
                );
        end
        
    end


end