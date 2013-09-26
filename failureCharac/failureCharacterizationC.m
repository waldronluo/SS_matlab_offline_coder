%%---------------------- Documentation -------------------------------------
% failureCharacterizationC
% 
% Adapted from failureCharacterization. This program builds on the previous
% one but seeks to provide more context-specific contextualization.
% 2013Sept15- Juan Rojas
%
% Exemplars
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
% Hence avgData will change from being a 4x2 data structure to a 6x3 data
% structure. It's organized by rows. 
% Old AvgData = [MyRot  FzRot; 
%                MzRot  -----;
%                FxAppP FzAppP;
%                FxAppM FzAppM]
% New AvgData = [MyRc     MyRm    MyRu    MyRl;
%                MzR1c    MzR1m   MzR1u   MzR1l;
%                MzR23c   MzR23m  MzR23u  MzR23l;
%                FzA1c    FzA1m   FzA1u   FzA1l;
%                FzA2c    FzA2m   FzA2u   FzA2l;
%                FzA3c    FzA3m   FzA3u   FzA3l];
%
% Similarly the bool_FCData output used to be a 8x9 structure. Where 8
% represented the number of exemplars and 9 had an additional column at the
% beginning to indicate if failure was identified along that deviation. 
% Now we have 6 exemplars. So it's a 6x7 organized by rows, ie:
% [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]  
%
% Averaged Histories
% Before called f_histAvgMyRotAvgMag. Now just MyR or MzR or FzA for
% simplicity. These are not organized by rows but by columns. Successful
% cols on the left and failure cols on the right: [S | F ] .
% MyR has 1 exemplar, MzR has 2 exemplars. FzA has 3 3xemplars. 
%
% MyR (4x2):
% [ s_ctr   f_ctr;
%   s_mean  f_mean;
%   s_upper f_upper;
%   s_lower f_lower]
%
% MzR:
% [s1   |   f1;
%  s23  |   f23];
%
% FzA"
% [ s1  | f1;
%   s2  | f2;
%   s3  | f3];
% 
% X-Direction Deviation Characteristics:
% i)  My magnitude is greater than average
% ii) 1st 1/3 of Fz.Rot exhibits more variation than normal.
%
% Y-Direction Deviation Characteristics:
% i) Mz amplitude is greater than average.
% ii) Whole state analysis.
%
% Yall Angle Direction Devaition:
% i) Fz Amplitude is greater than average
% ii) Look at the last half of the state
%
% Inputs
% fpath:            - path of working directory
% StrategyType      - type of strategy/experiment
% stateData         - col vec to automata state transition times
% motCompsFM        - Motion composition structure: mx11x6 (Num of MCs, 11 elements, 6 axis) 
% mcNumElems        - 6x1 col vec with number of elements of mc's that are not ==-99. Recal that in HLB Layer, there was filling to create a single data structure.
% llbehFM           - Low-level Beh structure: mx17x6 (Num of LLBs, 17 data elements, 6 axis)
% llbehNumElems     - same as mcNumElems
% whichState        - indicates which automata state we want to analyze
%
% Output:
% bool_fcData       - boolean. [3x7 structure. 3: xDir, yDir, xYallDir. 7: first two, check whether 
%                     original categories for test show success/failure of task. If failure, a 0 will 
%                     appear in whichever parameter is correlated, implying whether failure comes from xDir,yDir,xYallDir or a comb. 
% avgData           - array of averaged values [mx2] for xDir, yDir, xYallDir
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
%-------------------------------------------------------------------------
function [bool_fcData,avgData]=failureCharacterizationC(fPath,StratTypeFolder,stateData,motCompsFM,mcNumElems,~,~,whichState)%(fPath,StratTypeFolder,stateData,motCompsFM,mcNumElems,llbehFM,llbehNumElems,whichState)

%% Global Variables
    % FAILURE CHARACTERIZATION TESTING FLAGS. They serve as masks.
    global xDirTest;                            % Enables analysis on xDir, yDir, xRoll.
    global yDirTest;
    global xYallDirTest; 
    global isTraining;
    
    % Create a structure for them
    isTrainStruc=[isTraining, xDirTest, yDirTest, xYallDirTest];

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
    
    % New AvgData = [MyRc     MyRm    MyRu    MyRl;
    %                MzR1c    MzR1m   MzR1u   MzR1l;
    %                MzR23c   MzR23m  MzR23u  MzR23l;
    %                FzA1c    FzA1m   FzA1u   FzA1l;
    %                FzA2c    FzA2m   FzA2u   FzA2l;
    %                FzA2c    FzA2m   FzA2u   FzA2l];    
    numSet      =6;
    numParams   =4;
    totParamSet =6;
    avgData = zeros(numSet,numParams);
    
    % Historical Values
    sCol=1; fCol=2; % Success and failure columns

%% Create outcome data structures for both success and failure: bool_fcData__Dir: [failed_condition1 MyR MzR1 MzR23 FzA1 FzA2 FzA3]                                                                               
    % bool_fcData: [
    bool_fcDataXDir         = [0,ones(1,numSet)];       % MyR only has one subgroup
    
    bool_fcDataYDir         = [0,ones(1,numSet);        % MzR1
                               0,ones(1,numSet)];       % MzR23 
                           
    bool_fcDataXYallDir     = [0,ones(1,numSet);        % FzA1
                               0,ones(1,numSet);        % FzA2
                               0,ones(1,numSet)];       % FzA3

%% Load All Historical Averaged Data (Successful and Failure)
%---XDir-----------------------------------------------------------------------------------------------------
    matName='MyR.mat';    [MyR,~] = loadFCData(fPath,StratTypeFolder,matName);
%---YDir-----------------------------------------------------------------------------------------------------
    matName='MzR.mat';    [MzR,~] = loadFCData(fPath,StratTypeFolder,matName);
%---xYallDirPos-------------------------------------------------------------------------------------------------
    matName='FzA.mat';    [FzA,~] = loadFCData(fPath,StratTypeFolder,matName);
%% Approach State Analysis    
    if(whichState==approachState)

        %% Go through all the analysis states
        for analysis=xDir:xYall % May include later when more case scenarios exist.
        

            %% X-Direction Analysis
            if(analysis==xDir && xDirTest) % xDirTest &associated params are used during a testing phase, so that only that element is being tested (ie a mask). During real trials all params will be true.

                %% Analyze Deviation in X-Direction                       

                %% Test 1st condition: My.Rot              
                % 1) Load SUCCESSFUL historically averaged Mz.Rot.Pos.AvgMag data
                s_histAvgMyRotAvgMag = MyR(:,sCol);                                     % The first column of our data structure holds success values. Pass this for analysis.

                dataStruc = MCs;                dataType = magnitudeType;
                dataThreshold  = [1.20,0.80];   percStateToAnalyze = 0.5;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied
                %[bool_analysisOutcome1,MyR]=
                %analyzeAvgData(motCompsFM,mcNumElems,dataType,stateData,My,rotState,s_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); %Original version; 
                [bool_analysisOutcome1,MyR]= analyzeAvgDataC(motCompsFM,mcNumElems,dataType,stateData,My,rotState,s_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold,isTrainStruc); % outputs bool and then an array struc of 1x4 with counter, mean, upperBound, lowerBound

                %% Compute Outputs
                bool_fcDataXDir(1,1)  = bool_analysisOutcome1;
                avgData(1,:)          = MyR;                                           % Counter, Mean, UpperBound, LowerBound

                %% Analyze 1st restult to find out which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                % Analyze MyRot
                if(bool_analysisOutcome1)
                    dataThreshold  = [1.55,0.65]; % [max,min]                    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/MyR(2,fCol);      if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyR1=1;      else MyR1=0;        end; 
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/MzR1(2,fCol);     if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR1=1;      else MzR1=0;        end;  
                    ratio=AvgMyRotMag/MzR23(6,fCol);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR23=1;     else MzR23=0;       end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/FzA(2,fCol);      if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA1=1; else FzA1=0;    end;  
                    ratio=AvgMyRotMag/FzA(6,fCol);      if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA2=1; else FzA2=0;    end;
                    ratio=AvgMyRotMag/FzA(10,fCol);     if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA3=1; else FzA3=0;    end;  
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    bool_fcDataXDir(1,2:totParamSet+1) = [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3];
                end

            %% Y-Direction Analysis
            elseif(analysis==yDir && yDirTest)
                %% Analyze Deviation in POS AND MIN Y-Direction. If mean is positive, only keep in MzRotPos. If minus, keep in MzR23.          
                % 1) Load SUCCESSFUL historically averaged Mz.Rot.Pos.AvgMag data
                s_histAvgMzRotPosAvgMag = MzR(:,sCol);                                  % The first column of our data structure holds success values. Pass this for analysis.             
                
                %% Test 1st condition: MzR1
                dataStruc = MCs;                dataType = amplitudeType;
                dataThreshold  = [1.30,0.70];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome3,MzR]= analyzeAvgDataC(motCompsFM,mcNumElems,dataType,stateData,Mz,rotState,s_histAvgMzRotPosAvgMag,dataStruc,percStateToAnalyze,dataThreshold,isTrainStruc);
                            

                %% Compute Output BASED ON VALENCY                
                % If the mean is positive, automatically set the boolOutcome of the min task to 0(non failure), and it's mean value equal to the historical value)
                bool_fcDataYDir(1,1)    = bool_analysisOutcome3;
                avgData(2,:)            = MzR;                                          % Counter, Mean, UpperBound, LowerBound

                % Here: Consider returning other data for recovery... Assgin steps for recovery 

                %% Analyze which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                if(bool_analysisOutcome3)
                    dataThreshold  = [3.50,0.30];                   
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=MzR/MyR(2,1);     if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; %[MyRot,~]= analyzeAvgDataC(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold,isTrainStruc); 
                    ratio=MzR/f_histAvgFzRotAvgMag(2,1);     if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=MzR/MzR(2,1);  if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR1=1; else MzR1=0;    end; 
                    ratio=MzR/f_histAvgMzR23AvgMag(2,1);  if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR23=1; else MzR23=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=MzR/FzA(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA1=1; else FzA1=0;    end;  
                    ratio=MzR/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA2=1; else FzA2=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=MzR/f_histAvgFzA3AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA3=1; else FzA3=0;    end;  
                    ratio=MzR/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------               
                    bool_fcDataYDir(1,2:totParamSet+1) = [MyRot,FzRot,MzR1,MzR23,FzA1,FzA2,FzA3,FzAppMin];
                    bool_fcDataYDir(2,2:7) = 1;                   
                end           

            %% XRollPos-Direction Analysis
            elseif(analysis==xYall && xYallDirTest)

                % ---------------------------- Analyze Deviation in xRollPos-Direction -------------------------------------          
                % 1) Load SUCCESSFUL historically averaged Mz.Rot.Pos.AvgMag data
                s_histAvgFzAppPosAvgMag = FzA(:,1);                                        % The first column of our data structure holds success values. Pass this for analysis.        

                %% --------------------------------------------------------------------------------- Test Conditions -------------------------------------------------------------
                % 1) condition: FzA
                dataStruc=MCs;                  dataType = magnitudeType;
                dataThreshold  = [1.20,0.80];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome6,AvgFzAppPosMag]= analyzeAvgDataC(motCompsFM,mcNumElems,dataType,stateData,Fz,approachState,s_histAvgFzAppPosAvgMag,dataStruc,percStateToAnalyze,dataThreshold,isTrainStruc);
                               
                %% Compute Output BASED ON VALENCY of FxAppPos
                
                % If the mean is positive, automatically set the boolOutcome of the min task to 0(non failure), and it's mean value equal to the historical value)
                if(AvgFxAppPosMag>0)                                                                                    % Group FxAppPos and FzAppPos
                    bool_fcDataXYallDir(1,1)    = bool_analysisOutcome5;
                    bool_fcDataXYallDir(2,1)    = bool_analysisOutcome6;
                    avgData(3,:)                = [AvgFxAppPosMag,AvgFzAppPosMag];
                    
                    bool_analysisOutcome7       = 0;
                    bool_analysisOutcome8       = 0;
                    avgData(4,:)                = [0,0]; %[AvgFzA3Mag,AvgFzAppMinMag];
                else                                                                                                    % Group FzA3 and FzAppMin
                    
                %% Min ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    % 3) condition: Fx.AppMin
                    dataStruc = MCs;                dataType  = magnitudeType;
                    dataThreshold  = [1.20,0.80];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                    [bool_analysisOutcome7,AvgFzA3Mag]= analyzeAvgDataC(motCompsFM,mcNumElems,dataType,stateData,Fx,approachState,s_histAvgFzA3AvgMag,dataStruc,percStateToAnalyze,dataThreshold,isTrainStruc);

                    % 4) condition: Fz.AppMin
                    dataStruc=MCs;                  dataType = magnitudeType;
                    dataThreshold  = [1.20,0.80];   percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                    [bool_analysisOutcome8,AvgFzAppMinMag]= analyzeAvgDataC(motCompsFM,mcNumElems,dataType,stateData,Fz,approachState,s_histAvgFzAppMinAvgMag,dataStruc,percStateToAnalyze,dataThreshold,isTrainStruc);

                
                    bool_fcDataXYallDir(3,1)    = bool_analysisOutcome7;
                    bool_fcDataXYallDir(4,1)    = bool_analysisOutcome8;
                    avgData(4,:)                = [AvgFzA3Mag,AvgFzAppMinMag];
                    
                    bool_analysisOutcome5       = 0;
                    bool_analysisOutcome6       = 0;
                    avgData(3,:)                = [0,0]; %[AvgFzA3Mag,AvgFzAppMinMag];
                    
                end
                % Here: Consider returning other data for recovery... Assgin steps for recovery

                %% Analyze which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                % Analyze FxAppPos
                if(bool_analysisOutcome5)
                    dataThreshold  = [1.9,0.00];                    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppPosMag/MyR(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFxAppPosMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;  
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppPosMag/MzR(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR1=1; else MzR1=0;    end;  
                    ratio=AvgFxAppPosMag/f_histAvgMzR23AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR23=1; else MzR23=0;    end;    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppPosMag/FzA(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA1=1; else FzA1=0;    end;  
                    ratio=AvgFxAppPosMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA2=1; else FzA2=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppPosMag/f_histAvgFzA3AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA3=1; else FzA3=0;    end;  
                    ratio=AvgFxAppPosMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------  
                    bool_fcDataXYallDir(1,2:totParamSet+1) = [MyRot,FzRot,MzR1,MzR23,FzA1,FzA2,FzA3,FzAppMin];     
                end 
                % Analyze FzAppPos
                if(bool_analysisOutcome6)
                    dataThreshold  = [2.45,-0.80];                   
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppPosMag/MyR(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFzAppPosMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppPosMag/MzR(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR1=1; else MzR1=0;    end;  
                    ratio=AvgFzAppPosMag/f_histAvgMzR23AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR23=1; else MzR23=0;    end;    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppPosMag/FzA(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA1=1; else FzA1=0;    end;  
                    ratio=AvgFzAppPosMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA2=1; else FzA2=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppPosMag/f_histAvgFzA3AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA3=1; else FzA3=0;    end;  
                    ratio=AvgFzAppPosMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------  
                    bool_fcDataXYallDir(2,2:totParamSet+1) = [MyRot,FzRot,MzR1,MzR23,FzA1,FzA2,FzA3,FzAppMin];
                end                    
                % Analyze FzA3
                if(bool_analysisOutcome7)
                    dataThreshold  = [2.75,0.45];                   
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzA3Mag/MyR(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFzA3Mag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;  
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzA3Mag/MzR(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR1=1; else MzR1=0;    end;  
                    ratio=AvgFzA3Mag/f_histAvgMzR23AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR23=1; else MzR23=0;    end;    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzA3Mag/FzA(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA1=1; else FzA1=0;    end;  
                    ratio=AvgFzA3Mag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA2=1; else FzA2=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzA3Mag/f_histAvgFzA3AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA3=1; else FzA3=0;    end;  
                    ratio=AvgFzA3Mag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------  
                    bool_fcDataXYallDir(3,2:totParamSet+1) = [MyRot,FzRot,MzR1,MzR23,FzA1,FzA2,FzA3,FzAppMin];     
                end 
                % Analyze FzAppMin
                if(bool_analysisOutcome8)
                    dataThreshold  = [2.01,0.50];                    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMinMag/MyR(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFzAppMinMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzRot=1;    else FzRot=0;       end;    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMinMag/MzR(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR1=1; else MzR1=0;    end;  
                    ratio=AvgFzAppMinMag/f_histAvgMzR23AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); MzR23=1; else MzR23=0;    end;    
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMinMag/FzA(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA1=1; else FzA1=0;    end;  
                    ratio=AvgFzAppMinMag/f_histAvgFzAppPosAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA2=1; else FzA2=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMinMag/f_histAvgFzA3AvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzA3=1; else FzA3=0;    end;  
                    ratio=AvgFzAppMinMag/f_histAvgFzAppMinAvgMag(2,1); if( ratio>=dataThreshold(1,1) || ratio <= dataThreshold(1,2) ); FzAppMin=1; else FzAppMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------  
                    bool_fcDataXYallDir(4,2:totParamSet+1) = [MyRot,FzRot,MzR1,MzR23,FzA1,FzA2,FzA3,FzAppMin];
                end            
            end     % End for xDir Analysis                                                 
        end         % End for loop
    end             % End State Analysis
    
    bool_fcData=[bool_fcDataXDir;bool_fcDataYDir;bool_fcDataXYallDir];
end             % End Function