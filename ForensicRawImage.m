%{
A RAW Digital Negative (DNG) image file with forensics functions attached.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 17, 2011
updated: August 04, 2011
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

classdef ForensicRawImage < handle
    
    properties (GetAccess='public',SetAccess='public')
        filename
        image
        image8
        info
        infoRAW
    end
    
    methods
        
        % Forensic Raw Image constructor
        % f=filename, must be a Digital Negative (DNG) file
        function obj = ForensicRawImage(f)
            obj.filename = f;
            warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning
            tiff = Tiff(f,'r'); % open RAW image as tiff
            offsets = getTag(tiff,'SubIFD');
            setSubDirectory(tiff,offsets(1));
            cfa = read(tiff);
            close(tiff);
            obj.image = cfa; % save tiff image
            obj.info = imfinfo(f);
            obj.infoRAW = obj.info.SubIFDs{1};
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
        function nbhood = getnb(obj,r,c,win)
            size = win^2-1;
            t = floor(win/2);
            box = obj.image(r-t:r+t,c-t:c+t);
            nbhood = int16(box(1:size+1)); % includes center pixel 
        end
        
        % Get raw image curve
        function curve = getCurve(obj)
            hasLT = obj.hasCurve();
            if (hasLT)
                curve = obj.info.SubIFDs{1}.LinearizationTable;
            else
                curve = NaN;
            end
        end
        
        % Does raw image have linearization table?
        function hasLT = hasCurve(obj)
            hasLT = isfield(obj.info.SubIFDs{1},'LinearizationTable');
        end
        
        % Create 8-bit raw image
        function image8 = imraw8(obj)
            minRaw = min(obj.image(:));
            maxRaw = max(obj.image(:));
            power = log2(double(maxRaw));
            maxPower = ceil(power);
            twoToMaxPowerDiv256 = (2^maxPower)/256;
            % take ceiling of power
            % guess that max val of raw is (2^ceil(power))-1
            hasLT = obj.hasCurve();
            if (hasLT)
                curve = obj.getCurve();
                curve = [0; curve];
                img = curve(obj.image+1);
                obj.image8 = uint8(img./twoToMaxPowerDiv256);
            else
                obj.image8 = uint8(obj.image./twoToMaxPowerDiv256);
            end
            image8 = obj.image8;
        end
        
        % Get bayer color patterns
        % assumes 8 bit image has already been made
        % creates 4 images in which each pixel is the mean of an
        % appropriate neighborhood
        % imgVB = 5x5 vBand patterns for 8 bit RAW image
        % imgHB = 5x5 hBand patterns for 8 bit RAW image
        % imgD1 = 5x5 Diag1 patterns for 8 bit RAW image
        % imgD2 = 5x5 Diag2 patterns for 8 bit RAW image
        function [imgVB,imgHB,imgD1,imgD2] = getColorPats(obj)
            
            % Get 8 bit raw image
            bayer = obj.image8;
            
            % Get 5x5 vBand patterns for 8 bit RAW image
            Vband = @(x) mean(double(x([6 8 10 16 18 20],:)));
            imgVB = colfilt(bayer,[5 5],'sliding',Vband);
            % 1/4 red, 1/4 blue, 1/2 ignore
            
            % Get 5x5 hBand patterns for 8 bit RAW image
            Hband = @(x) mean(double(x([2 4 12 14 22 24],:)));
            imgHB = colfilt(bayer,[5 5],'sliding',Hband);
            % 1/4 red, 1/4 blue, 1/2 ignore
            
            % Get 5x5 Diag1 patterns for 8 bit RAW image
            Diag1 = @(x) mean(double(x([2 4 6 8 10 12 14 16 18 20 22 24] ...
                ,:)));
            imgD1 = colfilt(bayer,[5 5],'sliding',Diag1);
            % 1/2 green, 1/2 ignore
            
            % Get 5x5 Diag2 patterns for 8 bit RAW image
            Diag2 = @(x) mean(double(x([7 9 17 19],:)));
            imgD2 = colfilt(bayer,[5 5],'sliding',Diag2);
            % 1/4 red, 1/4 blue, 1/2 ignore
            
        end
        
        % Demosaic assumed bayer red pattern image
        % must be used with block process
        % x = anonymous function variable
        % imgVB = 5x5 vBand patterns for assumed Bayer R CFA pattern image
        % imgHB = 5x5 hBand patterns for assumed Bayer R CFA pattern image
        % imgD1 = 5x5 Diag1 patterns for assumed Bayer R CFA pattern image
        % imgD2 = 5x5 Diag2 patterns for assumed Bayer R CFA pattern image
        % imgDemo = smooth JPEG created from assumed bayer red pattern image
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
        
        % Demosaic assumed bayer green 1 pattern image
        % must be used with block process
        % x = anonymous function variable
        % imgVB = 5x5 vBand patterns for assumed Bayer G1 CFA pattern image
        % imgHB = 5x5 hBand patterns for assumed Bayer G1 CFA pattern image
        % imgD1 = 5x5 Diag1 patterns for assumed Bayer G1 CFA pattern image
        % imgD2 = 5x5 Diag2 patterns for assumed Bayer G1 CFA pattern image
        % imgDemo = smooth JPEG created from assumed bayer green 1 pattern image
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
        
        % Demosaic assumed bayer green 2 pattern image
        % must be used with block process
        % x = anonymous function variable
        % imgVB = 5x5 vBand patterns for assumed Bayer G2 CFA pattern image
        % imgHB = 5x5 hBand patterns for assumed Bayer G2 CFA pattern image
        % imgD1 = 5x5 Diag1 patterns for assumed Bayer G2 CFA pattern image
        % imgD2 = 5x5 Diag2 patterns for assumed Bayer G2 CFA pattern image
        % imgDemo = smooth JPEG created from assumed bayer green 2 pattern image
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
        
        % Demosaic assumed bayer blue pattern image
        % must be used with block process
        % x = anonymous function variable
        % imgVB = 5x5 vBand patterns for assumed Bayer B CFA pattern image
        % imgHB = 5x5 hBand patterns for assumed Bayer B CFA pattern image
        % imgD1 = 5x5 Diag1 patterns for assumed Bayer B CFA pattern image
        % imgD2 = 5x5 Diag2 patterns for assumed Bayer B CFA pattern image
        % imgDemo = smooth JPEG created from assumed bayer blue pattern image
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
        
        % Get Edge images
        % assumes 8 bit image has already been made
        % imgEdge = edge pattern images
        function imgEdge = getImgEdge(obj)
            
            % Get 8 bit raw image
            bayer = obj.image8;
            
            % Get 5x5 horizontal edges for 8 bit RAW image
            hDiff = @(x) abs(double(x(3,:))-double(x(23,:)));
            imgHD = colfilt(bayer,[5 5],'sliding',hDiff);

            % Get 5x5 vertical edges for 8 bit RAW image
            vDiff = @(x) abs(double(x(11,:))-double(x(15,:)));
            imgVD = colfilt(bayer,[5 5],'sliding',vDiff);

            % Get 5x5 forward diagonal edges for 8 bit RAW image
            D1diff = @(x) abs(double(x(7,:))-double(x(19,:)));
            imgD1 = colfilt(bayer,[5 5],'sliding',D1diff);

            % Get 5x5 backward diagonal edges for 8 bit RAW image
            D2diff = @(x) abs(double(x(9,:))-double(x(17,:)));
            imgD2 = colfilt(bayer,[5 5],'sliding',D2diff);

            % Get 5x5 hDiff patterns for 8 bit RAW image
            HDpat = @(x) mean(double(x([12 14],:)));
            imgHDpat = colfilt(bayer,[5 5],'sliding',HDpat);

            % Get 5x5 vDiff patterns for 8 bit RAW image
            VDpat = @(x) mean(double(x([8 18],:)));
            imgVDpat = colfilt(bayer,[5 5],'sliding',VDpat);

            % Get 5x5 diag1 diff patterns for 8 bit RAW image
            D1Dpat = @(x) mean(double(x([9 17],:)));
            imgD1pat = colfilt(bayer,[5 5],'sliding',D1Dpat);

            % Get 5x5 diag2 diff patterns for 8 bit RAW image
            D2Dpat = @(x) mean(double(x([7 19],:)));
            imgD2pat = colfilt(bayer,[5 5],'sliding',D2Dpat);

            % Get Edge Color Objects for further investigation
            imgEdge = imgEdges(imgHD,imgVD,imgD1,imgD2,imgHDpat,imgVDpat,imgD1pat,imgD2pat);
            
        end
        
        % Get chirality images for bayer pattern image
        % assumes 8 bit image has already been made
        % iEdge = imgEdges for image with edge types
        % iTh = image with edge types
        % imgChr = image of edge chiralities
        function imgChr = getImgChr(obj,iEdge,iTh)
            
            % Get 8 bit raw image
            bayer = obj.image8;
            
            % get chiralities of edge types in image
            iHDC = iEdge.getChiral(bayer,iTh,1,7,3,5);
            iVDC = iEdge.getChiral(bayer,iTh,2,1,5,5);
            iD1C = iEdge.getChiral(bayer,iTh,4,6,2,5);
            iD2C = iEdge.getChiral(bayer,iTh,8,8,4,5);
            
            % combine chirality images
            imgChr = iHDC+iVDC+iD1C+iD2C;
            
        end
        
        % Get chiral patterns from 8 bit RAW image
        % creates 4 images in which each pixel is the mean of an
        % appropriate neighborhood
        % iCV = imgChiral for vert edge chiral patterns
        % iCH = imgChiral for horiz edge chiral patterns
        % iCD1 = imgChiral for Diag1 edge chiral patterns
        % iCD2 = imgChiral for Diag2 edge chiral patterns
        function [iCV,iCH,iCD1,iCD2] = getChrPats(obj)
            
            % Get 8 bit raw image
            bayer = obj.image8;
            
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
            index = find(imgChr==-3);
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
            index = find(imgChr==3);
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
            index = find(imgChr==-4);
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
            index = find(imgChr==4);
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
        
        % Demosaic raw image
        % th1 = threshold for edge detection
        % iStat = image statistics for demosaiced image
        function iStat = demosaicImg(obj,th1)
            
            % Crop image to 512 by 512 square pixels
            obj.crop512();

            % Get 8 bit raw image
            im8bit = obj.imraw8();

            % find edges in 8 bit raw image
            imgBW = edge(im8bit,'sobel',th1,'nothinning');

            % Get 5x5 color patterns for 8 bit raw image
            [imgVB,imgHB,imgD1,imgD2] = obj.getColorPats();

            % R G
            % G B

            % Get RGB colors for assumed Bayer R CFA pattern image
            imgRnew = blockproc(im8bit,[2 2], ...
                @(x)obj.demoBayerR(x,imgVB,imgHB,imgD1,imgD2));

            % G R
            % B G

            % Get RGB colors for assumed Bayer G1 CFA pattern image
            imgG1new = blockproc(im8bit,[2 2], ...
                @(x)obj.demoBayerG1(x,imgVB,imgHB,imgD1,imgD2));

            % G B
            % R G

            % Get RGB colors for assumed Bayer G2 CFA pattern image
            imgG2new = blockproc(im8bit,[2 2], ...
                @(x)obj.demoBayerG2(x,imgVB,imgHB,imgD1,imgD2));

            % B G
            % G R

            % Get RGB colors for assumed Bayer B CFA pattern image
            imgBnew = blockproc(im8bit,[2 2], ...
                @(x)obj.demoBayerB(x,imgVB,imgHB,imgD1,imgD2));

            % get imgEdges for 8 bit raw image
            edges = obj.getImgEdge();
            
            % get edge types for 8 bit raw image
            iTh = edges.getEdgeTypes(imgBW);
            
            % get chiralities of 8 bit raw image edges
            imgChr = obj.getImgChr(edges,iTh);
            
            % get 8 bit raw image chiral patterns
            [iCV,iCH,iCD1,iCD2] = obj.getChrPats();

            % R G
            % G B

            % convert assumed bayer R image back to JPEG
            imgRdemo = obj.chr2jpg(1,imgRnew,imgChr,iCV,iCH,iCD1,iCD2);

            % G R
            % B G

            % convert assumed bayer G1 image back to JPEG
            imgG1demo = obj.chr2jpg(2,imgG1new,imgChr,iCV,iCH,iCD1,iCD2);

            % G B
            % R G

            % convert assumed bayer G2 image back to JPEG
            imgG2demo = obj.chr2jpg(3,imgG2new,imgChr,iCV,iCH,iCD1,iCD2);

            % B G
            % G R

            % convert assumed bayer B image back to JPEG
            imgBdemo = obj.chr2jpg(4,imgBnew,imgChr,iCV,iCH,iCD1,iCD2);

            % Calculate distances from original image
            [l,w,h] = size(obj.image8);
            img = im8bit(3:(l-2),3:(w-2));
            diffR = abs(double(img)-double(imgRdemo(3:(l-2),3:(w-2),3)));
            diffG1 = abs(double(img)-double(imgG1demo(3:(l-2),3:(w-2),3)));
            diffG2 = abs(double(img)-double(imgG2demo(3:(l-2),3:(w-2),3)));
            diffB = abs(double(img)-double(imgBdemo(3:(l-2),3:(w-2),3)));

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
            % stats contain data for all 4 assumed bayer images as 4x1 vectors
            iStat = imgStats(avg,sd,skew,kurt,entropy,energy,0,0,0);
            
        end
        
    end
    
end
