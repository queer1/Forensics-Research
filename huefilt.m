%{
Smooth Hue Transition filter for images that ignores the origin pixel.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: September 23, 2011
updated: December 02, 2011
Copyright (C) Fall 2011  Skidmore College

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

% Smooth Hue Transition filter that ignores center pixel
% image = non-green component of image
% green = green component of image
function result = huefilt(image, green, win, bNum)
    
    % create complex matrix [image + green*i]
    imgComplex = complex(image,green);

    if (win == 3)
        
        % Get 3x3 G1 hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iG1hue = @(x) abs(imag(x(5,:)) ./ 2 .* ...
            (real(x(2,:))./imag(x(2,:)) + real(x(8,:))./imag(x(8,:))));
        imgG1hue = colfilt(imgComplex,[3 3],'sliding',iG1hue);

        % Get 3x3 G2 hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iG2hue = @(x) abs(imag(x(5,:)) ./ 2 .* ...
            (real(x(4,:))./imag(x(4,:)) + real(x(6,:))./imag(x(6,:))));
        imgG2hue = colfilt(imgComplex,[3 3],'sliding',iG2hue);

        % Get 3x3 RB hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iRBhue = @(x) abs(imag(x(5,:)) ./ 4 .* ...
            (real(x(1,:))./imag(x(1,:)) + real(x(7,:))./imag(x(7,:)) + ...
            real(x(3,:))./imag(x(3,:)) + real(x(9,:))./imag(x(9,:))));
        imgRBhue = colfilt(imgComplex,[3 3],'sliding',iRBhue);
        
    elseif (win == 5)
        
        % Get 5x5 G1 hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iG1hue = @(x) abs(imag(x(13,:)) ./ 6 .* ...
            (real(x(6,:))./imag(x(6,:)) + real(x(16,:))./imag(x(16,:)) + ...
            real(x(8,:))./imag(x(8,:)) + real(x(18,:))./imag(x(18,:)) + ...
            real(x(10,:))./imag(x(10,:)) + real(x(20,:))./imag(x(20,:))));
        imgG1hue = colfilt(imgComplex,[5 5],'sliding',iG1hue);

        % Get 5x5 G2 hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iG2hue = @(x) abs(imag(x(13,:)) ./ 6 .* ...
            (real(x(2,:))./imag(x(2,:)) + real(x(4,:))./imag(x(4,:)) + ...
            real(x(12,:))./imag(x(12,:)) + real(x(14,:))./imag(x(14,:)) + ...
            real(x(22,:))./imag(x(22,:)) + real(x(24,:))./imag(x(24,:))));
        imgG2hue = colfilt(imgComplex,[5 5],'sliding',iG2hue);

        % Get 5x5 RB hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iRBhue = @(x) abs(imag(x(13,:)) ./ 4 .* ...
            (real(x(7,:))./imag(x(7,:)) + real(x(9,:))./imag(x(9,:)) + ...
            real(x(17,:))./imag(x(17,:)) + real(x(19,:))./imag(x(19,:))));
        imgRBhue = colfilt(imgComplex,[5 5],'sliding',iRBhue);
        
    elseif (win == 7)
        
        % Get 7x7 G1 hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iG1hue = @(x) abs(imag(x(25,:)) ./ 12 .* ...
            (real(x(2,:))./imag(x(2,:)) + real(x(16,:))./imag(x(16,:)) + ...
            real(x(4,:))./imag(x(4,:)) + real(x(18,:))./imag(x(18,:)) + ...
            real(x(6,:))./imag(x(6,:)) + real(x(20,:))./imag(x(20,:)) + ...
            real(x(30,:))./imag(x(30,:)) + real(x(44,:))./imag(x(44,:)) + ...
            real(x(32,:))./imag(x(32,:)) + real(x(46,:))./imag(x(46,:)) + ...
            real(x(34,:))./imag(x(34,:)) + real(x(48,:))./imag(x(48,:))));
        imgG1hue = colfilt(imgComplex,[7 7],'sliding',iG1hue);

        % Get 7x7 G2 hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iG2hue = @(x) abs(imag(x(25,:)) ./ 12 .* ...
            (real(x(8,:))./imag(x(8,:)) + real(x(10,:))./imag(x(10,:)) + ...
            real(x(22,:))./imag(x(22,:)) + real(x(24,:))./imag(x(24,:)) + ...
            real(x(36,:))./imag(x(36,:)) + real(x(38,:))./imag(x(38,:)) + ...
            real(x(12,:))./imag(x(12,:)) + real(x(14,:))./imag(x(14,:)) + ...
            real(x(26,:))./imag(x(26,:)) + real(x(28,:))./imag(x(28,:)) + ...
            real(x(40,:))./imag(x(40,:)) + real(x(42,:))./imag(x(42,:))));
        imgG2hue = colfilt(imgComplex,[7 7],'sliding',iG2hue);

        % Get 7x7 RB hue for Bayer CFA pattern image
        % imag(x) => green
        % real(x) => image color
        iRBhue = @(x) abs(imag(x(25,:)) ./ 16 .* ...
            (real(x(1,:))./imag(x(1,:)) + real(x(15,:))./imag(x(15,:)) + ...
            real(x(3,:))./imag(x(3,:)) + real(x(17,:))./imag(x(17,:)) + ...
            real(x(5,:))./imag(x(5,:)) + real(x(19,:))./imag(x(19,:)) + ...
            real(x(7,:))./imag(x(7,:)) + real(x(21,:))./imag(x(21,:)) + ...
            real(x(29,:))./imag(x(29,:)) + real(x(43,:))./imag(x(43,:)) + ...
            real(x(31,:))./imag(x(31,:)) + real(x(45,:))./imag(x(45,:)) + ...
            real(x(33,:))./imag(x(33,:)) + real(x(47,:))./imag(x(47,:)) + ...
            real(x(35,:))./imag(x(35,:)) + real(x(49,:))./imag(x(49,:))));
        imgRBhue = colfilt(imgComplex,[7 7],'sliding',iRBhue);
        
    end
    
    
    % Get Smooth Hue Transition interpolation for image
    % must be used with block process
    % x = anonymous function variable
    % iG1hue = G1 hue for Bayer CFA pattern image
    % iG2hue = G2 hue for Bayer CFA pattern image
    % iRBhue = RB hue for Bayer CFA pattern image
    function iHfilt = hFilt(x,iG1hue,iG2hue,iRBhue,bNum)

        % get current block process location
        sr = x.location(1);
        sc = x.location(2);
        srIsEven = mod(sr,2);
        scIsEven = mod(sc,2);
        
        pix11 = x.data(1,1);
        pix12 = x.data(1,2);
        pix21 = x.data(2,1);
        pix22 = x.data(2,2);
        
        % R G
        % G B
        if (bNum == 1)
            
            if ((srIsEven == 0) && (scIsEven == 0))
                pix12 = iG1hue(sr,sc+1);
                pix21 = iG2hue(sr+1,sc);
                pix22 = iRBhue(sr+1,sc+1);
            elseif ((srIsEven == 1) && (scIsEven == 0))
                pix11 = iG2hue(sr,sc);
                pix12 = iRBhue(sr,sc+1);
                pix22 = iG1hue(sr+1,sc+1);
            elseif ((srIsEven == 0) && (scIsEven == 1))
                pix11 = iG1hue(sr,sc);
                pix21 = iRBhue(sr+1,sc);
                pix22 = iG2hue(sr+1,sc+1);
            else
                pix11 = iRBhue(sr,sc);
                pix12 = iG2hue(sr,sc+1);
                pix21 = iG1hue(sr+1,sc);
            end
            
        % G R
        % B G
        elseif (bNum == 2)
            
            if ((srIsEven == 0) && (scIsEven == 0))
                pix11 = iG1hue(sr,sc);
                pix21 = iRBhue(sr+1,sc);
                pix22 = iG2hue(sr+1,sc+1);
            elseif ((srIsEven == 1) && (scIsEven == 0))
                pix11 = iRBhue(sr,sc);
                pix12 = iG2hue(sr,sc+1);
                pix21 = iG1hue(sr+1,sc);
            elseif ((srIsEven == 0) && (scIsEven == 1))
                pix12 = iG1hue(sr,sc+1);
                pix21 = iG2hue(sr+1,sc);
                pix22 = iRBhue(sr+1,sc+1);
            else
                pix11 = iG2hue(sr,sc);
                pix12 = iRBhue(sr,sc+1);
                pix22 = iG1hue(sr+1,sc+1);
            end
        
        % G B
        % R G
        elseif (bNum == 3)
            
            if ((srIsEven == 0) && (scIsEven == 0))
                pix11 = iG2hue(sr,sc);
                pix12 = iRBhue(sr,sc+1);
                pix22 = iG1hue(sr+1,sc+1);
            elseif ((srIsEven == 1) && (scIsEven == 0))
                pix12 = iG1hue(sr,sc+1);
                pix21 = iG2hue(sr+1,sc);
                pix22 = iRBhue(sr+1,sc+1);
            elseif ((srIsEven == 0) && (scIsEven == 1))
                pix11 = iRBhue(sr,sc);
                pix12 = iG2hue(sr,sc+1);
                pix21 = iG1hue(sr+1,sc);
            else
                pix11 = iG1hue(sr,sc);
                pix21 = iRBhue(sr+1,sc);
                pix22 = iG2hue(sr+1,sc+1);
            end
            
        % B G
        % G R
        elseif (bNum == 4)
            
            if ((srIsEven == 0) && (scIsEven == 0))
                pix11 = iRBhue(sr,sc);
                pix12 = iG2hue(sr,sc+1);
                pix21 = iG1hue(sr+1,sc);
            elseif ((srIsEven == 1) && (scIsEven == 0))
                pix11 = iG1hue(sr,sc);
                pix21 = iRBhue(sr+1,sc);
                pix22 = iG2hue(sr+1,sc+1);
            elseif ((srIsEven == 0) && (scIsEven == 1))
                pix11 = iG2hue(sr,sc);
                pix12 = iRBhue(sr,sc+1);
                pix22 = iG1hue(sr+1,sc+1);
            else
                pix11 = iG1hue(sr,sc+1);
                pix21 = iG2hue(sr+1,sc);
                pix22 = iRBhue(sr+1,sc+1);
            end
            
        end

        % create 2x2x3 color pixel block at current location
        % assume current block of image is smooth
        iHfilt = ...
            [pix11 pix12; ...
             pix21 pix22];

    end
    
    result = blockproc(image,[2 2], ...
                @(x)hFilt(x,imgG1hue,imgG2hue,imgRBhue,bNum));
    
end
