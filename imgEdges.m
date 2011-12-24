%{
Holds edges for images.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 29, 2011
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

classdef imgEdges
    
    properties (GetAccess='public',SetAccess='public')
        imgHdiff
        imgVdiff
        imgD1diff
        imgD2diff
        imgHpat
        imgVpat
        imgD1pat
        imgD2pat
    end
    
    methods
        
        % imgEdges constructor
        function obj = imgEdges(imgHdiff,imgVdiff,imgD1diff,imgD2diff, ...
                imgHpat,imgVpat,imgD1pat,imgD2pat)
            obj.imgHdiff = imgHdiff;
            obj.imgVdiff = imgVdiff;
            obj.imgD1diff = imgD1diff;
            obj.imgD2diff = imgD2diff;
            obj.imgHpat = imgHpat;
            obj.imgVpat = imgVpat;
            obj.imgD1pat = imgD1pat;
            obj.imgD2pat = imgD2pat;
        end
        
        % Get method imgHdiff
        function imgHdiff = get.imgHdiff(obj)
            imgHdiff = obj.imgHdiff;
        end
        
        % Get method imgVdiff
        function imgVdiff = get.imgVdiff(obj)
            imgVdiff = obj.imgVdiff;
        end
        
        % Get method imgD1Bdiff
        function imgD1diff = get.imgD1diff(obj)
            imgD1diff = obj.imgD1diff;
        end
        
        % Get method imgD2Bdiff
        function imgD2diff = get.imgD2diff(obj)
            imgD2diff = obj.imgD2diff;
        end
        
        % Get method imgHpat
        function imgHpat = get.imgHpat(obj)
            imgHpat = obj.imgHpat;
        end
        
        % Get method imgVpat
        function imgVpat = get.imgVpat(obj)
            imgVpat = obj.imgVpat;
        end
        
        % Get method imgD1pat
        function imgD1pat = get.imgD1pat(obj)
            imgD1pat = obj.imgD1pat;
        end
        
        % Get method imgD2pat
        function imgD2pat = get.imgD2pat(obj)
            imgD2pat = obj.imgD2pat;
        end
        
        % Set method imgHdiff
        function obj = set.imgHdiff(obj,newimgHdiff)
            obj.imgHdiff = newimgHdiff;
        end
        
        % Set method imgVdiff
        function obj = set.imgVdiff(obj,newimgVdiff)
            obj.imgVdiff = newimgVdiff;
        end
        
        % Set method imgD1diff
        function obj = set.imgD1diff(obj,newimgD1diff)
            obj.imgD1diff = newimgD1diff;
        end
        
        % Set method imgD2diff
        function obj = set.imgD2diff(obj,newimgD2diff)
            obj.imgD2diff = newimgD2diff;
        end
        
        % Set method imgHpat
        function obj = set.imgHpat(obj,newimgHpat)
            obj.imgHpat = newimgHpat;
        end
        
        % Set method imgVpat
        function obj = set.imgVpat(obj,newimgVpat)
            obj.imgVpat = newimgVpat;
        end
        
        % Set method imgD1pat
        function obj = set.imgD1pat(obj,newimgD1pat)
            obj.imgD1pat = newimgD1pat;
        end
        
        % Set method imgD2pat
        function obj = set.imgD2pat(obj,newimgD2pat)
            obj.imgD2pat = newimgD2pat;
        end
        
        % Get edge types for grayscale image
        % all values above thresh are 1, everything else 0
        % imgBW = edge detection image
        % iTh = grayscale image with edge types
        function iTh = getEdgeTypes(obj,imgBW)
            
            % initialize variables
            [r,c] = size(obj.imgHdiff);
            iTh = zeros(r,c);
            
            % get maximum edge gradient at each pixel
            maxEdge = max(obj.imgHdiff,max(obj.imgVdiff,max(obj.imgD1diff,obj.imgD2diff)));
            
            %disp('maxEdge(50:59,70:79)');
            %maxEdge(50:59,70:79)
            
            % remove all horiz diffs in smooth areas
            % make image 1 where horiz is maximum edge gradient
            testHdiff = imgBW.*(maxEdge==obj.imgHdiff);
            
            %disp('testHdiff(50:59,70:79)');
            %testHdiff(50:59,70:79)
            
            % remove all vert diffs in smooth areas
            % make image 2 where vert is maximum edge gradient
            testVdiff = 2*(imgBW.*(maxEdge==obj.imgVdiff));
            
            %disp('testVdiff(50:59,70:79)');
            %testVdiff(50:59,70:79)
            
            % remove all D1 diffs in smooth areas
            % make image 4 where D1 is maximum edge gradient
            testD1diff = 4*(imgBW.*(maxEdge==obj.imgD1diff));
            
            %disp('testD1diff(50:59,70:79)');
            %testD1diff(50:59,70:79)
            
            % remove all D2 diffs in smooth areas
            % make image 8 where D2 is maximum edge gradient
            testD2diff = 8*(imgBW.*(maxEdge==obj.imgD2diff));
            
            %disp('testD2diff(50:59,70:79)');
            %testD2diff(50:59,70:79)
            
            % combine edge types
            iTh = testHdiff+testVdiff+testD1diff+testD2diff;
            
            % all mixed max edge types with horiz become horiz
            test = bitand(uint8(iTh),uint8(1));
            ind = test>0;
            iTh(ind) = 1;
            
            % all mixed max edge types with vert become vert
            test = bitand(uint8(iTh),uint8(2));
            ind = test>0;
            iTh(ind) = 2;
            
            % all mixed max edge types with D1 become D1
            test = bitand(uint8(iTh),uint8(4));
            ind = test>0;
            iTh(ind) = 4;
            
            % all mixed max edge types with D2 become D2
            test = bitand(uint8(iTh),uint8(8));
            ind = test>0;
            iTh(ind) = 8;
            
        end
        
        % Adjust signs of thresholded image for chirality
        % all values above thresh are 1, everything else 0
        % img = grayscale image
        % imgTh = image with edge types
        % cType = edge type
        % s1 = side1 based on matrix in comments below
        % s2 = side2 based on matrix in comments below
        % win = window size
        % chiral = image with chiralities for edge types
        function chiral = getChiral(obj,img,imgTh,cType,s1,s2,win)
            
            % initialize variables
            index = find(imgTh==cType);
            [l,w] = size(img);
            [r,c] = ind2sub([l,w],index);
            chiral = zeros(l,w); % -1 = side1, 1 = side2, 0 = garbage
            mid = floor(win/2);
            
            % loop through all pixels with given edge type
            for i = 1:length(index)
                
                % get location information
                ind = index(i);
                row = r(i);
                col = c(i);
                pix = img(ind);
                rStart = max(row-mid,1);
                rEnd = min(row+mid,l);
                cStart = max(col-mid,1);
                cEnd = min(col+mid,w);
                
                % 8 x 1 x 2
                % x x x x x
                % 7 x x x 3
                % x x x x x
                % 6 x 5 x 4
                
                % get indices of neighbors like the ones in matrix above
                ind2 = sub2ind([l,w], ...
                    [rStart,rStart,row,rEnd,rEnd,rEnd,row,rStart], ...
                    [col,cEnd,cEnd,cEnd,col,cStart,cStart,cStart]);
                test = img(ind2);
                
                % get different btween middle pixel and side pixel values
                side1 = abs(double(pix)-double(test(s1)));
                side2 = abs(double(pix)-double(test(s2)));
                
                % determine chirality of edge
                if (side1<=side2)
                    chiral(ind) = -1*imgTh(ind); % side1
                else
                    chiral(ind) = 1*imgTh(ind); % side2
                end
                
            end
            
        end
        
    end
    
end
