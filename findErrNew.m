%{
Read the given image and gather different statistics for the error values
of the pixels using a 3 by 3 pixel window.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 14, 2011
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
fimg = ForensicImage('bassCrop.jpg');
win = 3;

% calculate image dimensions
s = size(fimg.image);
dim = s(1)-2*floor(win/2);
pixStart = floor(win/2)+1;
pixEnd = 512-floor(win/2)+1;
rStart = floor(win/2)+1;
rEnd = s(1)-floor(win/2);
cStart = floor(win/2)+1;
cEnd = s(2)-floor(win/2);

% Get RGB values for image pixels
pixels = int16(fimg.image(rStart:rEnd,cStart:cEnd,1:3));

% get pixel neighborhoods for image pixels
meds(:,:,1) = medfilt2(fimg.image(:,:,1),[3 3]);
meds(:,:,2) = medfilt2(fimg.image(:,:,2),[3 3]);
meds(:,:,3) = medfilt2(fimg.image(:,:,3),[3 3]);
meds = meds(rStart:rEnd,cStart:cEnd,1:3);

% get error for image pixels
errors = abs(double(meds)-double(pixels));
redErr = errors(:,:,1);
greenErr = errors(:,:,2);
blueErr = errors(:,:,3);

% Get mean, sd, skew and kurtosis for errors
avg = [mean(redErr(:)), mean(greenErr(:)), mean(blueErr(:))];
sd = [std(redErr(:),1), std(greenErr(:),1), std(blueErr(:),1)];
skew = [skewness(redErr(:)), skewness(greenErr(:)), skewness(blueErr(:))];
kurt = [kurtosis(redErr(:)), kurtosis(greenErr(:)), kurtosis(blueErr(:))];

% Get entropy for errors
entropy = [0 0 0];
rEn = redErr.*log2(redErr);
entropy(1) = -1*sum(rEn(~isnan(rEn(:))));
gEn = greenErr.*log2(greenErr);
entropy(2) = -1*sum(gEn(~isnan(gEn(:))));
bEn = blueErr.*log2(blueErr);
entropy(3) = -1*sum(bEn(~isnan(bEn(:))));

% Get energy for errors
energy = [0,0,0];
for i = 1:dim^2
    energy(1) = energy(1)+redErr(i)^2;
    energy(2) = energy(2)+greenErr(i)^2;
    energy(3) = energy(3)+blueErr(i)^2;
end

% Return image statistics as imgStats for 3x3 window
% each iStat object contains data for all 1 of 3 color channels
iStat3Red = imgStats(avg(1),sd(1),skew(1),kurt(1),entropy(1),energy(1),pixels(:,:,1),meds(:,:,1),redErr)
iStat3Green = imgStats(avg(2),sd(2),skew(2),kurt(2),entropy(2),energy(2),pixels(:,:,2),meds(:,:,2),greenErr)
iStat3Blue = imgStats(avg(3),sd(3),skew(3),kurt(3),entropy(3),energy(3),pixels(:,:,3),meds(:,:,3),blueErr)

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
