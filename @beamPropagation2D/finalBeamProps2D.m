%% <finalBeamProps2D.m, Creates the dialogs for gathering beam properties.>
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
% This function is more or less an internal function used in the rect and
% hex beam def functions. It generates a dialog box with input fields
% arranged in the shape of the beams for easier assignment of values.
% It takes a single char string as input when called with dot notiation.
% That controls which values are asked for and some of the processing.
% There is also a single output which is the values in a singular
% dimensioned matrix based on number of beams and valType.

function valArray = finalBeamProps2D(this,valType)

% Grab beam positions and query numbers
positions = this.field_beamPos;
N = numel(positions(:,1));
NuniX = numel(unique(positions(:,1)));
NuniY = numel(unique(positions(:,2)));

% Create figure & its components
figWidth = NuniX*60;
figHeight = NuniY*60;

% It will get really tiny if these conditions are not present
if figWidth < 250
    figWidth = 250;
end
if figHeight < 250
    figHeight = 250;
end


% Grab screen size info and place GUIs in the center
screenInfo = get(0,'screensize');
screenInfo = screenInfo(3:4);

figLeft = (screenInfo(1)/2) - (figWidth/2);
figBott = (screenInfo(2)/2) - (figHeight/2);

fig = figure('Visible','off',...
    'Name','Final Properties',...
    'Numbertitle','off',...
    'Position',[figLeft figBott figWidth figHeight]);
set(fig, 'MenuBar', 'none');
set(fig, 'ToolBar', 'none');


% create the labels for the checkboxes
for ii = 1:N
    userInput.label{ii} = ii;
end

% If else block to handle tricky zero cases for beam positions
if (NuniX == 1) && (NuniY == 1)
    % Scale the positions for the boxes
    positions(:,1) = positions(:,1)...
        * (NuniX/2)...
        / 1;
    positions(:,2) = positions(:,2)...
        * (NuniY/2)...
        / 1;
elseif NuniX == 1
    % Scale the positions for the boxes
    positions(:,1) = positions(:,1)...
        * (NuniX/2)...
        / 1;
    positions(:,2) = positions(:,2)...
        * (NuniY/2)...
        /abs(max(positions(:,2)));
elseif NuniY == 1
    % Scale the positions for the boxes
    positions(:,1) = positions(:,1)...
        * (NuniX/2)...
        /abs(max(positions(:,1)));
    positions(:,2) = positions(:,2)...
        * (NuniY/2)...
        /1;
else
    % Scale the positions for the boxes
    positions(:,1) = positions(:,1)...
        * (NuniX/2)...
        /abs(max(positions(:,1)));
    positions(:,2) = positions(:,2)...
        * (NuniY/2)...
        /abs(max(positions(:,2)));
end



% enumerate the checkboxes and position them
if strcmpi(valType,'on')
    
    % create positions of the checkboxes
    widthChecks = 35;
    heightChecks = 20;
    distChecks = 40;
    
    % Place them in the center
    positions(:,1) = (figWidth/2-widthChecks/2) + distChecks*positions(:,1);
    positions(:,2) = (figHeight/2-heightChecks/2)+15 + distChecks*positions(:,2);
    
    % Create the positions for checkboxes
    for ii = 1:N
        userInput.position{ii} =...
            [positions(ii,1) positions(ii,2) widthChecks heightChecks];
    end
    
    % Create the checkboxes and their interaction
    for k=1:N
        userInput.interact(k) =...
            uicontrol(fig , 'Style','checkbox','String',userInput.label{k},...
            'Position',userInput.position{k},'Value',1);
        set(userInput.interact(k),'KeyPressFcn',@check_call);
    end
    
elseif strcmpi(valType,'amp')
    
    % create positions of the checkboxes
    widthBoxes = 35;
    heightBoxes = 20;
    distBoxes = 40;
    
    % Place them in the center
    positions(:,1) = (figWidth/2-widthBoxes/2) + distBoxes*positions(:,1);
    positions(:,2) = (figHeight/2-heightBoxes/2)+15 + distBoxes*positions(:,2);
    
    % Create the positions for checkboxes
    for ii = 1:N
        userInput.position{ii} =...
            [positions(ii,1) positions(ii,2) widthBoxes heightBoxes];
    end
    
    % Create the checkboxes and their interaction
    for k = 1:N
        userInput.interact(k) =...
            uicontrol(fig , 'Style','edit','String','1.0',...
            'Position',userInput.position{k});
    end
    
    
    
