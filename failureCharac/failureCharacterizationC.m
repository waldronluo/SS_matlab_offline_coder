%%---------------------- Documentation -------------------------------------
% failureCharacterizationC
% 
% Adapted from failureCharacterization. This program builds on the previous
% one but seeks to provide more context-specific contextualization.
% 2013Sept15- Juan Rojas
%
%------------------------------------------------------------------------------------------
% Exemplars
%------------------------------------------------------------------------------------------
% xDir: MyRotAvgMag = MyR
% yDir: MzRotAvgAmp = MzR
% Yall: FzAppAvgAmp = FzA
%
% Each exemplar can be devided by deviation subgroups: deviations in 1,2 or 3 directions. 
% The decision to divide into exemplars comes from the statistical
% breakdown results done in the 2013ICRA paper. They are as follows:
% MyR = keep one exemplar for all deviations: MyR.
% MzR = 2 subgroups. 1 for 1-dir devs. Anoter for 2- and3-dir devs: MzR1 and MzR23
% FzA = 3 subgroups. 1,1-dir; 1-2dir; 1-3dir: FzA1, FzA2, FzA3.
%
% Statistics
% Before we only kept a record of exemplar mean values. In this program we
% keep record of 4 data types: counter, means, upper bounds, and lower bounds. 
%
%------------------------------------------------------------------------------------------
% AvgData
%------------------------------------------------------------------------------------------
% Hence avgData will change from being a 4x2 data structure to a 6x3 data
% structure. It's organized by rows. 
% Old AvgData = [MyRot  FzRot; 
%                MzRot  -----;
%                FxAppP FzAppP;
%                FxAppM FzAppM]
%
% New AvgData = [MyRc     MyRm    MyRu    MyRl;
%                MzR1c    MzR1m   MzR1u   MzR1l;
%                MzR23c   MzR23m  MzR23u  MzR23l;
%                FzA1c    FzA1m   FzA1u   FzA1l;
%                FzA2c    FzA2m   FzA2u   FzA2l;
%                FzA3c    FzA3m   FzA3u   FzA3l];
%
%------------------------------------------------------------------------------------------
% bool_FCData
%------------------------------------------------------------------------------------------
% Similarly the bool_FCData output used to be a 8x9 structure. Where 8
% represented the number of exemplars and 9 had an additional column at the
% beginning to indicate if failure was identified along that deviation. 
%
% In the new structure, we consider 3 exemplars, but exemplars with
% sub-groups. Exemplary MyR only has one subexemplar. Exemplar MzR has two
% sub-exemplars: MzR1 and MzR23. And exemplar FzA has three sub-exemplars:
% FzA1, FzA2, and FzA3. 
%
% So the new bool_FCData is effectively a 3x7 boolean sparse matrix that
% will contain 1's only for those exemplars that are correlated with a deviation direction. 
% New bool_FCData = 
% MyR: [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]
% MzR: [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]
% FzA: [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]
%
%------------------------------------------------------------------------------------------
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
% MyR (4x2):
%--------------------------------------------------------------------------
% [ s_ctr   f_ctr;
%   s_mean  f_mean;
%   s_upper f_upper;
%   s_lower f_lower] = [s | f1]
%
%--------------------------------------------------------------------------
% MzR (8x2):
%--------------------------------------------------------------------------
% [s    |   f1;
%  ---  |   f23];
%
%--------------------------------------------------------------------------
% FzA (12x2):
%--------------------------------------------------------------------------
% [ s   | f1;
%   --- | f2;
%   --- | f3];
% 
%------------------------------------------------------------------------------------------
% X-Direction Deviation Characteristics:
%------------------------------------------------------------------------------------------
% i)  My magnitude is greater than average
% ii) 1st 1/3 of Fz.Rot exhibits more variation than normal.
%
%------------------------------------------------------------------------------------------
% Y-Direction Deviation Characteristics:
%------------------------------------------------------------------------------------------
% i) Mz amplitude is greater than average.
% ii) Whole state analysis.
%
%------------------------------------------------------------------------------------------
% Yall Angle Direction Devaition:
%------------------------------------------------------------------------------------------
% i) Fz Amplitude is greater than average
% ii) Look at the last half of the state
%
%------------------------------------------------------------------------------------------
% Inputs
%------------------------------------------------------------------------------------------
% fpath:            - path of working directory
% StrategyType      - type of strategy/experiment
% stateData         - col vec to automata state transition times
% motCompsFM        - Motion composition structure: mx11x6 (Num of MCs, 11 elements, 6 axis) 
% mcNumElems        - 6x1 col vec with number of elements of mc's that are not ==-99. Recal that in HLB Layer, there was filling to create a single data structure.
% llbehFM           - Low-level Beh structure: mx17x6 (Num of LLBs, 17 data elements, 6 axis)
% llbehNumElems     - same as mcNumElems
% whichState        - indicates which automata state we want to analyze
%
%------------------------------------------------------------------------------------------
% Output:
%------------------------------------------------------------------------------------------
% bool_fcData       - boolean. [3x7 structure. 3: xDir, yDir, xYallDir. 7: first two, check whether 
%                     original categories for test show success/failure of task. If failure, a 0 will 
%                     appear in whichever parameter is correlated, implying whether failure comes from xDir,yDir,xYallDir or a comb. 
% avgData           - array of mean averaged values [xDir_mean;yDir_mean;xYallDir_mean];
% histAvgStruc      - the historical averaged values [ctr,mean,UB,LB] will
%                     be used in snapVerification->finalStatisticalUpdate->updateHistData_C. 
%------------------------------------------------------------------------------------------
% For Reference: Structures and Labels
%------------------------------------------------------------------------------------------
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
%-------------------------------------------------------------------------
function [bool_fcData,avgData]=failureCharacterizationC(fPath,StratTypeFolder,...               % Former prototype: %(fPath,StratTypeFolder,stateData,motCompsFM,mcNumElems,llbehFM,llbehNumElems,whichState)
                                                        stateData,motCompsFM,mcNumElems,...
                                                        ~,~,...
                                                        whichState,isTrainStruc)

%% Global Variables
    % FAILURE CHARACTERIZATION TESTING FLAGS. They serve as masks.    
    %isTraining= isTrainStruc(1,1);
    xDirTest     = isTrainStruc(1,2);                           % Enables analysis on xDir, yDir, xRoll.
    yDirTest     = isTrainStruc(1,3);
    xYallDirTest = isTrainStruc(1,4); 

%% Local Variables

    % Automata State
    approachState=1; rotState=2; %snapState=3;matState=4;

    % Divergence Direction Analysis. 
    xDir=1;yDir=2;xYall=3;%yRotAnalysis=5;zRotAnalysis=6;
    
    % Standard indeces
    Fz=3; My=5; Mz=6;
    
    % DataStructures
    MCs=2;  % Flag to indicate we are using motion compositions
%   LLBs=3; % Flag to indicate we are using low-level behaviors
    
    % Data Types
    magnitudeType   = 1;
%   maxValType      = 2;
    amplitudeType   = 3;    
    
    %% Average Data    
    numSet      =6;
%   numParams   =4;
    totParamSet =6;
%   avgData = zeros(numSet,numParams);
    avgData = zeros(3,1); % Holds 3 mean values computed for the averages of exemplars MyR, MzR, and FzA
    
    % Historical Values
    sCol=1; %fCol=2; % Success and failure columns
    %sRow=1:4;

    %% Create outcome data structures for both success and failure: bool_fcData__Dir: [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]                                                                               
    % bool_fcData: [
    bool_fcDataXDir         = [0,ones(1,numSet)];       % MyR only has one subgroup
    bool_fcDataYDir         = [0,ones(1,numSet)];        % MzR1
                               %0,ones(1,numSet)];       % MzR23                            
    bool_fcDataXYallDir     = [0,ones(1,numSet)];        % FzA1
                               %0,ones(1,numSet);        % FzA2
                               %0,ones(1,numSet)];       % FzA3

