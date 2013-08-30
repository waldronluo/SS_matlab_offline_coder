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
% analysisOutcome   - boolean. If 0 no failure, if 1 failure.
% avgData           - array of averaged values [mx1]
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
function [analysisOutcome,avgData]=failureCharacterization(fPath,StratTypeFolder,stateData,motCompsFM,~,whichState)

%% Local Variables

    % Set outcome to SUCCESS
    analysisOutcome = 0;

    % Automata State
    approachState=1; rotState=2; %snapState=3;matState=4;

    % Divergence Direction Analysis. 
    xDirAnalysis=1;yDirAnalysis=2;xRotAnalysis=4;yRotAnalysis=5;zRotAnalysis=6;
    
    % Standard indeces
    Fz=3; My=5;
    
    % DataStructures
    MCs=2;  % Flag to indicate we are using motion compositions
    LLBs=3; % Flag to indicate we are using low-level behaviors
    
    % Data Types
    magnitudeType   = 1;
%     rmsType         = 2;
%     AmplitudeType   = 3;    
%  
%% Approach State Analysis    
    if(whichState==approachState)

        %% Go through all the analysis states
        %for analysis=FxAnalysis:FxAnalysis. % May include later when more case scenarios exist.
        analysis=xDirAnalysis;

        %% X-Direction Analysis
        if(analysis==xDirAnalysis)
            
            %% Analyze Deviation in X-Direction            
            % 1) Load historically averaged My.Rot.AvgMag ata
            matName='histMyRotAvgMag.mat';
            [histAvgMyRotAvgRMS,~] = loadFCData(fPath,StratTypeFolder,matName);

            % Load historically averaged Fz.Rot.AvgRMS value
            matName='histFzRotAvgMag.mat';
            [histAvgFzRotAvgRMS,~] = loadFCData(fPath,StratTypeFolder,matName);
            
            % 2) Sum current My.Rot.AvgRMS

            %% Test 1st condition: My.Rot
            dataStruc = MCs;
            dataType = magnitudeType;
            [analysisOutcome1,AvgMyRotMag]= analyzeAvgData(motCompsFM,dataType,stateData,My,rotState,histAvgMyRotAvgRMS,dataStruc);
                
            %% Test 2nd condition: Fz.Rot
            dataStruc=MCs;
            dataType = magnitudeType;
            [analysisOutcome2,AvgFzRotMag]= analyzeAvgData(motCompsFM,dataType,stateData,Fz,rotState,histAvgFzRotAvgRMS,dataStruc);
            
            %% Compute Outputs
            analysisOutcome=(analysisOutcome1&&analysisOutcome2);
            avgData = [AvgMyRotMag,AvgFzRotMag];
            
            % Here: Consider returning other data for recovery...
            % Assgin steps for recovery

        elseif(analysis==yDirAnalysis)
        elseif(analysis==xRotAnalysis)
        elseif(analysis==yRotAnalysis)
        elseif(analysis==zRotAnalysis)
        end     % End Axis Analysis
    end         % End State Analysis
end             % End Function