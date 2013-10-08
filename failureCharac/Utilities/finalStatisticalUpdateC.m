% finalStatisticalUpdateC
% This function takes the computed mean values (avgData) for exemplars during an
% assembly trials and then uses them to update the historical averaged
% values (MyR, MzR {MzR1,MzR23}, and FzA {FzA1, FzA2, FzA3} for the mean. 
% This function also updates the values for the upper and the lower bounds. 
%
% At the end, the function also updates a counter. This update is done separately 
% for successful trials and for failure trails. Both failure values and
% successful values are saved in the historical averaged structures:
% MyR (4x2) - only one segment
% [ s_ctr   f_ctr;
%   s_mean  f_mean;
%   s_upper f_upper;
%   s_lower f_lower] = [s1 | f1]
%
% MzR (8x2) - two segements
% [s1   |   f1;
%  s23  |   f23];
%
% FzA (12x2) - three segements
% [ s1  | f1;
%   s2  | f2;
%   s3  | f3];
%
% And we identify if there was a failure based on the bool_FCData struc,
% which is effectively a 3x7 sparse matrix that on its 1st column has a 1 for failed
% conditions a zero for successful conditions, and in the rest of the col's,
% it has 1's only for those exemplars that are correlated with a deviation direction. 
% bool_FCData = 
% MyR: [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]
% MzR: [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]
% FzA: [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]
%
%--------------------------------------------------------------------------
% Inputs:
%--------------------------------------------------------------------------
% fPath             - Path to saved data 
% StratTypeFolder   - type of strategy "ErrorCharac"
% fcAvgData         - This data is a 3x1 col vector that contains the mean
%                     of the averaged exemplar values during
%                     failureCharacterization. 
% bool_fcData       - boolean. [3x7 structure. 3: xDir, yDir, xYallDir. 7: first two, check whether 
%                     original categories for test show success/failure of task. If failure, a 0 will 
%                     appear in whichever parameter is correlated, implying whether failure comes from xDir,yDir,xYallDir or a comb. 
% successFlag       - If successFlag is true, the assembly has succeeded and there is no failure
%--------------------------------------------------------------------------
% Outputs:
%--------------------------------------------------------------------------
% N/A
%-------------------------------------------------------------------------- 
function finalStatisticalUpdateC(fPath,StratTypeFolder,fcAvgData,boolFCData,successFlag)

    %% Local Variables
    global xDirTest;
    global yDirTest;
    global xYallDirTest;
    
    %% Deviation Directions -- Segments
    %  Given that historical averages MyR, MzR, FzA, can have upto 3
    %  different exemplars that encode information for deviations in 1-3
    %  directions, we need a way to pass this information on to the
    %  updateHistDataC function. To this end, we create a variable called
    %  updateSegment that can have 4 different kinds of values: 1 for
    %  success cases, 3 for failure cases. For failure cases,
    %  updateSegment=1 represents the idea that there is only a deviation
    %  in 1 direction; updateSegment=2 indicates deviations in 2
    %  directions, and updateSegment=3 indicates deviations in 3
    %  directions. Success cases only have one exemplar measure, so we will
    %  always pass this value as 1. 
    
    successSegment   = 1;
    oneDeviation     = 1;
    twoDevaitions    = 2;
    threeDeviations  = 3;

    if(successFlag)

            % x-Dir Deviation
            if(xDirTest)
                % Do these if there was no failure, ie boolFCData is zero.
                if(boolFCData(1,1)==0)          % Order of indeces is connected to the specific names of variables.
                    % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                    xDevDirAvgMeanData = fcAvgData(1,1);
                    updateSegment=successSegment;
                    updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,xDevDirAvgMeanData,'MyR.mat');
                end
            end
            % y-Dir Deviation
            if(yDirTest)
                if(boolFCData(2,1)==0)
                    % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                    yDevDirAvgMeanData = fcAvgData(2,1);
                    updateSegment=successSegment;
                    updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,yDevDirAvgMeanData,'MyR.mat');
                end
            end
           % Yal-Dir Deviation
           if(xYallDirTest)
               if(boolFCData(3,1)==0)
                    % 1) Update Historically Averaged Fx.App.AvgMag data as well as counter time for successful assemblies        
                    YallDevDirAvgMeanData = fcAvgData(3,1);
                    updateSegment=successSegment;
                    updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,YallDevDirAvgMeanData,'MyR.mat');
               end               
           end           

	%% If Unsuccessful Assembly: Update historical values for key parameters. Use bool_FCData to identify them.
    else        
            % x-Dir Deviation
            if(xDirTest)
                % Do these if there was failure, ie fcbool is 1.
                if(boolFCData(1,2))
                    % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                    xDevDirAvgMeanData = fcAvgData(1,1);
                    updateSegment = oneDeviation;
                end
                
                % Update counters, means, upper and lower bounds
                %updateHistData(fPath,StratTypeFolder,xDevDirAvgMeanData,'MyR.mat');
                updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,xDevDirAvgMeanData,'MyR.mat');
            end
            
            % y-Dir Deviation
            if(yDirTest)
                if(boolFCData(2,3))
                    % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                    yDevDirAvgMeanData = fcAvgData(2,1);
                    updateSegment = oneDeviation;
                elseif(boolFCData(2,4))
                    % 2) Update Historically Averaged Mz.Rot.Min.AvgMag data as well as counter time for successful assemblies        
                    yDevDirAvgMeanData = fcAvgData(2,2);
                    updateSegment = twoDevaitions;
                end
                
               % Update counters, means, upper and lower bounds
               updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,yDevDirAvgMeanData,'MzR.mat');
            end
            
            % Yall-Angle Deviation
            if(xYallDirTest)
                %% xRollDirPos
                if(boolFCData(3,5))
                    % 1) Update Historically Averaged Fx.App.Min.AvgMag data as well as counter time for successful assemblies        
                    YallDevDirAvgMeanData = fcAvgData(3,1);
                    updateSegment=oneDeviation;                    
                elseif(boolFCData(3,6))
                    % 2) Update Historically Averaged Fz.App.Min.AvgMag
                    YallDevDirAvgMeanData = fcAvgData(3,2);   
                    updateSegment=twoDevaitions;                    
                elseif(boolFCData(3,7))
                    % 2) Update Historically Averaged Fz.App.Min.AvgMag
                    YallDevDirAvgMeanData = fcAvgData(3,2);     
                    updateSegment=threeDeviations;                    
                end
                
                % Update counters, means, upper and lower bounds
                updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,YallDevDirAvgMeanData,'FzA.mat');                            
            end
    end
    save(strcat('/home/vmrguser/Documents/School/Research/AIST/Results/',StratTypeFolder,FolderName,'/','MATs','/output.mat'),'fcAvgData','boolFCData');
end