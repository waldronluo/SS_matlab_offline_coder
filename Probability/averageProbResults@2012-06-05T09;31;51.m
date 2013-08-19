function [hlbBelief hlbPriorRot hlbPriorSnp hlbPriorMat] = averageProbResults

%% Load Data

    % 1) Define computer path
    if(ispc)
        Path = 'C:\Documents and Settings\suarezjl\My Documents\School\Research\AIST\Results\ForceControl\'; 
        TOP  = 'SideApproach';
    % Linux
    else
       Path = '\\home\\juan\\Documents\\Results'; 
       % QNX
       % '\\home\\vmrguser\\Documents\\Results'; 
    end

    % Folder Name (stringed) array. 
    % Use the command dir on the top folder to get a struc for each file/folder
    % in the top folder.
    % First two elements are to be ignored, then use a loop and check the
    % 'isdir' property to check if it is a folder. If so, store the name if the
    % FolderName array. Note that this can stringed array can be easily be
    % implemented because all names have the same length.

    FolderNames = cell(1,1);
    
    % Save the folder structure into listing
    listing = dir(strcat(Path,TOP));

    % Get the size
    r = size(listing);
    
    % Iterate through listing struc and save names of directories. Start at i=3.
    for i=3:r(1)
       % If we have a directry
       if(listing(i,1).isdir == 1)
           % If successful attempt
           temp = listing(i,1).name;
           if(length(temp)<28)
               continue; % skip this one
           elseif(strcmp(temp(1,28),'S'))
               % Store the name
               FolderNames{i-2,1} = temp;
           end
       end
    end

    % Get thesize of FolderNames
    r = size(FolderNames);
    
%%      Create buffers as big as the number of files
    hlbBeliefMat   = zeros(r(1),1);
    hlbPriorRotMat = zeros(r(1),1);
    hlbPriorSnpMat = zeros(r(1),1);
    hlbPriorMatMat = zeros(r(1),1);    
        
%% Load .mat files and states 

    % Probability Path
    ProbData        = '\\Probability\\Data\\';
    
    % Prob Files
    hlbBeliefFile   = 'hlbBeliefMat.mat';

    hlbPriorRotFile = 'hlbPriorRotMat.mat';
    hlbPriorSnpFile = 'hlbPriorSnpMat.mat';    
    hlbPriorMatFile = 'hlbPriorMatMat.mat';
    
    
%%  Load Data for each folder
    for i=1:r(1)
        hlbBeliefMat(i)   = load(strcat(Path,FolderNames(i),ProbData,hlbBeliefFile));
        hlbBeliefMat(i)   = Sheet1;
        
        hlbPriorRotMat(i) = load(strcat(Path,FolderNames(i),ProbData,hlbPriorRotFile));
        hlbPriorRotMat(i) = Sheet1;
        
        hlbPriorSnpMat(i) = load(strcat(Path,FolderNames(i),ProbData,hlbPriorSnpFile));
        hlbPriorSnpMat(i) = Sheet1;
        
        hlbPriorMatMat(i) = load(strcat(Path,FolderNames(i),ProbData,hlbPriorMatFile));        
        hlbPriorMatMat(i) = Sheet1;
    end
    
%% Compute the average for each 

    hlbBelief   = sum(hlbBeliefMat)/r(1);
    hlbPriorRot = sum(hlbPriorRotMat)/r(1);
    hlbPriorSnp = sum(hlbPriorSnpMat)/r(1);
    hlbPriorMat = sum(hlbPriorMatMat)/r(1);    
end