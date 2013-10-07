%--------------------------------------------------------------------------
% loadMyRotAvgRMSData
% Loads historical exemplar loadHistStateData by formulating the right path
% structure and loading from MATLABs mat data struc. See details of
% historical data below:
%--------------------------------------------------------------------------
% Averaged Histories
%------------------------------------------------------------------------------------------
% Before called f_histAvgMyRotAvgMag. Now just MyR or MzR or FzA for
% simplicity. These are not organized by rows but by columns. Successful
% cols on the left and failure cols on the right: [S | F ] .
% MyR has 1 exemplar, MzR has 2 exemplars. FzA has 3 3xemplars. 
%
% Each exemplar will have its own statistics for the failure case, but there
% will only be one overall statistic for the success case. That is to say,
% when we fail, there may be deviation in 1 direction, or in 2, or in 3.
% However, when we succeed there is no deviation. So we keep a general
% computation of success values and a more specific computation of failure
% cases according to the number of deviation directions. 
%
%--------------------------------------------------------------------------
% MyR (4x2)
%--------------------------------------------------------------------------
% [ s_ctr   f_ctr;
%   s_mean  f_mean;
%   s_upper f_upper;
%   s_lower f_lower] = [s1 | f1]
%
%--------------------------------------------------------------------------
% MzR (8x2)
%--------------------------------------------------------------------------
% [s    |   f1;
%  ---  |   f23];
%
%--------------------------------------------------------------------------
% FzA (12x2)
%--------------------------------------------------------------------------
% [ s   | f1;
%   --- | f2;
%   --- | f3];
%
%--------------------------------------------------------------------------
% Inputs
%--------------------------------------------------------------------------
% fPath:                    working directory
% StratTypeFolder:          correct path according to strategy
% matName:                  string name of mat to be loaded
% 
%--------------------------------------------------------------------------
% Outputs
%--------------------------------------------------------------------------
% data:          historical exemplar data that includes counters, means,
%                upper bounds and lower bounds for both successful and
%                failure cases. 
% dataPath:      path where the historical My.Rot.AvgRMS data of successful assemblies can be found
%--------------------------------------------------------------------------
function [data,dataPath] = loadFCData_C(fPath,StratTypeFolder,matName)

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
    if(strcmp(matName,    'MyR.mat') )
        data=struc(1).MyR;  
    
    % YDirPos---------------------------------------------------------------------        
    elseif(strcmp(matName,'MzR.mat') )
        data=struc(1).MzR;           
        
    % YallDirPos-----------------------------------------------------------------                
    elseif(strcmp(matName,'FzA.mat') )
        data=struc(1).FzA;
    else
        data=-1;
    end
       
end