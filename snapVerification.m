%*************************** Documentation *******************************
% snapVerification()
%
% Is the main program to execute the relative-change-based hieararchical
% taxonomy (RCBHT). Also includes a probabilistic version called
% probabilistic RCBHT or pRCBHT. 
%
% This is currently done offline. 
%
% This function does the following:
% 1) Loads Force, Angles, Cartesian Positions, and State Transition
% information from either of the following experiments: 
% - PA10 Simulation Straight Line Approach
% - PA10 Simulation Pivot Approach
% - HIRO Simulation Side Approach
% - HIRO Simulation Error Characterization
%
% Then, for each separate force axis do the following:
% 2) Primitives Level: 
% Perform a linear regression fit of the force data using a correlation
% parameter. Then, assign a "Primitive" label to each segment based on the
% magnitude of the gradent. There are 11 possible classifications. Then, do
% filtering at this level using primitivesCleanUp.
%
% Note:
% There is a possibility to run an optimization algorithm here by turning
% on the optimization flag. This routines optimizes the gradient thresholds
% used in the regressionFit that labels the segments based on gradient
% value. 
%
% 3) Motion Compositions (MCs) Level:
% Combine 2 neighboring primitives to abstract complexity and call these
% motion compositions. Motion compositions can be of 9 different
% types according to the types of primitives that are combined. There are
% rules to label according to primitive type. There is also a filtering
% stage here called cleanUp.m
%
% 4) Low-Level Behaviors (LLBs) Level:
% Combines neighboring compositions to abstract complexity. There are also
% 9 different types of LLBs according to the types of compositions
% combines. There is also a filtering stage here called Refinement.
%
% 5) High-Level Behaviors (HLBs) Level:
% This function is designed to study whether failure is likely in the
% Approach stage or if the whole assembly has been successful. To do so it
% looks for specific characteristics outlined in more detailed in those
% functions or in the documentation.
%
% 6) Bayes Filtering or pRCBHT
% This function converts data found in the MC/LLB/HLB layers into a
% probabilistic rendition and uses that information to study whether
% failure is likely or success has happened.
%
% 7) Save Learning Data
% After the analysis has finished, data that is required for probabilistic
% learning or for failure characterization is performed.
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
%
% Inputs:
% StrategyType  : HIRO - Offline Snap Verification for Side Approach
% FolderName    : Name of folder where results are stored, user based.
% first         : which plot do you want to segment first
% last          : which plot do you want to segment last
%                 where first:last is a vector list.
%
% Outputs:
% hlbBelief     : the belief or posterior probability about the success
%                 rate of the task.
% llbBelief     : the belief about all the different LLBs found throughout
%                 the task
% stateTimes    : col vector of automata state transition times
% hlbehStruc    : boolean row vec containing one element per automata state
%                 indicating whether state was successful based on 
%                 pre-probabilistic analysis.
%**************************************************************************
function  [hlbBelief,llbBelief,stateTimes,hlbehStruc] = snapVerification(StrategyType,FolderName,first,last)
%  function snapVerification()
%  StrategyType = 'HSA';
%  FolderName='20120426-1844-SideApproach-S';
%  first=1;last=6;

%% Global Variables
%-----------------------------------------------------------------------------------------
    %opengl software;       % If matlab crashes make sure to enable this command as matlab cannot render the state colors in hardware. 
    global Optimization;    % The Optimization variable is used to extract gradient classifications from a first trial. Normally should have a zero value.
    Optimization = 0;       % If you want to calibrate gradient values turn this to 1 and make sure that all calibration files found in:
                            % C:\Documents and Settings\suarezjl\My Documents\School\Research\AIST\Results\ForceControl\SideApproach\gradClassFolder
                            % are deleted. 
                            % After one run, turn the switch off. The routine will used the saved values to file. 
                            
%------------------------------------------------------------------------------------------
    
    global DB_PLOT;         % To plot graphs
    global DB_PRINT;        % To print console messages
    global DB_WRITE;        % To write data to file
    global DB_DEBUG;        % To enable debugging capabilities
    
    DB_PLOT=1;
    DB_PRINT=0; 
    DB_WRITE=1;
    DB_DEBUG=0;
    
%------------------------------------------------------------------------------------------    

    global MC_COMPS_CLEANUP_CYCLES;
    global LLB_REFINEMENT_CYCLES;  
    
    MC_COMPS_CLEANUP_CYCLES         = 4;    % Value for FailureCharac 0 % 2013Aug value for normal RCBHT is 4. Pre2013 value was 2    
    LLB_REFINEMENT_CYCLES           = 5;    % Value for FailureCharac 2 % 2013Aug value for normal RCBHT is 5. Pre2013 value was 4
    
%------------------------------------------------------------------------------------------

    % Variables - to run or not to run layers
    PRIM_LAYER  = 1;    % Compute the primitives layer
    MC_LAYER    = 1;    % Compute the  motion compositions and clean up cycle
    LLB_LAYER   = 1;    % Compute the low-level behavior and refinement cycle
    HLB_LAYER   = 1;    % Compute the higher-level behavior
    pRCBHT      = 0;    % Compute the llb and hlb Beliefs  
%------------------------------------------------------------------------------------------
%% Debug Enable Commands
% Not supported for cplusplus code generation
%     if(DB_DEBUG)
%         dbstop if error
%     end
    
%% Initialization/Preprocessing
    % Create a CELL of strings to capture the types of possible force-torque data plots
    plotType = ['Fx';'Fy';'Fz';'Mx';'My';'Mz'];
    stateTimes=-1;
