% updateHistStateData
% This function will first update four types of data:
% countes, mean values of historically averaged data, upper bounds, and lower bounds.
% It will also do this for quantities of two types: successful assemblies and failure assemblies. 
%
% The function works by first loadingthe selected historically averaged data, and it then
% performes averaging and counter updating with the new data and then
% saves the data to file. Here is a more detailed description of averaged
% history data structures:
%
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
%--------------------------------------------------------------------------
% Inputs:
%--------------------------------------------------------------------------
% fPath             - path to results
% StratTypeFolder   - folder represening data for strategy used
% isSuccess         - boolean value to represent if the assembly was successful.
% updateSegment     - What part of the exemplar are we updating? 1DevDir
%                     (rows 1:4), 2DevDir (rows 5:8), 3DevDir (rows 9:12)
% data              - a 3x1 col vector with the mean values of averaged
%                     exemplars.
% matName           - name of file where updated historical data should be
%                     saved.
% isTrainStruc      - [isTrainingFailure?,XDirTrainingFlag,YDirTrainingFlag,xYallDirTrainingFlag]

%--------------------------------------------------------------------------
% Output
%--------------------------------------------------------------------------
% histData:        outputs the col vec with ctr and times info
%--------------------------------------------------------------------------
function histData=updateHistDataC(fPath,StratTypeFolder,isSuccess,updateSegment,data,matName)

%% Local variables

    % Columns for historical data
    sCol=1; % Successful column data
    fCol=2; % Failure column data

    % updateSegment Interpretation
    % In our three exemplars MyR, MzR, FzA, we can have exemplar sub-groups
    % to capture the numer of dimensions in which deviation occurs: MyR,
    % MzR {MzR1, MzR23), and FzA {FzA1,FzA2,FzA3}.
    if(updateSegment==1)
        rows=1:4;
    elseif(updateSegment==2)
        rows=5:8;
    elseif(updateSegment==3)
        rows=9:12;
    else
        rows=-1;
    end
    
%% --------------------- SUCCESSFUL DATA UPDATE-------------------------------------------------
    if(isSuccess)
        % xDir-------------------------------------------------------------------------------
        if(strcmp(matName,'MyR.mat') )
            % Load the historical stateData structure
            [MyR,hisDataPath] = loadFCData_C(fPath,StratTypeFolder,matName);

            % Select the correct segment (succ/fail and rows) whose mean is
            % to be updated and upper and lower bounds updated
            MyR(rows,sCol) = averageHistData(data,MyR(rows,sCol)); % [current mean data,historical averaged data]

            % Save statData.mat to file
            save(strcat(hisDataPath),'MyR');

        % yDirPos----------------------------------------------------------------------------                   
        elseif(strcmp(matName,'MzR.mat') )
            % Load the historical stateData structure
            [MzR,hisDataPath] = loadFCData_C(fPath,StratTypeFolder,matName);

             MzR(rows,sCol)= averageHistData(data,MzR(rows,sCol));

            % Save statData.mat to file
            save(strcat(hisDataPath),'MzR');

        % YallDirPos----------------------------------------------------------------------------        
        elseif(strcmp(matName,'FzA.mat') )
            % Load the historical stateData structure
            [FzA,hisDataPath] = loadFCData_C(fPath,StratTypeFolder,matName);

             FzA(rows,sCol)= averageHistData(data,FzA(rows,sCol));

            % Save statData.mat to file
            save(strcat(hisDataPath),'FzA');
        else
            histData=-1;
        end
        
    %% --------------------- FAILURE DATA UPDATE-------------------------------------------------        
    else
% xDir-------------------------------------------------------------------------------
        if(strcmp(matName,'MyR.mat') )
            % Load the historical stateData structure
            [MyR,hisDataPath] = loadFCData_C(fPath,StratTypeFolder,matName);

            MyR(rows,fCol) = averageHistData(data,MyR(rows,fCol));

            % Save statData.mat to file
            save(strcat(hisDataPath),'MyR');

        % yDirPos----------------------------------------------------------------------------                   
        elseif(strcmp(matName,'MzR.mat') )
            % Load the historical stateData structure
            [MzR,hisDataPath] = loadFCData_C(fPath,StratTypeFolder,matName);

             MzR(rows,fCol)= averageHistData(data,MzR(rows,fCol));

            % Save statData.mat to file
            save(strcat(hisDataPath),'MzR');

        % YallDirPos----------------------------------------------------------------------------        
        elseif(strcmp(matName,'FzA.mat') )
            % Load the historical stateData structure
            [FzA,hisDataPath] = loadFCData_C(fPath,StratTypeFolder,matName);

             FzA(rows,fCol)= averageHistData(data,FzA(rows,fCol));

            % Save statData.mat to file
            save(strcat(hisDataPath),'FzA');
        else
            histData=-1;
        end        
        
    end
    
end