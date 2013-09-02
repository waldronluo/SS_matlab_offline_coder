%%---------------------- Documentation -------------------------------------
% failureCharacterization
%
% X-Direction Deviation Characteristics:
% i)  My magnitude is greater than average
% ii) 1st 1/3 of Fz.Rot exhibits more variation than normal.
%
% Inputs
% fpath:            - path of working directory
% StrategyType      - type of strategy/experiment
% stateData         - col vec to automata state transition times
% motCompsFM        - Motion composition structure: mx11x6 (Num of MCs, 11 elements, 6 axis) 
% llbehFM           - Low-level Beh structure: mx17x6 (Num of LLBs, 17 data elements, 6 axis)
% whichState        - indicates which automata state we want to analyze
%
% Output:
% bool_fcData       - boolean. [3x7 structure. 3: xDir, yDir, xRollDir. 7: first two, check whether 
%                     original categories for test show success/failure of task. If failure, a 0 will 
%                     appear in whichever parameter is correlated, implying whether failure comes from xDir,yDir,xRollDir or a comb. 
% avgData           - array of averaged values [mx2] for xDir, yDir, xRollDir
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
function [bool_fcData,avgData]=failureCharacterization(fPath,StratTypeFolder,stateData,motCompsFM,llbehFM,whichState)

%% Global Variables
    % FAILURE CHARACTERIZATION TESTING FLAGS. They serve as masks.
    global xDirTest;                            % Enables analysis on xDir, yDir, xRoll.
    global yDirTest;
    global xRollDirTest;    

%% Local Variables

    % Set outcome to SUCCESS
    analysisOutcome = 0;

    % Automata State
    approachState=1; rotState=2; %snapState=3;matState=4;

    % Divergence Direction Analysis. 
    xDir=1;yDir=2;xRot=3;%yRotAnalysis=5;zRotAnalysis=6;
    
    % Standard indeces
    Fx=1; Fz=3; My=5; Mz=6;
    
    % DataStructures
    MCs=2;  % Flag to indicate we are using motion compositions
    LLBs=3; % Flag to indicate we are using low-level behaviors
    
    % Data Types
    magnitudeType   = 1;
%   rmsType         = 2;
    amplitudeType   = 3;    

%% Create outcome data structures for both success and failure: bool_fcData__Dir: [failed_condition1? FxAppAvgMag FzAppAvgMag MzRotPosAvgMag MzRotMinAvgMag FxAppAvgMag FzAppAvgMag;
%%                                                                                 failed_condition2? FxAppAvgMag FzAppAvgMag MzRotPosAvgMag MzRotMinAvgMag FxAppAvgMag FzAppAvgMag]
    bool_fcDataXDir         = [0,ones(1,6); 0 ones(1,6)];
    bool_fcDataYDir         = [0,ones(1,6); 0 ones(1,6)];
    bool_fcDataXRollDir     = [0,ones(1,6); 0 ones(1,6)];

%% Load All FAILURE Historical Averaged Data First
%---XDir-----------------------------------------------------------------------------------------------------
    matName='f_histMyRotAvgMag.mat';    [f_histAvgMyRotAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName);
    matName='f_histFzRotAvgMag.mat';    [f_histAvgFzRotAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName);
%---YDir-----------------------------------------------------------------------------------------------------
    matName='f_histMzRotPosAvgMag.mat'; [f_histAvgMzRotPosAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);
    matName='f_histMzRotMinAvgMag.mat'; [f_histAvgMzRotMinAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);    
%---XRollDir-------------------------------------------------------------------------------------------------
    matName='f_histFxAppAvgMag.mat';    [f_histAvgFxAppAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName);
    matName='f_histFzAppAvgMag.mat';    [f_histAvgFzAppAvgMag,~]    = loadFCData(fPath,StratTypeFolder,matName); 
%% Approach State Analysis    
    if(whichState==approachState)

        %% Go through all the analysis states
        for analysis=xDir:xRot % May include later when more case scenarios exist.
        

            %% X-Direction Analysis
            if(analysis==xDir && xDirTest) % xDirTest &associated params are used during a testing phase, so that only that element is being tested (ie a mask). During real trials all params will be true.

                %% Analyze Deviation in X-Direction            
                % 1) Load SUCCESSFUL historically averaged My.Rot.AvgMag data
                matName='s_histMyRotAvgMag.mat'; [s_histAvgMyRotAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);

                % Load successful historically averaged Fz.Rot.AvgMag data
                matName='s_histFzRotAvgMag.mat'; [s_histAvgFzRotAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);           

                %% Test 1st condition: My.Rot
                dataStruc = MCs;        dataType = magnitudeType;
                dataThreshold  = 0.20;  percStateToAnalyze = 0.5;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied
                [bool_analysisOutcome1,AvgMyRotMag]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,s_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                %% Test 2nd condition: Fz.Rot
                dataStruc=MCs;          dataType = magnitudeType;
                dataThreshold  = 0.15;  percStateToAnalyze = 0.5;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied
                [bool_analysisOutcome2,AvgFzRotMag]= analyzeAvgData(motCompsFM,dataType,stateData,Fz,rotState,s_histAvgFzRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                %% Compute Outputs
                bool_fcDataXDir(1:2,1)  = [bool_analysisOutcome1;bool_analysisOutcome2];
                avgData(1,:)            = [AvgMyRotMag,AvgFzRotMag];                       % First Row

                %% Analyze 1st restult to find out which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                % Analyze MyRot
                if(bool_analysisOutcome1)
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MyRot=1;    else MyRot=0;       end; %[MyRot,~]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); 
                    ratio=AvgMyRotMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzRot=1;    else FzRot=0;       end; 
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgMyRotMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotMin=1; else MzRotMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMyRotMag/f_histAvgFxAppAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FxApp=1;    else FxApp=0;       end;  
                    ratio=AvgMyRotMag/f_histAvgFzAppAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzApp=1;    else FzApp=0;       end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    bool_fcDataXDir(1,2:7) = [MyRot,FzRot,MzRotPos,MzRotMin,FxApp,FzApp];
                
                % Analyze FzRot
                elseif(bool_analysisOutcome2)
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzRotMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MyRot=1;    else    MyRot=0;    end; %[MyRot,~]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); 
                    ratio=AvgFzRotMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzRot=1;    else    FzRot=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzRotMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgFzRotMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotMin=1; else MzRotMin=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzRotMag/f_histAvgFxAppAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FxApp=1;    else    FxApp=0;    end;  
                    ratio=AvgFzRotMag/f_histAvgFzAppAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzApp=1;    else    FzApp=0;    end;
                    %-----------------------------------------------------------------------------------------------------------------------------------------------
                    bool_fcDataXDir(2,2:7) = [MyRot,FzRot,MzRotPos,MzRotMin,FxApp,FzApp];                    
                end

            %% Y-Direction Analysis
            elseif(analysis==yDir && yDirTest)
                %% Analyze Deviation in POS AND MIN Y-Direction. If mean is positive, only keep in MzRotPos. If minus, keep in MzRotMin.          
                % 1) Load SUCCESSFUL historically averaged Mz.Rot.Pos.AvgMag data
                matName='s_histMzRotPosAvgMag.mat'; [s_histAvgMzRotPosAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);

                % 2) Load SUCCESSFUL historically averaged Mz.Rot.Min.AvgMag data
                matName='s_histMzRotMinAvgMag.mat'; [s_histAvgMzRotMinAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);                
                
                %% Test 1st condition: Mz.Rot.Pos
                dataStruc = MCs;        dataType = magnitudeType;
                dataThreshold  = 0.20;  percStateToAnalyze = 0.5;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome3,AvgMzRotPosMag]= analyzeAvgData(motCompsFM,dataType,stateData,Mz,rotState,s_histAvgMzRotPosAvgMag,dataStruc,percStateToAnalyze,dataThreshold);
                
                %% Test 2nd condition: Mz.Rot.Min
                dataStruc = MCs;        dataType = magnitudeType;
                dataThreshold  = 0.20;  percStateToAnalyze = 0.5;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome4,AvgMzRotMinMag]= analyzeAvgData(motCompsFM,dataType,stateData,Mz,rotState,s_histAvgMzRotMinAvgMag,dataStruc,percStateToAnalyze,dataThreshold);                

                %% Compute Output BASED ON VALENCY
                
                % If the mean is positive, automatically set the boolOutcome of the min task to 0(non failure), and it's mean value equal to the historical value)
                if(AvgMzRotPosMag>0)                                                                             % Don't need to check f_histAvgMzRotMinAvgMag b/c it will produce the same mean value
                    bool_fcDataYDir(1:2,1)  = [bool_analysisOutcome3,0];
                    avgData(2,:)            = [AvgMzRotPosMag,s_histAvgMzRotMinAvgMag(2,1)];                     % Second Row: since the min value is not tested, just place its historical value in col 2 
                else
                    bool_fcDataYDir(1:2,2)  = [0,bool_analysisOutcome4];
                    avgData(2,:)            = [s_histAvgMzRotPosAvgMag(2,1),AvgMzRotMinMag];                     % Second Row: since th epos value is not teste, just place its historical value in col 1                     
                end
                % Here: Consider returning other data for recovery... Assgin steps for recovery 

                %% Analyze which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                if(bool_analysisOutcome3)
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotPosMag/f_histAvgMyRotAvgMag(2,1);     if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MyRot=1;    else MyRot=0;       end; %[MyRot,~]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); 
                    ratio=AvgMzRotPosMag/f_histAvgFzRotAvgMag(2,1);     if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzRot=1;    else FzRot=0;       end;
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotPosMag/f_histAvgMzRotPosAvgMag(2,1);  if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotPos=1; else MzRotPos=0;    end; 
                    ratio=AvgMzRotPosMag/f_histAvgMzRotMinAvgMag(2,1);  if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotMin=1; else MzRotMin=0;    end;
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotPosMag/f_histAvgFxAppAvgMag(2,1);     if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FxApp=1;    else FxApp=0;       end;  
                    ratio=AvgMzRotPosMag/f_histAvgFzAppAvgMag(2,1);     if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzApp=1;    else FzApp=0;       end;
                    %---------------------------------------------------------------------------------------------------------------------------------------------------                    
                    bool_fcDataYDir(1,2:7) = [MyRot,FzRot,MzRotPos,MzRotMin,FxApp,FzApp];
                    bool_fcDataYDir(2,2:7) = 1;                   
                    
                elseif(bool_analysisOutcome4)
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotMinMag/f_histAvgMyRotAvgMag(2,1);     if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MyRot=1;    else MyRot=0;       end; %[MyRot,~]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,     f_histAvgMyRotAvgMag,dataStruc,percStateToAnalyze,dataThreshold); 
                    ratio=AvgMzRotMinMag/f_histAvgFzRotAvgMag(2,1);     if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzRot=1;    else FzRot=0;       end;
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotMinMag/f_histAvgMzRotPosAvgMag(2,1);  if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgMzRotMinMag/f_histAvgMzRotMinAvgMag(2,1);  if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotMin=1; else MzRotMin=0;    end;
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgMzRotMinMag/f_histAvgFxAppAvgMag(2,1);     if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FxApp=1;    else FxApp=0;       end;  
                    ratio=AvgMzRotMinMag/f_histAvgFzAppAvgMag(2,1);     if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzApp=1;    else FzApp=0;       end;
                    %---------------------------------------------------------------------------------------------------------------------------------------------------                    
                    bool_fcDataYDir(1,2:7) = 1;
                    bool_fcDataYDir(2,2:7) = [MyRot,FzRot,MzRotPos,MzRotMin,FxApp,FzApp];                    
                end            

            %% XRoll-Direction Analysis
            elseif(analysis==xRot && xRollDirTest)

                %% Analyze Deviation in xRoll-Direction            
                % 1) Load SUCCESSFUL historically averaged Fx.App.AvgMag data
                matName='s_histFxAppAvgMag.mat'; [s_histAvgFxAppAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);

                % Load historically averaged Fz.App.AvgMag data
                matName='s_histFzAppAvgMag.mat'; [s_histAvgFzAppAvgMag,~] = loadFCData(fPath,StratTypeFolder,matName);           

                %% Test 1st condition: Fx.App
                dataStruc = MCs;        dataType = magnitudeType;
                dataThreshold  = 0.20;  percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome5,AvgFxAppMag]= analyzeAvgData(motCompsFM,dataType,stateData,Fx,approachState,s_histAvgFxAppAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                %% Test 2nd condition: Fz.App
                dataStruc=MCs;          dataType = magnitudeType;
                dataThreshold  = 0.20;  percStateToAnalyze = 1.0;               % Threshold value to compare avgSum to histAvgSum and determine success/failure & percentage of state that should be studied            
                [bool_analysisOutcome6,AvgFzAppMag]= analyzeAvgData(motCompsFM,dataType,stateData,Fz,approachState,s_histAvgFzAppAvgMag,dataStruc,percStateToAnalyze,dataThreshold);

                %% Compute Outputs
                bool_fcDataXRollDir(1:2,1)  = [bool_analysisOutcome5,bool_analysisOutcome6];
                avgData(3,:) = [AvgFxAppMag,AvgFzAppMag];            
                % Here: Consider returning other data for recovery... Assgin steps for recovery

                %% Analyze which Failure this is. If 0, that is the correlation and indication of our test. If 1 ignore.            
                % Analyze FxApp
                if(bool_analysisOutcome5)
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFxAppMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzRot=1;    else FzRot=0;       end;  
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgFxAppMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotMin=1; else MzRotMin=0;    end;    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFxAppMag/f_histAvgFxAppAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FxApp=1;    else FxApp=0;       end;  
                    ratio=AvgFxAppMag/f_histAvgFzAppAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzApp=1;    else FzApp=0;       end;  
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    bool_fcDataXRollDir(1,2:7) = [MyRot,FzRot,MzRotPos,MzRotMin,FxApp,FzApp];
                    
                % Analyze FzApp    
                elseif(bool_analysisOutcome6)
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMag/f_histAvgMyRotAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MyRot=1;    else MyRot=0;       end; 
                    ratio=AvgFzAppMag/f_histAvgFzRotAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzRot=1;    else FzRot=0;       end;    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMag/f_histAvgMzRotPosAvgMag(2,1); if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotPos=1; else MzRotPos=0;    end;  
                    ratio=AvgFzAppMag/f_histAvgMzRotMinAvgMag(2,1); if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); MzRotMin=1; else MzRotMin=0;    end;    
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    ratio=AvgFzAppMag/f_histAvgFxAppAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FxApp=1;    else FxApp=0;       end;  
                    ratio=AvgFzAppMag/f_histAvgFzAppAvgMag(2,1);    if( ratio>(1+dataThreshold) || ratio < (1-dataThreshold) ); FzApp=1;    else FzApp=0;       end;  
                    %---------------------------------------------------------------------------------------------------------------------------------------------------
                    bool_fcDataXRollDir(2,2:7) = [MyRot,FzRot,MzRotPos,MzRotMin,FxApp,FzApp];        
                end            
            end     % End Axis Analysis
        end         % End for xDir Analysis
    end             % End State Analysis
    
    bool_fcData=[bool_fcDataXDir;bool_fcDataYDir;bool_fcDataXRollDir];
end             % End Function