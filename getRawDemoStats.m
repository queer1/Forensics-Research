%{
Search through all images in RAWs directory, and save statistics data from
demosaicing RAW images in <cameraDir>.txt

author: Adam Steinberger <http://www.amsteinberger.com/>
date: July 19, 2011
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

diary off;
clear; % clear matlab environment
clc; % clear homescreen
startTime = clock; % keep track of overall runtime
thresh = 0.035; % threshold for edge detection
d = datestr(now);
diary(['getRawDemoStats ',d,'.diary']);

%{
MODIFY THESE DIRECTORIES TO DESIRED LOCATIONS ON EACH PARTICULAR MACHINE
Photos must be 512 by 512 pixel JPEGs. The photos directory should have a
folder for each camera, and images inside of each camera directory. Log file
contains the filename, cam #, and photo # of last photo processed. Computation
will start at next photo if software crashes or is killed. To run software for
first time, you must edit this file so it reads: filename 1 0. Image stats are
saved in text files, one file per camera, in the statistics directory. Each
line in these files contains statistics for an individual image.
%}
photoDirectory = '/students/home/semistatic/summer2011/raws/';
logDirectory = '/students/home/visionmatlab/workspace/iStatRawDemo.log';
statsDirectory = '/students/home/visionmatlab/stats/07-28-rawdemo/';
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
        
        % only process DNGs in indoors and outdoors directories
        if (((size(strfind(fileLists{camera}{photo},'.DNG'),1) > 0) || ...
                (size(strfind(fileLists{camera}{photo},'.dng'),1) > 0)) && ...
                ((size(strfind(fileLists{camera}{photo},'dark-frame'),1) == 0)) && ...
                ((size(strfind(fileLists{camera}{photo},'blue-sky'),1) == 0)))
            
            % read raw image file
            frimg = ForensicRawImage(fileLists{camera}{photo});

            % get image statistics
            iStat = frimg.demosaicImg(thresh);
            
            % remove all NaNs from image stats
            iStat = iStat.clean();
            
            % all image stats for red bayer image
            iStatRed = imgStats(iStat.avg(1),iStat.sd(1), ...
                iStat.skew(1),iStat.kurt(1),iStat.entropy(1), ...
                iStat.energy(1),0,0,0);
            
            % all image stats for green 1 bayer image
            iStatGreen1 = imgStats(iStat.avg(2),iStat.sd(2), ...
                iStat.skew(2),iStat.kurt(2),iStat.entropy(2), ...
                iStat.energy(2),0,0,0);
            
            % all image stats for green 2 bayer image
            iStatGreen2 = imgStats(iStat.avg(3),iStat.sd(3), ...
                iStat.skew(3),iStat.kurt(3),iStat.entropy(3), ...
                iStat.energy(3),0,0,0);
            
            % all image stats for blue bayer image
            iStatBlue = imgStats(iStat.avg(4),iStat.sd(4), ...
                iStat.skew(4),iStat.kurt(4),iStat.entropy(4), ...
                iStat.energy(4),0,0,0);
            
            % open data text file for appending data to it
            dataOut = fopen(dataFile,'a');
            
            % format for writting data to text file
            format = ['%s %d ', ...
                '1:%f 2:%f 3:%f 4:%f 5:%f 6:%f ', ...
                '7:%f 8:%f 9:%f 10:%f 11:%f 12:%f ', ...
                '13:%f 14:%f 15:%f 16:%f 17:%f 18:%f ', ...
                '19:%f 20:%f 21:%f 22:%f 23:%f 24:%f\n'];
                        
            % append data to data text file
            fprintf(dataOut,format,strrep(frimg.filename,' ','_'),camera-2, ...
                iStatRed.avg,iStatRed.sd,iStatRed.skew, ...
                iStatRed.kurt,iStatRed.entropy,iStatRed.energy, ...
                iStatGreen1.avg,iStatGreen1.sd,iStatGreen1.skew, ...
                iStatGreen1.kurt,iStatGreen1.entropy,iStatGreen1.energy, ...
                iStatGreen2.avg,iStatGreen2.sd,iStatGreen2.skew, ...
                iStatGreen2.kurt,iStatGreen2.entropy,iStatGreen2.energy, ...
                iStatBlue.avg,iStatBlue.sd,iStatBlue.skew, ...
                iStatBlue.kurt,iStatBlue.entropy,iStatBlue.energy);
            
            % close data text file
            fclose(dataOut);
            
            % allow software to start where it left off by saving last
            % image file and camera/photo number data to log file
            logFile = fopen(logDirectory,'w');
            fprintf(logFile,'%s %d %d',frimg.filename,camera-2,photo);
            fclose(logFile);
            
        end

    end
    
    % reset photoStart to get all images in next camera directory
    photoStart = 1;

end

% get overall runtime
diary off;
fprintf('Total duration: %f sec\n',etime(clock,startTime))
