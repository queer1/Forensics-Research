%{
Graph image means, standard deviations, skewnesses, and kurtosises.

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
Image stats are saved in text files, one file per camera, in the
statistics directory. Each line in these files contains statistics for an
individual image.
%}
statsDir = '/students/home/visionmatlab/stats/07-11/';
dirs = strfind(statsDir,'/');
pDirLen = length(dirs);

% Get all files for each camera in photos directory
fileLists = getAllFiles(statsDir);
numFiles = length(fileLists);

% Loop through each image file
for camera = 1:numFiles
    
    % get directory information
    filename = fileLists{camera};
    ext = strfind(filename,'.');
    model = filename(dirs(end)+1:ext(end)-1);
    str = ['Opening data file ',filename];
    dstr = [datestr(now),': ',str];
    disp(dstr)
    
    % open data file
    fid = fopen(filename,'rt');
    
    count = 1;
    
    % read file line by line
    while ~feof(fid)
        
        % format for reading data from text file
        format = ['%*s %*d 1:%f 2:%f 3:%f 4:%f 5:%f 6:%f 7:%f 8:%f ', ...
            '9:%f 10:%f 11:%f 12:%f 13:%f 14:%f 15:%f 16:%f 17:%f ', ...
            '18:%f 19:%f 20:%f 21:%f 22:%f 23:%f 24:%f 25:%f 26:%f ', ...
            '27:%f 28:%f 29:%f 30:%f 31:%f 32:%f 33:%f 34:%f 35:%f ', ...
            '36:%f 37:%f 38:%f 39:%f 40:%f 41:%f 42:%f 43:%f 44:%f ', ...
            '45:%f 46:%f 47:%f 48:%f 49:%f 50:%f 51:%f 52:%f 53:%f 54:%f\n'];
        
        % read line from data file (without newline char)
        data = fscanf(fid,format);
        
        % all image stats for red, green and blue 3x3 neighborhoods
        iStat3Red = imgStats(data(1),data(2),data(3),data(4),data(5),data(6),0,0,0);
        iStat3Green = imgStats(data(7),data(8),data(9),data(10),data(11),data(12),0,0,0);
        iStat3Blue = imgStats(data(13),data(14),data(15),data(16),data(17),data(18),0,0,0);
        
        % all image stats for red, green and blue 5x5 neighborhoods
        iStat5Red = imgStats(data(19),data(20),data(21),data(22),data(23),data(24),0,0,0);
        iStat5Green = imgStats(data(25),data(26),data(27),data(28),data(29),data(30),0,0,0);
        iStat5Blue = imgStats(data(31),data(32),data(33),data(34),data(35),data(36),0,0,0);
        
        % all image stats for red, green and blue 7x7 neighborhoods
        iStat7Red = imgStats(data(37),data(38),data(39),data(40),data(41),data(42),0,0,0);
        iStat7Green = imgStats(data(43),data(44),data(45),data(46),data(47),data(48),0,0,0);
        iStat7Blue = imgStats(data(49),data(50),data(51),data(52),data(53),data(54),0,0,0);
        
        % save red 3x3 stats for further processing
        averages(camera,count) = iStat3Red.avg;
        stds(camera,count) = iStat3Red.sd;
        skews(camera,count) = iStat3Red.skew;
        kurts(camera,count) = iStat3Red.kurt;
        count = count+1;

    end
    
    str = ['Closing data file ',filename];
    dstr = [datestr(now),': ',str];
    disp(dstr)
    
    % close data file
    fclose(fid);

end

% plot mean data
avgSize = size(averages);
cams = ones(avgSize(1),avgSize(2));
for i = 1:25
    cams(i,:) = i*cams(i,:);
end
scatter(averages(:),cams(:))
figure;

% plot sd data
scatter(stds(:),cams(:))
figure;

% plot skew data
scatter(skews(:),cams(:))
figure;

% plot kurt data
scatter(kurts(:),cams(:))

% get overall runtime
fprintf('Total duration: %f sec\n',etime(clock,startTime))