%% Load All Historical Averaged Data (Successful and Failure)
%---XDir-----------------------------------------------------------------------------------------------------
    matName='MyR.mat';    [MyR,~] = loadFCData_C(fPath,StratTypeFolder,matName); % loadFCData return data struc and path
%---YDir-----------------------------------------------------------------------------------------------------
    matName='MzR.mat';    [MzR,~] = loadFCData_C(fPath,StratTypeFolder,matName);
%---xYallDirPos-------------------------------------------------------------------------------------------------
    matName='FzA.mat';    [FzA,~] = loadFCData_C(fPath,StratTypeFolder,matName);
    
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
%% Approach State Analysis    
    if(whichState==approachState)

        %% Go through all the analysis states
        for analysis=xDir:xYall % May include later when more case scenarios exist.
        

            %% X-Direction Analysis
            if(analysis==xDir && xDirTest) % xDirTest &associated params are used during a testing phase, so that only that element is being tested (ie a mask). During real trials all params will be true.                      

                %% Test My.Rot              
                % Load SUCCESSFUL historically averaged My.Rot.AvgMag data
                s_histAvgMyRotAvgMag = MyR;%(sRow,sCol);                                         % The first column of our data structure holds success values. Pass this for analysis.

                dataStruc = MCs;                                        dataType = magnitudeType;
                SucDataThreshold  = s_histAvgMyRotAvgMag(3:4,sCol)';    percStateToAnalyze = 0.5;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied
                %[bool_analysisOutcome1,MyR]    = analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,My,rotState,s_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); %Original version; 
                [bool_analysisOutcome1,MyR_mean]= analyzeAvgDataC(motCompsFM,mcNumElems,dataType,stateData,My,rotState,s_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,SucDataThreshold,isTrainStruc); % outputs bool and then an array struc of 1x4 with counter, mean, upperBound, lowerBound

                %% Compute Outputs
                bool_fcDataXDir(1,1)  = bool_analysisOutcome1;
                avgData(1,1)          = MyR_mean;                                           % Counter, Mean, UpperBound, LowerBound

                %% Analyze MyRot to find out which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.             
                if(bool_analysisOutcome1)
                    [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3]=performFailureCorrelationC(MyR_mean,MyR,MzR,FzA,isTrainStruc,My);                    
                    bool_fcDataXDir(1,2:totParamSet+1) = [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3];
                end

            %% Y-Direction Analysis
            elseif(analysis==yDir && yDirTest)
         
                % Load SUCCESSFUL historically averaged Mz.Rot.AvgAmp data                
                s_histAvgMzRotPosAvgMag = MzR;%(row,col);                                  % The first column of our data structure holds success values. Pass this for analysis.             
                
                %% Test MzR (MzR1 and MzR23 will be automatically distinguished in analyzeAvgDataC). 
                dataStruc = MCs;                                        dataType = amplitudeType;
                dataThreshold  = s_histAvgMzRotPosAvgMag(3:4,sCol)';    percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome2,MzR_mean]= analyzeAvgDataC(motCompsFM,mcNumElems,dataType,stateData,Mz,rotState,s_histAvgMzRotPosAvgMag,dataStruc,percStateToAnalyze,dataThreshold,isTrainStruc);                            

                %% Compute Outputs 
                bool_fcDataYDir(1,1)    = bool_analysisOutcome2;
                avgData(2,1)            = MzR_mean;                                     % Counter, Mean, UpperBound, LowerBound

                %% Analyze MzRot to find out which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.             
                if(bool_analysisOutcome2)
                    [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3]=performFailureCorrelationC(MzR_mean,MyR,MzR,FzA,isTrainStruc,Mz);               
                    bool_fcDataYDir(1,2:totParamSet+1) = [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3];                  
                end           

            %% xYall-Direction Analysis
            elseif(analysis==xYall && xYallDirTest)

                % Load SUCCESSFUL historically averaged Fz.App.Avg.Amp data
                s_histAvgFzAppPosAvgMag = FzA;%(sRow,sCol);                                % The first column of our data structure holds success values. Pass this for analysis.        

                %% Test FzA (FzA1, FzA2, FzA3 will be automatically distinguished in analyzeAvgDataC). 
                dataStruc=MCs;                                          dataType = magnitudeType;
                dataThreshold  = s_histAvgFzAppPosAvgMag(3:4,sCol)';    percStateToAnalyze = -0.33;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome3,FzA_mean]= analyzeAvgDataC(motCompsFM,mcNumElems,dataType,stateData,Fz,approachState,s_histAvgFzAppPosAvgMag,dataStruc,percStateToAnalyze,dataThreshold,isTrainStruc);
                               
                %% Compute Outputs
                bool_fcDataXYallDir(1,1)    = bool_analysisOutcome3;
                avgData(3,1)                = FzA_mean;                    

                %% Analyze FzApp to find out which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.             
                if(bool_analysisOutcome3)
                    [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3]=performFailureCorrelationC(FzA_mean,MyR,MzR,FzA,isTrainStruc,Fz);   
                    bool_fcDataXYallDir(1,2:totParamSet+1) = [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3];   
                end            
            end     % End for xDir Analysis                                                 
        end         % End for loop
    end             % End State Analysis
    
    %% Configure the Output Structures: bool_fcData and avgData
    bool_fcData=[bool_fcDataXDir;bool_fcDataYDir;bool_fcDataXYallDir];
end             % End Function