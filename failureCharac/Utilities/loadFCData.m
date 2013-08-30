%--------------------------------------------------------------------------
% loadMyRotAvgRMSData
% Loads the data structure loadHistStateData by formulating the right path
% structure and loading from MATLABs mat data struc.
%
% Inputs
% fPath:                    working directory
% StratTypeFolder:          correct path according to strategy
% matName:                  string name of mat to be loaded
% 
% Outputs
% data:          a col vec w/ 2 elements: (i) counter, (ii) rms avg valu for all LLBs in My.Rot
% hisStateDataPath:         path where the historical My.Rot.AvgRMS data of successful assemblies can be found
%--------------------------------------------------------------------------
function [data,dataPath] = loadFCData(fPath,StratTypeFolder,matName)

    % Set the path where the historicalData will be saved
    histMyDataDir = 'TrainingData/';
    
    % Create the entire working path
    dataPath = strcat(fPath,StratTypeFolder,histMyDataDir,matName);
    
    % Load the data
    struc=load(dataPath,'-mat');  % 1x2 data struc. 1st element is a counter, 2nd is a col vector with 5 states and average transitions times
                                    % No need to provide an output arg. It
                                    % will load with the name with which it
                                    % was saved: histStateData 
              
    % Personalize the data variable
    if( strcmp(matName,'histMyRotAvgMag.mat') )
        data=struc(1).histMyRotAvgMag;
    elseif(strcmp(matName,'histFzRotAvgMag.mat') )
        data=struc(1).histFzRotAvgMag;
    else
        data=-1;
    end
       
end