% Load Data
% Function modified last: Nov. 26, 2012
%
% To prepare for codegen
%
% Arguments removed. Codegen does not support strcat, ispc, 
% Solution: 
%   Assign a hardcoded folder for results to come in.
%       If simulation select your folder of choice.
%       If Hiro robot select: \\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin)
%
% CodeGen does not recognize:
% strcat commands
% if(ispc) remove
%--------------------------------------------------------------------------
function [AD,FD,CP,SD] = loadData(fPath,StratTypeFolder,FolderName)


    % If manually loading adjust here and comment out later
%     AngleData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/Angles.dat';
%     ForceData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/Torques.dat';
%     CartPos         ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/CartPos.dat';
%     StateData       ='/home/grxuser/Documents/School/Research/AIST/Results/ForceControl/ErrorCharac/State.dat';
    
    % If running HIRO Online Experiments use:
    %AngleData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\Angles.dat';
    %ForceData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\Torques.dat';
    %CartPos         ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\CartPos.dat';
    %StateData       ='\\home\\grxuser\\src\\OpenHRP3-0\\Controller\\IOserver\\HRP2STEP1\\bin\\State.dat';


    % Assign the right folder name
    AngleData       =strcat(fPath,StratTypeFolder,FolderName,'/Angles.dat');
    ForceData       =strcat(fPath,StratTypeFolder,FolderName,'/Torques.dat');
    CartPos         =strcat(fPath,StratTypeFolder,FolderName,'/CartPos.dat');
    StateData       =strcat(fPath,StratTypeFolder,FolderName,'/State.dat');
   
    %% Load the data
    AD=load(AngleData);
    FD=load(ForceData);
    CP=load(CartPos); 
    SD=load(StateData);
    
    % Adjust the data length so that it finishes when mating is finished. 
    endTime = SD(5,1);
    
    % Makes sure that endTime is greater than the actual length of the demo. If not, do nothing.
    if(AD(end,1)>endTime)

        % Note that SD(5,1) is hardcoded as some time k later thatn SD(4,1). 
        endTime = floor(endTime/0.005)+1; % The Angles/Torques data is comprised of steps of magnitude 0.0005. Then we round down.

        % Time will be from 1:to the entry denoted by the State Vector in it's 5th entry. 
        AD = AD(1:endTime,:);
        FD = FD(1:endTime,:);
        CP = CP(1:endTime,:);
    end
    
    %% Check to make sure that StateData has a finishing time included
    if(strcmp(StratTypeFolder,'ForceControl/SideApproach/') || strcmp(StratTypeFolder,'ForceControl/ErrorCharac/'))
        if(length(SD)~=5)
            fprintf('StateData does not have 5 entries. You probably need to include the finishing time of the Assembly task in this vector.');
        end
    end
end