%{
Search through all images in crops directory, and save statistics data from
images in <cameraDir>.txt

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
logDirectory = '/students/home/visionmatlab/workspace/iStatHue.log';
statsDirectory = '/students/home/visionmatlab/stats/12-02-hue/';
folders = strfind(photoDirectory,'/');
pDirLen = length(folders);

% pre-allocate new 500x500 cell matrix
fileLists = cell(500,500);

% color channels
r = 1;
g = 2;
b = 3;

% Get all files for each camera in photos directory
cameraList = dir(photoDirectory);
numCams = length(cameraList);
for i = 3:length(cameraList)
    cam = [photoDirectory,cameraList(i).name];
    fileLists{i} = getAllFiles(cam);
end

% Get log of last image processed by this software
logFile = fopen(logDirectory,'r');
data = textscan(logFile,'%s %d %d');
camStart = data{2}+2;
photoStart = data{3}+1;
fclose(logFile);

% Loop through each image file
for camera = camStart:numCams
    
    % get directory information
    currentDir = fileLists{camera}{1};
    fold = strfind(currentDir,'/');
    ext = strfind(currentDir,'.');
    model = currentDir(fold(pDirLen)+1:fold(pDirLen+1)-1);
    dataFile = strcat(statsDirectory,model,'.txt');
    
    for photo = photoStart:length(fileLists{camera})
        
        str = ['Read camera ',num2str(camera-2),' of ', ...
            num2str(numCams-2),' file ',num2str(photo),' of ', ...
            num2str(length(fileLists{camera})),' ', ...
            fileLists{camera}{photo}];
        
        dstr = [datestr(now),': ',str];
        disp(dstr)
        
        % make sure file is a JPEG image before further processing
        if ((size(strfind(fileLists{camera}{photo},'.JPG'),1) > 0) || ...
                (size(strfind(fileLists{camera}{photo},'.jpg'),1) > 0))
        
%         % only process JPEGs in indoors and outdoors directories
%         if (((size(strfind(fileLists{camera}{photo},'.JPG'),1) > 0) || ...
%                 (size(strfind(fileLists{camera}{photo},'.jpg'),1) > 0)) && ...
%                 ((size(strfind(fileLists{camera}{photo},'dark-frame'),1) == 0)) && ...
%                 ((size(strfind(fileLists{camera}{photo},'blue-sky'),1) == 0)))
            
            % read image file
            fimg = ForensicImage(fileLists{camera}{photo});
            
            % get image statistics
            [iStat3,iStat5,iStat7] = fimg.imgStatsHue();
            
            % all image stats for red 3x3 neighborhoods
            iStat3Red = imgStats(iStat3.avg(r),iStat3.sd(r), ...
                iStat3.skew(r),iStat3.kurt(r),iStat3.entropy(r), ...
                iStat3.energy(r),iStat3.pixels(:,:,r), ...
                iStat3.meds(:,:,r),iStat3.errors(:,:,r));
            
            % all image stats for green 3x3 neighborhoods
            iStat3Green = imgStats(iStat3.avg(g),iStat3.sd(g), ...
                iStat3.skew(g),iStat3.kurt(g),iStat3.entropy(g), ...
                iStat3.energy(g),iStat3.pixels(:,:,g), ...
                iStat3.meds(:,:,g),iStat3.errors(:,:,g));
            
            % all image stats for blue 3x3 neighborhoods
            iStat3Blue = imgStats(iStat3.avg(b),iStat3.sd(b), ...
                iStat3.skew(b),iStat3.kurt(b),iStat3.entropy(b), ...
                iStat3.energy(b),iStat3.pixels(:,:,b), ...
                iStat3.meds(:,:,b),iStat3.errors(:,:,b));
            
            % all image stats for red 5x5 neighborhoods
            iStat5Red = imgStats(iStat5.avg(r),iStat5.sd(r), ...
                iStat5.skew(r),iStat5.kurt(r),iStat5.entropy(r), ...
                iStat5.energy(r),iStat5.pixels(:,:,r), ...
                iStat5.meds(:,:,r),iStat5.errors(:,:,r));
            
            % all image stats for green 5x5 neighborhoods
            iStat5Green = imgStats(iStat5.avg(g),iStat5.sd(g), ...
                iStat5.skew(g),iStat5.kurt(g),iStat5.entropy(g), ...
                iStat5.energy(g),iStat5.pixels(:,:,g), ...
                iStat5.meds(:,:,g),iStat5.errors(:,:,g));
            
            % all image stats for blue 5x5 neighborhoods
            iStat5Blue = imgStats(iStat5.avg(b),iStat5.sd(b), ...
                iStat5.skew(b),iStat5.kurt(b),iStat5.entropy(b), ...
                iStat5.energy(b),iStat5.pixels(:,:,b), ...
                iStat5.meds(:,:,b),iStat5.errors(:,:,b));
            
            % all image stats for red 7x7 neighborhoods
            iStat7Red = imgStats(iStat7.avg(r),iStat7.sd(r), ...
                iStat7.skew(r),iStat7.kurt(r),iStat7.entropy(r), ...
                iStat7.energy(r),iStat7.pixels(:,:,r), ...
                iStat7.meds(:,:,r),iStat7.errors(:,:,r));
            
            % all image stats for green 7x7 neighborhoods
            iStat7Green = imgStats(iStat7.avg(g),iStat7.sd(g), ...
                iStat7.skew(g),iStat7.kurt(g),iStat7.entropy(g), ...
                iStat7.energy(g),iStat7.pixels(:,:,g), ...
                iStat7.meds(:,:,g),iStat7.errors(:,:,g));
            
            % all image stats for blue 7x7 neighborhoods
            iStat7Blue = imgStats(iStat7.avg(b),iStat7.sd(b), ...
                iStat7.skew(b),iStat7.kurt(b),iStat7.entropy(b), ...
                iStat7.energy(b),iStat7.pixels(:,:,b), ...
                iStat7.meds(:,:,b),iStat7.errors(:,:,b));
            
            % format for writting data to text file
            format = ['%s %d ', ...
                '1:%f 2:%f 3:%f 4:%f 5:%e 6:%d ', ...
                '7:%f 8:%f 9:%f 10:%f 11:%e 12:%d ', ...
                '13:%f 14:%f 15:%f 16:%f 17:%e 18:%d ', ...
                '19:%f 20:%f 21:%f 22:%f 23:%e 24:%d ', ...
                '25:%f 26:%f 27:%f 28:%f 29:%e 30:%d ', ...
                '31:%f 32:%f 33:%f 34:%f 35:%e 36:%d ', ...
                '37:%f 38:%f 39:%f 40:%f 41:%e 42:%d ', ...
                '43:%f 44:%f 45:%f 46:%f 47:%e 48:%d ', ...
                '49:%f 50:%f 51:%f 52:%f 53:%e 54:%d\n'];
            
            % open data text file for appending data to it
            dataOut = fopen(dataFile,'a');
            
            % append data to data text file
            fprintf(dataOut,format,strrep(fimg.filename,' ','_'),camera-2, ...
                iStat3Red.avg,iStat3Red.sd,iStat3Red.skew, ...
                iStat3Red.kurt,iStat3Red.entropy,iStat3Red.energy, ...
                iStat3Green.avg,iStat3Green.sd,iStat3Green.skew, ...
                iStat3Green.kurt,iStat3Green.entropy,iStat3Green.energy, ...
                iStat3Blue.avg,iStat3Blue.sd,iStat3Blue.skew, ...
                iStat3Blue.kurt,iStat3Blue.entropy,iStat3Blue.energy, ...
                iStat5Red.avg,iStat5Red.sd,iStat5Red.skew, ...
                iStat5Red.kurt,iStat5Red.entropy,iStat5Red.energy, ...
                iStat5Green.avg,iStat5Green.sd,iStat5Green.skew, ...
                iStat5Green.kurt,iStat5Green.entropy,iStat5Green.energy, ...
                iStat5Blue.avg,iStat5Blue.sd,iStat5Blue.skew, ...
                iStat5Blue.kurt,iStat5Blue.entropy,iStat5Blue.energy, ...
                iStat7Red.avg,iStat7Red.sd,iStat7Red.skew, ...
                iStat7Red.kurt,iStat7Red.entropy,iStat7Red.energy, ...
                iStat7Green.avg,iStat7Green.sd,iStat7Green.skew, ...
                iStat7Green.kurt,iStat7Green.entropy,iStat7Green.energy, ...
                iStat7Blue.avg,iStat7Blue.sd,iStat7Blue.skew, ...
                iStat7Blue.kurt,iStat7Blue.entropy,iStat7Blue.energy);
            
            % close data text file
            fclose(dataOut);
            
            % allow software to start where it left off by saving last
            % image file and camera/photo number data to log file
            logFile = fopen(logDirectory,'w');
            fprintf(logFile,'%s %d %d',fimg.filename,camera-2,photo);
            fclose(logFile);
            
        end

    end
    
    % reset photoStart to get all images in next camera directory
    photoStart = 1;

end

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
