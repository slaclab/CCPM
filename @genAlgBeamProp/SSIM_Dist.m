%% <SSIM_Dist.m, Calculates true distance SSIM for two images.>
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
% This function is adapted from on the MATLAB implementations of SSIM by
% Zhou Wang found at https://ece.uwaterloo.ca/~z70wang/research/ssim/
% with reduced operations and memory usage. The final formula is from: 
%   Rehman, Abdul, et al. "SSIM-inspired image denoising using sparse representations."
%   2011 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP). IEEE, 2011.
% that is an improvement making it a true distance metric like MSE.
%
% It is a special SSIM function designed to work with images that are the 
% double data type and normalized to one. It takes two inputs and output a
% single valuef from the calculation.

function val = SSIM_Dist(im1,im2)

% Meshgrid of a gaussian window used for filtering and bluring images
[x,y] = meshgrid(1:7,1:7);
window = exp(-(...
    ((x-ceil(length(x)/2)).^2)./(2*1.5^2) +...
    ((y-ceil(length(y)/2)).^2)./(2*1.5^2)...
    ));

% Normalize and rotate for the convolutions below
window = window/sum(window,'all');
window = rot90(window,2);

% constants to protect from infinities
c(2) = (0.05*255)^2;
c(1) = (0.02*255)^2;

% window the images with the above
avg1 = conv2(im1,window,'valid');
avg2 = conv2(im2,window,'valid');

% calculate cross and same intensities
avg12 = avg1.*avg2;
avg1 = avg1.^2;
avg2 = avg2.^2;

% substract from clear images
s12 = conv2(im1.*im2,window,'valid') - avg12;
im1 = conv2(im1.^2,window,'valid') - avg1;
im2 = conv2(im2.^2,window,'valid') - avg2;

% combine info according to paper equation
mat = sqrt( 2 - ((2*avg12 + c(1))./(avg1 + avg2 + c(1))) - ((2*s12 + c(2))./(im1 + im2 + c(2))) );

% output mean of the equation
val = mean(mat,'all');

end