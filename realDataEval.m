%% <realDataEval.m, Run SSIM on real image and appropriate window of sims.>
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
% This has no inputs and ouputs the fitness values for all individuals in a
% generation. It compares a like size window of the sim fields to the real
% image.
%

function err = realDataEval(this) % Could be added to class at some point
% Maybe make it a if statement in evalFit... idk yet...

err = zeros(this.herd_numHerd,2);
err(:,1) = 1:this.herd_numHerd;

simY = this.sol_simPoints{1};
simX = this.sol_simPoints{2};

[y,x] = meshgrid(linspace(0,1,length(simX)),linspace(0,1,length(simY))); % simulation grid
[Y,X] = meshgrid(linspace(0,1,size(this.sol_Image,2)),linspace(0,1,size(this.sol_Image,1))); % image grid

for ii = 1:this.herd_numHerd
    
    simImg = abs(this.herd(ii).field_fList(simY,simX)).^2/max(max(abs(this.herd(ii).field_fList(simY,simX)).^2));
    
    err(ii,2) = 1/newSSIM(...
        this.sol_Image,...
        interp2(y,x,simImg,Y,X,'cubic') ... % do interp so you compare like sizes
        );
    
end

end

function val = newSSIM(im1,im2)

% This function is adapted from on the MATLAB implementations of SSIM by
% Zhou Wang found at https://ece.uwaterloo.ca/~z70wang/research/ssim/
% with reduced operations and memory usage. The final formula is from: 
%   Rehman, Abdul, et al. "SSIM-inspired image denoising using sparse representations."
%   2011 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP). IEEE, 2011.
% that is an improvement making it a true distance metric like MSE.

[x,y] = meshgrid(1:7,1:7);
window = exp(-(...
    ((x-ceil(length(x)/2)).^2)./(2*1.5^2) +...
    ((y-ceil(length(y)/2)).^2)./(2*1.5^2)...
    ));
window = window/sum(window,'all');
window = rot90(window,2);

c(2) = (0.05*255)^2;
c(1) = (0.02*255)^2;

avg1 = conv2(im1,window,'valid');
avg2 = conv2(im2,window,'valid');
avg12 = avg1.*avg2;
avg1 = avg1.^2;
avg2 = avg2.^2;
s12 = conv2(im1.*im2,window,'valid') - avg12;
im1 = conv2(im1.^2,window,'valid') - avg1;
im2 = conv2(im2.^2,window,'valid') - avg2;

mat = sqrt( 2 - ((2*avg12 + c(1))./(avg1 + avg2 + c(1))) - ((2*s12 + c(2))./(im1 + im2 + c(2))) );

val = mean2(mat);

end