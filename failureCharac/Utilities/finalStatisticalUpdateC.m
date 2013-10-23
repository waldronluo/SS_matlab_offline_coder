% finalStatisticalUpdateC
% This function takes the computed mean values (avgData) for exemplars during an
% assembly trials and then uses them to update the historical averaged
% values (MyR, MzR {MzR1,MzR23}, and FzA {FzA1, FzA2, FzA3} for the mean. 
% This function also updates the values for the upper and the lower bounds. 
%
% Value can be updated in one of three cases:
% (1) The assembly was successful, 
% (2) We are training and the assembly failed, or
% (3) We are testing and the assembly failed.
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
% FolderName        - Folder where data and results are stored
% fcAvgData         - This data is a 3x1 col vector that contains the mean
%                     of the averaged exemplar values during
%                     failureCharacterization. 
% bool_fcData       - boolean. [3x7 structure. 3: xDir, yDir, xYallDir. 7: first two, check whether 
%                     original categories for test show success/failure of task. If failure, a 0 will 
%                     appear in whichever parameter is correlated, implying whether failure comes from xDir,yDir,xYallDir or a comb. 
% successFlag       - If successFlag is true, the assembly has succeeded and there is no failure
% isTrainStruc      - [isTrainingFailure?,XDirTrainingFlag,YDirTrainingFlag,xYallDirTrainingFlag]
%--------------------------------------------------------------------------
% Outputs:
%--------------------------------------------------------------------------
% N/A
%-------------------------------------------------------------------------- 
function finalStatisticalUpdateC(fPath,StratTypeFolder,FolderName,fcAvgData,boolFCData,successFlag,isTrainStruc)

    %% Local Variables
    %isTraining = isTrainStruc(1,1);
    xDirTest    = isTrainStruc(1,2);
    yDirTest    = isTrainStruc(1,3);
    xYallDirTest= isTrainStruc(1,4);
    
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
    
    %% Success always looks at first segement of exemplar data
    successSegment   = 1;
    oneDeviation     = 1;
    twoDeviations    = 2;
    threeDeviations  = 3;
    
    %% Deviation Directions and Segments
    devSum = sum(isTrainStruc(1,2:4));
    if(devSum==1)
        updateSegment = oneDeviation;
    elseif(devSum==2)
        updateSegment = twoDeviations;
    else
        updateSegment = threeDeviations;
    end

    %% Historical Data
    histDataX=-1;
    histDataY=-1;
    histDataL=-1;
    
    %% Snap Assembly Success or Failure
    succeed=0;
    failed =1;
    
    %% Correlation Values as Assigned in performFailureCorrelation.m
    notCorrelated   =0;
    Correlated      =1;
    
    %% Analyze Assemblies that are only Successful Assemblies
    if(successFlag && isTrainStruc(1,1)==0)

            % x-Dir Deviation
            if(xDirTest)
                % Do these if there was no failure, ie boolFCData is zero.
                if(boolFCData(1,1)==succeed)          % Order of indeces is connected to the specific names of variables.
                    % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                    xDevDirAvgMeanData = fcAvgData(1,1);
                    updateSegment=successSegment;
                    histDataX=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,xDevDirAvgMeanData,'MyR.mat',isTrainStruc);
                end
            end
            % y-Dir Deviation
            if(yDirTest)
                if(boolFCData(2,1)==succeed)
                    % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                    yDevDirAvgMeanData = fcAvgData(2,1);
                    updateSegment=successSegment;
                    histDataY=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,yDevDirAvgMeanData,'MzR.mat',isTrainStruc);
                end
            end
           % Yal-Dir Deviation
           if(xYallDirTest)
               if(boolFCData(3,1)==succeed)
                    % 1) Update Historically Averaged Fx.App.AvgMag data as well as counter time for successful assemblies        
                    YallDevDirAvgMeanData = fcAvgData(3,1);
                    updateSegment=successSegment;
                    histDataL=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,YallDevDirAvgMeanData,'Fza.mat',isTrainStruc);
               end               
           end           
    end
	%% If Unsuccessful Assembly: Update historical values for key parameters. Use bool_FCData to identify them.
    %% Failure Training. 
    if(isTrainStruc(1,1)==1)            % Need to hardcode correlation parameters to correctly update historic data. 
                    % In the next section, when we fail but are not training but testing, then we look at the value of the correlation parameters in order to update the correct historic element values.       
            % x-Dir Deviation
            if(xDirTest && boolFCData(1,1)==failed) % If there is failure in the x-direction
                
                % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                xDevDirAvgMeanData = fcAvgData(1,1);                                     
                
                % Update counters, means, upper and lower bounds                
                % Regardless of how many deviation, MyR, is always updated as a oneDeviation exemplar.
                histDataX=updateHistDataC(fPath,StratTypeFolder,successFlag,oneDeviation,xDevDirAvgMeanData,'MyR.mat',isTrainStruc); %updateHistData(fPath,StratTypeFolder,xDevDirAvgMeanData,'MyR.mat');
                    
            end
            
            % y-Dir Deviation
            if(yDirTest && boolFCData(2,1)==failed)  % If there is failure in the y-direction
                
                % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                yDevDirAvgMeanData = fcAvgData(2,1);
                
                % Do these if there was failure, ie fcbool is 1 for correlation param MzR1 located at (2,3)
                if(updateSegment == oneDeviation)                    
                    % Update counters, means, upper and lower bounds
                    histDataY=updateHistDataC(fPath,StratTypeFolder,successFlag,oneDeviation,yDevDirAvgMeanData,'MzR.mat',isTrainStruc);
                    
                % Do these if there was failure, ie fcbool is 1 for correlation param MyR23 located at (2,4)    
                elseif(updateSegment == twoDeviations)
                    % Update counters, means, upper and lower bounds
                    histDataY=updateHistDataC(fPath,StratTypeFolder,successFlag,twoDeviations,yDevDirAvgMeanData,'MzR.mat',isTrainStruc);
                end                               
            end
            
            % Yall-Angle Deviation
            if(xYallDirTest && boolFCData(3,1)==failed)  % If there is failure in the yall-direction
                
                % 1) Update Historically Averaged Fx.App.Min.AvgMag data as well as counter time for successful assemblies        
                YallDevDirAvgMeanData = fcAvgData(3,1);   
                
                %% xYallDirPos
                % Do these if there was failure, ie fcbool is 1 for correlation param FzA1 located at (3,5)
                if(updateSegment == oneDeviation)
                    % Update counters, means, upper and lower bounds
                    histDataL=updateHistDataC(fPath,StratTypeFolder,successFlag,oneDeviation,YallDevDirAvgMeanData,'FzA.mat',isTrainStruc);   
                    
                % Do these if there was failure, ie fcbool is 1 for correlation param FzA2 located at (3,6)
                elseif(updateSegment == twoDeviations)
                    % Update counters, means, upper and lower bounds
                    histDataL=updateHistDataC(fPath,StratTypeFolder,successFlag,twoDeviations,YallDevDirAvgMeanData,'FzA.mat',isTrainStruc);      
                    
                % Do these if there was failure, ie fcbool is 1 for correlation param FzA3 located at (3,7)    
                elseif(updateSegment == threeDeviations)
                    % Update counters, means, upper and lower bounds
                    histDataL=updateHistDataC(fPath,StratTypeFolder,successFlag,threeDeviations,YallDevDirAvgMeanData,'FzA.mat',isTrainStruc);                          
                end                                          
            end
    %% Failure Testing
    elseif(isTrainStruc(1,1)==2)
            % x-Dir Deviation
            if(xDirTest && boolFCData(1,1)==failed) % If there is failure in the x-direction
                % Do these if there was failure, ie fcbool is 1 for correlation param MyR located at (1,2)
                if(boolFCData(1,2)==Correlated)
                    % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                    xDevDirAvgMeanData = fcAvgData(1,1);  
                    updateSegment = oneDeviation;
                
                    % Update counters, means, upper and lower bounds
                    %updateHistData(fPath,StratTypeFolder,xDevDirAvgMeanData,'MyR.mat');
                    histDataX=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,xDevDirAvgMeanData,'MyR.mat',isTrainStruc);
                end
            end
            
            % y-Dir Deviation
            if(yDirTest && boolFCData(2,1)==failed)  % If there is failure in the y-direction
                % Do these if there was failure, ie fcbool is 1 for correlation param MzR1 located at (2,3)
                if(boolFCData(2,3)==Correlated)
                    % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                    yDevDirAvgMeanData = fcAvgData(2,1);
                    updateSegment = oneDeviation;
                    
                    % Update counters, means, upper and lower bounds
                    histDataY=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,yDevDirAvgMeanData,'MzR.mat',isTrainStruc);                    
                    
                % Do these if there was failure, ie fcbool is 1 for correlation param MyR23 located at (2,4)    
                elseif(boolFCData(2,4)==Correlated)
                    % 2) Update Historically Averaged Mz.Rot.Min.AvgMag data as well as counter time for successful assemblies        
                    yDevDirAvgMeanData = fcAvgData(2,1);
                    updateSegment = twoDeviations;
                                                        
                    % Update counters, means, upper and lower bounds
                    histDataY=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,yDevDirAvgMeanData,'MzR.mat',isTrainStruc);
                end
            end
            
            % Yall-Angle Deviation
            if(xYallDirTest && boolFCData(3,1)==failed)  % If there is failure in the yall-direction
                
                %% xYallDirPos
                % Do these if there was failure, ie fcbool is 1 for correlation param FzA1 located at (3,5)
                if(boolFCData(3,5)==Correlated)
                    % 1) Update Historically Averaged Fx.App.Min.AvgMag data as well as counter time for successful assemblies        
                    YallDevDirAvgMeanData = fcAvgData(3,1);
                    updateSegment=oneDeviation; 
                    
                    % Update counters, means, upper and lower bounds
                    histDataL=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,YallDevDirAvgMeanData,'FzA.mat',isTrainStruc);                     
                    
                % Do these if there was failure, ie fcbool is 1 for correlation param FzA2 located at (3,6)
                elseif(boolFCData(3,6)==Correlated)
                    % 2) Update Historically Averaged Fz.App.Min.AvgMag
                    YallDevDirAvgMeanData = fcAvgData(3,1);   
                    updateSegment=twoDeviations; 
                    
                    % Update counters, means, upper and lower bounds
                    histDataL=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,YallDevDirAvgMeanData,'FzA.mat',isTrainStruc);                         
                    
                % Do these if there was failure, ie fcbool is 1 for correlation param FzA3 located at (3,7)    
                elseif(boolFCData(3,7)==Correlated)
                    % 2) Update Historically Averaged Fz.App.Min.AvgMag
                    YallDevDirAvgMeanData = fcAvgData(3,1);     
                    updateSegment=threeDeviations;                    

                    % Update counters, means, upper and lower bounds
                    histDataL=updateHistDataC(fPath,StratTypeFolder,successFlag,updateSegment,YallDevDirAvgMeanData,'FzA.mat',isTrainStruc);                         
                end                                      
            end        
    end
    save(strcat(fPath,StratTypeFolder,FolderName,'/','MATs','/output.mat'),'fcAvgData','boolFCData','histDataX','histDataY','histDataL');
end