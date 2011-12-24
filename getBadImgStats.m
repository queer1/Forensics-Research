%{
Search through all images in crops directory, and save statistics data from
images in <cameraDir>.txt THAT SHOULD GIVE POOR RESULTS

author: Adam Steinberger <http://www.amsteinberger.com/>
date: August 04, 2011
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
logDirectory = '/students/home/visionmatlab/workspace/iStatBad.log';
statsDirectory = '/students/home/visionmatlab/stats/08-04-bad/';
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
        
        % make sure file is a JPEG image before further processing
        if ((size(strfind(fileLists{camera}{photo},'.JPG'),1) > 0) || ...
                (size(strfind(fileLists{camera}{photo},'.jpg'),1) > 0))
            
            % read image file
            fimg = ForensicImage(fileLists{camera}{photo});
            
            % get image color channels
            [red,green,blue] = fimg.getColorCh();
            
            % get corner and center pixels from all 3 color channels
            redPts = [red(1,1) red(1,512) red(512,1) red(512,512) red(256,256)];
            greenPts = [green(1,1) green(1,512) green(512,1) green(512,512) green(256,256)];
            bluePts = [blue(1,1) blue(1,512) blue(512,1) blue(512,512) blue(256,256)];
            
            % format for writting data to text file
            format = ['%s %d ', ...
                '1:%d 2:%d 3:%d 4:%d 5:%d ', ...
                '6:%d 7:%d 8:%d 9:%d 10:%d ', ...
                '11:%d 12:%d 13:%d 14:%d 15:%d\n'];
            
            % open data text file for appending data to it
            dataOut = fopen(dataFile,'a');
            
            % append data to data text file
            fprintf(dataOut,format,strrep(fimg.filename,' ','_'),camera-2, ...
                redPts(1),redPts(2),redPts(3),redPts(4),redPts(5), ...
                greenPts(1),greenPts(2),greenPts(3),greenPts(4),greenPts(5), ...
                bluePts(1),bluePts(2),bluePts(3),bluePts(4),bluePts(5));
            
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
