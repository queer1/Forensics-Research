%{
Search through all images in photos directory, crop images and save cropped
image in crops directory.

author: Adam Steinberger <http://www.amsteinberger.com/>
date: June 08, 2011
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
Photos must be JPEGs larger than 512 by 512 pixels. The photos directory 
should have a folder for each camera, and images inside of each camera
directory. Crops directory will populate with photos cropped to 512 by 512
pixels. The folder structure will be identical to that of photos directory.
%}
photoDirectory = '/students/home/semistatic/summer2011/photos/';
cropDirectory = '/students/home/semistatic/summer2011/crops/';
dirs = strfind(photoDirectory,'/');
pDirLen = length(dirs);

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
% start at 3 because element 1 is . and element 2 is ..
for camera = 3:numCams
    
    for photo = 1:length(fileLists{camera})
        
        str = ['Read camera ',num2str(camera-2),' of ', ...
            num2str(numCams-2),' file ',num2str(photo),' of ',num2str( ...
            length(fileLists{camera})),' ',fileLists{camera}{photo}];
        
        disp(str)
        
        % make sure file is JPEG image before cropping
        if ((size(strfind(fileLists{camera}{photo},'.JPG'),1) > 0) || ...
                (size(strfind(fileLists{camera}{photo},'.jpg'),1) > 0))
            
            % read image file
            fimg = ForensicImage(fileLists{camera}{photo});
            
            % Crop image file to 512x512
            [len,width,channels] = size(fimg.image);
            rowStart = len/2-256;
            colStart = width/2-256;
            window = [colStart,rowStart,511,511];
            fimgCrop = imcrop(fimg.image,window);
            
            % write cropped image to file
            currentDir = fileLists{camera}{photo};
            dir = strfind(currentDir,'/');
            ext = strfind(currentDir,'.');
            filename = currentDir(dir(end)+1:end);
            
            % get middle directories
            middle = currentDir(dir(pDirLen)+1:dir(end)-1);
            midDir = strfind(middle,'/');
            [l,w] = size(midDir);
            [x,y] = size(middle);
            
            % create first middle directory if it doesn't already exist
            folder = middle(1:midDir(1)-1);
            newDir = strcat(cropDirectory,folder);
            fExists = exist(newDir);
            if (~fExists)
                status = mkdir(newDir);
            end
            
            % create middle middle directories that don't already exist
            for i = 1:w-1
                folder = middle(midDir(i)+1:midDir(i+1)-1);
                newDir = strcat(newDir,'/',folder);
                fExists = exist(newDir);
                if (~fExists)
                    status = mkdir(newDir);
                end
            end

            % create last middle directory if it doesn't already exist
            folder = middle(midDir(end)+1:y);
            newDir = strcat(newDir,'/',folder);
            fExists = exist(newDir);
            if (~fExists)
                status = mkdir(newDir);
            end
            
            % write image to file
            fileLoc = strcat(newDir,'/',filename);
            imwrite(fimgCrop,fileLoc);
            
        end

    end

end

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