elseif strcmpi(valType,'curve')
    
    % create positions of the checkboxes
    widthBoxes = 35;
    heightBoxes = 20;
    distBoxes = 40;
    
    % Place them in the center
    positions(:,1) = (figWidth/2-widthBoxes/2) + distBoxes*positions(:,1);
    positions(:,2) = (figHeight/2-heightBoxes/2)+15 + distBoxes*positions(:,2);
    
    % Create the positions for checkboxes
    for ii = 1:N
        userInput.position{ii} =...
            [positions(ii,1) positions(ii,2) widthBoxes heightBoxes];
    end
    
    % Special box to grab a phase curvature default value to save the user
    % from filling in N checkboxes
    defaultVal = inputdlg('Enter default phase curvature:',...
        'Final Properties',...
        [1 40],{'0'});
    defaultVal = defaultVal{1};
    
    
    
    % Create the checkboxes and their interaction
    for k = 1:N
        userInput.interact(k) =...
            uicontrol(fig , 'Style','edit','String',defaultVal,...
            'Position',userInput.position{k});
    end
    
    
    
elseif strcmpi(valType,'phase')
    
    % create positions of the checkboxes
    widthBoxes = 35;
    heightBoxes = 20;
    distBoxes = 40;
    
    % Place them in the center
    positions(:,1) = (figWidth/2-widthBoxes/2) + distBoxes*positions(:,1);
    positions(:,2) = (figHeight/2-heightBoxes/2)+15 + distBoxes*positions(:,2);
    
    % Create the positions for checkboxes
    for ii = 1:N
        userInput.position{ii} =...
            [positions(ii,1) positions(ii,2) widthBoxes heightBoxes];
    end
    
    % Set default value to 0 so that it doesn't change global offset
    defaultVal = 0;
    
    
    
    % Create the checkboxes and their interaction
    for k = 1:N
        userInput.interact(k) =...
            uicontrol(fig , 'Style','edit','String',defaultVal,...
            'Position',userInput.position{k});
    end
    
    
end


% create the push button to exit the dialog
userInput.push = uicontrol(fig ,'style','pushbutton','units','pixels',...
    'position',[figWidth/2-90/2 5 90 20],'string','OK');

% set the pushing response
set(userInput.push,'callback',@push_call);
set(userInput.push,'KeyPressFcn',@push_call);

% makes the handles a retrievable part of the figure
guidata(fig,userInput);
set(fig, 'Visible', 'on');

% Checks to see if return was pressed
if (strcmp( get(gcf,'CurrentKey'), 'return'))
    push_call(fig, eventdata, userInput);
end


% waits for user input, otherwise the code continues to excicute
uiwait;

% Makes sure user didn't cancel out to protect from NaNs
if ~exist('valArray','var')
    error('Dialog Box Closed. No user input.');
end

% Transform output to a useable form
if strcmpi(valType,'on')
    if numel(valArray) ~= 1
        valArray = cell2mat(valArray)';
    end
elseif strcmpi(valType,'amp')
    valArray = str2double(valArray)';
elseif strcmpi(valType,'curve')
    valArray = str2double(valArray)';
    valArray(valArray == 0) = inf;
elseif strcmpi(valType,'phase')
    valArray = cellfun(@str2num,valArray);
end



% Callback function for check_boxes
    function check_call(fig, eventdata, handles)
        handles = guidata(fig);
        if strcmpi(eventdata.Key,'return')
            % Checks which box is pressed and changes state
            boxNum = str2double(eventdata.Source.String);
            val = handles.interact(boxNum).Value;
            val = ~val;
            set(handles.interact(boxNum),'Value',val);
        end
    end

% Callback function for button
    function push_call(fig, eventdata, handles)
        if strcmpi(eventdata.EventName,'Action') || strcmpi(eventdata.Key,'return')
            handles = guidata(fig);
            % If else to handle different data types
            if strcmpi(valType,'on')
                valArray = get(handles.interact, 'Value');
            elseif strcmpi(valType,'amp')
                valArray = get(handles.interact, 'String');
            elseif strcmpi(valType,'curve')
                valArray = get(handles.interact, 'String');
            elseif strcmpi(valType,'phase')
                valArray = get(handles.interact, 'String');
            end
            close(gcf)
        end
    end

end