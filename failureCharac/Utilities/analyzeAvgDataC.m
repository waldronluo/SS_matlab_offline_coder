% Documentation
%
% This function is part of the Failure Characterization for the PA-RCBHT
% approach. For Failure Characterization we use exemplars to understand
% whether or not we can detect failure in the task.
%
% This function will compute the average value of magnitudes in a specified
% range and then see if that value is within the bounds of the pertinent
% successful exemplars. If so, it will flag the exemplar as 0 indicating
% "not a failure," otherwise 1.
%
% Inputs
% data                  - can be motion compositions (motCompsFM) or low-level behaviors (llbehFM)
% numElems              - 6x1 col vec with number of elements that have not been used for padding. Those numbers have a value of -99.
% dataType              - what type of data do we want to average? Magnitude, RMS, or Amplitude
% stateData             - col vec of automata state transitions
% whichAxis             - what axis do we want to work with: Fx-Mz
% whichState            - Approach/Rotation/Insertion/Mating (have not added PA10 PivotApproach functionality)
% histAvgData           - Before called f_histAvgMyRotAvgMag. Now just MyR or MzR or FzA for simplicity. These 
%                         are not organized by rows but by columns. Successful cols on the left and failure cols 
%                         on the right: [S | F ] . MyR has 1 exemplar, MzR has 2 exemplars. FzA has 3 3xemplars.
% dataFlag              - Indicates if using motionCompositions or LLBs.
% percStateToAnalyze    - how much of the state do you want to look at
% dataThreshold         - 1x2 array of thresholds. [max,min]. They determine if averaged data is too far out from success levels
%
%
% Outputs
% analysisOutcome       - Did the current average surpass the threshold level? If threshold surpassed, then set outcome to 1, which indicates the task has failed.
% AvgDataSum            - This is the averaged data of sums of dataType. Used to update history later.
%
%
%--------------------------------------------------------------------------
% For Reference: Structures and Labels
%--------------------------------------------------------------------------
% Primitives = [bpos,mpos,spos,bneg,mneg,sneg,cons,pimp,nimp,none]      % Represented by integers: [1,2,3,4,5,6,7,8,9,10]  
% statData   = [dAvg dMax dMin dStart dFinish dGradient dLabel]
%--------------------------------------------------------------------------
% actionLbl  = ['a','i','d','k','pc','nc','c','u','n','z'];             % Represented by integers: [1,2,3,4,5,6,7,8,9,10]  
% motComps   = [nameLabel,avgVal,rmsVal,amplitudeVal,
%               p1lbl,p2lbl,
%               t1Start,t1End,t2Start,t2End,tAvgIndex]
%--------------------------------------------------------------------------
% llbehLbl   = ['FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N'];                 % Represented by integers: [1,2,3,4,5,6,7,8]
% llbehStruc:  [actnClass,...
%              avgMagVal1,avgMagVal2,AVG_MAG_VAL,
%              rmsVal1,rmsVal2,AVG_RMS_VAL,
%              ampVal1,ampVal2,AVG_AMP_VAL,
%              mc1,mc2,
%              T1S,T1_END,T2S,T2E,TAVG_INDEX]
%--------------------------------------------------------------------------
% Averaged Histories
%
% MyR (4x2):
% [ s_ctr   f_ctr;
%   s_mean  f_mean;
%   s_upper f_upper;
%   s_lower f_lower]
%
% MzR (8x2):
% [s1   |   f1;
%  s23  |   f23];
%
% FzA (12x2):
% [ s1  | f1;
%   s2  | f2;
%   s3  | f3];
%--------------------------------------------------------------------------
function [analysisOutcome,meanSum]= analyzeAvgDataC(data,numElems,dataType,stateData,whichAxis,whichState,histAvgData,dataFlag,percStateToAnalyze,dataThreshold,isTrainStruc)


    %% Local Variables
        
    % States
    startState=whichState; 
    endState=startState+1;
    
    % Data Type
    MCs=2;  % Flag to indicate we are using motion compositions
    LLBs=3; % Flag to indicate we are using low-level behaviors    
    
    % Data Types
    magnitudeType   = 1;
    rmsType         = 2;
    AmplitudeType   = 3;
    
    % MC and LLB Data Struc Indeces
    mcMagIndex=2;   mcRMSIndex=3;   mcAmpIndex=4; % See note on amplitude update below.
    llbMagIndex=4;  llbRMSIndex=7;  llbAmpIndex=10;
    
    % Deviation Indeces (used with isTrainStruc
    %xDir=2; yDir=3; xYallDir=4;
    
    % Indeces for success/failure cols in historical averages
    %sCol=1; %fCol=2;
    
    % %% Create index values for historical averaged data: counters, means, upper_bounds, and lower_bounds
    % % MyR
    % MyRc=1; MyRm=2; MyR_UB=3; MyR_LB=4;
    % 
    % % MzR
    % % 1D
    % MzR1c=1;  MzR1m=2;  MzR1_UB=3;  MzR1_LB=4;
    % % 2D or 3D
    % MzR23c=5; MzR23m=6; MzR23_UB=7; MzR23_LB=8;
    % 
    % % FzA
    % % 1D
    % FzA1c=1; FzA1m=2;  FzA1_UB=3;  FzA1_LB=4;
    % FzA2c=5; FzA2m=6;  FzA2_UB=7;  FzA2_LB=8;
    % FzA3c=9; FzA3m=10; FzA3_UB=11; FzA3_LB=12;  
    %MyRm=2; MzR1m=2; MzR23m=6; FzA1m=2; FzA2m=6; FzA3m=10;

    % Standard indeces
    Fz=3; My=5; Mz=6;
    
    
    % Check threshold size
    if(length(dataThreshold)==1)
        dataThreshold = [dataThreshold,dataThreshold]; %[max,min]
    end
    
    %% Assign Correct Indeces Based on Type of Incoming Data
    if(dataFlag==MCs)
        
        % Set the data index (appropriate to Motion Compositions) to the correct value according to the data we want to average
        if(dataType==magnitudeType);        dataIndex=mcMagIndex; 
        elseif(dataType==rmsType);          dataIndex=mcRMSIndex; % 2013Sept rms changed to max value of signal. 
        elseif(dataType==AmplitudeType);    dataIndex=mcAmpIndex; 
        end
                                    
    elseif(dataFlag==LLBs)
        
        % Set the data index (appropriate to Motion Compositions) to the correct value according to the data we want to average
        if(dataType==magnitudeType);        dataIndex=llbMagIndex; 
        elseif(dataType==rmsType);          dataIndex=llbRMSIndex; 
        elseif(dataType==AmplitudeType);    dataIndex=llbAmpIndex; 
        end        
    end
    
    %% Find starting index and ending index: In this case we only want to examine the first 1/2 of the Rot State. Modify the stateData here to represent that
    % Positive Percentage: Looking from start to finish. 
    if(percStateToAnalyze>0)
        diff = ( (stateData(endState,1)-stateData(startState,1))*percStateToAnalyze);
        endStateShort = stateData(startState,1) + diff; % Add to START state
        stateData(endState,1) = endStateShort;
        
    % Negative Percentage (Want to analyze the latter part of a state)
    else
        diff = ( (stateData(endState,1)-stateData(startState,1))*percStateToAnalyze);
        startStateLate = stateData(endState,1) + diff;  % Subtract from END state
        stateData(startState,1) = startStateLate;
    end
    [startStateIndex,endStateIndex]=getStateIndeces(data,numElems,stateData,whichAxis,whichState,dataFlag);

    %% Compute Average Values for Magnitudes or Max-Min vals for Amplitudes.
    
    % 1. First set the start index for computing means. 
    if(endStateIndex-startStateIndex>2)
        startStateIndex=startStateIndex+1; % Avoid transition points
    end
    
    % Set the end index
    if(percStateToAnalyze==1.0)
        if(endStateIndex>startStateIndex+2)
            endStateIndex=endStateIndex-1;
        end
    end
    
    % 2a. Compute Amplitude's maximum and minium values.
    if(dataFlag==MCs && dataType==AmplitudeType)
        
        maxValVec=data(startStateIndex:endStateIndex,mcRMSIndex,whichAxis); % Retrieve the maximum values recorded for each of the elements.
        maxVal = max(maxValVec);                                            % Retrieve the maximum of all values
        
        amplVec = data(startStateIndex:endStateIndex,dataIndex,whichAxis);  % Retrieve amplitude values
        minValVec=maxValVec-amplVec;                                        % Subtract amplitude values from max values
        minVal = min(minValVec);                                            % Retrieve the minimum of all values
        meanSum=abs(maxVal-minVal);                                         % Compute maximum amplitude and place it in the variable meanSum to keep compatibility
        
    % 2b. Compute the average value for magnitudes.
    else        
        meanSum=mean(data(startStateIndex:endStateIndex,dataIndex,whichAxis)); % Compute the average LLbs in Fz.Rot
    end

    %% Compute ratio of successful absolute values of meanData and historicalMeanData to see if average is > or < threshold: indicates success or failure
    % Note that to compute the ratio we must select the correct index for
    % the MyR or MzR or FzA historical data structure (they have different
    % sizes).
    %
    % isTrainStruc = [trainingFlag,xDirFlag,yDirFlag,xYallDirFlag]
    % If training we can directly know where to look, if testing we have to
    % test all possibilities.
    
    % Compute the sum of indeces 2:4 to get a quick understanding of
    % whether we are dealing with 1,2,3 deviations during training.
    
    %% Success Training
    if(isTrainStruc(1,1)==0)
        devSum=sum(isTrainStruc(2:4));
        [meanIndex,~,col]=returnDivergenceMeanSubGroupDataC(devSum,whichAxis);
         
        if(abs(histAvgData(2,1))>0)
            ratio=abs(meanSum)/abs(histAvgData(meanIndex,col));    % In 1D analysis, this index is always the same
            percUB=dataThreshold(1,1)/histAvgData(meanIndex,col);
            percLB=dataThreshold(1,2)/histAvgData(meanIndex,col);
        else
            ratio=0;
        end
        
        %% Compute Outcome Based on Ratio Value
        % If greater than top threshold=failure; if less than bottom threshold=failure

        if( ratio >= percUB || ratio <= percLB ) % dataThreshold is [max,min]
            analysisOutcome = 1;    % If true, then failure.

            % If we need to consider other factors, it would happen here. I.e.:
            % Time at which failure happens?
            % Magnitudes?
        else
            analysisOutcome=0;
        end 
    
    %% Failure Training
    elseif(isTrainStruc(1,1)==1)
        
        % Compute sum to identify training
        devSum=sum(isTrainStruc(2:4));
        
        %% 1D Deviation Training - all structures (MyR,MzR,FzA) have the same mean index.
%       if(devSum==1)
            
        % Compute the correct mean index to return. For 1D MyR=2; MzR=2; FzA=2
        % Compute the correct mean index to return. For 2D MyR=2; MzR=6; FzA=6
        % Compute the correct mean index to return. For 3D MyR=2; MzR=6; FzA=10
        [meanIndex,~,col]=returnDivergenceMeanSubGroupDataC(devSum,whichAxis);
        %meanIndex=returnDivergenceMeanIndexC(devSum,whichAxis);

        if(abs(histAvgData(meanIndex,col))>0)
            ratio=abs(meanSum)/abs(histAvgData(meanIndex,col));    % In 1D analysis, this index is always the same
            percUB=dataThreshold(1,1)/histAvgData(meanIndex,col);
            percLB=dataThreshold(1,2)/histAvgData(meanIndex,col);                
        else
            ratio=0;
        end
%       end
            
%         %% 2D Deviation Training
%         % Possible combinations (x,y); (x,xYall); (y,xYall)
%         % More possibilities, for MyR use same index as ID, for MzR and FzA, use mean value 2. z
%         elseif(devSum==2)
%             
%             % Compute the right mean index to return. For MyR=2; MzR=6; FzA=6
%             meanIndex=returnDivergenceMeanIndexC(devSum,whichAxis);
%             
%             % xDir,yDir Deviation - 2Dim           
%             if(isTrainStruc(xDir) && isTrainStruc(yDir))                
%                 if(abs(histAvgData(meanIndex,1))>0)
%                     ratio=abs(meanSum)/abs(histAvgData(meanIndex,1));
%                 else
%                     ratio=0;
%                 end 
%             end        
%             
%         %% 3D Deviation Training
%         elseif(devSum==3)
%             
%             % Compute the right mean index to return. For MyR=2; MzR=6; FzA=10
%             meanIndex=returnDivergenceMeanIndexC(devSum,whichAxis);
%             
%             % xDir,yDir,xYallDir  Deviation - 2Dim
%             if(isTrainStruc(xDir) && isTrainStruc(yDir) && isTrainStruc(xYallDir))
%                 if(abs(histAvgData(meanIndex,1))>0)
%                     ratio=abs(meanSum)/abs(histAvgData(meanIndex,1));
%                 else
%                     ratio=0;
%                 end
%             end
%             
%         end    
        %% Compute Outcome Based on Ratio Value
        % If greater than top threshold=failure; if less than bottom threshold=failure
        if( ratio >= percUB || ratio <= percLB ) % dataThreshold is [max,min]
            analysisOutcome = 1;    % If true, then failure.

            % If we need to consider other factors, it would happen here. I.e.:
            % Time at which failure happens?
            % Magnitudes?
        else
            analysisOutcome=0;
        end  
    
    %% Failure Testing: 
    % Must test if we are working with MyR,MzR,FzA.
    % Then, look for all corresponding mean indeces for 1D, 2D, 3D. 
    % If either is successful,then return, correlation tests will be 
    % performed later. Otherwise return failure.
    
    %% MyR 1st and Only Exemplar. Testing for Deviation in X-Diretion.
    else
        devSum=sum(isTrainStruc(2:4));
        if(whichAxis==My)
            [meanIndex,~,col]=returnDivergenceMeanSubGroupDataC(devSum,whichAxis);
            if(abs(histAvgData(meanIndex,1))>0)                      % Check we don't have an empty value
                ratio=abs(meanSum)/abs(histAvgData(meanIndex,col));    % In 1D analysis, this index is always the same
                percUB=dataThreshold(1,1)/histAvgData(meanIndex,col);
                percLB=dataThreshold(1,2)/histAvgData(meanIndex,col);
            else
                ratio=0;
            end        
            
            % Compute ratio for exemplar: greaterthanqual_max or lessthanequal_min
            if( ratio >= percUB || ratio <= percLB ); analysisOutcome = 1;    % If true, then failure.
            else   analysisOutcome=0;
            end
            
        %% MzR. 2 exemplars. Testing for Deviation in Y-Direction.
        %% MzR1 1st Exemplar. 
        elseif(whichAxis==Mz)
            [meanIndex,~,col]=returnDivergenceMeanSubGroupDataC(devSum,whichAxis);
            if(abs(histAvgData(meanIndex,1))>0)
                ratio=abs(meanSum)/abs(histAvgData(meanIndex,col));    % In 1D analysis, this index is always the same
                percUB=dataThreshold(1,1)/histAvgData(meanIndex,col);
                percLB=dataThreshold(1,2)/histAvgData(meanIndex,col);
            else
                ratio=0;
            end
            
            % Compute ratio for 1st exemplar
            if( ratio >= percUB || ratio <= percLB );   analysisOutcome = 1;    % If true, then failure.
            
            % If the ratio did not fail for this measure, try checking the
            % exemplar for deviation in both YDir and YallDir: MzR23
            else   
                
            %% MzR23 2nd Exemplar.
                 [meanIndex,~,col]=returnDivergenceMeanSubGroupDataC(devSum,whichAxis);
                if(abs(histAvgData(meanIndex,col))>0)
                    ratio=abs(meanSum)/abs(histAvgData(meanIndex,col));    % In 1D analysis, this index is always the same
                    percUB=dataThreshold(1,1)/histAvgData(meanIndex,col);
                    percLB=dataThreshold(1,2)/histAvgData(meanIndex,col);
                else
                    ratio=0;
                end

                if( ratio >= percUB || ratio <= percLB ); analysisOutcome = 1;    % If true, then failure.
                else    analysisOutcome=0;
                end            
                
            end   
          
        %% FzA. 3 exemplars. Testing for Deviation in Yall-Direction.
        %% FzA 1st Exemplar.
        elseif(whichAxis==Fz)            
            [meanIndex,~,col]=returnDivergenceMeanSubGroupDataC(devSum,whichAxis);
            if(abs(histAvgData(meanIndex,col))>0)
                ratio=abs(meanSum)/abs(histAvgData(meanIndex,col));    % In 1D analysis, this index is always the same
                percUB=dataThreshold(1,1)/histAvgData(meanIndex,col);
                percLB=dataThreshold(1,2)/histAvgData(meanIndex,col);
            else
                ratio=0;
            end
            
            % Compute ratio for 1st exemplar
            if( ratio >= percUB || ratio <= percLB );   analysisOutcome = 1;    % If true, then failure.
            
            %% FzA 2nd Exemplar.
            % If not successful, then look at 2nd exemplar
            else   
                [meanIndex,~,col]=returnDivergenceMeanSubGroupDataC(devSum,whichAxis);
                if(abs(histAvgData(meanIndex,col))>0)
                    ratio=abs(meanSum)/abs(histAvgData(meanIndex,col));    % In 1D analysis, this index is always the same
                    percUB=dataThreshold(1,1)/histAvgData(meanIndex,col);
                    percLB=dataThreshold(1,2)/histAvgData(meanIndex,col);
                else
                    ratio=0;
                end

                if( ratio >= percUB || ratio <= percLB ); analysisOutcome = 1;    % If true, then failure.
                    
                    
                %% FzA 3rd Exemplar.
                % If not successful, then return analysisOutcome 0.
                else    
                    [meanIndex,~,col]=returnDivergenceMeanSubGroupDataC(devSum,whichAxis);
                    if(abs(histAvgData(meanIndex,col))>0)
                        ratio=abs(meanSum)/abs(histAvgData(meanIndex,col));    % In 1D analysis, this index is always the same
                        percUB=dataThreshold(1,1)/histAvgData(meanIndex,col);
                        percLB=dataThreshold(1,2)/histAvgData(meanIndex,col);
                    else
                        ratio=0;
                    end

                    if( ratio >= percUB || ratio <= percLB ); analysisOutcome = 1;    % If true, then failure.
                    else analysisOutcome=0;                        
                    end  
                end                           
            end            
        end
    end                
end