%% <normEnergy.m, Sets the field to contain a certain amount of energy.>
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
% This function has a single input value when called with dot notation that
% is the total energy of the field in appropriate units. It then normalizes
% the field of the calling object inorder to sum to this value.
% There is no output
%
% WARNING: This function was created long ago and never tested as it wasn't
% crucial at the time. If you want to use it, you should make sure it is
% working as you expect.


function normEnergy(this,energy)

if nargin == 1 % If no energy is given, get one.
    
    prompt = {'Energy in total field (uJ):'};
    title = 'Power Normalization';
    dims = [1 60];
    definput = {'50'};
    opts.Interpreter = 'tex';
    userInput = inputdlg(prompt,title,dims,definput,opts);
    
    % Check if user input something (avoids NaN)
    if ~size(userInput)
        error('Dialog Box Closed. No user input.');
    end
    
    energy = userInput{1};
    
end


% Find constant to normalize the field then divide by it.
const = energy/sum(this.field_fList,'all');
this.field_fList = this.field_fList .* const;





end