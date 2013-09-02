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
                                    % Load/Save. Doesn't matter what file name a .mat file is saved with, it will load/save with whatever name was in the workspace.
                                    % To make things simple, keep the file name the same as the variable name in the workspace 
              
%% Look for success and failure with Personalize the data variable
    % XDir---------------------------------------------------------------------        
    if(strcmp(matName,    's_histMyRotAvgMag.mat') )
        data=struc(1).s_histMyRotAvgMag;  
    elseif(strcmp(matName,'s_histFzRotAvgMag.mat') )
        data=struc(1).s_histFzRotAvgMag; 
    % YDir---------------------------------------------------------------------        
    elseif(strcmp(matName,'s_histMzRotPosAvgMag.mat') )
        data=struc(1).s_histMzRotPosAvgMag;
    elseif(strcmp(matName,'s_histMzRotMinAvgMag.mat') )
        data=struc(1).s_histMzRotMinAvgMag;        
    % XRollDir-----------------------------------------------------------------                
    elseif(strcmp(matName,'s_histFxAppAvgMag.mat') )
        data=struc(1).s_histFxAppAvgMag;   
    elseif(strcmp(matName,'s_histFzAppAvgMag.mat') )
        data=struc(1).s_histFzAppAvgMag;  
        
     %% Failure
    % XDir---------------------------------------------------------------------             
    elseif(strcmp(matName,'f_histMyRotAvgMag.mat') )
        data=struc(1).f_histMyRotAvgMag;   
    elseif(strcmp(matName,'f_histFzRotAvgMag.mat') )
        data=struc(1).f_histFzRotAvgMag;   
    % YDir---------------------------------------------------------------------                
    elseif(strcmp(matName,'f_histMzRotPosAvgMag.mat') )
        data=struc(1).f_histMzRotPosAvgMag;   
    elseif(strcmp(matName,'f_histMzRotMinAvgMag.mat') )
        data=struc(1).f_histMzRotMinAvgMag;           
    % XRollDir-----------------------------------------------------------------           
    elseif(strcmp(matName,'f_histFxAppAvgMag.mat') )
        data=struc(1).f_histFxAppAvgMag;           
    elseif(strcmp(matName,'f_histFzAppAvgMag.mat') )
        data=struc(1).f_histFzAppAvgMag;   
    else
        data=-1;
    end
       
end