%{
Read the given image and gather different statistics for the error values
of the edge pixels using different pixel window sizes.

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

clear; % clear matlab environment
clc; % clear homescreen
startTime = clock; % keep track of overall runtime
thresh = 20; % used in median filter for edges

% read image file
fimg = ForensicImage('bassCrop.jpg');

% DEBUGGING
%disp('fimg.image(50:59,70:79,1)')
%fimg.image(50:59,70:79,1)

% window sizes
win = 3;
win2 = 5;
win3 = 7;

% image dimensions
s = size(fimg.image);
dim = s(1)-2*floor(win/2);

% row cropping dimensions
rStart = floor(win/2)+1;
rEnd = s(1)-floor(win/2);

% column cropping dimensions
cStart = floor(win/2)+1;
cEnd = s(2)-floor(win/2);

% Get RGB values for image pixels
% for 3x3 neighborhoods use middle 510 by 510 pixels
pixels = int16(fimg.image(rStart:rEnd,cStart:cEnd,1:3));

% Get RGB values for image pixels
% for 5x5 neighborhoods use middle 508 by 508 pixels
pixels2 = int16(fimg.image(rStart+1:rEnd-1,cStart+1:cEnd-1,1:3));

% Get RGB values for image pixels
% for 7x7 neighborhoods use middle 506 by 506 pixels
pixels3 = int16(fimg.image(rStart+2:rEnd-2,cStart+2:cEnd-2,1:3));

% DEBUGGING
%pixels(48,69:78,1)
%disp('pixels(49:58,69:78,1)')
%pixels(49:58,69:78,1)

% convert image to grayscale
% extract color channels from image
[red,green,blue] = fimg.getColorCh();

% find edges in grayscale image
imgBWR = edge(red,'sobel',0.035,'nothinning');
imgBWG = edge(green,'sobel',0.035,'nothinning');
imgBWB = edge(blue,'sobel',0.035,'nothinning');

% DEBUGGING
%disp('imgBWR(50:59,70:79)')
%imgBWR(50:59,70:79)

% crop binary images to 510 by 510 pixels for 3x3 windows
iBWcR = imgBWR(rStart:rEnd,cStart:cEnd);
iBWcG = imgBWG(rStart:rEnd,cStart:cEnd);
iBWcB = imgBWB(rStart:rEnd,cStart:cEnd);

% DEBUGGING
%disp('iBWcR(49:58,69:78)')
%iBWcR(49:58,69:78)

% crop binary images to 508 by 508 pixels for 5x5 windows
iBWcR2 = imgBWR(rStart+1:rEnd-1,cStart+1:cEnd-1);
iBWcG2 = imgBWG(rStart+1:rEnd-1,cStart+1:cEnd-1);
iBWcB2 = imgBWB(rStart+1:rEnd-1,cStart+1:cEnd-1);

% crop binary images to 506 by 506 pixels for 7x7 windows
iBWcR3 = imgBWR(rStart+2:rEnd-2,cStart+2:cEnd-2);
iBWcG3 = imgBWG(rStart+2:rEnd-2,cStart+2:cEnd-2);
iBWcB3 = imgBWB(rStart+2:rEnd-2,cStart+2:cEnd-2);

% expand binary images to 3 channels for 3x3 windows
imgBWcrop = cat(3,iBWcR,iBWcG,iBWcB);

% expand binary images to 3 channels for 5x5 windows
imgBWcrop2 = cat(3,iBWcR2,iBWcG2,iBWcB2);

% expand binary images to 3 channels for 7x7 windows
imgBWcrop3 = cat(3,iBWcR3,iBWcG3,iBWcB3);

% extract only edges from image for 3x3 windows
pixEdge = int16(imgBWcrop).*int16(pixels);

% extract only edges from image for 5x5 windows
pixEdge2 = int16(imgBWcrop2).*int16(pixels2);

% extract only edges from image for 7x7 windows
pixEdge3 = int16(imgBWcrop3).*int16(pixels3);

% get pixel neighborhoods for image pixels
% extract median edge neighbor for each pixel in 3x3 window
% then crop to 510 by 510
meds(:,:,1) = medfilt2edge(red,imgBWR,win,thresh);
meds(:,:,2) = medfilt2edge(green,imgBWG,win,thresh);
meds(:,:,3) = medfilt2edge(blue,imgBWB,win,thresh);
meds = meds(rStart:rEnd,cStart:cEnd,:);

% get pixel neighborhoods for image pixels
% extract median edge neighbor for each pixel in 5x5 window
% then crop to 508 by 508
meds2(:,:,1) = medfilt2edge(red,imgBWR,win2,thresh);
meds2(:,:,2) = medfilt2edge(green,imgBWG,win2,thresh);
meds2(:,:,3) = medfilt2edge(blue,imgBWB,win2,thresh);
meds2 = meds2(rStart+1:rEnd-1,cStart+1:cEnd-1,1:3);

% get pixel neighborhoods for image pixels
% extract median edge neighbor for each pixel in 7x7 window
% then crop to 506 by 506
meds3(:,:,1) = medfilt2edge(red,imgBWR,win3,thresh);
meds3(:,:,2) = medfilt2edge(green,imgBWG,win3,thresh);
meds3(:,:,3) = medfilt2edge(blue,imgBWB,win3,thresh);
meds3 = meds3(rStart+2:rEnd-2,cStart+2:cEnd-2,1:3);

% get indices for edges in binary edge-detect image for each
% color channel for 3x3 window image
indR = iBWcR>0;
medR = meds(:,:,1);
medR = indR.*medR;
indR = medR>0;

indG = iBWcG>0;
medG = meds(:,:,2);
medG = indG.*medG;
indG = medG>0;

indB = iBWcB>0;
medB = meds(:,:,3);
medB = indB.*medB;
indB = medB>0;

% split pixel neighborhood medians by color channel for 3x3 
% window image
medR = meds(:,:,1); % red
medG = meds(:,:,2); % green
medB = meds(:,:,3); % blue

% DEBUGGING
%disp('medR');
%medR(49:58,69:78)

% split edge-only image by color channel for 3x3 window image
pixER = pixEdge(:,:,1); % red
pixEG = pixEdge(:,:,2); % green
pixEB = pixEdge(:,:,3); % blue

% DEBUGGING
%disp('pixER');
%pixER(49:58,69:78)

% get error for image pixels
% error is the absolute difference of medians from 3x3 window 
% neighborhoods and image pixels
% separate errors into each color channel
redErr = abs(double(medR)-double(pixER));
greenErr = abs(double(medG)-double(pixEG));
blueErr = abs(double(medB)-double(pixEB));
errors = {redErr(indR) greenErr(indG) blueErr(indB)};

% DEBUGGING
%disp('redErr');
%redErr(49:58,69:78)

% get indices for edges in binary edge-detect image for each
% color channel for 5x5 window image
indR2 = iBWcR2>0;
medR2 = meds2(:,:,1);
medR2 = indR2.*medR2;
indR2 = medR2>0;

indG2 = iBWcG2>0;
medG2 = meds2(:,:,2);
medG2 = indG2.*medG2;
indG2 = medG2>0;

indB2 = iBWcB2>0;
medB2 = meds2(:,:,3);
medB2 = indB2.*medB2;
indB2 = medB2>0;

% split pixel neighborhood medians by color channel for 5x5 
% window image
medR2 = meds2(:,:,1); % red
medG2 = meds2(:,:,2); % green
medB2 = meds2(:,:,3); % blue

% DEBUGGING
%disp('medR2');
%medR2(49:58,69:78)

% split edge-only image by color channel for 5x5 window image
pixER2 = pixEdge2(:,:,1); % red
pixEG2 = pixEdge2(:,:,2); % green
pixEB2 = pixEdge2(:,:,3); % blue

% DEBUGGING
%disp('pixER2');
%pixER2(49:58,69:78)

% get error for image pixels
% error is the absolute difference of medians from 5x5 window 
% neighborhoods and image pixels
% separate errors into each color channel
redErr2 = abs(double(medR2)-double(pixER2));
greenErr2 = abs(double(medG2)-double(pixEG2));
blueErr2 = abs(double(medB2)-double(pixEB2));
errors2 = {redErr2(indR2) greenErr2(indG2) blueErr2(indB2)};

% get indices for edges in binary edge-detect image for each
% color channel for 7x7 window image
indR3 = iBWcR3>0;
medR3 = meds3(:,:,1);
medR3 = indR3.*medR3;
indR3 = medR3>0;

indG3 = iBWcG3>0;
medG3 = meds3(:,:,2);
medG3 = indG3.*medG3;
indG3 = medG3>0;

indB3 = iBWcB3>0;
medB3 = meds3(:,:,3);
medB3 = indB3.*medB3;
indB3 = medB3>0;

% split pixel neighborhood medians by color channel for 7x7 
% window image
medR3 = meds3(:,:,1); % red
medG3 = meds3(:,:,2); % green
medB3 = meds3(:,:,3); % blue

% split edge-only image by color channel for 7x7 window image
pixER3 = pixEdge3(:,:,1); % red
pixEG3 = pixEdge3(:,:,2); % green
pixEB3 = pixEdge3(:,:,3); % blue

% get error for image pixels
% error is the absolute difference of medians from 7x7 window 
% neighborhoods and image pixels
% separate errors into each color channel
redErr3 = abs(double(medR3)-double(pixER3));
greenErr3 = abs(double(medG3)-double(pixEG3));
blueErr3 = abs(double(medB3)-double(pixEB3));
errors3 = {redErr3(indR3) greenErr3(indG3) blueErr3(indB3)};

% Get mean, sd, skew and kurtosis for errors
% for errors from 3x3 window neighborhoods and image pixels
avg = [mean(redErr(indR)), mean(greenErr(indG)), mean(blueErr(indB))];
sd = [std(redErr(indR),1), std(greenErr(indG),1), std(blueErr(indB),1)];
skew = [skewness(redErr(indR)), skewness(greenErr(indG)), skewness(blueErr(indB))];
kurt = [kurtosis(redErr(indR)), kurtosis(greenErr(indG)), kurtosis(blueErr(indB))];

% Get mean, sd, skew and kurtosis for errors
% for errors from 5x5 window neighborhoods and image pixels
avg2 = [mean(redErr2(indR2)), mean(greenErr2(indG2)), mean(blueErr2(indB2))];
sd2 = [std(redErr2(indR2),1), std(greenErr2(indG2),1), std(blueErr2(indB2),1)];
skew2 = [skewness(redErr2(indR2)), skewness(greenErr2(indG2)), skewness(blueErr2(indB2))];
kurt2 = [kurtosis(redErr2(indR2)), kurtosis(greenErr2(indG2)), kurtosis(blueErr2(indB2))];

% Get mean, sd, skew and kurtosis for errors
% for errors from 7x7 window neighborhoods and image pixels
avg3 = [mean(redErr3(indR3)), mean(greenErr3(indG3)), mean(blueErr3(indB3))];
sd3 = [std(redErr3(indR3),1), std(greenErr3(indG3),1), std(blueErr3(indB3),1)];
skew3 = [skewness(redErr3(indR3)), skewness(greenErr3(indG3)), skewness(blueErr3(indB3))];
kurt3 = [kurtosis(redErr3(indR3)), kurtosis(greenErr3(indG3)), kurtosis(blueErr3(indB3))];

% initialize entropy arrays
entropy = [0 0 0];
entropy2 = [0 0 0];
entropy3 = [0 0 0];

% get entropy for red 3x3 window errors
rEn = redErr(indR).*log2(redErr(indR));
entropy(1) = -1*sum(rEn(~isnan(rEn(:))));

% get entropy for green 3x3 window errors
gEn = greenErr(indG).*log2(greenErr(indG));
entropy(2) = -1*sum(gEn(~isnan(gEn(:))));

% get entropy for blue 3x3 window errors
bEn = blueErr(indB).*log2(blueErr(indB));
entropy(3) = -1*sum(bEn(~isnan(bEn(:))));

% get entropy for red 5x5 window errors
rEn2 = redErr2(indR2).*log2(redErr2(indR2));
entropy2(1) = -1*sum(rEn2(~isnan(rEn2(:))));

% get entropy for green 5x5 window errors
gEn2 = greenErr2(indG2).*log2(greenErr2(indG2));
entropy2(2) = -1*sum(gEn2(~isnan(gEn2(:))));

% get entropy for blue 5x5 window errors
bEn2 = blueErr2(indB2).*log2(blueErr2(indB2));
entropy2(3) = -1*sum(bEn2(~isnan(bEn2(:))));

% get entropy for red 7x7 window errors
rEn3 = redErr3(indR3).*log2(redErr3(indR3));
entropy3(1) = -1*sum(rEn3(~isnan(rEn3(:))));

% get entropy for green 7x7 window errors
gEn3 = greenErr3(indG3).*log2(greenErr3(indG3));
entropy3(2) = -1*sum(gEn3(~isnan(gEn3(:))));

% get entropy for blue 7x7 window errors
bEn3 = blueErr3(indB3).*log2(blueErr3(indB3));
entropy3(3) = -1*sum(bEn3(~isnan(bEn3(:))));

% Get energy for errors from 3x3 window and image pixels
energy = [0,0,0];
for i = 1:size(redErr,1)
    energy(1) = energy(1)+redErr(i)^2;
end
for i = 1:size(greenErr,1)
    energy(2) = energy(2)+greenErr(i)^2;
end
for i = 1:size(blueErr,1)
    energy(3) = energy(3)+blueErr(i)^2;
end

% Get energy for errors from 5x5 window and image pixels
energy2 = [0,0,0];
for i = 1:size(redErr2,1)
    energy2(1) = energy2(1)+redErr2(i)^2;
end
for i = 1:size(greenErr2,1)
    energy2(2) = energy2(2)+greenErr2(i)^2;
end
for i = 1:size(blueErr2,1)
    energy2(3) = energy2(3)+blueErr2(i)^2;
end

% Get energy for errors from 7x7 window and image pixels
energy3 = [0,0,0];
for i = 1:size(redErr3,1)
    energy3(1) = energy3(1)+redErr3(i)^2;
end
for i = 1:size(greenErr3,1)
    energy3(2) = energy3(2)+greenErr3(i)^2;
end
for i = 1:size(blueErr3,1)
    energy3(3) = energy3(3)+blueErr3(i)^2;
end

% Return image statistics as imgStats for 3x3 window
% stats contain data for all 3 color channels as 3x1 vectors
iStat3 = imgStats(avg,sd,skew,kurt,entropy,energy,pixels,meds,errors)

% Return image statistics as imgStats for 5x5 window
% stats contain data for all 3 color channels as 3x1 vectors
iStat5 = imgStats(avg2,sd2,skew2,kurt2,entropy2,energy2,pixels2,meds2,errors2)

% Return image statistics as imgStats for 7x7 window
% stats contain data for all 3 color channels as 3x1 vectors
iStat7 = imgStats(avg3,sd3,skew3,kurt3,entropy3,energy3,pixels3,meds3,errors3)
            
% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
