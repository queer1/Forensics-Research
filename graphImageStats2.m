%{
Graph image errors for red 3x3 neighborhoods for each image in database.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 22, 2011
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

clear; % clear matlab environment
clc; % clear homescreen
startTime = clock; % keep track of overall runtime

%{
MODIFY THESE DIRECTORIES TO DESIRED LOCATIONS ON EACH PARTICULAR MACHINE
Photos must be 512 by 512 pixel JPEGs. The photos directory should have a
folder for each camera, and images inside of each camera directory. Log
file contains the filename, cam #, and photo # of last photo processed.
Computation will start at next photo if software crashes or is killed. To
run software for first time, you must edit this file so it reads: FILE 1 0.
Image stats are saved in text files, one file per camera, in the statistics
directory. Each line in these files contains statistics for an individual
image.
%}
photoDirectory = '/students/home/semistatic/summer2011/crops/';
logDirectory = '/students/home/visionmatlab/workspace/iStat.log';
statsDirectory = '/students/home/visionmatlab/';
folders = strfind(photoDirectory,'/');
pDirLen = length(folders);

% pre-allocate new 500x500 cell matrix
fileLists = cell(500,500);

% Get all files for each camera in photos directory
cameraList = dir(photoDirectory);
numCams = length(cameraList);
for i = 3:length(cameraList)
    cam = [photoDirectory,cameraList(i).name];
    fileLists{i} = getAllFiles(cam);
end

% Loop through each image file
for camera = 3:numCams
    
    for photo = 1:length(fileLists{camera})
        
        str = ['Read camera ',num2str(camera-2),' of ',num2str( ...
            numCams-2),' file ',num2str(photo),' of ',num2str(length( ...
            fileLists{camera})),' ',fileLists{camera}{photo}];
        dstr = [datestr(now),': ',str];
        disp(dstr)
        
        % only process JPEGs
        if ((size(strfind(fileLists{camera}{photo},'.JPG'),1) > 0) || ...
                (size(strfind(fileLists{camera}{photo},'.jpg'),1) > 0))
            
            % read image file
            fimg = ForensicImage(fileLists{camera}{photo});
            
            % get image statistics
            [iStat3,iStat5,iStat7] = fimg.imgStats();
            
            % all image stats for red 3x3 neighborhoods
            iStat3Red = imgStats(iStat3.avg(1),iStat3.sd(1), ...
                iStat3.skew(1),iStat3.kurt(1),iStat3.entropy(1), ...
                iStat3.energy(1),iStat3.pixels(:,:,1), ...
                iStat3.meds(:,:,1),iStat3.errors(:,:,1));
            
            % all image stats for green 3x3 neighborhoods
            iStat3Green = imgStats(iStat3.avg(2),iStat3.sd(2), ...
                iStat3.skew(2),iStat3.kurt(2),iStat3.entropy(2), ...
                iStat3.energy(2),iStat3.pixels(:,:,2), ...
                iStat3.meds(:,:,2),iStat3.errors(:,:,2));
            
            % all image stats for blue 3x3 neighborhoods
            iStat3Blue = imgStats(iStat3.avg(3),iStat3.sd(3), ...
                iStat3.skew(3),iStat3.kurt(3),iStat3.entropy(3), ...
                iStat3.energy(3),iStat3.pixels(:,:,3), ...
                iStat3.meds(:,:,3),iStat3.errors(:,:,3));
            
            % all image stats for red 5x5 neighborhoods
            iStat5Red = imgStats(iStat5.avg(1),iStat5.sd(1), ...
                iStat5.skew(1),iStat5.kurt(1),iStat5.entropy(1), ...
                iStat5.energy(1),iStat5.pixels(:,:,1), ...
                iStat5.meds(:,:,1),iStat5.errors(:,:,1));
            
            % all image stats for green 5x5 neighborhoods
            iStat5Green = imgStats(iStat5.avg(2),iStat5.sd(2), ...
                iStat5.skew(2),iStat5.kurt(2),iStat5.entropy(2), ...
                iStat5.energy(2),iStat5.pixels(:,:,2), ...
                iStat5.meds(:,:,2),iStat5.errors(:,:,2));
            
            % all image stats for blue 5x5 neighborhoods
            iStat5Blue = imgStats(iStat5.avg(3),iStat5.sd(3), ...
                iStat5.skew(3),iStat5.kurt(3),iStat5.entropy(3), ...
                iStat5.energy(3),iStat5.pixels(:,:,3), ...
                iStat5.meds(:,:,3),iStat5.errors(:,:,3));
            
            % all image stats for red 7x7 neighborhoods
            iStat7Red = imgStats(iStat7.avg(1),iStat7.sd(1), ...
                iStat7.skew(1),iStat7.kurt(1),iStat7.entropy(1), ...
                iStat7.energy(1),iStat7.pixels(:,:,1), ...
                iStat7.meds(:,:,1),iStat7.errors(:,:,1));
            
            % all image stats for green 7x7 neighborhoods
            iStat7Green = imgStats(iStat7.avg(2),iStat7.sd(2), ...
                iStat7.skew(2),iStat7.kurt(2),iStat7.entropy(2), ...
                iStat7.energy(2),iStat7.pixels(:,:,2), ...
                iStat7.meds(:,:,2),iStat7.errors(:,:,2));
            
            % all image stats for blue 7x7 neighborhoods
            iStat7Blue = imgStats(iStat7.avg(3),iStat7.sd(3), ...
                iStat7.skew(3),iStat7.kurt(3),iStat7.entropy(3), ...
                iStat7.energy(3),iStat7.pixels(:,:,3), ...
                iStat7.meds(:,:,3),iStat7.errors(:,:,3));
            
            % graph image errors for red 3x3 neighborhoods
            histfit(iStat3Red.errors(:))
            figure;
            
        end

    end

end

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
