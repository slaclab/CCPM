%% <getSize.m, Calculates the object's size in memory.>
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
% This function takes no inputs when called with dot notation. If called
% with a single output it returns the size of calling object in MiB. If
% called without outputs it instead prints the size in MiB to the console.

% Using this method on very large spaning objects is generally a bad idea.
% It makes copies (and takes that much more memory to run) because this
% avoids using eval statements.

function varargout = getSize(this)

props = properties(this);
totSize = 0;

if isempty(props) % never hit this but should catch odd objects
    totSize = whos('obj');
    totSize = totSize.bytes;
    
else
    % Begin the loop 
    for ii  = 1:length(props)
        s = this.(props{ii}); % make copy of property
        if isobject(s) % if it's an object, get recursive!
            s = getSize(s);
            totSize = totSize + s;
        else % if it's not, add up the size it is taking
            s = whos('s');
            totSize = totSize + s.bytes;
        end
    end
end


if nargout == 0
    
    fprintf(1, '>> %.4f MiB\n', totSize/1024^2); % print size
    
elseif nargout == 1
    
    varargout{1} = totSize; % output bare number
    
end


end