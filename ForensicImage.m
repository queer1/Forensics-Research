%{
A color image file with forensics functions attached.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 06, 2011
updated: November 04, 2011
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

classdef ForensicImage < handle
    
    properties (GetAccess='public',SetAccess='public')
        filename
        image
        bayerR
        bayerG1
        bayerG2
        bayerB
    end
    
    methods
        
        % Forensic Image constructor
        % f=filename
        function obj = ForensicImage(f)
            obj.filename = f;
            obj.image = imread(f);
        end
        
        % Get image RGB color channels of image
        function [red,green,blue] = getColorCh(obj)
            red = obj.image(:,:,1);
            green = obj.image(:,:,2);
            blue = obj.image(:,:,3);
        end
        
        % Crop image file to 512x512
        function obj = crop512(obj)
            [length,width,~] = size(obj.image);
            rowStart = length/2-256;
            colStart = width/2-256;
            window = [colStart,rowStart,511,511];
            obj.image = imcrop(obj.image,window);
        end
        
        % Get image pixel neighbors
        % r=row, c=column, ch=color_channel, win=window_size
        % window is win by win square pixels in size
        % win must be an odd int greater than 1
        function nbhood = getnb(obj,r,c,ch,win)
            size = win^2-1;
            t = floor(win/2);
            box = obj.image(r-t:r+t,c-t:c+t,ch);
            nbhood = int16(box(1:size+1)); % includes center pixel 
        end
        
        % Get image's alternate color bins
        function [channel1,channel2,channel3] = getAltColorBins(obj)
            
            % get image's rgb color channels
            [red,green,blue] = obj.getColorCh();
            
            % get image's alternate color channels
            channel1 = double((red+green+blue)/3);
            channel2 = double((red-blue)/2);
            channel3 = double((2*green-red-blue)/4);

        end
        
        % Get image statistics for alternate color bins
        function iStatACB = imgStatsACB(obj)
            
            % color channels
            r = 1;
            g = 2;
            b = 3;
            
            % get alternate color bins
            [channel1,channel2,channel3] = obj.getAltColorBins();
            
            % Get mean, sd, skew and kurtosis for alternate color channels
            avg = [mean(channel1(:)), mean(channel2(:)), mean(channel3(:))];
            sd = [std(channel1(:),1), std(channel2(:),1), std(channel3(:),1)];
            skew = [skewness(channel1(:)), skewness(channel2(:)), skewness(channel3(:))];
            kurt = [kurtosis(channel1(:)), kurtosis(channel2(:)), kurtosis(channel3(:))];
            
            % initialize entropy
            entropy = [0 0 0];
            
            % get entropy for alternate color channel 1
            c1En = channel1.*log2(channel1);
            entropy(r) = -1*sum(channel1(~isnan(channel1(:))));
            
            % get entropy for alternate color channel 2
            c2En = channel2.*log2(channel2);
            entropy(g) = -1*sum(channel2(~isnan(channel2(:))));
            
            % get entropy for alternate color channel 3
            c3En = channel3.*log2(channel3);
            entropy(b) = -1*sum(channel3(~isnan(channel3(:))));
            
            % Get energy for alternate color channels
            energy = [0,0,0];
            for i = 1:size(channel1,1)^2
                energy(r) = energy(r)+channel1(i)^2;
                energy(g) = energy(g)+channel2(i)^2;
                energy(b) = energy(b)+channel3(i)^2;
            end
            
            % Return image statistics as imgStats for alternate color bins
            % stats contain data for all 3 color channels as 3x1 vectors
            iStatACB = imgStats(avg,sd,skew,kurt,entropy,energy,0,0,0);
            
        end
        
        % Get image's average pixel value
        function avgPix = AvgPixel(obj)
            
            % get image's rgb color channels
            [red,green,blue] = obj.getColorCh();
            
            % get mean value for each color channel
            redAvg = mean2(red);
            greenAvg = mean2(green);
            blueAvg = mean2(blue);
            
            % get mean value for all rgb color channels
            avgPix = [redAvg greenAvg blueAvg];
            
        end
        
        % Get image statistics
        % iStat3 = imgStats for 3x3 neighborhood edges
        % iStat5 = imgStats for 5x5 neighborhood edges
        % iStat7 = imgStats for 7x7 neighborhood edges
        function [iStat3,iStat5,iStat7] = imgStats(obj)
            
            % color channels
            r = 1;
            g = 2;
            b = 3;
            
            % window sizes
            win = 3;
            win2 = 5;
            win3 = 7;
            
            % image dimensions
            s = size(obj.image);
            dim = s(1)-2*floor(win/2);
            
            % row cropping dimensions
            rStart = floor(win/2)+1;
            rEnd = s(1)-floor(win/2);
            
            % column cropping dimensions
            cStart = floor(win/2)+1;
            cEnd = s(2)-floor(win/2);
            
            % Get RGB values for image pixels
            % for 3x3 neighborhoods use middle 510 by 510 pixels
            pixels = int16(obj.image(rStart:rEnd,cStart:cEnd,r:b));
            
            % Get RGB values for image pixels
            % for 5x5 neighborhoods use middle 508 by 508 pixels
            pixels2 = int16(obj.image(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b));
            
            % Get RGB values for image pixels
            % for 7x7 neighborhoods use middle 506 by 506 pixels
            pixels3 = int16(obj.image(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b));

            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 3x3 window
            % then crop to 510 by 510
            meds(:,:,r) = medfilt2new(obj.image(:,:,r),win);
            meds(:,:,g) = medfilt2new(obj.image(:,:,g),win);
            meds(:,:,b) = medfilt2new(obj.image(:,:,b),win);
            meds = meds(rStart:rEnd,cStart:cEnd,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 5x5 window
            % then crop to 508 by 508
            meds2(:,:,r) = medfilt2new(obj.image(:,:,r),win2);
            meds2(:,:,g) = medfilt2new(obj.image(:,:,g),win2);
            meds2(:,:,b) = medfilt2new(obj.image(:,:,b),win2);
            meds2 = meds2(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 7x7 window
            % then crop to 506 by 506
            meds3(:,:,r) = medfilt2new(obj.image(:,:,r),win3);
            meds3(:,:,g) = medfilt2new(obj.image(:,:,g),win3);
            meds3(:,:,b) = medfilt2new(obj.image(:,:,b),win3);
            meds3 = meds3(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b);

            % get error for image pixels
            % error is the absolute difference of medians from 3x3 window 
            % neighborhoods and image pixels
            % separate errors into each color channel
            errors = abs(double(meds)-double(pixels));
            redErr = errors(:,:,r);
            greenErr = errors(:,:,g);
            blueErr = errors(:,:,b);
            
            % get error for image pixels
            % error is the absolute difference of medians from 5x5 window 
            % neighborhoods and image pixels
            % separate errors into each color channel
            errors2 = abs(double(meds2)-double(pixels2));
            redErr2 = errors2(:,:,r);
            greenErr2 = errors2(:,:,g);
            blueErr2 = errors2(:,:,b);
            
            % get error for image pixels
            % error is the absolute difference of medians from 7x7 window 
            % neighborhoods and image pixels
            % separate errors into each color channel
            errors3 = abs(double(meds3)-double(pixels3));
            redErr3 = errors3(:,:,r);
            greenErr3 = errors3(:,:,g);
            blueErr3 = errors3(:,:,b);

            % Get mean, sd, skew and kurtosis for errors
            % for errors from 3x3 window neighborhoods and image pixels
            avg = [mean(redErr(:)), mean(greenErr(:)), mean(blueErr(:))];
            sd = [std(redErr(:),1), std(greenErr(:),1), std(blueErr(:),1)];
            skew = [skewness(redErr(:)), skewness(greenErr(:)), skewness(blueErr(:))];
            kurt = [kurtosis(redErr(:)), kurtosis(greenErr(:)), kurtosis(blueErr(:))];
            
            % Get mean, sd, skew and kurtosis for errors
            % for errors from 5x5 window neighborhoods and image pixels
            avg2 = [mean(redErr2(:)), mean(greenErr2(:)), mean(blueErr2(:))];
            sd2 = [std(redErr2(:),1), std(greenErr2(:),1), std(blueErr2(:),1)];
            skew2 = [skewness(redErr2(:)), skewness(greenErr2(:)), skewness(blueErr2(:))];
            kurt2 = [kurtosis(redErr2(:)), kurtosis(greenErr2(:)), kurtosis(blueErr2(:))];
            
            % Get mean, sd, skew and kurtosis for errors
            % for errors from 7x7 window neighborhoods and image pixels
            avg3 = [mean(redErr3(:)), mean(greenErr3(:)), mean(blueErr3(:))];
            sd3 = [std(redErr3(:),1), std(greenErr3(:),1), std(blueErr3(:),1)];
            skew3 = [skewness(redErr3(:)), skewness(greenErr3(:)), skewness(blueErr3(:))];
            kurt3 = [kurtosis(redErr3(:)), kurtosis(greenErr3(:)), kurtosis(blueErr3(:))];

            % initialize entropy arrays
            entropy = [0 0 0];
            entropy2 = [0 0 0];
            entropy3 = [0 0 0];
            
            % get entropy for red 3x3 window errors
            rEn = redErr.*log2(redErr);
            entropy(r) = -1*sum(rEn(~isnan(rEn(:))));
            
            % get entropy for green 3x3 window errors
            gEn = greenErr.*log2(greenErr);
            entropy(g) = -1*sum(gEn(~isnan(gEn(:))));
            
            % get entropy for blue 3x3 window errors
            bEn = blueErr.*log2(blueErr);
            entropy(b) = -1*sum(bEn(~isnan(bEn(:))));
            
            % get entropy for red 5x5 window errors
            rEn2 = redErr2.*log2(redErr2);
            entropy2(r) = -1*sum(rEn2(~isnan(rEn2(:))));
            
            % get entropy for green 5x5 window errors
            gEn2 = greenErr2.*log2(greenErr2);
            entropy2(g) = -1*sum(gEn2(~isnan(gEn2(:))));
            
            % get entropy for blue 5x5 window errors
            bEn2 = blueErr2.*log2(blueErr2);
            entropy2(b) = -1*sum(bEn2(~isnan(bEn2(:))));
            
            % get entropy for red 7x7 window errors
            rEn3 = redErr3.*log2(redErr3);
            entropy3(r) = -1*sum(rEn3(~isnan(rEn3(:))));
            
            % get entropy for green 7x7 window errors
            gEn3 = greenErr3.*log2(greenErr3);
            entropy3(g) = -1*sum(gEn3(~isnan(gEn3(:))));
            
            % get entropy for blue 7x7 window errors
            bEn3 = blueErr3.*log2(blueErr3);
            entropy3(b) = -1*sum(bEn3(~isnan(bEn3(:))));

            % Get energy for errors from 3x3 window and image pixels
            energy = [0,0,0];
            for i = 1:dim^2
                energy(r) = energy(r)+redErr(i)^2;
                energy(g) = energy(g)+greenErr(i)^2;
                energy(b) = energy(b)+blueErr(i)^2;
            end
            
            % Get energy for errors from 5x5 window and image pixels
            energy2 = [0,0,0];
            for i = 1:(dim-2)^2
                energy2(r) = energy2(r)+redErr2(i)^2;
                energy2(g) = energy2(g)+greenErr2(i)^2;
                energy2(b) = energy2(b)+blueErr2(i)^2;
            end
            
            % Get energy for errors from 7x7 window and image pixels
            energy3 = [0,0,0];
            for i = 1:(dim-4)^2
                energy3(r) = energy3(r)+redErr3(i)^2;
                energy3(g) = energy3(g)+greenErr3(i)^2;
                energy3(b) = energy3(b)+blueErr3(i)^2;
            end

            % Return image statistics as imgStats for 3x3 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat3 = imgStats(avg,sd,skew,kurt,entropy,energy,pixels,meds,errors);
            
            % Return image statistics as imgStats for 5x5 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat5 = imgStats(avg2,sd2,skew2,kurt2,entropy2,energy2,pixels2,meds2,errors2);
            
            % Return image statistics as imgStats for 7x7 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat7 = imgStats(avg3,sd3,skew3,kurt3,entropy3,energy3,pixels3,meds3,errors3);
            
        end
        
        % Get image statistics for smooth hue transition
        % iStat3 = imgStats for 3x3 neighborhood edges
        % iStat5 = imgStats for 5x5 neighborhood edges
        % iStat7 = imgStats for 7x7 neighborhood edges
        function [iStat3,iStat5,iStat7] = imgStatsHue(obj)
            
            % color channels
            r = 1;
            g = 2;
            b = 3;
            
            % window sizes
            win = 3;
            win2 = 5;
            win3 = 7;
            
            % image dimensions
            s = size(obj.image);
            dim = s(1)-2*floor(win/2);
            
            % row cropping dimensions
            rStart = floor(win/2)+1;
            rEnd = s(1)-floor(win/2);
            
            % column cropping dimensions
            cStart = floor(win/2)+1;
            cEnd = s(2)-floor(win/2);
            
            % Get RGB values for image pixels
            % for 3x3 neighborhoods use middle 510 by 510 pixels
            pixels = int16(obj.image(rStart:rEnd,cStart:cEnd,r:b));
            
            % Get RGB values for image pixels
            % for 5x5 neighborhoods use middle 508 by 508 pixels
            pixels2 = int16(obj.image(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b));
            
            % Get RGB values for image pixels
            % for 7x7 neighborhoods use middle 506 by 506 pixels
            pixels3 = int16(obj.image(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b));

            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 3x3 window
            % then crop to 510 by 510
            meds(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win,1);
            meds(:,:,g) = medfilt2new(obj.image(:,:,g),win);
            meds(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win,1);
            meds = meds(rStart:rEnd,cStart:cEnd,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 3x3 window
            % then crop to 510 by 510
            medsG1(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win,2);
            medsG1(:,:,g) = medfilt2new(obj.image(:,:,g),win);
            medsG1(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win,2);
            medsG1 = medsG1(rStart:rEnd,cStart:cEnd,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 3x3 window
            % then crop to 510 by 510
            medsG2(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win,3);
            medsG2(:,:,g) = medfilt2new(obj.image(:,:,g),win);
            medsG2(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win,3);
            medsG2 = medsG2(rStart:rEnd,cStart:cEnd,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 3x3 window
            % then crop to 510 by 510
            medsB(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win,4);
            medsB(:,:,g) = medfilt2new(obj.image(:,:,g),win);
            medsB(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win,4);
            medsB = medsB(rStart:rEnd,cStart:cEnd,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 5x5 window
            % then crop to 508 by 508
            meds2(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win2,1);
            meds2(:,:,g) = medfilt2new(obj.image(:,:,g),win2);
            meds2(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win2,1);
            meds2 = meds2(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 5x5 window
            % then crop to 508 by 508
            meds2G1(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win2,2);
            meds2G1(:,:,g) = medfilt2new(obj.image(:,:,g),win2);
            meds2G1(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win2,2);
            meds2G1 = meds2G1(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 5x5 window
            % then crop to 508 by 508
            meds2G2(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win2,3);
            meds2G2(:,:,g) = medfilt2new(obj.image(:,:,g),win2);
            meds2G2(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win2,3);
            meds2G2 = meds2G2(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 5x5 window
            % then crop to 508 by 508
            meds2B(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win2,4);
            meds2B(:,:,g) = medfilt2new(obj.image(:,:,g),win2);
            meds2B(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win2,4);
            meds2B = meds2B(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 7x7 window
            % then crop to 506 by 506
            meds3(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win3,1);
            meds3(:,:,g) = medfilt2new(obj.image(:,:,g),win3);
            meds3(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win3,1);
            meds3 = meds3(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 7x7 window
            % then crop to 506 by 506
            meds3G1(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win3,2);
            meds3G1(:,:,g) = medfilt2new(obj.image(:,:,g),win3);
            meds3G1(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win3,2);
            meds3G1 = meds3G1(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 7x7 window
            % then crop to 506 by 506
            meds3G2(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win3,3);
            meds3G2(:,:,g) = medfilt2new(obj.image(:,:,g),win3);
            meds3G2(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win3,3);
            meds3G2 = meds3G2(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b);
            
            % get pixel neighborhoods for image pixels
            % extract median neighbor for each pixel in 7x7 window
            % then crop to 506 by 506
            meds3B(:,:,r) = huefilt(obj.image(:,:,r),obj.image(:,:,g),win3,4);
            meds3B(:,:,g) = medfilt2new(obj.image(:,:,g),win3);
            meds3B(:,:,b) = huefilt(obj.image(:,:,b),obj.image(:,:,g),win3,4);
            meds3B = meds3B(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b);

            % get error for image pixels
            % error is the absolute difference of medians from 3x3 window 
            % neighborhoods and image pixels
            errors = abs(double(meds)-double(pixels));
            
            % get error for image pixels
            % error is the absolute difference of medians from 3x3 window 
            % neighborhoods and image pixels
            errorsG1 = abs(double(medsG1)-double(pixels));
            
            % get error for image pixels
            % error is the absolute difference of medians from 3x3 window 
            % neighborhoods and image pixels
            errorsG2 = abs(double(medsG2)-double(pixels));
            
            % get error for image pixels
            % error is the absolute difference of medians from 3x3 window 
            % neighborhoods and image pixels
            errorsB = abs(double(medsB)-double(pixels));
            
            % determine which bayer type is closest to original image
            % and use errors from that bayer type for statistics
            sigmaR = sum(sum(sum(errors)));
            sigmaG1 = sum(sum(sum(errorsG1)));
            sigmaG2 = sum(sum(sum(errorsG2)));
            sigmaB = sum(sum(sum(errorsB)));
            
            % get closest bayer type
            sigmaMin = min(sigmaR,min(sigmaG1,min(sigmaG2,sigmaB)));
            if (sigmaMin == sigmaG1)
                errors = errorsG1;
            elseif (sigmaMin == sigmaG2)
                errors = errorsG2;
            elseif (sigmaMin == sigmaB)
                errors = errorsB;
            end
            
            % separate errors into each color channel
            redErr = errors(:,:,r);
            greenErr = errors(:,:,g);
            blueErr = errors(:,:,b);
            
            % get error for image pixels
            % error is the absolute difference of medians from 5x5 window 
            % neighborhoods and image pixels
            errors2 = abs(double(meds2)-double(pixels2));
            
            % get error for image pixels
            % error is the absolute difference of medians from 5x5 window 
            % neighborhoods and image pixels
            errors2G1 = abs(double(meds2G1)-double(pixels2));
            
            % get error for image pixels
            % error is the absolute difference of medians from 5x5 window 
            % neighborhoods and image pixels
            errors2G2 = abs(double(meds2G2)-double(pixels2));
            
            % get error for image pixels
            % error is the absolute difference of medians from 5x5 window 
            % neighborhoods and image pixels
            errors2B = abs(double(meds2B)-double(pixels2));
            
            % determine which bayer type is closest to original image
            % and use errors from that bayer type for statistics
            sigmaR = sum(sum(sum(errors2)));
            sigmaG1 = sum(sum(sum(errors2G1)));
            sigmaG2 = sum(sum(sum(errors2G2)));
            sigmaB = sum(sum(sum(errors2B)));
            
            % get closest bayer type
            sigmaMin = min(sigmaR,min(sigmaG1,min(sigmaG2,sigmaB)));
            if (sigmaMin == sigmaG1)
                errors2 = errors2G1;
            elseif (sigmaMin == sigmaG2)
                errors2 = errors2G2;
            elseif (sigmaMin == sigmaB)
                errors2 = errors2B;
            end
            
            % separate errors into each color channel
            redErr2 = errors2(:,:,r);
            greenErr2 = errors2(:,:,g);
            blueErr2 = errors2(:,:,b);
            
            % get error for image pixels
            % error is the absolute difference of medians from 7x7 window 
            % neighborhoods and image pixels
            errors3 = abs(double(meds3)-double(pixels3));
            
            % get error for image pixels
            % error is the absolute difference of medians from 7x7 window 
            % neighborhoods and image pixels
            errors3G1 = abs(double(meds3G1)-double(pixels3));
            
            % get error for image pixels
            % error is the absolute difference of medians from 7x7 window 
            % neighborhoods and image pixels
            errors3G2 = abs(double(meds3G2)-double(pixels3));
            
            % get error for image pixels
            % error is the absolute difference of medians from 7x7 window 
            % neighborhoods and image pixels
            errors3B = abs(double(meds3B)-double(pixels3));
            
            % determine which bayer type is closest to original image
            % and use errors from that bayer type for statistics
            sigmaR = sum(sum(sum(errors3)));
            sigmaG1 = sum(sum(sum(errors3G1)));
            sigmaG2 = sum(sum(sum(errors3G2)));
            sigmaB = sum(sum(sum(errors3B)));
            
            % get closest bayer type
            sigmaMin = min(sigmaR,min(sigmaG1,min(sigmaG2,sigmaB)));
            if (sigmaMin == sigmaG1)
                errors3 = errors3G1;
            elseif (sigmaMin == sigmaG2)
                errors3 = errors3G2;
            elseif (sigmaMin == sigmaB)
                errors3 = errors3B;
            end
            
            % separate errors into each color channel
            redErr3 = errors3(:,:,r);
            greenErr3 = errors3(:,:,g);
            blueErr3 = errors3(:,:,b);

            % Get mean, sd, skew and kurtosis for errors
            % for errors from 3x3 window neighborhoods and image pixels
            avg = [mean(redErr(:)), mean(greenErr(:)), mean(blueErr(:))];
            sd = [std(redErr(:),1), std(greenErr(:),1), std(blueErr(:),1)];
            skew = [skewness(redErr(:)), skewness(greenErr(:)), skewness(blueErr(:))];
            kurt = [kurtosis(redErr(:)), kurtosis(greenErr(:)), kurtosis(blueErr(:))];
            
            % Get mean, sd, skew and kurtosis for errors
            % for errors from 5x5 window neighborhoods and image pixels
            avg2 = [mean(redErr2(:)), mean(greenErr2(:)), mean(blueErr2(:))];
            sd2 = [std(redErr2(:),1), std(greenErr2(:),1), std(blueErr2(:),1)];
            skew2 = [skewness(redErr2(:)), skewness(greenErr2(:)), skewness(blueErr2(:))];
            kurt2 = [kurtosis(redErr2(:)), kurtosis(greenErr2(:)), kurtosis(blueErr2(:))];
            
            % Get mean, sd, skew and kurtosis for errors
            % for errors from 7x7 window neighborhoods and image pixels
            avg3 = [mean(redErr3(:)), mean(greenErr3(:)), mean(blueErr3(:))];
            sd3 = [std(redErr3(:),1), std(greenErr3(:),1), std(blueErr3(:),1)];
            skew3 = [skewness(redErr3(:)), skewness(greenErr3(:)), skewness(blueErr3(:))];
            kurt3 = [kurtosis(redErr3(:)), kurtosis(greenErr3(:)), kurtosis(blueErr3(:))];

            % initialize entropy arrays
            entropy = [0 0 0];
            entropy2 = [0 0 0];
            entropy3 = [0 0 0];
            
            % get entropy for red 3x3 window errors
            rEn = redErr.*log2(redErr);
            entropy(r) = -1*sum(rEn(~isnan(rEn(:))));
            
            % get entropy for green 3x3 window errors
            gEn = greenErr.*log2(greenErr);
            entropy(g) = -1*sum(gEn(~isnan(gEn(:))));
            
            % get entropy for blue 3x3 window errors
            bEn = blueErr.*log2(blueErr);
            entropy(b) = -1*sum(bEn(~isnan(bEn(:))));
            
            % get entropy for red 5x5 window errors
            rEn2 = redErr2.*log2(redErr2);
            entropy2(r) = -1*sum(rEn2(~isnan(rEn2(:))));
            
            % get entropy for green 5x5 window errors
            gEn2 = greenErr2.*log2(greenErr2);
            entropy2(g) = -1*sum(gEn2(~isnan(gEn2(:))));
            
            % get entropy for blue 5x5 window errors
            bEn2 = blueErr2.*log2(blueErr2);
            entropy2(b) = -1*sum(bEn2(~isnan(bEn2(:))));
            
            % get entropy for red 7x7 window errors
            rEn3 = redErr3.*log2(redErr3);
            entropy3(r) = -1*sum(rEn3(~isnan(rEn3(:))));
            
            % get entropy for green 7x7 window errors
            gEn3 = greenErr3.*log2(greenErr3);
            entropy3(g) = -1*sum(gEn3(~isnan(gEn3(:))));
            
            % get entropy for blue 7x7 window errors
            bEn3 = blueErr3.*log2(blueErr3);
            entropy3(b) = -1*sum(bEn3(~isnan(bEn3(:))));

            % Get energy for errors from 3x3 window and image pixels
            energy = [0,0,0];
            for i = 1:dim^2
                energy(r) = energy(r)+redErr(i)^2;
                energy(g) = energy(g)+greenErr(i)^2;
                energy(b) = energy(b)+blueErr(i)^2;
            end
            
            % Get energy for errors from 5x5 window and image pixels
            energy2 = [0,0,0];
            for i = 1:(dim-2)^2
                energy2(r) = energy2(r)+redErr2(i)^2;
                energy2(g) = energy2(g)+greenErr2(i)^2;
                energy2(b) = energy2(b)+blueErr2(i)^2;
            end
            
            % Get energy for errors from 7x7 window and image pixels
            energy3 = [0,0,0];
            for i = 1:(dim-4)^2
                energy3(r) = energy3(r)+redErr3(i)^2;
                energy3(g) = energy3(g)+greenErr3(i)^2;
                energy3(b) = energy3(b)+blueErr3(i)^2;
            end

            % Return image statistics as imgStats for 3x3 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat3 = imgStats(avg,sd,skew,kurt,entropy,energy,pixels,meds,errors);
            
            % Return image statistics as imgStats for 5x5 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat5 = imgStats(avg2,sd2,skew2,kurt2,entropy2,energy2,pixels2,meds2,errors2);
            
            % Return image statistics as imgStats for 7x7 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat7 = imgStats(avg3,sd3,skew3,kurt3,entropy3,energy3,pixels3,meds3,errors3);
            
        end
        
        % Get image statistics for edges
        % th1 = threshold for edge detection
        % th2 = threshold for edge median filter
        % cam = camera number (when used in getImageStatsEdge.m)
        % pic = photo number (when used in getImageStatsEdge.m)
        % iStat3 = imgStats for 3x3 neighborhood edges
        % iStat5 = imgStats for 5x5 neighborhood edges
        % iStat7 = imgStats for 7x7 neighborhood edges
        function [iStat3,iStat5,iStat7] = imgStatsEdge(obj,th1,th2,cam,pic)
            
            % color channels
            r = 1;
            g = 2;
            b = 3;
            
            % window sizes
            win = 3;
            win2 = 5;
            win3 = 7;

            % image dimensions
            s = size(obj.image);
            dim = s(1)-2*floor(win/2);

            % row cropping dimensions
            rStart = floor(win/2)+1;
            rEnd = s(1)-floor(win/2);

            % column cropping dimensions
            cStart = floor(win/2)+1;
            cEnd = s(2)-floor(win/2);

            % Get RGB values for image pixels
            % for 3x3 neighborhoods use middle 510 by 510 pixels
            pixels = int16(obj.image(rStart:rEnd,cStart:cEnd,r:b));

            % Get RGB values for image pixels
            % for 5x5 neighborhoods use middle 508 by 508 pixels
            pixels2 = int16(obj.image(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b));

            % Get RGB values for image pixels
            % for 7x7 neighborhoods use middle 506 by 506 pixels
            pixels3 = int16(obj.image(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b));

            % convert image to grayscale
            % extract color channels from image
            [red,green,blue] = obj.getColorCh();

            % find edges in grayscale image
            imgBWR = edge(red,'sobel',th1,'nothinning');
            imgBWG = edge(green,'sobel',th1,'nothinning');
            imgBWB = edge(blue,'sobel',th1,'nothinning');
            
            % calculate how many edges are detected per color channel
            edgeNumR = sum(sum(imgBWR));
            edgeNumG = sum(sum(imgBWG));
            edgeNumB = sum(sum(imgBWB));
            
%             str = ['Detected ',num2str(edgeNumR),' red, ', ...
%             num2str(edgeNumG),' green and ',num2str(edgeNumB),' blue edges '];
%             dstr = [datestr(now),': ',str];
%             disp(dstr)

            % crop binary images to 510 by 510 pixels for 3x3 windows
            iBWcR = imgBWR(rStart:rEnd,cStart:cEnd);
            iBWcG = imgBWG(rStart:rEnd,cStart:cEnd);
            iBWcB = imgBWB(rStart:rEnd,cStart:cEnd);

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
            [meds(:,:,r),edgeNumR] = medfilt2edge(red,imgBWR,win,th2);
            [meds(:,:,g),edgeNumG] = medfilt2edge(green,imgBWG,win,th2);
            [meds(:,:,b),edgeNumB] = medfilt2edge(blue,imgBWB,win,th2);
            meds = meds(rStart:rEnd,cStart:cEnd,:);
            
%             str = ['Retained ',num2str(edgeNumR),' red, ', ...
%             num2str(edgeNumG),' green and ',num2str(edgeNumB), ...
%             ' blue edges for 3x3 window'];
%             dstr = [datestr(now),': ',str];
%             disp(dstr)
            
%             % save 3x3 red doubly thresholded image to file
%             fname = strcat('./c',num2str(cam),'p',num2str(pic),'_3x3_red_',num2str(th1),'_',num2str(th2),'.jpg');
%             imwrite(meds(:,:,1),fname);

            % get pixel neighborhoods for image pixels
            % extract median edge neighbor for each pixel in 5x5 window
            % then crop to 508 by 508
            [meds2(:,:,r),edgeNumR] = medfilt2edge(red,imgBWR,win2,th2);
            [meds2(:,:,g),edgeNumG] = medfilt2edge(green,imgBWG,win2,th2);
            [meds2(:,:,b),edgeNumB] = medfilt2edge(blue,imgBWB,win2,th2);
            meds2 = meds2(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b);
            
%             str = ['Retained ',num2str(edgeNumR),' red, ', ...
%             num2str(edgeNumG),' green and ',num2str(edgeNumB), ...
%             ' blue edges for 5x5 window'];
%             dstr = [datestr(now),': ',str];
%             disp(dstr)

            % get pixel neighborhoods for image pixels
            % extract median edge neighbor for each pixel in 7x7 window
            % then crop to 506 by 506
            [meds3(:,:,r),edgeNumR] = medfilt2edge(red,imgBWR,win3,th2);
            [meds3(:,:,g),edgeNumG] = medfilt2edge(green,imgBWG,win3,th2);
            [meds3(:,:,b),edgeNumB] = medfilt2edge(blue,imgBWB,win3,th2);
            meds3 = meds3(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b);
            
%             str = ['Retained ',num2str(edgeNumR),' red, ', ...
%             num2str(edgeNumG),' green and ',num2str(edgeNumB), ...
%             ' blue edges for 7x7 window'];
%             dstr = [datestr(now),': ',str];
%             disp(dstr)

            % get indices for edges in binary edge-detect image for each
            % color channel for 3x3 window image
            indR = iBWcR>0;
            medR = meds(:,:,r);
            medR = indR.*medR;
            indR = medR>0;

            indG = iBWcG>0;
            medG = meds(:,:,g);
            medG = indG.*medG;
            indG = medG>0;

            indB = iBWcB>0;
            medB = meds(:,:,b);
            medB = indB.*medB;
            indB = medB>0;

            % split pixel neighborhood medians by color channel for 3x3 
            % window image
            medR = meds(:,:,r); % red
            medG = meds(:,:,g); % green
            medB = meds(:,:,b); % blue

            % split edge-only image by color channel for 3x3 window image
            pixER = pixEdge(:,:,r); % red
            pixEG = pixEdge(:,:,g); % green
            pixEB = pixEdge(:,:,b); % blue

            % get error for image pixels
            % error is the absolute difference of medians from 3x3 window 
            % neighborhoods and image pixels
            % separate errors into each color channel
            redErr = abs(double(medR)-double(pixER));
            greenErr = abs(double(medG)-double(pixEG));
            blueErr = abs(double(medB)-double(pixEB));
            errors = {redErr(indR) greenErr(indG) blueErr(indB)};

            % get indices for edges in binary edge-detect image for each
            % color channel for 5x5 window image
            indR2 = iBWcR2>0;
            medR2 = meds2(:,:,r);
            medR2 = indR2.*medR2;
            indR2 = medR2>0;

            indG2 = iBWcG2>0;
            medG2 = meds2(:,:,g);
            medG2 = indG2.*medG2;
            indG2 = medG2>0;

            indB2 = iBWcB2>0;
            medB2 = meds2(:,:,b);
            medB2 = indB2.*medB2;
            indB2 = medB2>0;

            % split pixel neighborhood medians by color channel for 5x5 
            % window image
            medR2 = meds2(:,:,r); % red
            medG2 = meds2(:,:,g); % green
            medB2 = meds2(:,:,b); % blue

            % split edge-only image by color channel for 5x5 window image
            pixER2 = pixEdge2(:,:,r); % red
            pixEG2 = pixEdge2(:,:,g); % green
            pixEB2 = pixEdge2(:,:,b); % blue

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
            medR3 = meds3(:,:,r);
            medR3 = indR3.*medR3;
            indR3 = medR3>0;

            indG3 = iBWcG3>0;
            medG3 = meds3(:,:,g);
            medG3 = indG3.*medG3;
            indG3 = medG3>0;

            indB3 = iBWcB3>0;
            medB3 = meds3(:,:,b);
            medB3 = indB3.*medB3;
            indB3 = medB3>0;

            % split pixel neighborhood medians by color channel for 7x7 
            % window image
            medR3 = meds3(:,:,r); % red
            medG3 = meds3(:,:,g); % green
            medB3 = meds3(:,:,b); % blue

            % split edge-only image by color channel for 7x7 window image
            pixER3 = pixEdge3(:,:,r); % red
            pixEG3 = pixEdge3(:,:,g); % green
            pixEB3 = pixEdge3(:,:,b); % blue

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
            entropy(r) = -1*sum(rEn(~isnan(rEn(:))));

            % get entropy for green 3x3 window errors
            gEn = greenErr(indG).*log2(greenErr(indG));
            entropy(g) = -1*sum(gEn(~isnan(gEn(:))));

            % get entropy for blue 3x3 window errors
            bEn = blueErr(indB).*log2(blueErr(indB));
            entropy(b) = -1*sum(bEn(~isnan(bEn(:))));

            % get entropy for red 5x5 window errors
            rEn2 = redErr2(indR2).*log2(redErr2(indR2));
            entropy2(r) = -1*sum(rEn2(~isnan(rEn2(:))));

            % get entropy for green 5x5 window errors
            gEn2 = greenErr2(indG2).*log2(greenErr2(indG2));
            entropy2(g) = -1*sum(gEn2(~isnan(gEn2(:))));

            % get entropy for blue 5x5 window errors
            bEn2 = blueErr2(indB2).*log2(blueErr2(indB2));
            entropy2(b) = -1*sum(bEn2(~isnan(bEn2(:))));

            % get entropy for red 7x7 window errors
            rEn3 = redErr3(indR3).*log2(redErr3(indR3));
            entropy3(r) = -1*sum(rEn3(~isnan(rEn3(:))));

            % get entropy for green 7x7 window errors
            gEn3 = greenErr3(indG3).*log2(greenErr3(indG3));
            entropy3(g) = -1*sum(gEn3(~isnan(gEn3(:))));

            % get entropy for blue 7x7 window errors
            bEn3 = blueErr3(indB3).*log2(blueErr3(indB3));
            entropy3(b) = -1*sum(bEn3(~isnan(bEn3(:))));

            % Get energy for errors from 3x3 window and image pixels
            energy = [0,0,0];
            for i = 1:size(redErr,1)
                energy(r) = energy(r)+redErr(i)^2;
            end
            for i = 1:size(greenErr,1)
                energy(g) = energy(g)+greenErr(i)^2;
            end
            for i = 1:size(blueErr,1)
                energy(b) = energy(b)+blueErr(i)^2;
            end

            % Get energy for errors from 5x5 window and image pixels
            energy2 = [0,0,0];
            for i = 1:size(redErr2,1)
                energy2(r) = energy2(r)+redErr2(i)^2;
            end
            for i = 1:size(greenErr2,1)
                energy2(g) = energy2(g)+greenErr2(i)^2;
            end
            for i = 1:size(blueErr2,1)
                energy2(b) = energy2(b)+blueErr2(i)^2;
            end

            % Get energy for errors from 7x7 window and image pixels
            energy3 = [0,0,0];
            for i = 1:size(redErr3,1)
                energy3(r) = energy3(r)+redErr3(i)^2;
            end
            for i = 1:size(greenErr3,1)
                energy3(g) = energy3(g)+greenErr3(i)^2;
            end
            for i = 1:size(blueErr3,1)
                energy3(b) = energy3(b)+blueErr3(i)^2;
            end

            % Return image statistics as imgStats for 3x3 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat3 = imgStats(avg,sd,skew,kurt,entropy,energy,pixels,meds,errors);

            % Return image statistics as imgStats for 5x5 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat5 = imgStats(avg2,sd2,skew2,kurt2,entropy2,energy2,pixels2,meds2,errors2);

            % Return image statistics as imgStats for 7x7 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStat7 = imgStats(avg3,sd3,skew3,kurt3,entropy3,energy3,pixels3,meds3,errors3);
            
        end
        
        % Get image statistics for smooth areas
        % th1 = threshold for edge detection
        % iStatS3 = imgStats for 3x3 neighborhood smooth areas
        % iStatS5 = imgStats for 5x5 neighborhood smooth areas
        % iStatS7 = imgStats for 7x7 neighborhood smooth areas
        function [iStatS3,iStatS5,iStatS7] = imgStatsSmooth(obj,th1)
            
            % color channels
            r = 1;
            g = 2;
            b = 3;
            
            % window sizes
            win = 3;
            win2 = 5;
            win3 = 7;

            % image dimensions
            s = size(obj.image);
            dim = s(1)-2*floor(win/2);

            % row cropping dimensions
            rStart = floor(win/2)+1;
            rEnd = s(1)-floor(win/2);

            % column cropping dimensions
            cStart = floor(win/2)+1;
            cEnd = s(2)-floor(win/2);

            % Get RGB values for image pixels
            % for 3x3 neighborhoods use middle 510 by 510 pixels
            pixels = int16(obj.image(rStart:rEnd,cStart:cEnd,r:b));

            % Get RGB values for image pixels
            % for 5x5 neighborhoods use middle 508 by 508 pixels
            pixels2 = int16(obj.image(rStart+1:rEnd-1,cStart+1:cEnd-1,r:b));

            % Get RGB values for image pixels
            % for 7x7 neighborhoods use middle 506 by 506 pixels
            pixels3 = int16(obj.image(rStart+2:rEnd-2,cStart+2:cEnd-2,r:b));
            
            % DEBUGGING
            % disp('pixels(49:58,69:78,1)')
            % pixels(49:58,69:78,1)

            % convert image to grayscale
            % abstract color channels from image
            [red,green,blue] = obj.getColorCh();

            % find edges in grayscale image
            imgBWR = edge(red,'sobel',th1,'nothinning');
            imgBWG = edge(green,'sobel',th1,'nothinning');
            imgBWB = edge(blue,'sobel',th1,'nothinning');

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

            % crop binary images to 510 by 510 pixels for 3x3 windows
            iBWcRS = imgBWRS(rStart:rEnd,cStart:cEnd);
            iBWcGS = imgBWGS(rStart:rEnd,cStart:cEnd);
            iBWcBS = imgBWBS(rStart:rEnd,cStart:cEnd);

            % crop binary images to 508 by 508 pixels for 5x5 windows
            iBWcRS2 = imgBWRS(rStart+1:rEnd-1,cStart+1:cEnd-1);
            iBWcGS2 = imgBWGS(rStart+1:rEnd-1,cStart+1:cEnd-1);
            iBWcBS2 = imgBWBS(rStart+1:rEnd-1,cStart+1:cEnd-1);

            % crop binary images to 506 by 506 pixels for 7x7 windows
            iBWcRS3 = imgBWRS(rStart+2:rEnd-2,cStart+2:cEnd-2);
            iBWcGS3 = imgBWGS(rStart+2:rEnd-2,cStart+2:cEnd-2);
            iBWcBS3 = imgBWBS(rStart+2:rEnd-2,cStart+2:cEnd-2);

            % expand binary images to 3 channels for 3x3 windows
            imgBWScrop = cat(3,iBWcRS,iBWcGS,iBWcBS);

            % expand binary images to 3 channels for 5x5 windows
            imgBWScrop2 = cat(3,iBWcRS2,iBWcGS2,iBWcBS2);

            % expand binary images to 3 channels for 7x7 windows
            imgBWScrop3 = cat(3,iBWcRS3,iBWcGS3,iBWcBS3);

            % extract only smooth areas from image for 3x3 windows
            pixSmooth = int16(imgBWScrop).*int16(pixels);

            % extract only smooth areas from image for 5x5 windows
            pixSmooth2 = int16(imgBWScrop2).*int16(pixels2);

            % extract only smooth areas from image for 7x7 windows
            pixSmooth3 = int16(imgBWScrop3).*int16(pixels3);

            % get pixel neighborhoods for image pixels
            % extract median smooth area neighbor for each pixel in 3x3 window
            % then crop to 510 by 510
            medSmooth(:,:,r) = imgBWRS.*medfilt2new(red,win);
            medSmooth(:,:,g) = imgBWGS.*medfilt2new(green,win);
            medSmooth(:,:,b) = imgBWBS.*medfilt2new(blue,win);
            medSmooth = medSmooth(rStart:rEnd,cStart:cEnd,:);

            % get pixel neighborhoods for image pixels
            % extract median smooth area neighbor for each pixel in 5x5 window
            % then crop to 508 by 508
            medSmooth2(:,:,r) = imgBWRS.*medfilt2new(red,win2);
            medSmooth2(:,:,g) = imgBWGS.*medfilt2new(green,win2);
            medSmooth2(:,:,b) = imgBWBS.*medfilt2new(blue,win2);
            medSmooth2 = medSmooth2(rStart+1:rEnd-1,cStart+1:cEnd-1,:);

            % get pixel neighborhoods for image pixels
            % extract median smooth area neighbor for each pixel in 7x7 window
            % then crop to 506 by 506
            medSmooth3(:,:,r) = imgBWRS.*medfilt2new(red,win3);
            medSmooth3(:,:,g) = imgBWGS.*medfilt2new(green,win3);
            medSmooth3(:,:,b) = imgBWBS.*medfilt2new(blue,win3);
            medSmooth3 = medSmooth3(rStart+2:rEnd-2,cStart+2:cEnd-2,:);

            % get indices for smooth areas in binary edge-detect image for each
            % color channel for 3x3 window image
            indRS = iBWcRS>0;
            medRS = medSmooth(:,:,r);
            medRS = indRS.*medRS;
            indRS = medRS>0;

            indGS = iBWcGS>0;
            medGS = medSmooth(:,:,g);
            medGS = indGS.*medGS;
            indGS = medGS>0;

            indBS = iBWcBS>0;
            medBS = medSmooth(:,:,b);
            medBS = indBS.*medBS;
            indBS = medBS>0;

            % split pixel neighborhood medians by color channel for 3x3 
            % window image
            medRS = medSmooth(:,:,r); % red
            medGS = medSmooth(:,:,g); % green
            medBS = medSmooth(:,:,b); % blue

            % DEBUGGING
            % disp('medRS(49:58,69:78)');
            % medRS(49:58,69:78)

            % split smooth-only image by color channel for 3x3 window image
            pixSR = pixSmooth(:,:,r); % red
            pixSG = pixSmooth(:,:,g); % green
            pixSB = pixSmooth(:,:,b); % blue

            % DEBUGGING
            % disp('pixSR(49:58,69:78)');
            % pixSR(49:58,69:78)

            % get error for image pixels
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

            % get indices for smooth areas in binary edge-detect image for each
            % color channel for 5x5 window image
            indRS2 = iBWcRS2>0;
            medRS2 = medSmooth2(:,:,r);
            medRS2 = indRS2.*medRS2;
            indRS2 = medRS2>0;

            indGS2 = iBWcGS2>0;
            medGS2 = medSmooth2(:,:,g);
            medGS2 = indGS2.*medGS2;
            indGS2 = medGS2>0;

            indBS2 = iBWcBS2>0;
            medBS2 = medSmooth2(:,:,b);
            medBS2 = indBS2.*medBS2;
            indBS2 = medBS2>0;

            % split pixel neighborhood medians by color channel for 5x5 
            % window image
            medRS2 = medSmooth2(:,:,r); % red
            medGS2 = medSmooth2(:,:,g); % green
            medBS2 = medSmooth2(:,:,b); % blue

            % DEBUGGING
            % disp('medRS2');
            % medRS2(49:58,69:78)

            % split smooth-only image by color channel for 5x5 window image
            pixSR2 = pixSmooth2(:,:,r); % red
            pixSG2 = pixSmooth2(:,:,g); % green
            pixSB2 = pixSmooth2(:,:,b); % blue

            % DEBUGGING
            % disp('pixSR2');
            % pixSR2(49:58,69:78)

            % get error for image pixels
            % error is the absolute difference of medians from 5x5 window 
            % neighborhoods and image pixels
            % separate errors into each color channel
            redErrS2 = abs(double(medRS2)-double(pixSR2));
            greenErrS2 = abs(double(medGS2)-double(pixSG2));
            blueErrS2 = abs(double(medBS2)-double(pixSB2));
            errorsS2 = {redErrS2(indRS2) greenErrS2(indGS2) blueErrS2(indBS2)};

            % get indices for smooth areas in binary edge-detect image for each
            % color channel for 7x7 window image
            indRS3 = iBWcRS3>0;
            medRS3 = medSmooth3(:,:,r);
            medRS3 = indRS3.*medRS3;
            indRS3 = medRS3>0;

            indGS3 = iBWcGS3>0;
            medGS3 = medSmooth3(:,:,g);
            medGS3 = indGS3.*medGS3;
            indGS3 = medGS3>0;

            indBS3 = iBWcBS3>0;
            medBS3 = medSmooth3(:,:,b);
            medBS3 = indBS3.*medBS3;
            indBS3 = medBS3>0;

            % split pixel neighborhood medians by color channel for 7x7 
            % window image
            medRS3 = medSmooth3(:,:,r); % red
            medGS3 = medSmooth3(:,:,g); % green
            medBS3 = medSmooth3(:,:,b); % blue

            % split smooth-only image by color channel for 7x7 window image
            pixSR3 = pixSmooth3(:,:,r); % red
            pixSG3 = pixSmooth3(:,:,g); % green
            pixSB3 = pixSmooth3(:,:,b); % blue

            % get error for image pixels
            % error is the absolute difference of medians from 7x7 window 
            % neighborhoods and image pixels
            % separate errors into each color channel
            redErrS3 = abs(double(medRS3)-double(pixSR3));
            greenErrS3 = abs(double(medGS3)-double(pixSG3));
            blueErrS3 = abs(double(medBS3)-double(pixSB3));
            errorsS3 = {redErrS3(indRS3) greenErrS3(indGS3) blueErrS3(indBS3)};

            % Get mean, sd, skew and kurtosis for errors
            % for errors from 3x3 window neighborhoods and image pixels
            avgS = [mean(redErrS(indRS)), mean(greenErrS(indGS)), mean(blueErrS(indBS))];
            sdS = [std(redErrS(indRS),1), std(greenErrS(indGS),1), std(blueErrS(indBS),1)];
            skewS = [skewness(redErrS(indRS)), skewness(greenErrS(indGS)), skewness(blueErrS(indBS))];
            kurtS = [kurtosis(redErrS(indRS)), kurtosis(greenErrS(indGS)), kurtosis(blueErrS(indBS))];

            % Get mean, sd, skew and kurtosis for errors
            % for errors from 5x5 window neighborhoods and image pixels
            avgS2 = [mean(redErrS2(indRS2)), mean(greenErrS2(indGS2)), mean(blueErrS2(indBS2))];
            sdS2 = [std(redErrS2(indRS2),1), std(greenErrS2(indGS2),1), std(blueErrS2(indBS2),1)];
            skewS2 = [skewness(redErrS2(indRS2)), skewness(greenErrS2(indGS2)), skewness(blueErrS2(indBS2))];
            kurtS2 = [kurtosis(redErrS2(indRS2)), kurtosis(greenErrS2(indGS2)), kurtosis(blueErrS2(indBS2))];

            % Get mean, sd, skew and kurtosis for errors
            % for errors from 7x7 window neighborhoods and image pixels
            avgS3 = [mean(redErrS3(indRS3)), mean(greenErrS3(indGS3)), mean(blueErrS3(indBS3))];
            sdS3 = [std(redErrS3(indRS3),1), std(greenErrS3(indGS3),1), std(blueErrS3(indBS3),1)];
            skewS3 = [skewness(redErrS3(indRS3)), skewness(greenErrS3(indGS3)), skewness(blueErrS3(indBS3))];
            kurtS3 = [kurtosis(redErrS3(indRS3)), kurtosis(greenErrS3(indGS3)), kurtosis(blueErrS3(indBS3))];

            % initialize entropy arrays
            entropyS = [0 0 0];
            entropyS2 = [0 0 0];
            entropyS3 = [0 0 0];

            % get entropy for red 3x3 window errors
            rEnS = redErrS(indRS).*log2(redErrS(indRS));
            entropyS(r) = -1*sum(rEnS(~isnan(rEnS(:))));

            % get entropy for green 3x3 window errors
            gEnS = greenErrS(indGS).*log2(greenErrS(indGS));
            entropyS(g) = -1*sum(gEnS(~isnan(gEnS(:))));

            % get entropy for blue 3x3 window errors
            bEnS = blueErrS(indBS).*log2(blueErrS(indBS));
            entropyS(b) = -1*sum(bEnS(~isnan(bEnS(:))));

            % get entropy for red 5x5 window errors
            rEnS2 = redErrS2(indRS2).*log2(redErrS2(indRS2));
            entropyS2(r) = -1*sum(rEnS2(~isnan(rEnS2(:))));

            % get entropy for green 5x5 window errors
            gEnS2 = greenErrS2(indGS2).*log2(greenErrS2(indGS2));
            entropyS2(g) = -1*sum(gEnS2(~isnan(gEnS2(:))));

            % get entropy for blue 5x5 window errors
            bEnS2 = blueErrS2(indBS2).*log2(blueErrS2(indBS2));
            entropyS2(b) = -1*sum(bEnS2(~isnan(bEnS2(:))));

            % get entropy for red 7x7 window errors
            rEnS3 = redErrS3(indRS3).*log2(redErrS3(indRS3));
            entropyS3(r) = -1*sum(rEnS3(~isnan(rEnS3(:))));

            % get entropy for green 7x7 window errors
            gEnS3 = greenErrS3(indGS3).*log2(greenErrS3(indGS3));
            entropyS3(g) = -1*sum(gEnS3(~isnan(gEnS3(:))));

            % get entropy for blue 7x7 window errors
            bEnS3 = blueErrS3(indBS3).*log2(blueErrS3(indBS3));
            entropyS3(b) = -1*sum(bEnS3(~isnan(bEnS3(:))));

            % Get energy for errors from 3x3 window and image pixels
            energyS = [0,0,0];
            for i = 1:size(redErrS,1)
                energyS(r) = energyS(r)+redErrS(i)^2;
            end
            for i = 1:size(greenErrS,1)
                energyS(g) = energyS(g)+greenErrS(i)^2;
            end
            for i = 1:size(blueErrS,1)
                energyS(b) = energyS(b)+blueErrS(i)^2;
            end

            % Get energy for errors from 5x5 window and image pixels
            energyS2 = [0,0,0];
            for i = 1:size(redErrS2,1)
                energyS2(r) = energyS2(r)+redErrS2(i)^2;
            end
            for i = 1:size(greenErrS2,1)
                energyS2(g) = energyS2(g)+greenErrS2(i)^2;
            end
            for i = 1:size(blueErrS2,1)
                energyS2(b) = energyS2(b)+blueErrS2(i)^2;
            end

            % Get energy for errors from 7x7 window and image pixels
            energyS3 = [0,0,0];
            for i = 1:size(redErrS3,1)
                energyS3(r) = energyS3(r)+redErrS3(i)^2;
            end
            for i = 1:size(greenErrS3,1)
                energyS3(g) = energyS3(g)+greenErrS3(i)^2;
            end
            for i = 1:size(blueErrS3,1)
                energyS3(b) = energyS3(b)+blueErrS3(i)^2;
            end

            % Return image statistics as imgStats for 3x3 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStatS3 = imgStats(avgS,sdS,skewS,kurtS,entropyS,energyS,pixels,medSmooth,errorsS);

            % Return image statistics as imgStats for 5x5 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStatS5 = imgStats(avgS2,sdS2,skewS2,kurtS2,entropyS2,energyS2,pixels2,medSmooth2,errorsS2);

            % Return image statistics as imgStats for 7x7 window
            % stats contain data for all 3 color channels as 3x1 vectors
            iStatS7 = imgStats(avgS3,sdS3,skewS3,kurtS3,entropyS3,energyS3,pixels3,medSmooth3,errorsS3);
            
        end
        
        % Get Bayer images
        function [bayerR,bayerG1,bayerG2,bayerB] = getBayer(obj)
            
            % R G
            % G B
            getRG = @(x) ...
                [x.data(1,1,1) x.data(1,2,2); ...
                 x.data(2,1,2) x.data(2,2,3)];
            bayerR = blockproc(obj.image,[2 2],getRG);
            obj.bayerR = bayerR;
            
            % G R
            % B G
            getGR = @(x) ...
                [x.data(1,1,2) x.data(1,2,1); ...
                 x.data(2,1,3) x.data(2,2,2)];
            bayerG1 = blockproc(obj.image,[2 2],getGR);
            obj.bayerG1 = bayerG1;
            
            % G B
            % R G
            getGB = @(x) ...
                [x.data(1,1,2) x.data(1,2,3); ...
                 x.data(2,1,1) x.data(2,2,2)];
            bayerG2 = blockproc(obj.image,[2 2],getGB);
            obj.bayerG2 = bayerG2;
            
            % B G
            % G R
            getBG = @(x) ...
                [x.data(1,1,3) x.data(1,2,2); ...
                 x.data(2,1,2) x.data(2,2,1)];
            bayerB = blockproc(obj.image,[2 2],getBG);
            obj.bayerB = bayerB;
            
        end
        
        % Get Edge images
        % assumes bayer images have already been made
        % bNum = Bayer Number
        % bayerRG: bNum = 1
        % bayerGR: bNum = 2
        % bayerGB: bNum = 3
        % bayerBG: bNum = 4
        % imgEdge = edge pattern images
        function imgEdge = getImgEdge(obj,bNum)
            
            % R G
            % G B
            if (bNum == 1)
                bayer = obj.bayerR;

            % G R
            % B G
            elseif (bNum == 2)
                bayer = obj.bayerG1;

            % G B
            % R G
            elseif (bNum == 3)
                bayer = obj.bayerG2;

            % B G
            % G R
            elseif (bNum == 4)
                bayer = obj.bayerB;
            end

            % Get 5x5 horizontal edges for Bayer CFA pattern image
            hDiff = @(x) abs(double(x(3,:))-double(x(23,:)));
            imgHD = colfilt(bayer,[5 5],'sliding',hDiff);

            % Get 5x5 vertical edges for Bayer CFA pattern image
            vDiff = @(x) abs(double(x(11,:))-double(x(15,:)));
            imgVD = colfilt(bayer,[5 5],'sliding',vDiff);

            % Get 5x5 forward diagonal edges for Bayer CFA pattern image
            D1diff = @(x) abs(double(x(7,:))-double(x(19,:)));
            imgD1 = colfilt(bayer,[5 5],'sliding',D1diff);

            % Get 5x5 backward diagonal edges for Bayer CFA pattern image
            D2diff = @(x) abs(double(x(9,:))-double(x(17,:)));
            imgD2 = colfilt(bayer,[5 5],'sliding',D2diff);

            % Get 5x5 hDiff patterns for Bayer CFA pattern image
            HDpat = @(x) mean(double(x([12 14],:)));
            imgHDpat = colfilt(bayer,[5 5],'sliding',HDpat);

            % Get 5x5 vDiff patterns for Bayer CFA pattern image
            VDpat = @(x) mean(double(x([8 18],:)));
            imgVDpat = colfilt(bayer,[5 5],'sliding',VDpat);

            % Get 5x5 diag1 diff patterns for Bayer CFA pattern image
            D1Dpat = @(x) mean(double(x([9 17],:)));
            imgD1pat = colfilt(bayer,[5 5],'sliding',D1Dpat);

            % Get 5x5 diag2 diff patterns for Bayer CFA pattern image
            D2Dpat = @(x) mean(double(x([7 19],:)));
            imgD2pat = colfilt(bayer,[5 5],'sliding',D2Dpat);

            % Get Edge Color Objects for further investigation
            imgEdge = imgEdges(imgHD,imgVD,imgD1,imgD2,imgHDpat,imgVDpat,imgD1pat,imgD2pat);

        end
        
        % Get bayer color patterns
        % assumes bayer images have already been made
        % creates 4 images in which each pixel is the mean of an
        % appropriate neighborhood
        % bNum = Bayer Number
        % bayerRG: bNum = 1
        % bayerGR: bNum = 2
        % bayerGB: bNum = 3
        % bayerBG: bNum = 4
        % imgVB = 5x5 vBand patterns for Bayer CFA pattern images
        % imgHB = 5x5 hBand patterns for Bayer CFA pattern images
        % imgD1 = 5x5 Diag1 patterns for Bayer CFA pattern images
        % imgD2 = 5x5 Diag2 patterns for Bayer CFA pattern images
        function [imgVB,imgHB,imgD1,imgD2] = getColorPats(obj,bNum)
            
            % R G
            % G B
            if (bNum == 1)
                bayer = obj.bayerR;
                
            % G R
            % B G
            elseif (bNum == 2)
                bayer = obj.bayerG1;
                
            % G B
            % R G
            elseif (bNum == 3)
                bayer = obj.bayerG2;
                
            % B G
            % G R
            elseif (bNum == 4)
                bayer = obj.bayerB;
            end
            
            % Get 5x5 vBand patterns for Bayer CFA pattern images
            Vband = @(x) mean(double(x([6 8 10 16 18 20],:)));
            imgVB = colfilt(bayer,[5 5],'sliding',Vband);
            % 1/4 red, 1/4 blue, 1/2 ignore
            
            % Get 5x5 hBand patterns for Bayer CFA pattern images
            Hband = @(x) mean(double(x([2 4 12 14 22 24],:)));
            imgHB = colfilt(bayer,[5 5],'sliding',Hband);
            % 1/4 red, 1/4 blue, 1/2 ignore
            
            % Get 5x5 Diag1 patterns for Bayer CFA pattern images
            Diag1 = @(x) mean(double(x([2 4 6 8 10 12 14 16 18 20 22 24] ...
                ,:)));
            imgD1 = colfilt(bayer,[5 5],'sliding',Diag1);
            % 1/2 green, 1/2 ignore
            
            % Get 5x5 Diag2 patterns for Bayer CFA pattern images
            Diag2 = @(x) mean(double(x([7 9 17 19],:)));
            imgD2 = colfilt(bayer,[5 5],'sliding',Diag2);
            % 1/4 red, 1/4 blue, 1/2 ignore
            
        end
        
        % Demosaic bayer red pattern image
        % must be used with block process
        % x = anonymous function variable
        % imgVB = 5x5 vBand patterns for Bayer R CFA pattern images
        % imgHB = 5x5 hBand patterns for Bayer R CFA pattern images
        % imgD1 = 5x5 Diag1 patterns for Bayer R CFA pattern images
        % imgD2 = 5x5 Diag2 patterns for Bayer R CFA pattern images
        % imgDemo = smooth JPEG converted from bayer red pattern image
        function imgDemo = demoBayerR(obj,x,imgVB,imgHB,imgD1,imgD2)
            
            % R G
            % G B
            
            % get current block process location
            sr = x.location(1);
            sc = x.location(2);
            
            % create 2x2x3 color pixel block at current location
            % assume current block of image is smooth
            imgDemo = cat(3, ...
                [x.data(1,1) imgVB(sr,sc+1); ...
                 imgHB(sr+1,sc) imgD2(sr+1,sc+1)], ...
                 ...
                [imgD1(sr,sc) x.data(1,2); ...
                 x.data(2,1) imgD1(sr+1,sc+1)], ...
                 ...
                [imgD2(sr,sc) imgHB(sr,sc+1); ...
                 imgVB(sr+1,sc) x.data(2,2)]);
            
        end
        
        % Demosaic bayer green 1 pattern image
        % must be used with block process
        % x = anonymous function variable
        % imgVB = 5x5 vBand patterns for Bayer G1 CFA pattern images
        % imgHB = 5x5 hBand patterns for Bayer G1 CFA pattern images
        % imgD1 = 5x5 Diag1 patterns for Bayer G1 CFA pattern images
        % imgD2 = 5x5 Diag2 patterns for Bayer G1 CFA pattern images
        % imgDemo = smooth JPEG converted from bayer green 1 pattern image
        function imgDemo = demoBayerG1(obj,x,imgVB,imgHB,imgD1,imgD2)
            
            % G R
            % B G
            
            % get current block process location
            sr = x.location(1);
            sc = x.location(2);
            
            % create 2x2x3 color pixel block at current location
            % assume current block of image is smooth
            imgDemo = cat(3, ...
                [imgVB(sr,sc) x.data(1,2); ...
                 imgD2(sr+1,sc) imgHB(sr+1,sc+1)], ...
                 ...
                [x.data(1,1) imgD1(sr,sc+1); ...
                 imgD1(sr+1,sc) x.data(2,2)], ...
                 ...
                [imgHB(sr,sc) imgD2(sr,sc+1); ...
                 x.data(2,1) imgVB(sr+1,sc+1)]);
            
        end
        
        % Demosaic bayer green 2 pattern image
        % must be used with block process
        % x = anonymous function variable
        % imgVB = 5x5 vBand patterns for Bayer G2 CFA pattern images
        % imgHB = 5x5 hBand patterns for Bayer G2 CFA pattern images
        % imgD1 = 5x5 Diag1 patterns for Bayer G2 CFA pattern images
        % imgD2 = 5x5 Diag2 patterns for Bayer G2 CFA pattern images
        % imgDemo = smooth JPEG converted from bayer green 2 pattern image
        function imgDemo = demoBayerG2(obj,x,imgVB,imgHB,imgD1,imgD2)
            
            % G B
            % R G
            
            % get current block process location
            sr = x.location(1);
            sc = x.location(2);
            
            % create 2x2x3 color pixel block at current location
            % assume current block of image is smooth
            imgDemo = cat(3, ...
                [imgHB(sr,sc) imgD2(sr,sc+1); ...
                 x.data(2,1) imgVB(sr+1,sc+1)], ...
                 ...
                [x.data(1,1) imgD1(sr,sc+1); ...
                 imgD1(sr+1,sc) x.data(2,2)], ...
                 ...
                [imgVB(sr,sc) x.data(1,2); ...
                 imgD2(sr+1,sc) imgHB(sr+1,sc+1)]);
            
        end
        
        % Demosaic bayer blue pattern image
        % must be used with block process
        % x = anonymous function variable
        % imgVB = 5x5 vBand patterns for Bayer B CFA pattern images
        % imgHB = 5x5 hBand patterns for Bayer B CFA pattern images
        % imgD1 = 5x5 Diag1 patterns for Bayer B CFA pattern images
        % imgD2 = 5x5 Diag2 patterns for Bayer B CFA pattern images
        % imgDemo = smooth JPEG converted from bayer blue pattern image
        function imgDemo = demoBayerB(obj,x,imgVB,imgHB,imgD1,imgD2)
            
            % B G
            % G R
            
            % get current block process location
            sr = x.location(1);
            sc = x.location(2);
            
            % create 2x2x3 color pixel block at current location
            % assume current block of image is smooth
            imgDemo = cat(3, ...
                [imgD2(sr,sc) imgHB(sr,sc+1); ...
                 imgVB(sr+1,sc) x.data(2,2)], ...
                 ...
                [imgD1(sr,sc) x.data(1,2); ...
                 x.data(2,1) imgD1(sr+1,sc+1)], ...
                 ...
                [x.data(1,1) imgVB(sr,sc+1); ...
                 imgHB(sr+1,sc) imgD2(sr+1,sc+1)]);
            
        end
        
        % Get chirality images for bayer pattern image
        % bNum = Bayer Number
        % bayerRG: bNum = 1
        % bayerGR: bNum = 2
        % bayerGB: bNum = 3
        % bayerBG: bNum = 4
        % iEdge = imgEdges for image with edge types
        % iTh = image with edge types
        % imgChr = image of edge chiralities
        function imgChr = getImgChr(obj,bNum,iEdge,iTh)
            
            % R G
            % G B
            if (bNum == 1)
                bayer = obj.bayerR;
                
            % G R
            % B G
            elseif (bNum == 2)
                bayer = obj.bayerG1;
                
            % G B
            % R G
            elseif (bNum == 3)
                bayer = obj.bayerG2;
                
            % B G
            % G R
            elseif (bNum == 4)
                bayer = obj.bayerB;
            end
            
            % get chiralities of edge types in image
            iHDC = iEdge.getChiral(bayer,iTh,1,7,3,5);
            iVDC = iEdge.getChiral(bayer,iTh,2,1,5,5);
            iD1C = iEdge.getChiral(bayer,iTh,4,6,2,5);
            iD2C = iEdge.getChiral(bayer,iTh,8,8,4,5);
            
            % combine chirality images
            imgChr = iHDC+iVDC+iD1C+iD2C;
            
        end
        
        % Convert edges in bayer image to JPEG
        % bNum = Bayer Number
        % bayerRG: bNum = 1
        % bayerGR: bNum = 2
        % bayerGB: bNum = 3
        % bayerBG: bNum = 4
        % img = 3 color channel image
        % imgChr = image with edge type chiralities
        % iCV = imgChiral for vert edge chiral patterns
        % iCH = imgChiral for horiz edge chiral patterns
        % iCD1 = imgChiral for Diag1 edge chiral patterns
        % iCD2 = imgChiral for Diag2 edge chiral patterns
        % imgJPEG = JPEG image adjusted for edges
        function imgJPEG = chr2jpg(obj,bNum,img,imgChr,iCV,iCH,iCD1,iCD2)
            
            % initialize variables
            [l,w,h] = size(img);
            imgJPEG = img;
            
            % get bayer sensor color at a pixel
            function color = getColor(bNum,row,col)
                if (bNum == 1)
                    % R = row odd, col odd
                    if ((mod(row,2) == 1) && (mod(col,2) == 1))
                        color = 'R';
                    % G1 = row odd, col even
                    elseif ((mod(row,2) == 1) && (mod(col,2) == 0))
                        color = 'G1';
                    % G2 = row even, col odd
                    elseif ((mod(row,2) == 0) && (mod(col,2) == 1))
                        color = 'G2';
                    % B = row even, col even
                    else
                        color = 'B';
                    end
                elseif (bNum == 2)
                    % G1 = row odd, col odd
                    if ((mod(row,2) == 1) && (mod(col,2) == 1))
                        color = 'G1';
                    % R = row odd, col even
                    elseif ((mod(row,2) == 1) && (mod(col,2) == 0))
                        color = 'R';
                    % B = row even, col odd
                    elseif ((mod(row,2) == 0) && (mod(col,2) == 1))
                        color = 'B';
                    % G2 = row even, col even
                    else
                        color = 'G2';
                    end
                elseif (bNum == 3)
                    % G2 = row odd, col odd
                    if ((mod(row,2) == 1) && (mod(col,2) == 1))
                        color = 'G2';
                    % B = row odd, col even
                    elseif ((mod(row,2) == 1) && (mod(col,2) == 0))
                        color = 'B';
                    % R = row even, col odd
                    elseif ((mod(row,2) == 0) && (mod(col,2) == 1))
                        color = 'R';
                    % G1 = row even, col even
                    else
                        color = 'G1';
                    end
                else
                    % B = row odd, col odd
                    if ((mod(row,2) == 1) && (mod(col,2) == 1))
                        color = 'B';
                    % G2 = row odd, col even
                    elseif ((mod(row,2) == 1) && (mod(col,2) == 0))
                        color = 'G2';
                    % G1 = row even, col odd
                    elseif ((mod(row,2) == 0) && (mod(col,2) == 1))
                        color = 'G1';
                    % R = row even, col even
                    else
                        color = 'R';
                    end
                end
            end
            
            % adjust image for horizontal edges with negative chirality
            index = find(imgChr==-1);
            for i = 1:length(index)
                ind = index(i);
                [r,c] = ind2sub([l,w],ind);
                clr = getColor(bNum,r,c);
                if (clr == 'R')
                    imgJPEG(r,c,2) = iCH.imgD1neg(ind);
                    imgJPEG(r,c,3) = iCH.imgD2neg(ind);
                elseif (clr == 'G1')
                    imgJPEG(r,c,1) = iCH.imgVBneg(ind);
                    imgJPEG(r,c,3) = iCH.imgHBneg(ind);
                elseif (clr == 'G2')
                    imgJPEG(r,c,1) = iCH.imgHBneg(ind);
                    imgJPEG(r,c,3) = iCH.imgVBneg(ind);
                else
                    imgJPEG(r,c,1) = iCH.imgD2neg(ind);
                    imgJPEG(r,c,2) = iCH.imgD1neg(ind);
                end
            end
            
            % adjust image for horizontal edges with positive chirality
            index = find(imgChr==1);
            for i = 1:length(index)
                ind = index(i);
                [r,c] = ind2sub([l,w],ind);
                clr = getColor(bNum,r,c);
                if (clr == 'R')
                    imgJPEG(r,c,2) = iCH.imgD1pos(ind);
                    imgJPEG(r,c,3) = iCH.imgD2pos(ind);
                elseif (clr == 'G1')
                    imgJPEG(r,c,1) = iCH.imgVBpos(ind);
                    imgJPEG(r,c,3) = iCH.imgHBpos(ind);
                elseif (clr == 'G2')
                    imgJPEG(r,c,1) = iCH.imgHBpos(ind);
                    imgJPEG(r,c,3) = iCH.imgVBpos(ind);
                else
                    imgJPEG(r,c,1) = iCH.imgD2pos(ind);
                    imgJPEG(r,c,2) = iCH.imgD1pos(ind);
                end
            end
            
            % adjust image for vertical edges with negative chirality
            index = find(imgChr==-2);
            for i = 1:length(index)
                ind = index(i);
                [r,c] = ind2sub([l,w],ind);
                clr = getColor(bNum,r,c);
                if (clr == 'R')
                    imgJPEG(r,c,2) = iCV.imgD1neg(ind);
                    imgJPEG(r,c,3) = iCV.imgD2neg(ind);
                elseif (clr == 'G1')
                    imgJPEG(r,c,1) = iCV.imgVBneg(ind);
                    imgJPEG(r,c,3) = iCV.imgHBneg(ind);
                elseif (clr == 'G2')
                    imgJPEG(r,c,1) = iCV.imgHBneg(ind);
                    imgJPEG(r,c,3) = iCV.imgVBneg(ind);
                else
                    imgJPEG(r,c,1) = iCV.imgD2neg(ind);
                    imgJPEG(r,c,2) = iCV.imgD1neg(ind);
                end
            end
            
            % adjust image for vertical edges with positive chirality
            index = find(imgChr==2);
            for i = 1:length(index)
                ind = index(i);
                [r,c] = ind2sub([l,w],ind);
                clr = getColor(bNum,r,c);
                if (clr == 'R')
                    imgJPEG(r,c,2) = iCV.imgD1pos(ind);
                    imgJPEG(r,c,3) = iCV.imgD2pos(ind);
                elseif (clr == 'G1')
                    imgJPEG(r,c,1) = iCV.imgVBpos(ind);
                    imgJPEG(r,c,3) = iCV.imgHBpos(ind);
                elseif (clr == 'G2')
                    imgJPEG(r,c,1) = iCV.imgHBpos(ind);
                    imgJPEG(r,c,3) = iCV.imgVBpos(ind);
                else
                    imgJPEG(r,c,1) = iCV.imgD2pos(ind);
                    imgJPEG(r,c,2) = iCV.imgD1pos(ind);
                end
            end
            
            % adjust image for diag1 edges with negative chirality
            index = find(imgChr==-4);
            for i = 1:length(index)
                ind = index(i);
                [r,c] = ind2sub([l,w],ind);
                clr = getColor(bNum,r,c);
                if (clr == 'R')
                    imgJPEG(r,c,2) = iCD1.imgD1neg(ind);
                    imgJPEG(r,c,3) = iCD1.imgD2neg(ind);
                elseif (clr == 'G1')
                    imgJPEG(r,c,1) = iCD1.imgVBneg(ind);
                    imgJPEG(r,c,3) = iCD1.imgHBneg(ind);
                elseif (clr == 'G2')
                    imgJPEG(r,c,1) = iCD1.imgHBneg(ind);
                    imgJPEG(r,c,3) = iCD1.imgVBneg(ind);
                else
                    imgJPEG(r,c,1) = iCD1.imgD2neg(ind);
                    imgJPEG(r,c,2) = iCD1.imgD1neg(ind);
                end
            end
            
            % adjust image for diag1 edges with positive chirality
            index = find(imgChr==4);
            for i = 1:length(index)
                ind = index(i);
                [r,c] = ind2sub([l,w],ind);
                clr = getColor(bNum,r,c);
                if (clr == 'R')
                    imgJPEG(r,c,2) = iCD1.imgD1pos(ind);
                    imgJPEG(r,c,3) = iCD1.imgD2pos(ind);
                elseif (clr == 'G1')
                    imgJPEG(r,c,1) = iCD1.imgVBpos(ind);
                    imgJPEG(r,c,3) = iCD1.imgHBpos(ind);
                elseif (clr == 'G2')
                    imgJPEG(r,c,1) = iCD1.imgHBpos(ind);
                    imgJPEG(r,c,3) = iCD1.imgVBpos(ind);
                else
                    imgJPEG(r,c,1) = iCD1.imgD2pos(ind);
                    imgJPEG(r,c,2) = iCD1.imgD1pos(ind);
                end
            end
            
            % adjust image for diag2 edges with negative chirality
            index = find(imgChr==-8);
            for i = 1:length(index)
                ind = index(i);
                [r,c] = ind2sub([l,w],ind);
                clr = getColor(bNum,r,c);
                if (clr == 'R')
                    imgJPEG(r,c,2) = iCD2.imgD1neg(ind);
                    imgJPEG(r,c,3) = iCD2.imgD2neg(ind);
                elseif (clr == 'G1')
                    imgJPEG(r,c,1) = iCD2.imgVBneg(ind);
                    imgJPEG(r,c,3) = iCD2.imgHBneg(ind);
                elseif (clr == 'G2')
                    imgJPEG(r,c,1) = iCD2.imgHBneg(ind);
                    imgJPEG(r,c,3) = iCD2.imgVBneg(ind);
                else
                    imgJPEG(r,c,1) = iCD2.imgD2neg(ind);
                    imgJPEG(r,c,2) = iCD2.imgD1neg(ind);
                end
            end
            
            % adjust image for diag2 edges with positive chirality
            index = find(imgChr==8);
            for i = 1:length(index)
                ind = index(i);
                [r,c] = ind2sub([l,w],ind);
                clr = getColor(bNum,r,c);
                if (clr == 'R')
                    imgJPEG(r,c,2) = iCD2.imgD1pos(ind);
                    imgJPEG(r,c,3) = iCD2.imgD2pos(ind);
                elseif (clr == 'G1')
                    imgJPEG(r,c,1) = iCD2.imgVBpos(ind);
                    imgJPEG(r,c,3) = iCD2.imgHBpos(ind);
                elseif (clr == 'G2')
                    imgJPEG(r,c,1) = iCD2.imgHBpos(ind);
                    imgJPEG(r,c,3) = iCD2.imgVBpos(ind);
                else
                    imgJPEG(r,c,1) = iCD2.imgD2pos(ind);
                    imgJPEG(r,c,2) = iCD2.imgD1pos(ind);
                end
            end
            
        end
        
        % Get chiral patterns from a bayer image
        % assumes bayer images have already been made
        % creates 4 images in which each pixel is the mean of an
        % appropriate neighborhood
        % bNum = Bayer Number
        % bayerRG: bNum = 1
        % bayerGR: bNum = 2
        % bayerGB: bNum = 3
        % bayerBG: bNum = 4
        % iCV = imgChiral for vert edge chiral patterns
        % iCH = imgChiral for horiz edge chiral patterns
        % iCD1 = imgChiral for Diag1 edge chiral patterns
        % iCD2 = imgChiral for Diag2 edge chiral patterns
        function [iCV,iCH,iCD1,iCD2] = getChrPats(obj,bNum)
            
            % R G
            % G B
            if (bNum == 1)
                bayer = obj.bayerR;
                
            % G R
            % B G
            elseif (bNum == 2)
                bayer = obj.bayerG1;
                
            % G B
            % R G
            elseif (bNum == 3)
                bayer = obj.bayerG2;
                
            % B G
            % G R
            elseif (bNum == 4)
                bayer = obj.bayerB;
            end
            
            % Get 5x5 vertical edge chiral negative vBand patterns
            VEVBCn = @(x) median(double(x([6 8 10],:)));
            imgVEVBCn = colfilt(bayer,[5 5],'sliding',VEVBCn);
            
            % Get 5x5 vertical edge chiral negative hBand patterns
            VEHBCn = @(x) median(double(x([2 4 12 14],:)));
            imgVEHBCn = colfilt(bayer,[5 5],'sliding',VEHBCn);
            
            % Get 5x5 vertical edge chiral negative Diag1 patterns
            VED1Cn = @(x) median(double(x([2 4 6 8 10 12 14],:)));
            imgVED1Cn = colfilt(bayer,[5 5],'sliding',VED1Cn);
            
            % Get 5x5 vertical edge chiral negative Diag2 patterns
            VED2Cn = @(x) median(double(x([7 9],:)));
            imgVED2Cn = colfilt(bayer,[5 5],'sliding',VED2Cn);
            
            % Get 5x5 vertical edge chiral positive vBand patterns
            VEVBCp = @(x) median(double(x([16 18 20],:)));
            imgVEVBCp = colfilt(bayer,[5 5],'sliding',VEVBCp);
            
            % Get 5x5 vertical edge chiral positive hBand patterns
            VEHBCp = @(x) median(double(x([12 14 22 24],:)));
            imgVEHBCp = colfilt(bayer,[5 5],'sliding',VEHBCp);
            
             % Get 5x5 vertical edge chiral positive Diag1 patterns
            VED1Cp = @(x) median(double(x([12 14 16 18 20 22 24],:)));
            imgVED1Cp = colfilt(bayer,[5 5],'sliding',VED1Cp);
            
           % Get 5x5 vertical edge chiral positive Diag2 patterns
            VED2Cp = @(x) median(double(x([17 19],:)));
            imgVED2Cp = colfilt(bayer,[5 5],'sliding',VED2Cp);
            
            % Get 5x5 horiz edge chiral negative vBand patterns
            HEVBCn = @(x) median(double(x([6 8 16 18],:)));
            imgHEVBCn = colfilt(bayer,[5 5],'sliding',HEVBCn);
            
            % Get 5x5 horiz edge chiral negative hBand patterns
            HEHBCn = @(x) median(double(x([2 12 22],:)));
            imgHEHBCn = colfilt(bayer,[5 5],'sliding',HEHBCn);
            
            % Get 5x5 horiz edge chiral negative Diag1 patterns
            HED1Cn = @(x) median(double(x([2 6 8 12 16 18 22],:)));
            imgHED1Cn = colfilt(bayer,[5 5],'sliding',HED1Cn);
            
            % Get 5x5 horiz edge chiral negative Diag2 patterns
            HED2Cn = @(x) median(double(x([7 17],:)));
            imgHED2Cn = colfilt(bayer,[5 5],'sliding',HED2Cn);
            
            % Get 5x5 horiz edge chiral positive vBand patterns
            HEVBCp = @(x) median(double(x([8 10 18 20],:)));
            imgHEVBCp = colfilt(bayer,[5 5],'sliding',HEVBCp);
            
            % Get 5x5 horiz edge chiral positive hBand patterns
            HEHBCp = @(x) median(double(x([4 14 24],:)));
            imgHEHBCp = colfilt(bayer,[5 5],'sliding',HEHBCp);
            
            % Get 5x5 horiz edge chiral positive Diag1 patterns
            HED1Cp = @(x) median(double(x([4 8 10 14 18 20 24],:)));
            imgHED1Cp = colfilt(bayer,[5 5],'sliding',HED1Cp);
            
            % Get 5x5 horiz edge chiral positive Diag2 patterns
            HED2Cp = @(x) median(double(x([9 19],:)));
            imgHED2Cp = colfilt(bayer,[5 5],'sliding',HED2Cp);
            
            % Get 5x5 Diag1 edge chiral negative vBand patterns
            D1EVBCn = @(x) median(double(x([6 8 16],:)));
            imgD1EVBCn = colfilt(bayer,[5 5],'sliding',D1EVBCn);
            
            % Get 5x5 Diag1 edge chiral negative hBand patterns
            D1EHBCn = @(x) median(double(x([2 4 12],:)));
            imgD1EHBCn = colfilt(bayer,[5 5],'sliding',D1EHBCn);
            
            % Get 5x5 Diag1 edge chiral negative Diag1 patterns
            D1ED1Cn = @(x) median(double(x([2 4 6 8 12 16],:)));
            imgD1ED1Cn = colfilt(bayer,[5 5],'sliding',D1ED1Cn);
            
            % Get 5x5 Diag1 edge chiral negative Diag2 patterns
            D1ED2Cn = @(x) median(double(x([7 9 17],:)));
            imgD1ED2Cn = colfilt(bayer,[5 5],'sliding',D1ED2Cn);
            
            % Get 5x5 Diag1 edge chiral positive vBand patterns
            D1EVBCp = @(x) median(double(x([10 18 20],:)));
            imgD1EVBCp = colfilt(bayer,[5 5],'sliding',D1EVBCp);
            
            % Get 5x5 Diag1 edge chiral positive hBand patterns
            D1EHBCp = @(x) median(double(x([14 22 24],:)));
            imgD1EHBCp = colfilt(bayer,[5 5],'sliding',D1EHBCp);
            
            % Get 5x5 Diag1 edge chiral positive Diag1 patterns
            D1ED1Cp = @(x) median(double(x([10 14 18 20 22 24],:)));
            imgD1ED1Cp = colfilt(bayer,[5 5],'sliding',D1ED1Cp);
            
            % Get 5x5 Diag1 edge chiral positive Diag2 patterns
            D1ED2Cp = @(x) median(double(x([9 17 19],:)));
            imgD1ED2Cp = colfilt(bayer,[5 5],'sliding',D1ED2Cp);
            
            % Get 5x5 Diag2 edge chiral negative vBand patterns
            D2EVBCn = @(x) median(double(x([8 10 20],:)));
            imgD2EVBCn = colfilt(bayer,[5 5],'sliding',D2EVBCn);
            
            % Get 5x5 Diag2 edge chiral negative hBand patterns
            D2EHBCn = @(x) median(double(x([2 4 14],:)));
            imgD2EHBCn = colfilt(bayer,[5 5],'sliding',D2EHBCn);
            
            % Get 5x5 Diag2 edge chiral negative Diag1 patterns
            D2ED1Cn = @(x) median(double(x([2 4 8 10 14 20],:)));
            imgD2ED1Cn = colfilt(bayer,[5 5],'sliding',D2ED1Cn);
            
            % Get 5x5 Diag2 edge chiral negative Diag2 patterns
            D2ED2Cn = @(x) median(double(x([7 9 19],:)));
            imgD2ED2Cn = colfilt(bayer,[5 5],'sliding',D2ED2Cn);
            
            % Get 5x5 Diag2 edge chiral positive vBand patterns
            D2EVBCp = @(x) median(double(x([6 16 18],:)));
            imgD2EVBCp = colfilt(bayer,[5 5],'sliding',D2EVBCp);
            
            % Get 5x5 Diag2 edge chiral positive hBand patterns
            D2EHBCp = @(x) median(double(x([12 22 24],:)));
            imgD2EHBCp = colfilt(bayer,[5 5],'sliding',D2EHBCp);
            
             % Get 5x5 Diag2 edge chiral positive Diag1 patterns
            D2ED1Cp = @(x) median(double(x([6 12 16 18 22 24],:)));
            imgD2ED1Cp = colfilt(bayer,[5 5],'sliding',D2ED1Cp);
            
            % Get 5x5 Diag2 edge chiral positive Diag2 patterns
            D2ED2Cp = @(x) median(double(x([7 17 19],:)));
            imgD2ED2Cp = colfilt(bayer,[5 5],'sliding',D2ED2Cp);
            
            % Get imgChiral for vertical edge chiral patterns
            iCV = imgChiral(imgVEHBCn,imgVEVBCn,imgVED1Cn,imgVED2Cn, ...
                imgVEHBCp,imgVEVBCp,imgVED1Cp,imgVED2Cp);
            
            % Get imgChiral for horiz edge chiral patterns
            iCH = imgChiral(imgHEHBCn,imgHEVBCn,imgHED1Cn,imgHED2Cn, ...
                imgHEHBCp,imgHEVBCp,imgHED1Cp,imgHED2Cp);
            
            % Get imgChiral for Diag1 edge chiral patterns
            iCD1 = imgChiral(imgD1EHBCn,imgD1EVBCn,imgD1ED1Cn, ...
                imgD1ED2Cn,imgD1EHBCp,imgD1EVBCp,imgD1ED1Cp,imgD1ED2Cp);
            
            % Get imgChiral for Diag2 edge chiral patterns
            iCD2 = imgChiral(imgD2EHBCn,imgD2EVBCn,imgD2ED1Cn, ...
                imgD2ED2Cn,imgD2EHBCp,imgD2EVBCp,imgD2ED1Cp,imgD2ED2Cp);
            
        end
        
        % Demosaic image
        % th1 = threshold for edge detection
        % iStat = image statistics for demosaiced image
        function iStat = demoStats(obj,th1)
            
            % Get Bayer CFA patterns of image
            obj.getBayer();

            % R G
            % G B
            imgRG = obj.bayerR;

            % G R
            % B G
            imgGR = obj.bayerG1;

            % G B
            % R G
            imgGB = obj.bayerG2;

            % B G
            % G R
            imgBG = obj.bayerB;
            
            % find edges in grayscale images
            imgBWR = edge(imgRG,'sobel',th1,'nothinning');
            imgBWG1 = edge(imgGR,'sobel',th1,'nothinning');
            imgBWG2 = edge(imgGB,'sobel',th1,'nothinning');
            imgBWB = edge(imgBG,'sobel',th1,'nothinning');

            % Get 5x5 color patterns for Bayer CFA pattern images
            [imgRVB,imgRHB,imgRD1,imgRD2] = obj.getColorPats(1);
            [imgG1VB,imgG1HB,imgG1D1,imgG1D2] = obj.getColorPats(2);
            [imgG2VB,imgG2HB,imgG2D1,imgG2D2] = obj.getColorPats(3);
            [imgBVB,imgBHB,imgBD1,imgBD2] = obj.getColorPats(4);

            % R G
            % G B

            % Get RGB colors for Bayer R CFA pattern image
            imgRnew = blockproc(imgRG,[2 2], ...
                @(x)obj.demoBayerR(x,imgRVB,imgRHB,imgRD1,imgRD2));

            % G R
            % B G

            % Get RGB colors for Bayer G1 CFA pattern image
            imgG1new = blockproc(imgGR,[2 2], ...
                @(x)obj.demoBayerG1(x,imgG1VB,imgG1HB,imgG1D1,imgG1D2));

            % G B
            % R G

            % Get RGB colors for Bayer G2 CFA pattern image
            imgG2new = blockproc(imgGB,[2 2], ...
                @(x)obj.demoBayerG2(x,imgG2VB,imgG2HB,imgG2D1,imgG2D2));

            % B G
            % G R

            % Get RGB colors for Bayer B CFA pattern image
            imgBnew = blockproc(imgBG,[2 2], ...
                @(x)obj.demoBayerB(x,imgBVB,imgBHB,imgBD1,imgBD2));

            % R G
            % G B

            % get imgEdges for bayer R image
            edgeRed = obj.getImgEdge(1);
            
            % get edge types for bayer R image
            iThR = edgeRed.getEdgeTypes(imgBWR);
            
            % get chiralities of bayer R image edges
            imgChrR = obj.getImgChr(1,edgeRed,iThR);
            
            % get bayer R image chiral patterns
            [iRCV,iRCH,iRCD1,iRCD2] = obj.getChrPats(1);
            
            % convert bayer R image back to JPEG
            imgRdemo = obj.chr2jpg(1,imgRnew,imgChrR,iRCV,iRCH,iRCD1,iRCD2);

            % G R
            % B G

            % get imgEdges for bayer G1 image
            edgeGreen1 = obj.getImgEdge(2);
            
            % get edge types for bayer G1 image
            iThG1 = edgeGreen1.getEdgeTypes(imgBWG1);
            
            % get chiralities of bayer G1 image edges
            imgChrG1 = obj.getImgChr(2,edgeGreen1,iThG1);
            
            % get bayer G1 image chiral patterns
            [iG1CV,iG1CH,iG1CD1,iG1CD2] = obj.getChrPats(2);
            
            % convert bayer G1 image back to JPEG
            imgG1demo = obj.chr2jpg(2,imgG1new,imgChrG1,iG1CV,iG1CH,iG1CD1,iG1CD2);

            % G B
            % R G

            % get imgEdges for bayer G2 image
            edgeGreen2 = obj.getImgEdge(3);
            
            % get edge types for bayer G2 image
            iThG2 = edgeGreen2.getEdgeTypes(imgBWG2);
            
            % get chiralities of bayer G2 image edges
            imgChrG2 = obj.getImgChr(3,edgeGreen2,iThG2);
            
            % get bayer G2 image chiral patterns
            [iG2CV,iG2CH,iG2CD1,iG2CD2] = obj.getChrPats(3);
            
            % convert bayer G2 image back to JPEG
            imgG2demo = obj.chr2jpg(3,imgG2new,imgChrG2,iG2CV,iG2CH,iG2CD1,iG2CD2);

            % B G
            % G R

            % get imgEdges for bayer B image
            edgeBlue = obj.getImgEdge(4);
            
            % get edge types for bayer B image
            iThB = edgeBlue.getEdgeTypes(imgBWB);
            
            % get chiralities of bayer B image edges
            imgChrB = obj.getImgChr(4,edgeBlue,iThB);
            
            % get bayer B image chiral patterns
            [iBCV,iBCH,iBCD1,iBCD2] = obj.getChrPats(4);
            
            % convert bayer B image back to JPEG
            imgBdemo = obj.chr2jpg(4,imgBnew,imgChrB,iBCV,iBCH,iBCD1,iBCD2);

            % Calculate distances from original image
            [l,w,h] = size(obj.image);
            img = obj.image(3:(l-2),3:(w-2),3);
            imgColor = cat(3,img,img,img);
            diffR = abs(double(imgColor)-double(imgRdemo(3:(l-2),3:(w-2),:)));
            diffG1 = abs(double(imgColor)-double(imgG1demo(3:(l-2),3:(w-2),:)));
            diffG2 = abs(double(imgColor)-double(imgG2demo(3:(l-2),3:(w-2),:)));
            diffB = abs(double(imgColor)-double(imgBdemo(3:(l-2),3:(w-2),:)));

            % Get mean, sd, skew and kurtosis for errors
            % for errors from 3x3 window neighborhoods and image pixels
            avg = [mean2(diffR), mean2(diffG1), mean2(diffG2), mean2(diffB)];
            sd = [std(diffR(:),1), std(diffG1(:),1), std(diffG2(:),1), std(diffB(:),1)];
            skew = [skewness(diffR(:)), skewness(diffG1(:)), skewness(diffG2(:)), skewness(diffB(:))];
            kurt = [kurtosis(diffR(:)), kurtosis(diffG1(:)), kurtosis(diffG2(:)), kurtosis(diffB(:))];
            
            % initialize entropy arrays
            entropy = [0 0 0 0];
            
            % get entropy for red 3x3 window errors
            rEn = diffR.*log2(diffR);
            entropy(1) = -1*sum(rEn(~isnan(rEn(:))));
            
            % get entropy for green 1 3x3 window errors
            g1En = diffG1.*log2(diffG1);
            entropy(2) = -1*sum(g1En(~isnan(g1En(:))));
            
            % get entropy for green 2 3x3 window errors
            g2En = diffG2.*log2(diffG2);
            entropy(3) = -1*sum(g2En(~isnan(g2En(:))));
            
            % get entropy for blue 3x3 window errors
            bEn = diffB.*log2(diffB);
            entropy(4) = -1*sum(bEn(~isnan(bEn(:))));
            
            % Get energy for errors from 3x3 window and image pixels
            energy = [0 0 0 0];
            for i = 1:size(diffR,1)^2
                energy(1) = energy(1)+diffR(i)^2;
                energy(2) = energy(2)+diffG1(i)^2;
                energy(3) = energy(3)+diffG2(i)^2;
                energy(4) = energy(4)+diffB(i)^2;
            end
            
            % Return image statistics as imgStats
            % stats contain data for all 4 bayer images as 4x1 vectors
            iStat = imgStats(avg,sd,skew,kurt,entropy,energy,0,0,0);
            
        end
        
    end
    
end
