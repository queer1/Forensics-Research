%{
Median filter for images that ignores the origin pixel.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 17, 2011
updated: July 31, 2011
Copyright (C) Summer 2011  Skidmore College

This software was developed as part of a Skidmore College Summer
Faculty/Student Research Grant lead by Prof. Michael Eckmann.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.
%}

% Image median filter that ignores center pixel
% image = grayscale image
% win = window size, must be positive odd integer
function result = medfilt2new(image, win)
    
    % make a win by win pixel window filled with 1s
    domain = ones(win);
    
    % set the center pixel to 0
    domain(floor(win^2/2)+1) = 0;
    
    % n = # of pixels in neighborhood
    n = sum(sum(domain));
    
    % get middle two neighbors
    num = n/2;
    a = ordfilt2(image,num, domain);
    b = ordfilt2(image,num+1,domain);
    
    % return median of neighborhood
    result = (double(a)+double(b))./2;
    
end
