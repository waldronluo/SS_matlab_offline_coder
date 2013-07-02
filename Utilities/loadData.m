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

    % Load the data
    AD=load(AngleData);
    FD=load(ForceData);
    CP=load(CartPos); 
    SD=load(StateData);
end