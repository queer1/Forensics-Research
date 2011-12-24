%{
Convert JPEG to its Bayer images, then demosaic bayer images back to JPEG.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: July 13, 2011
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
fimg = ForensicImage('camCrop.jpg');

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

% find edges in grayscale images
imgBWR = edge(imgRG,'sobel',thresh,'nothinning');
imgBWG1 = edge(imgGR,'sobel',thresh,'nothinning');
imgBWG2 = edge(imgGB,'sobel',thresh,'nothinning');
imgBWB = edge(imgBG,'sobel',thresh,'nothinning');

% Get 5x5 color patterns for Bayer CFA pattern images
[imgRVB,imgRHB,imgRD1,imgRD2] = fimg.getColorPats(1);
[imgG1VB,imgG1HB,imgG1D1,imgG1D2] = fimg.getColorPats(2);
[imgG2VB,imgG2HB,imgG2D1,imgG2D2] = fimg.getColorPats(3);
[imgBVB,imgBHB,imgBD1,imgBD2] = fimg.getColorPats(4);

% R G
% G B

% Get RGB colors for Bayer R CFA pattern image
imgRnew = blockproc(imgRG,[2 2],@(x)fimg.demoBayerR(x,imgRVB,imgRHB,imgRD1,imgRD2));

% G R
% B G

% Get RGB colors for Bayer G1 CFA pattern image
imgG1new = blockproc(imgGR,[2 2],@(x)fimg.demoBayerG1(x,imgG1VB,imgG1HB,imgG1D1,imgG1D2));

% G B
% R G

% Get RGB colors for Bayer G2 CFA pattern image
imgG2new = blockproc(imgGB,[2 2],@(x)fimg.demoBayerG2(x,imgG2VB,imgG2HB,imgG2D1,imgG2D2));

% B G
% G R

% Get RGB colors for Bayer B CFA pattern image
imgBnew = blockproc(imgBG,[2 2],@(x)fimg.demoBayerB(x,imgBVB,imgBHB,imgBD1,imgBD2));

% R G
% G B

% get imgEdges for bayer R image
edgeRed = fimg.getImgEdge(1);

% get edge types for bayer R image
iThR = edgeRed.getEdgeTypes(imgBWR);

% get chiralities of bayer R image edges
imgChrR = fimg.getImgChr(1,edgeRed,iThR);

% get bayer R image chiral patterns
[iRCV,iRCH,iRCD1,iRCD2] = fimg.getChrPats(1);

% convert bayer R image back to JPEG
imgRdemo = fimg.chr2jpg(1,imgRnew,imgChrR,iRCV,iRCH,iRCD1,iRCD2);

% G R
% B G

% get imgEdges for bayer G1 image
edgeGreen1 = fimg.getImgEdge(2);

% get edge types for bayer G1 image
iThG1 = edgeGreen1.getEdgeTypes(imgBWG1);

% get chiralities of bayer G1 image edges
imgChrG1 = fimg.getImgChr(2,edgeGreen1,iThG1);

% get bayer G1 image chiral patterns
[iG1CV,iG1CH,iG1CD1,iG1CD2] = fimg.getChrPats(2);

% convert bayer G1 image back to JPEG
imgG1demo = fimg.chr2jpg(2,imgG1new,imgChrG1,iG1CV,iG1CH,iG1CD1,iG1CD2);

% G B
% R G

% get imgEdges for bayer G2 image
edgeGreen2 = fimg.getImgEdge(3);

% get edge types for bayer G2 image
iThG2 = edgeGreen2.getEdgeTypes(imgBWG2);

% get chiralities of bayer G2 image edges
imgChrG2 = fimg.getImgChr(3,edgeGreen2,iThG2);

% get bayer G2 image chiral patterns
[iG2CV,iG2CH,iG2CD1,iG2CD2] = fimg.getChrPats(3);

% convert bayer G2 image back to JPEG
imgG2demo = fimg.chr2jpg(3,imgG2new,imgChrG2,iG2CV,iG2CH,iG2CD1,iG2CD2);

% B G
% G R

% get imgEdges for bayer B image
edgeBlue = fimg.getImgEdge(4);

% get edge types for bayer B image
iThB = edgeBlue.getEdgeTypes(imgBWB);

% get chiralities of bayer B image edges
imgChrB = fimg.getImgChr(4,edgeBlue,iThB);

% get bayer B image chiral patterns
[iBCV,iBCH,iBCD1,iBCD2] = fimg.getChrPats(4);

% convert bayer B image back to JPEG
imgBdemo = fimg.chr2jpg(4,imgBnew,imgChrB,iBCV,iBCH,iBCD1,iBCD2);

% Calculate distances from original image
[l,w,h] = size(fimg.image);
img = fimg.image(3:(l-2),3:(w-2),:);
diffR = abs(double(img)-double(imgRdemo(3:(l-2),3:(w-2),1:3)));
diffG1 = abs(double(img)-double(imgG1demo(3:(l-2),3:(w-2),1:3)));
diffG2 = abs(double(img)-double(imgG2demo(3:(l-2),3:(w-2),1:3)));
diffB = abs(double(img)-double(imgBdemo(3:(l-2),3:(w-2),1:3)));

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
