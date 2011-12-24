%{
Holds chiral patterns for bayer images.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: July 15, 2011
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

classdef imgChiral
    
    properties (GetAccess='public',SetAccess='public')
        imgHBneg
        imgVBneg
        imgD1neg
        imgD2neg
        imgHBpos
        imgVBpos
        imgD1pos
        imgD2pos
    end
    
    methods
        
        % imgChiral constructor
        function obj = imgChiral(imgHBneg,imgVBneg,imgD1neg,imgD2neg, ...
                imgHBpos,imgVBpos,imgD1pos,imgD2pos)
            obj.imgHBneg = imgHBneg;
            obj.imgVBneg = imgVBneg;
            obj.imgD1neg = imgD1neg;
            obj.imgD2neg = imgD2neg;
            obj.imgHBpos = imgHBpos;
            obj.imgVBpos = imgVBpos;
            obj.imgD1pos = imgD1pos;
            obj.imgD2pos = imgD2pos;
        end
        
        % Get method imgHBneg
        function imgHBneg = get.imgHBneg(obj)
            imgHBneg = obj.imgHBneg;
        end
        
        % Get method imgVBneg
        function imgVBneg = get.imgVBneg(obj)
            imgVBneg = obj.imgVBneg;
        end
        
        % Get method imgD1neg
        function imgD1neg = get.imgD1neg(obj)
            imgD1neg = obj.imgD1neg;
        end
        
        % Get method imgD2neg
        function imgD2neg = get.imgD2neg(obj)
            imgD2neg = obj.imgD2neg;
        end
        
        % Get method imgHBpos
        function imgHBpos = get.imgHBpos(obj)
            imgHBpos = obj.imgHBpos;
        end
        
        % Get method imgVBpos
        function imgVBpos = get.imgVBpos(obj)
            imgVBpos = obj.imgVBpos;
        end
        
        % Get method imgD1pos
        function imgD1pos = get.imgD1pos(obj)
            imgD1pos = obj.imgD1pos;
        end
        
        % Get method imgD2pos
        function imgD2pos = get.imgD2pos(obj)
            imgD2pos = obj.imgD2pos;
        end
        
        % Set method imgHBneg
        function obj = set.imgHBneg(obj,newimgHBneg)
            obj.imgHBneg = newimgHBneg;
        end
        
        % Set method imgVBneg
        function obj = set.imgVBneg(obj,newimgVBneg)
            obj.imgVBneg = newimgVBneg;
        end
        
        % Set method imgD1neg
        function obj = set.imgD1neg(obj,newimgD1neg)
            obj.imgD1neg = newimgD1neg;
        end
        
        % Set method imgD2neg
        function obj = set.imgD2neg(obj,newimgD2neg)
            obj.imgD2neg = newimgD2neg;
        end
        
        % Set method imgHBpos
        function obj = set.imgHBpos(obj,newimgHBpos)
            obj.imgHBpos = newimgHBpos;
        end
        
        % Set method imgVBpos
        function obj = set.imgVBpos(obj,newimgVBpos)
            obj.imgVBpos = newimgVBpos;
        end
        
        % Set method imgD1pos
        function obj = set.imgD1pos(obj,newimgD1pos)
            obj.imgD1pos = newimgD1pos;
        end
        
        % Set method imgD2pos
        function obj = set.imgD2pos(obj,newimgD2pos)
            obj.imgD2pos = newimgD2pos;
        end
        
    end
    
end
