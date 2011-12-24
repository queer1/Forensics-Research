%{
Convert RAW 16bit images to 8bit images

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 21, 2011
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
 
clear; % clear matlab environment
clc; % clear homescreen
startTime = clock; % keep track of overall runtime

%{
MODIFY THESE DIRECTORIES TO DESIRED LOCATIONS ON EACH PARTICULAR MACHINE
Photos must be Digital Negative (DNG) Raw image files. The photos 
directory should have a folder for each camera, and images inside of each
camera directory.
%}
photoDirectory = '/students/home/semistatic/summer2011/raws/';
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
for camera = 1:numCams
    
    for photo = 1:length(fileLists{camera})
        
        str = ['Read camera ',num2str(camera-2),' of ',num2str( ...
            numCams-2),' file ',num2str(photo),' of ',num2str(length( ...
            fileLists{camera})),' ',fileLists{camera}{photo}];
        dstr = [datestr(now),': ',str];
        disp(dstr)
        
        if ((size(strfind(fileLists{camera}{photo},'.dng'),1) > 0) || ...
                (size(strfind(fileLists{camera}{photo},'.DNG'),1) > 0))
            
            % read raw image file
            frimg = ForensicRawImage(fileLists{camera}{photo});
            
            % Get 8-bit raw image
            image8 = frimg.imraw8();
            
            % create filename for new png image
            currentDir = fileLists{camera}{photo};
            fold = strfind(currentDir,'/');
            ext = strfind(currentDir,'.');
            model = currentDir(fold(pDirLen)+1:fold(pDirLen+1)-1);
            file = currentDir(fold(pDirLen+1)+1:ext(end)-1);
            pngFile = strcat(photoDirectory,model,'/',file,'.png');
            
            % Write data to text file
            imwrite(image8,pngFile,'PNG');
            
        end

    end

end

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
