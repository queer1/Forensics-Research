%{
Median filter using binary image of edges.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: July 01, 2011
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

% Median filter for images that adjusts for edges
% image = grayscale image
% imgBW = binary image of edges
% wn = window size (3, 5 or 7)
% thr = threshold for edge-type gradients
% result = image with edge-type values instead of pixel values
% edgeNum = number of retained edges
function [result,edgeNum] = medfilt2edge(image,imgBW,wn,thr)
    
    % Probes are test points for edges based on window size
    % probe = [ horiz - diff, vert | diff, forward diag / diff, backward diag \ diff ]
    %       ~ [ vert | edge, horiz - edge, backward diag \ edge, forward diag / edge ]
    lProbe = [2,4,1,3];
    rProbe = [8,6,9,7];
    if (wn == 5)
        lProbe = [3,11,1,5];
        rProbe = [23,15,25,21];
    elseif (wn == 7)
        lProbe = [4,22,1,7];
        rProbe = [46,28,49,43];
    end
    
    % Get vertical | edges (horiz diff -) for grayscale image
    % take difference of probe test points for all pixels in image
    hDiff = @(x) abs(int16(x(lProbe(1),:))-int16(x(rProbe(1),:)));
    imgHD = colfilt(image,[wn wn],'sliding',hDiff);
    imgHD = (double(imgHD)>thr).*double(imgHD);
    imgHD = double(imgBW).*double(imgHD);
    
    %disp('imgHD(50:59,70:79)');
    %imgHD(50:59,70:79)
    
    % Get horizontal - edges (vert diff |) for grayscale image
    % take difference of probe test points for all pixels in image
    vDiff = @(x) abs(int16(x(lProbe(2),:))-int16(x(rProbe(2),:)));
    imgVD = colfilt(image,[wn wn],'sliding',vDiff);
    imgVD = (double(imgVD)>thr).*double(imgVD);
    imgVD = double(imgBW).*double(imgVD);
    
    %disp('imgVD(50:59,70:79)');
    %imgVD(50:59,70:79)
    
    % Get backward diagonal \ edges (diag 1 diff /) for grayscale image
    % take difference of probe test points for all pixels in image
    D1diff = @(x) abs(int16(x(lProbe(3),:))-int16(x(rProbe(3),:)));
    imgD1 = colfilt(image,[wn wn],'sliding',D1diff);
    imgD1 = (double(imgD1)>thr).*double(imgD1);
    imgD1 = double(imgBW).*double(imgD1);
    
    %disp('imgD1(50:59,70:79)');
    %imgD1(50:59,70:79)
    
    % Get forward diagonal / edges (diag 2 diff \) for grayscale image
    % take difference of probe test points for all pixels in image
    D2diff = @(x) abs(int16(x(lProbe(4),:))-int16(x(rProbe(4),:)));
    imgD2 = colfilt(image,[wn wn],'sliding',D2diff);
    imgD2 = (double(imgD2)>thr).*double(imgD2);
    imgD2 = double(imgBW).*double(imgD2);
    
    %disp('imgD2(50:59,70:79)');
    %imgD2(50:59,70:79)
    
    % get number of retained edges
    imgBWnew = max(imgHD,max(imgVD,max(imgD1,imgD2)));
    index = (imgBWnew==0);
    imgBW(index) = 0;
    edgeNum = (size(image,1)*size(image,2))-sum(sum(index));
    
    % threshold image edges
    % and determine edge type
    % type 1 = vert edge | (horiz diff - largest)
    % type 2 = horiz edge - (vert diff | largest)
    % type 4 = diag 2 edge \ (diag 1 diff / largest)
    % type 8 = diag 1 edge / (diag 2 diff \ largest)
    iEd = imgEdges(imgHD,imgVD,imgD1,imgD2,0,0,0,0);
    iTh = iEd.getEdgeTypes(imgBW);
    
    %disp('iTh(50:59,70:79)');
    %iTh(50:59,70:79)
    
    % 8 x 1 x 2
    % x x x x x
    % 7 x x x 3
    % x x x x x
    % 6 x 5 x 4
    
    % get chirality of image edges
    iHDC = iEd.getChiral(image,iTh,1,7,3,wn); % 1 = vert edge |
    iVDC = iEd.getChiral(image,iTh,2,1,5,wn); % 2 = horiz edge -
    iD1C = iEd.getChiral(image,iTh,4,6,2,wn); % 4 = diag 2 edge \
    iD2C = iEd.getChiral(image,iTh,8,8,4,wn); % 8 = diag 1 edge /
    
    % combine chiralities of edge types
    imgChr = iHDC+iVDC+iD1C+iD2C;
    
    %disp('imgChr(50:59,70:79)');
    %imgChr(50:59,70:79)
    
    % Get vertical edge | chiral negative (left) patterns
    md = ceil(wn/2);
    crop1 = 1;
    crop2 = md*(wn-1);
    crop3 = crop2+2;
    crop4 = md*wn;
    vertEdgeChr = @(x) median(double(x([crop1:crop2 crop3:crop4],:)));
    imgVECn = colfilt(image,[wn wn],'sliding',vertEdgeChr);
    
    % Get vertical edge | chiral positive (right) patterns
    md = ceil(wn/2);
    crop1 = wn*(md-1)+1;
    crop2 = md*(wn-1);
    crop3 = crop2+2;
    crop4 = wn^2;
    vertEdgeChr = @(x) median(double(x([crop1:crop2 crop3:crop4],:)));
    imgVECp = colfilt(image,[wn wn],'sliding',vertEdgeChr);
    
    % Get horizontal edge - chiral negative (top) patterns
    img2 = rot90(image);
    md = ceil(wn/2);
    crop1 = 1;
    crop2 = md*(wn-1);
    crop3 = crop2+2;
    crop4 = md*wn;
    horizEdgeChr = @(x) median(double(x([crop1:crop2 crop3:crop4],:)));
    imgHECn = colfilt(img2,[wn wn],'sliding',horizEdgeChr);
    imgHECn = rot90(imgHECn,3);
    
    % Get horizontal edge - chiral positive (bottom) patterns
    img2 = rot90(image);
    md = ceil(wn/2);
    crop1 = wn*(md-1)+1;
    crop2 = md*(wn-1);
    crop3 = crop2+2;
    crop4 = wn^2;
    horizEdgeChr = @(x) median(double(x([crop1:crop2 crop3:crop4],:)));
    imgHECp = colfilt(img2,[wn wn],'sliding',horizEdgeChr);
    imgHECp = rot90(imgHECp,3);
    
    % Get forward diagonal edge / chiral negative (top left) patterns
    domain  = [1 2 3 4 7];
    if (wn == 5)
        domain = [1 2 3 4 5 6 7 8 9 11 12 16 17 21];
    elseif (wn == 7)
        domain = [1 2 3 4 5 6 7 8 9 10 11 12 13 15 16 17 18 19 22 23 24 29 30 31 36 37 43];
    end
    diag1EdgeChr = @(x) median(double(x(domain,:)));
    imgD1ECn = colfilt(image,[wn wn],'sliding',diag1EdgeChr);
    
    % Get forward diagonal edge / chiral positive (bottom right) patterns
    domain  = [3 6 7 8 9];
    if (wn == 5)
        domain = [5 9 10 14 15 17 18 19 20 21 22 23 24 25];
    elseif (wn == 7)
        domain = [7 13 14 19 20 21 26 27 28 31 32 33 34 35 37 38 39 40 41 42 43 44 45 46 47 48 49];
    end
    diag1EdgeChr = @(x) median(double(x(domain,:)));
    imgD1ECp = colfilt(image,[wn wn],'sliding',diag1EdgeChr);
    
    % Get backward diagonal edge \ chiral negative (bottom left) patterns
    domain  = [1 2 3 6 9];
    if (wn == 5)
        domain = [1 2 3 4 5 7 8 9 10 14 15 19 20 25];
    elseif (wn == 7)
        domain = [1 2 3 4 5 6 7 9 10 11 12 13 14 17 18 19 20 21 26 27 28 33 34 35 41 42 49];
    end
    diag2EdgeChr = @(x) median(double(x(domain,:)));
    imgD2ECn = colfilt(image,[wn wn],'sliding',diag2EdgeChr);
    
    % Get backward diagonal edge \ chiral positive (top right) patterns
    domain  = [1 4 7 8 9];
    if (wn == 5)
        domain = [1 6 7 11 12 16 17 18 19 21 22 23 24 25];
    elseif (wn == 7)
        domain = [1 8 9 15 16 17 22 23 24 29 30 31 32 33 36 37 38 39 40 41 43 44 45 46 47 48 49];
    end
    diag2EdgeChr = @(x) median(double(x(domain,:)));
    imgD2ECp = colfilt(image,[wn wn],'sliding',diag2EdgeChr);
    
    [l,w] = size(image);
    result = zeros(l,w);
    
    % adjust image for vertical edges | with negative chirality (left)
    index = find(imgChr==-1);
    for i = 1:length(index)
        ind = index(i);
        [r,c] = ind2sub([l,w],ind);
        result(r,c) = imgVECn(r,c);
    end
    
    % adjust image for vertical edges | with positive chirality (right)
    index = find(imgChr==1);
    for i = 1:length(index)
        ind = index(i);
        [r,c] = ind2sub([l,w],ind);
        result(r,c) = imgVECp(r,c);
    end
    
    % adjust image for horizontal edges - with negative chirality (top)
    index = find(imgChr==-2);
    for i = 1:length(index)
        ind = index(i);
        [r,c] = ind2sub([l,w],ind);
        result(r,c) = imgHECn(r,c);
    end
    
    % adjust image for horizontal edges - with positive chirality (bottom)
    index = find(imgChr==2);
    for i = 1:length(index)
        ind = index(i);
        [r,c] = ind2sub([l,w],ind);
        result(r,c) = imgHECp(r,c);
    end
    
    % adjust image for backward diag edges \ with negative chirality (bottom left)
    index = find(imgChr==-4);
    for i = 1:length(index)
        ind = index(i);
        [r,c] = ind2sub([l,w],ind);
        result(r,c) = imgD2ECn(r,c);
    end
    
    % adjust image for backward diag edges \ with positive chirality (top right)
    index = find(imgChr==4);
    for i = 1:length(index)
        ind = index(i);
        [r,c] = ind2sub([l,w],ind);
        result(r,c) = imgD2ECp(r,c);
    end
    
    % adjust image for forward diag edges / with negative chirality (top left)
    index = find(imgChr==-8);
    for i = 1:length(index)
        ind = index(i);
        [r,c] = ind2sub([l,w],ind);
        result(r,c) = imgD1ECn(r,c);
    end
    
    % adjust image for forward diag edges / with positive chirality (bottom right)
    index = find(imgChr==8);
    for i = 1:length(index)
        ind = index(i);
        [r,c] = ind2sub([l,w],ind);
        result(r,c) = imgD1ECp(r,c);
    end
    
end