%% A) Plot Forces
    plotOptions=1;  % plotOptions=0: plot separate figures. =1, plot in subplots
    [fPath,StratTypeFolder,forceData,stateData,axesHandles,TL,BL]=snapData3(StrategyType,FolderName,plotOptions);

%% B) Perform regression curves for force moment reasoning          
    % Iterate through each of the six force-moment plots Fx Fy Fz Mx My Mz
    % generated in snapData3 and superimpose regressionfit lines in each of
    % the diagrams. 
    for axisIndex=first:last
        if(PRIM_LAYER)
            wStart  = 1;                            % Initialize index for starting analysis

            % Determine how many handles
            if(last-first==0)
                pHandle = 0;
            else
                pHandle = axesHandles(axisIndex);           % Retrieve the handle for each of the force curves
            end

            % Determine the type of the plot
            pType   = plotType(axisIndex,:);                  % Use curly brackets to retrieve the plotType out of the cell

            % Compute regression curves for each force curve
            [statData,curHandle,gradLabels]=fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,pType,forceData,stateData,wStart,pHandle,TL,BL,axisIndex);        

            if(Optimization==1)
               gradientCalibration(fPath,StratTypeFolder,stateData,statData,axisIndex);

               llbBelief=-1;
               hlbBelief=-1; % Dummy variables for this segment
            end
        end     % End PRIMITIVES_LAYER
        
%% Do the following only if (gradient classification) optimization is turned off
        if(Optimization==0) 
            
            
%% C)       Generate the compound motion compositions for each of the six force elements

            if(MC_LAYER)
                % If you want to save the .mat of motComps, set saveData to 1. 
                saveData = 0;
                motComps = CompoundMotionComposition(StrategyType,statData,saveData,gradLabels,curHandle,TL(axisIndex),BL(axisIndex),fPath,StratTypeFolder,FolderName,pType,stateData); %TL(axisIndex+2) skips limits for the first two snapJoint suplots              
            
                if(axisIndex==1)
                    MCFx = motComps;
                elseif(axisIndex==2)
                    MCFy = motComps;
                elseif(axisIndex==3)
                    MCFz = motComps;
                elseif(axisIndex==4)
                    MCMx = motComps;
                elseif(axisIndex==5)
                    MCMy = motComps;
                elseif(axisIndex==6)
                    MCMz = motComps;
                end     
            end

%% D)       Generate the low-level behaviors
        
            if(LLB_LAYER)
                % Combine motion compositions to produce low-level behaviors
                [llbehStruc,llbehLbl] = llbehComposition(StrategyType,motComps,curHandle,TL(axisIndex),BL(axisIndex),fPath,StratTypeFolder,FolderName,pType);                          
                
%% E)          Copy to a fixed structure for post-processing        
                if(axisIndex==1)
                    llbehFx = llbehStruc;
                elseif(axisIndex==2)
                    llbehFy = llbehStruc;
                elseif(axisIndex==3)
                    llbehFz = llbehStruc;
                elseif(axisIndex==4)
                    llbehMx = llbehStruc;
                elseif(axisIndex==5)
                    llbehMy = llbehStruc;
                elseif(axisIndex==6)
                    llbehMz = llbehStruc;
                end
            end
        end                                
    end % End all axes
%%  F) After all axes are finished computing the LLB layer, generate and plot labels for high-level behaviors.
    if(HLB_LAYER)                        
        % Save all llbeh strucs in a structure. One field for each llbeh. This is an
        % update from the previous array. 
        % 2013July: 
        mcFlag=2; llbFlag=3;
        % Each of these structures are mx17, so they can be separated in this way.    
        [motCompsFM,MCnumElems] = zeroFill(MCFx,MCFy,MCFz,MCMx,MCMy,MCMz,mcFlag);
        [llbehFM   ,LLBehNumElems] = zeroFill(llbehFx,llbehFy,llbehFz,llbehMx,llbehMy,llbehMz,llbFlag);
        
        % Generate the high level behaviors
        [hlbehStruc,avgData,successFlag]=hlbehComposition_new(motCompsFM,MCnumElems,llbehFM,LLBehNumElems,llbehLbl,stateData,axesHandles,TL,BL,fPath,StratTypeFolder,FolderName);    
    end
    
%% G) Compute the Bayesian Filter for the HLB
    if(Optimization==0)
        if(pRCBHT==1)
            Status = 'Offline'; % Can be online as well. 
            [hlbBelief, llbBelief, stateTimes] = SnapBayesFiltering(fPath,StrategyType,FolderName,Status);
        else
            % Place dummy variables in output when Optimization is running
            hlbBelief=-1;
            llbBelief=-1;            
            stateTimes=-1;
        end
    end   
    
%% F) Save Learning Data To File

    %% Probabilistic Data
    
    %% Failure Characterization Data
    % If the assembly was successful record its data
    if(successFlag)
        
        % 1) Update Historically Averaged My.Rot.AvgRMS data as well as counter time for successful assemblies        
        avgMyData = avgData(1,1);
        updateHistData(fPath,StratTypeFolder,avgMyData,'histMyRotAvgMag.mat');
    
        % 2) Update Historically Averaged Fz.Rot.LLBs.AvgMagVal 
        avgFzData = avgData(1,2);        
        updateHistData(fPath,StratTypeFolder,avgFzData,'histFzRotAvgMag.mat');
        
    end
end