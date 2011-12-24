%{
Demosaic RAW images to JPEG.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: July 18, 2011
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
thresh = 0.035; % used in edge detection

% read image file
frimg = ForensicRawImage('rawTest.dng');

% Crop image to 512 by 512 square pixels
frimg.crop512();

% Get 8 bit raw image
im8bit = frimg.imraw8();

% find edges in grayscale image
imgBW = edge(im8bit,'sobel',thresh,'nothinning');

% Get 5x5 color patterns for raw image
[imgVB,imgHB,imgD1,imgD2] = frimg.getColorPats();

% R G
% G B

% Get RGB colors for assumed Bayer R CFA pattern raw image
imgRnew = blockproc(im8bit,[2 2], ...
    @(x)frimg.demoBayerR(x,imgVB,imgHB,imgD1,imgD2));

% G R
% B G

% Get RGB colors for assumed Bayer G1 CFA pattern raw image
imgG1new = blockproc(im8bit,[2 2], ...
    @(x)frimg.demoBayerG1(x,imgVB,imgHB,imgD1,imgD2));

% G B
% R G

% Get RGB colors for assumed Bayer G2 CFA pattern raw image
imgG2new = blockproc(im8bit,[2 2], ...
    @(x)frimg.demoBayerG2(x,imgVB,imgHB,imgD1,imgD2));

% B G
% G R

% Get RGB colors for assumed Bayer B CFA pattern raw image
imgBnew = blockproc(im8bit,[2 2], ...
    @(x)frimg.demoBayerB(x,imgVB,imgHB,imgD1,imgD2));

% R G
% G B

% get imgEdges for raw image
edges = frimg.getImgEdge();

% get edge types for raw image
iTh = edges.getEdgeTypes(imgBW);

% get chiralities of raw image edges
imgChr = frimg.getImgChr(edges,iTh);

% get raw image chiral patterns
[iCV,iCH,iCD1,iCD2] = frimg.getChrPats();

% R G
% G B

% Convert assumed Bayer R CFA pattern raw image to JPEG
imgRdemo = frimg.chr2jpg(1,imgRnew,imgChr,iCV,iCH,iCD1,iCD2);

% G R
% B G

% Convert assumed Bayer G1 CFA pattern raw image to JPEG
imgG1demo = frimg.chr2jpg(2,imgG1new,imgChr,iCV,iCH,iCD1,iCD2);

% G B
% R G

% Convert assumed Bayer G2 CFA pattern raw image to JPEG
imgG2demo = frimg.chr2jpg(3,imgG2new,imgChr,iCV,iCH,iCD1,iCD2);

% B G
% G R

% Convert assumed Bayer B CFA pattern raw image to JPEG
imgBdemo = frimg.chr2jpg(4,imgBnew,imgChr,iCV,iCH,iCD1,iCD2);

% Calculate distances from original image
[l,w,h] = size(frimg.image8);
img = im8bit(3:(l-2),3:(w-2));
diffR = abs(double(img)-double(imgRdemo(3:(l-2),3:(w-2),3)));
diffG1 = abs(double(img)-double(imgG1demo(3:(l-2),3:(w-2),3)));
diffG2 = abs(double(img)-double(imgG2demo(3:(l-2),3:(w-2),3)));
diffB = abs(double(img)-double(imgBdemo(3:(l-2),3:(w-2),3)));

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
