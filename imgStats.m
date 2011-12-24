%{
Holds statistics for images.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 15, 2011
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

classdef imgStats
    
    properties (GetAccess='public',SetAccess='public')
        avg
        sd
        skew
        kurt
        entropy
        energy
        pixels
        meds
        errors
    end
    
    methods
        
        % imgStats constructor
        function obj = imgStats(avg,sd,skew,kurt,entropy,energy,pixels,meds,errors)
            obj.avg = avg;
            obj.sd = sd;
            obj.skew = skew;
            obj.kurt = kurt;
            obj.entropy = entropy;
            obj.energy = energy;
            obj.pixels = pixels;
            obj.meds = meds;
            obj.errors = errors;
        end
        
        % Get method avg
        function avg = get.avg(obj)
            avg = obj.avg;
        end
        
        % Get method sd
        function sd = get.sd(obj)
            sd = obj.sd;
        end
        
        % Get method skew
        function skew = get.skew(obj)
            skew = obj.skew;
        end
        
        % Get method kurt
        function kurt = get.kurt(obj)
            kurt = obj.kurt;
        end
        
        % Get method entropy
        function entropy = get.entropy(obj)
            entropy = obj.entropy;
        end
        
        % Get method energy
        function energy = get.energy(obj)
            energy = obj.energy;
        end
        
        % Get method pixels
        function pixels = get.pixels(obj)
            pixels = obj.pixels;
        end
        
        % Get method meds
        function meds = get.meds(obj)
            meds = obj.meds;
        end
        
        % Get method errors
        function errors = get.errors(obj)
            errors = obj.errors;
        end
        
        % Set method avg
        function obj = set.avg(obj,newavg)
            obj.avg = newavg;
        end
        
        % Set method sd
        function obj = set.sd(obj,newsd)
            obj.sd = newsd;
        end
        
        % Set method skew
        function obj = set.skew(obj,newskew)
            obj.skew = newskew;
        end
        
        % Set method kurt
        function obj = set.kurt(obj,newkurt)
            obj.kurt = newkurt;
        end
        
        % Set method entropy
        function obj = set.entropy(obj,newentropy)
            obj.entropy = newentropy;
        end
        
        % Set method energy
        function obj = set.energy(obj,newenergy)
            obj.energy = newenergy;
        end
        
        % Set method pixels
        function obj = set.pixels(obj,newpixels)
            obj.pixels = newpixels;
        end
        
        % Set method meds
        function obj = set.meds(obj,newmeds)
            obj.meds = newmeds;
        end
        
        % Set method errors
        function obj = set.errors(obj,newerrors)
            obj.errors = newerrors;
        end
        
        % clean imgStats data
        function obj = clean(obj)
            
            % copy object data to temporary variables
            favg = obj.avg;
            fsd = obj.sd;
            fskew = obj.skew;
            fkurt = obj.kurt;
            fentropy = obj.entropy;
            fenergy = obj.energy;
            fpixels = obj.pixels;
            fmeds = obj.meds;
            
            % convert all NaNs in temporary variables to 0s
            favg(find(isnan(favg))) = 0;
            fsd(find(isnan(fsd))) = 0;
            fskew(find(isnan(fskew))) = 0;
            fkurt(find(isnan(fkurt))) = 0;
            fentropy(find(isnan(fentropy))) = 0;
            fenergy(find(isnan(fenergy))) = 0;
            fpixels(find(isnan(fpixels))) = 0;
            fmeds(find(isnan(fmeds))) = 0;
            
            % save modified temporary variables to object data
            obj.avg = favg;
            obj.sd = fsd;
            obj.skew = fskew;
            obj.kurt = fkurt;
            obj.entropy = fentropy;
            obj.energy = fenergy;
            obj.pixels = fpixels;
            obj.meds = fmeds;
            
        end
        
    end
    
end
