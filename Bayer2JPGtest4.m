%{
Convert image to its four Bayer patterns and then back to JPEG (smooth)

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 30, 2011
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

clear; % clear matlab environment
clc; % clear homescreen
startTime = clock; % keep track of overall runtime

% read image file
fimg = ForensicImage('camCrop2.jpg');

% Get Bayer CFA patterns of image
fimg.getBayer();

% R G
% G B
imgRG = fimg.bayerR;

% G R
% B G
imgGR = fimg.bayerG1;

% G B
% R G
imgGB = fimg.bayerG2;

% B G
% G R
imgBG = fimg.bayerB;

% Get 5x5 bayer difference patterns for Bayer CFA pattern images
[imgRVB,imgRHB,imgRD1,imgRD2] = fimg.getDifPats(1);
[imgG1VB,imgG1HB,imgG1D1,imgG1D2] = fimg.getDifPats(2);
[imgG2VB,imgG2HB,imgG2D1,imgG2D2] = fimg.getDifPats(3);
[imgBVB,imgBHB,imgBD1,imgBD2] = fimg.getDifPats(4);

% R G
% G B

% Get RGB colors for Bayer R CFA pattern image
imgRnew = blockproc(imgRG,[2 2], ...
    @(x)fimg.demoBayerR(x,imgRVB,imgRHB,imgRD1,imgRD2));

% G R
% B G

% Get RGB colors for Bayer G1 CFA pattern image
imgG1new = blockproc(imgGR,[2 2], ...
    @(x)fimg.demoBayerG1(x,imgG1VB,imgG1HB,imgG1D1,imgG1D2));

% G B
% R G

% Get RGB colors for Bayer G2 CFA pattern image
imgG2new = blockproc(imgGB,[2 2], ...
    @(x)fimg.demoBayerG2(x,imgG2VB,imgG2HB,imgG2D1,imgG2D2));

% B G
% G R

% Get RGB colors for Bayer B CFA pattern image
imgBnew = blockproc(imgBG,[2 2], ...
    @(x)fimg.demoBayerB(x,imgBVB,imgBHB,imgBD1,imgBD2));

% Calculate distances from original image
diffR = abs(double(fimg.image)-double(imgRnew));
diffG1 = abs(double(fimg.image)-double(imgG1new));
diffG2 = abs(double(fimg.image)-double(imgG2new));
diffB = abs(double(fimg.image)-double(imgBnew));

% Find stats on distances for all new images
avgR = mean2(diffR)
sdR = std(diffR(:),1)

avgG1 = mean2(diffG1)
sdG1 = std(diffG1(:),1)

avgG2 = mean2(diffG2)
sdG2 = std(diffG2(:),1)

avgB = mean2(diffB)
sdB = std(diffB(:),1)

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
