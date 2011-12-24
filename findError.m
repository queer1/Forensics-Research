%{
Read the given image and gather different statistics for the error values
of the pixels using a 3 by 3 pixel window.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 08, 2011
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

% Get RGB values for image pixels
pixels = int16(fimg.image(2:511,2:511,1:3));

% get pixel neighborhoods for image pixels
nbhoods = zeros(510,510,3,9);
for c = 1:510
    for r = 1:510
        nbhoods(r,c,1,:) = fimg.getnb(r+1,c+1,1,3);
        nbhoods(r,c,2,:) = fimg.getnb(r+1,c+1,2,3);
        nbhoods(r,c,3,:) = fimg.getnb(r+1,c+1,3,3);
    end
end

% get median values for all pixel neighborhoods
% mean of the two center values after sorted low to high
meds = zeros(510,510,3);
for c = 1:510
    for r = 1:510
        meds(r,c,1) = median(nbhoods(r,c,1,:));
        meds(r,c,2) = median(nbhoods(r,c,2,:));
        meds(r,c,3) = median(nbhoods(r,c,3,:));
    end
end

% get error for image pixels
errors = abs(double(meds)-double(pixels));
redErr = errors(:,:,1);
greenErr = errors(:,:,2);
blueErr = errors(:,:,3);

% Get mean, sd, skew and kurtosis for errors
avg = [mean(redErr(:)) mean(greenErr(:)) mean(blueErr(:))];
sd = [std(redErr(:),1) std(greenErr(:),1) std(blueErr(:),1)];
skew = [skewness(redErr(:)) skewness(greenErr(:)) skewness(blueErr(:))];
kurt = [kurtosis(redErr(:)) kurtosis(greenErr(:)) kurtosis(blueErr(:))];

% Get entropy for errors
entropy = [0 0 0];
for i = 1:260100
    if (redErr(i) ~= 0)
        entropy(1) = entropy(1)+redErr(i)*log2(redErr(i));
    end
end
entropy(1) = -1*entropy(1);

for i = 1:260100
    if (greenErr(i) ~= 0)
        entropy(2) = entropy(2)+greenErr(i)*log2(greenErr(i));
    end
end
entropy(2) = -1*entropy(2);

for i = 1:260100
    if (blueErr(i) ~= 0)
        entropy(3) = entropy(3)+blueErr(i)*log2(blueErr(i));
    end
end
entropy(3) = -1*entropy(3);

% Get energy for errors
energy = [0 0 0];
for i = 1:260100
    energy(1) = energy(1)+redErr(i)^2;
end

for i = 1:260100
    energy(2) = energy(2)+greenErr(i)^2;
end

for i = 1:260100
    energy(3) = energy(3)+blueErr(i)^2;
end

% Return image statistics as imgStats for 3x3 window
% each iStat object contains data for all 1 of 3 color channels
iStat3Red = imgStats(avg(1),sd(1),skew(1),kurt(1),entropy(1),energy(1),pixels(:,:,1),meds(:,:,1),redErr)
iStat3Green = imgStats(avg(2),sd(2),skew(2),kurt(2),entropy(2),energy(2),pixels(:,:,2),meds(:,:,2),greenErr)
iStat3Blue = imgStats(avg(3),sd(3),skew(3),kurt(3),entropy(3),energy(3),pixels(:,:,3),meds(:,:,3),blueErr)

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
