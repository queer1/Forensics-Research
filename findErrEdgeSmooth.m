%{
Read the given image and gather different statistics for the error values
of the smooth area and edge pixels using different pixel window sizes.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: July 26, 2011
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
thresh1 = 0.035; % used in edge detection
thresh2 = 30; % used in median filter for edges

% read image file
fimg = ForensicImage('bassCrop.jpg');

% DEBUGGING
% disp('fimg.image(50:59,70:79,1)')
% fimg.image(50:59,70:79,1)

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

% DEBUGGING
% disp('pixels(49:58,69:78,1)')
% pixels(49:58,69:78,1)

% Get RGB values for image pixels
% for 5x5 neighborhoods use middle 508 by 508 pixels
pixels2 = int16(fimg.image(rStart+1:rEnd-1,cStart+1:cEnd-1,1:3));

% Get RGB values for image pixels
% for 7x7 neighborhoods use middle 506 by 506 pixels
pixels3 = int16(fimg.image(rStart+2:rEnd-2,cStart+2:cEnd-2,1:3));

% convert image to grayscale
% extract color channels from image
[red,green,blue] = fimg.getColorCh();

% find edges in grayscale image
imgBWR = edge(red,'sobel',thresh1,'nothinning');
imgBWG = edge(green,'sobel',thresh1,'nothinning');
imgBWB = edge(blue,'sobel',thresh1,'nothinning');

% DEBUGGING
% disp('imgBWR(50:59,70:79)')
% imgBWR(50:59,70:79)

% find smooth areas in grayscale image
imgBWRS = ~imgBWR;
imgBWGS = ~imgBWG;
imgBWBS = ~imgBWB;

% DEBUGGING
% disp('imgBWRS(50:59,70:79)')
% imgBWRS(50:59,70:79)

% crop binary images to 510 by 510 pixels for 3x3 windows (edge)
iBWcR = imgBWR(rStart:rEnd,cStart:cEnd);
iBWcG = imgBWG(rStart:rEnd,cStart:cEnd);
iBWcB = imgBWB(rStart:rEnd,cStart:cEnd);

% DEBUGGING
% disp('iBWcR(49:58,69:78)')
% iBWcR(49:58,69:78)

% crop binary images to 510 by 510 pixels for 3x3 windows (smooth)
iBWcRS = imgBWRS(rStart:rEnd,cStart:cEnd);
iBWcGS = imgBWGS(rStart:rEnd,cStart:cEnd);
iBWcBS = imgBWBS(rStart:rEnd,cStart:cEnd);

% DEBUGGING
% disp('iBWcRS(49:58,69:78)')
% iBWcRS(49:58,69:78)

% crop binary images to 508 by 508 pixels for 5x5 windows (edge)
iBWcR2 = imgBWR(rStart+1:rEnd-1,cStart+1:cEnd-1);
iBWcG2 = imgBWG(rStart+1:rEnd-1,cStart+1:cEnd-1);
iBWcB2 = imgBWB(rStart+1:rEnd-1,cStart+1:cEnd-1);

% crop binary images to 508 by 508 pixels for 5x5 windows (smooth)
iBWcRS2 = imgBWRS(rStart+1:rEnd-1,cStart+1:cEnd-1);
iBWcGS2 = imgBWGS(rStart+1:rEnd-1,cStart+1:cEnd-1);
iBWcBS2 = imgBWBS(rStart+1:rEnd-1,cStart+1:cEnd-1);

% crop binary images to 506 by 506 pixels for 7x7 windows (edge)
iBWcR3 = imgBWR(rStart+2:rEnd-2,cStart+2:cEnd-2);
iBWcG3 = imgBWG(rStart+2:rEnd-2,cStart+2:cEnd-2);
iBWcB3 = imgBWB(rStart+2:rEnd-2,cStart+2:cEnd-2);

% crop binary images to 506 by 506 pixels for 7x7 windows (smooth)
iBWcRS3 = imgBWRS(rStart+2:rEnd-2,cStart+2:cEnd-2);
iBWcGS3 = imgBWGS(rStart+2:rEnd-2,cStart+2:cEnd-2);
iBWcBS3 = imgBWBS(rStart+2:rEnd-2,cStart+2:cEnd-2);

% expand binary images to 3 channels for 3x3 windows (edge)
imgBWcrop = cat(3,iBWcR,iBWcG,iBWcB);

% expand binary images to 3 channels for 5x5 windows (edge)
imgBWcrop2 = cat(3,iBWcR2,iBWcG2,iBWcB2);

% expand binary images to 3 channels for 7x7 windows (edge)
imgBWcrop3 = cat(3,iBWcR3,iBWcG3,iBWcB3);

% expand binary images to 3 channels for 3x3 windows (smooth)
imgBWScrop = cat(3,iBWcRS,iBWcGS,iBWcBS);

% expand binary images to 3 channels for 5x5 windows (smooth)
imgBWScrop2 = cat(3,iBWcRS2,iBWcGS2,iBWcBS2);

% expand binary images to 3 channels for 7x7 windows (smooth)
imgBWScrop3 = cat(3,iBWcRS3,iBWcGS3,iBWcBS3);

% extract only edges from image for 3x3 windows
pixEdge = int16(imgBWcrop).*int16(pixels);

% extract only edges from image for 5x5 windows
pixEdge2 = int16(imgBWcrop2).*int16(pixels2);

% extract only edges from image for 7x7 windows
pixEdge3 = int16(imgBWcrop3).*int16(pixels3);

% extract only smooth areas from image for 3x3 windows
pixSmooth = int16(imgBWScrop).*int16(pixels);

% extract only smooth areas from image for 5x5 windows
pixSmooth2 = int16(imgBWScrop2).*int16(pixels2);

% extract only smooth areas from image for 7x7 windows
pixSmooth3 = int16(imgBWScrop3).*int16(pixels3);

% get pixel neighborhoods for image pixels
% extract median edge neighbor for each pixel in 3x3 window
% then crop to 510 by 510
meds(:,:,1) = medfilt2edge(red,imgBWR,win,thresh2);
meds(:,:,2) = medfilt2edge(green,imgBWG,win,thresh2);
meds(:,:,3) = medfilt2edge(blue,imgBWB,win,thresh2);
meds = meds(rStart:rEnd,cStart:cEnd,:);

% get pixel neighborhoods for image pixels
% extract median smooth area neighbor for each pixel in 3x3 window
% then crop to 510 by 510
medSmooth(:,:,1) = imgBWRS.*medfilt2new(red,win);
medSmooth(:,:,2) = imgBWGS.*medfilt2new(green,win);
medSmooth(:,:,3) = imgBWBS.*medfilt2new(blue,win);
medSmooth = medSmooth(rStart:rEnd,cStart:cEnd,:);

% get pixel neighborhoods for image pixels
% extract median edge neighbor for each pixel in 5x5 window
% then crop to 508 by 508
meds2(:,:,1) = medfilt2edge(red,imgBWR,win2,thresh2);
meds2(:,:,2) = medfilt2edge(green,imgBWG,win2,thresh2);
meds2(:,:,3) = medfilt2edge(blue,imgBWB,win2,thresh2);
meds2 = meds2(rStart+1:rEnd-1,cStart+1:cEnd-1,1:3);

% get pixel neighborhoods for image pixels
% extract median smooth area neighbor for each pixel in 5x5 window
% then crop to 508 by 508
medSmooth2(:,:,1) = imgBWRS.*medfilt2new(red,win2);
medSmooth2(:,:,2) = imgBWGS.*medfilt2new(green,win2);
medSmooth2(:,:,3) = imgBWBS.*medfilt2new(blue,win2);
medSmooth2 = medSmooth2(rStart+1:rEnd-1,cStart+1:cEnd-1,:);

% get pixel neighborhoods for image pixels
% extract median edge neighbor for each pixel in 7x7 window
% then crop to 506 by 506
meds3(:,:,1) = medfilt2edge(red,imgBWR,win3,thresh2);
meds3(:,:,2) = medfilt2edge(green,imgBWG,win3,thresh2);
meds3(:,:,3) = medfilt2edge(blue,imgBWB,win3,thresh2);
meds3 = meds3(rStart+2:rEnd-2,cStart+2:cEnd-2,1:3);

% get pixel neighborhoods for image pixels
% extract median smooth area neighbor for each pixel in 7x7 window
% then crop to 506 by 506
medSmooth3(:,:,1) = imgBWRS.*medfilt2new(red,win3);
medSmooth3(:,:,2) = imgBWGS.*medfilt2new(green,win3);
medSmooth3(:,:,3) = imgBWBS.*medfilt2new(blue,win3);
medSmooth3 = medSmooth3(rStart+2:rEnd-2,cStart+2:cEnd-2,:);

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

% get indices for smooth areas in binary edge-detect image for each
% color channel for 3x3 window image
indRS = iBWcRS>0;
medRS = medSmooth(:,:,1);
medRS = indRS.*medRS;
indRS = medRS>0;

indGS = iBWcGS>0;
medGS = medSmooth(:,:,2);
medGS = indGS.*medGS;
indGS = medGS>0;

indBS = iBWcBS>0;
medBS = medSmooth(:,:,3);
medBS = indBS.*medBS;
indBS = medBS>0;

% split pixel neighborhood medians by color channel for 3x3 
% window image (edge)
medR = meds(:,:,1); % red
medG = meds(:,:,2); % green
medB = meds(:,:,3); % blue

% DEBUGGING
% disp('medR(49:58,69:78)');
% medR(49:58,69:78)

% split pixel neighborhood medians by color channel for 3x3 
% window image (smooth)
medRS = medSmooth(:,:,1); % red
medGS = medSmooth(:,:,2); % green
medBS = medSmooth(:,:,3); % blue

% DEBUGGING
% disp('medRS(49:58,69:78)');
% medRS(49:58,69:78)

% split edge-only image by color channel for 3x3 window image
pixER = pixEdge(:,:,1); % red
pixEG = pixEdge(:,:,2); % green
pixEB = pixEdge(:,:,3); % blue

% DEBUGGING
% disp('pixER(49:58,69:78)');
% pixER(49:58,69:78)

% split smooth-only image by color channel for 3x3 window image
pixSR = pixSmooth(:,:,1); % red
pixSG = pixSmooth(:,:,2); % green
pixSB = pixSmooth(:,:,3); % blue

% DEBUGGING
% disp('pixSR(49:58,69:78)');
% pixSR(49:58,69:78)

% get error for image pixels (edge)
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

% get error for image pixels (smooth)
% error is the absolute difference of medians from 3x3 window 
% neighborhoods and image pixels
% separate errors into each color channel
redErrS = abs(double(medRS)-double(pixSR));
greenErrS = abs(double(medGS)-double(pixSG));
blueErrS = abs(double(medBS)-double(pixSB));
errorsS = {redErrS(indRS) greenErrS(indGS) blueErrS(indBS)};

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

% get indices for smooth areas in binary edge-detect image for each
% color channel for 5x5 window image
indRS2 = iBWcRS2>0;
medRS2 = medSmooth2(:,:,1);
medRS2 = indRS2.*medRS2;
indRS2 = medRS2>0;

indGS2 = iBWcGS2>0;
medGS2 = medSmooth2(:,:,2);
medGS2 = indGS2.*medGS2;
indGS2 = medGS2>0;

indBS2 = iBWcBS2>0;
medBS2 = medSmooth2(:,:,3);
medBS2 = indBS2.*medBS2;
indBS2 = medBS2>0;

% split pixel neighborhood medians by color channel for 5x5 
% window image (edge)
medR2 = meds2(:,:,1); % red
medG2 = meds2(:,:,2); % green
medB2 = meds2(:,:,3); % blue

% DEBUGGING
% disp('medR2');
% medR2(49:58,69:78)

% split pixel neighborhood medians by color channel for 5x5 
% window image (smooth)
medRS2 = medSmooth2(:,:,1); % red
medGS2 = medSmooth2(:,:,2); % green
medBS2 = medSmooth2(:,:,3); % blue

% DEBUGGING
% disp('medRS2');
% medRS2(49:58,69:78)

% split edge-only image by color channel for 5x5 window image
pixER2 = pixEdge2(:,:,1); % red
pixEG2 = pixEdge2(:,:,2); % green
pixEB2 = pixEdge2(:,:,3); % blue

% DEBUGGING
% disp('pixER2');
% pixER2(49:58,69:78)

% split smooth-only image by color channel for 5x5 window image
pixSR2 = pixSmooth2(:,:,1); % red
pixSG2 = pixSmooth2(:,:,2); % green
pixSB2 = pixSmooth2(:,:,3); % blue

% DEBUGGING
% disp('pixSR2');
% pixSR2(49:58,69:78)

% get error for image pixels (edge)
% error is the absolute difference of medians from 5x5 window 
% neighborhoods and image pixels
% separate errors into each color channel
redErr2 = abs(double(medR2)-double(pixER2));
greenErr2 = abs(double(medG2)-double(pixEG2));
blueErr2 = abs(double(medB2)-double(pixEB2));
errors2 = {redErr2(indR2) greenErr2(indG2) blueErr2(indB2)};

% get error for image pixels (smooth)
% error is the absolute difference of medians from 5x5 window 
% neighborhoods and image pixels
% separate errors into each color channel
redErrS2 = abs(double(medRS2)-double(pixSR2));
greenErrS2 = abs(double(medGS2)-double(pixSG2));
blueErrS2 = abs(double(medBS2)-double(pixSB2));
errorsS2 = {redErrS2(indRS2) greenErrS2(indGS2) blueErrS2(indBS2)};

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

% get indices for smooth areas in binary edge-detect image for each
% color channel for 7x7 window image
indRS3 = iBWcRS3>0;
medRS3 = medSmooth3(:,:,1);
medRS3 = indRS3.*medRS3;
indRS3 = medRS3>0;

indGS3 = iBWcGS3>0;
medGS3 = medSmooth3(:,:,2);
medGS3 = indGS3.*medGS3;
indGS3 = medGS3>0;

indBS3 = iBWcBS3>0;
medBS3 = medSmooth3(:,:,3);
medBS3 = indBS3.*medBS3;
indBS3 = medBS3>0;

% split pixel neighborhood medians by color channel for 7x7 
% window image (edge)
medR3 = meds3(:,:,1); % red
medG3 = meds3(:,:,2); % green
medB3 = meds3(:,:,3); % blue

% split pixel neighborhood medians by color channel for 7x7 
% window image (smooth)
medRS3 = medSmooth3(:,:,1); % red
medGS3 = medSmooth3(:,:,2); % green
medBS3 = medSmooth3(:,:,3); % blue

% split edge-only image by color channel for 7x7 window image
pixER3 = pixEdge3(:,:,1); % red
pixEG3 = pixEdge3(:,:,2); % green
pixEB3 = pixEdge3(:,:,3); % blue

% split smooth-only image by color channel for 7x7 window image
pixSR3 = pixSmooth3(:,:,1); % red
pixSG3 = pixSmooth3(:,:,2); % green
pixSB3 = pixSmooth3(:,:,3); % blue

% get error for image pixels (edge)
% error is the absolute difference of medians from 7x7 window 
% neighborhoods and image pixels
% separate errors into each color channel
redErr3 = abs(double(medR3)-double(pixER3));
greenErr3 = abs(double(medG3)-double(pixEG3));
blueErr3 = abs(double(medB3)-double(pixEB3));
errors3 = {redErr3(indR3) greenErr3(indG3) blueErr3(indB3)};

% get error for image pixels (smooth)
% error is the absolute difference of medians from 7x7 window 
% neighborhoods and image pixels
% separate errors into each color channel
redErrS3 = abs(double(medRS3)-double(pixSR3));
greenErrS3 = abs(double(medGS3)-double(pixSG3));
blueErrS3 = abs(double(medBS3)-double(pixSB3));
errorsS3 = {redErrS3(indRS3) greenErrS3(indGS3) blueErrS3(indBS3)};

% Get mean, sd, skew and kurtosis for errors (edge)
% for errors from 3x3 window neighborhoods and image pixels
avg = [mean(redErr(indR)), mean(greenErr(indG)), mean(blueErr(indB))];
sd = [std(redErr(indR),1), std(greenErr(indG),1), std(blueErr(indB),1)];
skew = [skewness(redErr(indR)), skewness(greenErr(indG)), skewness(blueErr(indB))];
kurt = [kurtosis(redErr(indR)), kurtosis(greenErr(indG)), kurtosis(blueErr(indB))];

% Get mean, sd, skew and kurtosis for errors (edge)
% for errors from 5x5 window neighborhoods and image pixels
avg2 = [mean(redErr2(indR2)), mean(greenErr2(indG2)), mean(blueErr2(indB2))];
sd2 = [std(redErr2(indR2),1), std(greenErr2(indG2),1), std(blueErr2(indB2),1)];
skew2 = [skewness(redErr2(indR2)), skewness(greenErr2(indG2)), skewness(blueErr2(indB2))];
kurt2 = [kurtosis(redErr2(indR2)), kurtosis(greenErr2(indG2)), kurtosis(blueErr2(indB2))];

% Get mean, sd, skew and kurtosis for errors (edge)
% for errors from 7x7 window neighborhoods and image pixels
avg3 = [mean(redErr3(indR3)), mean(greenErr3(indG3)), mean(blueErr3(indB3))];
sd3 = [std(redErr3(indR3),1), std(greenErr3(indG3),1), std(blueErr3(indB3),1)];
skew3 = [skewness(redErr3(indR3)), skewness(greenErr3(indG3)), skewness(blueErr3(indB3))];
kurt3 = [kurtosis(redErr3(indR3)), kurtosis(greenErr3(indG3)), kurtosis(blueErr3(indB3))];

% Get mean, sd, skew and kurtosis for errors (smooth)
% for errors from 3x3 window neighborhoods and image pixels
avgS = [mean(redErrS(indRS)), mean(greenErrS(indGS)), mean(blueErrS(indBS))];
sdS = [std(redErrS(indRS),1), std(greenErrS(indGS),1), std(blueErrS(indBS),1)];
skewS = [skewness(redErrS(indRS)), skewness(greenErrS(indGS)), skewness(blueErrS(indBS))];
kurtS = [kurtosis(redErrS(indRS)), kurtosis(greenErrS(indGS)), kurtosis(blueErrS(indBS))];

% Get mean, sd, skew and kurtosis for errors (smooth)
% for errors from 5x5 window neighborhoods and image pixels
avgS2 = [mean(redErrS2(indRS2)), mean(greenErrS2(indGS2)), mean(blueErrS2(indBS2))];
sdS2 = [std(redErrS2(indRS2),1), std(greenErrS2(indGS2),1), std(blueErrS2(indBS2),1)];
skewS2 = [skewness(redErrS2(indRS2)), skewness(greenErrS2(indGS2)), skewness(blueErrS2(indBS2))];
kurtS2 = [kurtosis(redErrS2(indRS2)), kurtosis(greenErrS2(indGS2)), kurtosis(blueErrS2(indBS2))];

% Get mean, sd, skew and kurtosis for errors (smooth)
% for errors from 7x7 window neighborhoods and image pixels
avgS3 = [mean(redErrS3(indRS3)), mean(greenErrS3(indGS3)), mean(blueErrS3(indBS3))];
sdS3 = [std(redErrS3(indRS3),1), std(greenErrS3(indGS3),1), std(blueErrS3(indBS3),1)];
skewS3 = [skewness(redErrS3(indRS3)), skewness(greenErrS3(indGS3)), skewness(blueErrS3(indBS3))];
kurtS3 = [kurtosis(redErrS3(indRS3)), kurtosis(greenErrS3(indGS3)), kurtosis(blueErrS3(indBS3))];

% initialize entropy arrays
entropy = [0 0 0];
entropy2 = [0 0 0];
entropy3 = [0 0 0];
entropyS = [0 0 0];
entropyS2 = [0 0 0];
entropyS3 = [0 0 0];

% get entropy for red 3x3 window errors (edge)
rEn = redErr(indR).*log2(redErr(indR));
entropy(1) = -1*sum(rEn(~isnan(rEn(:))));

% get entropy for green 3x3 window errors (edge)
gEn = greenErr(indG).*log2(greenErr(indG));
entropy(2) = -1*sum(gEn(~isnan(gEn(:))));

% get entropy for blue 3x3 window errors (edge)
bEn = blueErr(indB).*log2(blueErr(indB));
entropy(3) = -1*sum(bEn(~isnan(bEn(:))));

% get entropy for red 3x3 window errors (smooth)
rEnS = redErrS(indRS).*log2(redErrS(indRS));
entropyS(1) = -1*sum(rEnS(~isnan(rEnS(:))));

% get entropy for green 3x3 window errors (smooth)
gEnS = greenErrS(indGS).*log2(greenErrS(indGS));
entropyS(2) = -1*sum(gEnS(~isnan(gEnS(:))));

% get entropy for blue 3x3 window errors (smooth)
bEnS = blueErrS(indBS).*log2(blueErrS(indBS));
entropyS(3) = -1*sum(bEnS(~isnan(bEnS(:))));

% get entropy for red 5x5 window errors (edge)
rEn2 = redErr2(indR2).*log2(redErr2(indR2));
entropy2(1) = -1*sum(rEn2(~isnan(rEn2(:))));

% get entropy for green 5x5 window errors (edge)
gEn2 = greenErr2(indG2).*log2(greenErr2(indG2));
entropy2(2) = -1*sum(gEn2(~isnan(gEn2(:))));

% get entropy for blue 5x5 window errors (edge)
bEn2 = blueErr2(indB2).*log2(blueErr2(indB2));
entropy2(3) = -1*sum(bEn2(~isnan(bEn2(:))));

% get entropy for red 5x5 window errors (smooth)
rEnS2 = redErrS2(indRS2).*log2(redErrS2(indRS2));
entropyS2(1) = -1*sum(rEnS2(~isnan(rEnS2(:))));

% get entropy for green 5x5 window errors (smooth)
gEnS2 = greenErrS2(indGS2).*log2(greenErrS2(indGS2));
entropyS2(2) = -1*sum(gEnS2(~isnan(gEnS2(:))));

% get entropy for blue 5x5 window errors (smooth)
bEnS2 = blueErrS2(indBS2).*log2(blueErrS2(indBS2));
entropyS2(3) = -1*sum(bEnS2(~isnan(bEnS2(:))));

% get entropy for red 7x7 window errors (edge)
rEn3 = redErr3(indR3).*log2(redErr3(indR3));
entropy3(1) = -1*sum(rEn3(~isnan(rEn3(:))));

% get entropy for green 7x7 window errors (edge)
gEn3 = greenErr3(indG3).*log2(greenErr3(indG3));
entropy3(2) = -1*sum(gEn3(~isnan(gEn3(:))));

% get entropy for blue 7x7 window errors (edge)
bEn3 = blueErr3(indB3).*log2(blueErr3(indB3));
entropy3(3) = -1*sum(bEn3(~isnan(bEn3(:))));

% get entropy for red 7x7 window errors (smooth)
rEnS3 = redErrS3(indRS3).*log2(redErrS3(indRS3));
entropyS3(1) = -1*sum(rEnS3(~isnan(rEnS3(:))));

% get entropy for green 7x7 window errors (smooth)
gEnS3 = greenErrS3(indGS3).*log2(greenErrS3(indGS3));
entropyS3(2) = -1*sum(gEnS3(~isnan(gEnS3(:))));

% get entropy for blue 7x7 window errors (smooth)
bEnS3 = blueErrS3(indBS3).*log2(blueErr3(indBS3));
entropyS3(3) = -1*sum(bEnS3(~isnan(bEnS3(:))));

% Get energy for errors from 3x3 window and image pixels (edge)
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

% Get energy for errors from 3x3 window and image pixels (smooth)
energyS = [0,0,0];
for i = 1:size(redErrS,1)
    energyS(1) = energyS(1)+redErrS(i)^2;
end
for i = 1:size(greenErrS,1)
    energyS(2) = energyS(2)+greenErrS(i)^2;
end
for i = 1:size(blueErrS,1)
    energyS(3) = energyS(3)+blueErrS(i)^2;
end

% Get energy for errors from 5x5 window and image pixels (edge)
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

% Get energy for errors from 5x5 window and image pixels (smooth)
energyS2 = [0,0,0];
for i = 1:size(redErrS2,1)
    energyS2(1) = energyS2(1)+redErrS2(i)^2;
end
for i = 1:size(greenErrS2,1)
    energyS2(2) = energyS2(2)+greenErrS2(i)^2;
end
for i = 1:size(blueErrS2,1)
    energyS2(3) = energyS2(3)+blueErrS2(i)^2;
end

% Get energy for errors from 7x7 window and image pixels (edge)
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

% Get energy for errors from 7x7 window and image pixels (smooth)
energyS3 = [0,0,0];
for i = 1:size(redErrS3,1)
    energyS3(1) = energyS3(1)+redErrS3(i)^2;
end
for i = 1:size(greenErrS3,1)
    energyS3(2) = energyS3(2)+greenErrS3(i)^2;
end
for i = 1:size(blueErrS3,1)
    energyS3(3) = energyS3(3)+blueErrS3(i)^2;
end

% Return image statistics as imgStats for 3x3 window (edge)
% stats contain data for all 3 color channels as 3x1 vectors
iStat3 = imgStats(avg,sd,skew,kurt,entropy,energy,pixels,meds,errors)

% Return image statistics as imgStats for 5x5 window (edge)
% stats contain data for all 3 color channels as 3x1 vectors
iStat5 = imgStats(avg2,sd2,skew2,kurt2,entropy2,energy2,pixels2,meds2,errors2)

% Return image statistics as imgStats for 7x7 window (edge)
% stats contain data for all 3 color channels as 3x1 vectors
iStat7 = imgStats(avg3,sd3,skew3,kurt3,entropy3,energy3,pixels3,meds3,errors3)

% Return image statistics as imgStats for 3x3 window (smooth)
% stats contain data for all 3 color channels as 3x1 vectors
iStatS3 = imgStats(avgS,sdS,skewS,kurtS,entropyS,energyS,pixels,meds,errors)

% Return image statistics as imgStats for 5x5 window (smooth)
% stats contain data for all 3 color channels as 3x1 vectors
iStatS5 = imgStats(avgS2,sdS2,skewS2,kurtS2,entropyS2,energyS2,pixels2,meds2,errors2)

% Return image statistics as imgStats for 7x7 window (smooth)
% stats contain data for all 3 color channels as 3x1 vectors
iStatS7 = imgStats(avgS3,sdS3,skewS3,kurtS3,entropyS3,energyS3,pixels3,meds3,errors3)

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
