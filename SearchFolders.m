%% This program looks in the directory where this .m file is located for 
%  all folders containing relevant data. The data is plotted on a figure, 
%  which is then saved in the 'Plots' folder by its spec number.

%% Clear the command window, clear all variables in the workspace, and 
% close all figures that are open
clc;
clear all;
close all;

%% See if there's a 'Plots' folder. If not, create it
if exist('Plots') == 0
    mkdir 'Plots';
end

%% Find all folders starting with 'spec'
dataFolderInfo = dir(strcat('spec','*'));

% count of plots
count = 0;

%% For each folder that matches the specified naming convention
for i = 1:size(dataFolderInfo)
    % Get folder name
    folder = dataFolderInfo(i).name;
    
    % Get the spec #
    folderParts = strsplit(folder, 'c');
    specNo = folderParts{2};
    
    % Go into folder
    cd(strcat('.\', folder));
    
    % Open the file (must be in same directory as this matlab script)
    dataFile = fopen('specimen.dat');
    
    % If there is a file named specimen.dat in this folder
    if dataFile ~= -1
        % Header information
        for line = 1:5
            lineText = fgetl(dataFile);
            %disp(lineText);
        end

        % Initialize 1x3 array of zero's
        theData = zeros(1,3);

        % Start at the first DATA row
        row = 1;

        % While the end of the file is not yet reached
        while (~feof(dataFile))
            % Read a line in the file
            dataLine = fgetl(dataFile);

            % If the line isn't empty
            if length(dataLine) ~= 0
                % Split the string up whenever a space is seen
                stringArray = strsplit(dataLine, ' ');

                % Store each dimension (x,y,z) in our data array
                for col = 1:3
                    theData(row,col) = str2num(stringArray{col});
                end  
                row = row + 1;
            else % The line is empty...throw away the next 3 lines, they're junk
                for i = 1:3
                    fgetl(dataFile);
                end
            end
        end    

        % Prints the status in the command window
        disp(strcat('Spec', {' '}, specNo, ' Done...'));
        
        % Close all open files (really just 1 open at a time)
        fclose('all');

        % Get the first and second columns for plotting
        x = theData(:,1); % Time
        y = theData(:,2); % Force

        % Do the plotting
        f = figure; % New figure handle
        plot(x,y);
        title(strcat('Force vs. Time: Spec', {' '}, specNo));
        xlabel('Time [s]');
        ylabel('Force [lbf]');
        
        % Increment plot count
        count = count + 1;
        
        % Save the figure in Plots folder then go back to base directory
        cd('.\..\Plots');
        saveas(f, strcat('spec_',specNo,'_plot'), 'jpeg');
    else
        disp(strcat('Spec', {' '}, specNo, ' has no data file...skipping...'));
    end
    
    % Go back to base directory
    cd('.\..');
end

% Close all figures
close all;
% Print notification
disp(strcat('All Done...', num2str(count), ' new plots have been created in the Plots folder'));
