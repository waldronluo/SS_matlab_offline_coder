%% loadTrainingVariance
% This function loads covariances computed for a given automata state for
% each force axis for each llb accross 7 trials. 
%
% There will be 3 6x6 matrices; where the 3 matrices correspond to the
% automata states: Rotation, Snap, and Mating, and the 6x6 represent the
% force axes as rows and the columns as the six llbs.
% 
% Output:
% Is a structure containing an mxn matrix for each automata state with the
% the covariances for each force axes for each llb. 
%%
function [Var_Rot Var_Snap Var_Mat] = loadTrainingVariance

%% Define Path
    Path = 'C:\\Documents and Settings\\suarezjl\\My Documents\\MATLAB\\Active Sensing\\Probability\\20120525-TrainingData\\Variance';
    
%% Load Data    
    % Rotation
    Var_Rot = load(strcat(Path,'\\Variance-Rot-FxMz-FX-AL.mat')); % When loading data is saved to a structure. 
    Var_Rot = Var_Rot.Sheet1;                                     % Extract information from structure into easy-to-understand variable name
    
    % Snap
    Var_Snap = load(strcat(Path,'\\Variance-Snap-FxMz-FX-AL.mat'));
    Var_Snap = Var_Snap.Sheet1;
    
    % Mating
    Var_Mat = load(strcat(Path,'\\Variance-Mat-FxMz-FX-AL.mat'));
    Var_Mat = Var_Mat.Sheet1;     
end