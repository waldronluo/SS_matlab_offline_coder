%% ****************************** Documentation ***************************
% Update: Jan 2013.
% This code originally was developed for the PivotApproach/PA10 Simulation.
% We want to extend this to include SideApproach HIRO in Simulation/Physical Experiment.
%
% The fifth layer of the taxonomy looks one state-at-a-time (context
% specific) 
% across all six force-moment low-level behaviors to produce high-level behaviors. 
% The high-level behaviors represent human-apropos behaviors associated with 
% each stage of the pivot assembly process. Here is a list across states:
%
%   •	State 1: Approach 	Y/N
%   •	State 2: Rotation	Y/N
%   •	State 3: Alignment 	Y/N << For PivotApproach/PA10 but not for SideApproach/HIRO
%   •	State 4: Snap 		Y/N
%   •	State 5: Mating 	Y/N
% 
% Each of the high-level behaviors requires a specific combination of low-level 
% behaviors across the different force-elements but not necessarily all of them. 
% The key is that if certain key low-level behaviors are present, the presence of 
% the high-level behavior can be ascertained. 
%
% Note: for State 1 and State 5. 
%   State 1: given that in State 1 the mating parts do not contact each other, 
%            we will not try to interpret this information to determine if the approach 
%            proceeds successfully. If, however, a rotation can be ascertained in state 2, 
%            then we can safely state that the approach has taken place. 
%   State 5: If state 4 completes successfully it is assumed for now that the 
%            mating remains fixed and proper. 
% 
% Here is the list of necessary state-sensitive low-level behavior requirements. 
%
% PivotApproach - PA10 - Simulation
% In other words, if the low-level behaviors are present (or a sequence of them are 
% present) then, we have a higher-level behavior. If not, we have the negative form 
% of the high-level behavior. 
%
%   •	Rotation: 
%       o	Fz-> FX (with value not equal to zero)
%       o	Fy -> PL 
%       o	Mx -> ALIGN
%   •	Alignment
%       o	AL to show up in all axes (in our present case Fxyz, Mxyz). However, 
%           the moment axis corresponding to the direction of motion in which the 
%           insertion is taking place (Mz) could have just a FX reference or ALIGN->FS instead. 
%   •	Snap
%       o	Fz – CT+AL
%       o	FxFyMxMyMz = ALIGN+FX || FX
%
% SideApproach - HIRO - Simulation
% keyLLB(axes) = KeyLLBLookUp(StrategyType,HLB(hlbTag,:),axes);
%
% This layer has a struc that lists the low-level behaviors contained in each state for each force axis
% 
% hlbehStruc = { 
%               stateLbl2{ Fx{} … Mz{} } 
%               stateLbl3{ Fx{} … Mz{} } 
%               stateLbl4{ Fx{} … Mz{} }
%              }
%
% Input Parameters:
% llbehFM:      - This 1x6 cell array structure, contains CELLs that each
%                 contain an mx17 cell structure that contains the
%                 low-level behavior struc (llbehStruc) of each of the six
%                 force elements.
% llbehLbl:     - cell array structure that contains a list of strings of 
%                 possible low-level behaviors.
% stateData:    - 4x1 vector that contains the times at which states for
%                 the pivot approach start. The first element refers to
%                 state 2. Will insert state 1 at the initialization stage.
% curHandle:    - handle to axes in figure.
% TL/BL:        - top and bottom limits of all axes in the subplot fig.
% fPath,StratTypeFolder,FolderName
%
% Output Parameters:
% hlbehStruc:   - a 1x5 numeric array that holds 1's or 0's, determing
%                 whether each state produced a successful:
%               - For PA10:
%                    - APPROACH
%                    - ROTATION
%                    - ALIGHMENT
%                    - INSERTION
%                    - MATING
%**************************************************************************
function hlbehStruc = hlbehComposition(llbehFM,llbehLbl,stateData,curHandle,TL,BL,fPath,StratTypeFolder,FolderName)
   
%%  Structure and indeces for low-level behavior structure
%%  Labels for low-level behaviors
 	FIX     = 1;        % Fixed in place
    CONTACT = 2;        % Contact
%   PUSH    = 3;        % Push
    PULL    = 4;        % Pull
    ALIGN   = 5;        % Alignment
    SHIFT   = 6;        % Shift
%   UNSTABLE= 7;        % Unstable
%   NOISE   = 8;        % Noise
%   llbehLbl    = {'FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N'}; % {'fix' 'cont' 'push' 'pull' 'align' 'shift' 'unstable' 'noise'};
    
%% Indeces for llbehStruc
    behLbl          = 1;   % action class
%   averageVal1     = 2;   % averageVal1
%   averageVal2     = 3;
%   AVG_MAG_VAL     = 4;
%   rmsVal1         = 5;
%   rmsVal2         = 6;
%   AVG_RMS_VAL     = 7;
%   ampVal1         = 8;
%   ampVal2         = 9;
%   AVG_AMP_VAL     = 10;
%   mc1             = 11;
%   mc2             = 12;    
    T1S             = 13; 
%   T1E             = 14;
%   T2S             = 15; 
    T2E             = 16;    
%   TAVG_INDEX      = 17;
     
%% Initialization    
    
    % Compute the number of low-level behaviors per force/moment axis.
    NumForceAxis = length(llbehFM);       % Currently expect 6 for FxyzMxyz
    
%%  Structure Size    
    % Create a matrix to keep the dimensions of each LLB struc. A (6,m)
    % matrix where m is the number of LLBs for a given axis. 
    strucSize = zeros(NumForceAxis,2);  % 6axis x 2(rows=#LLBs,cols=17)   
    
    % Fill in strucSize with the size of each of the six llbehStruc's
    for index=1:NumForceAxis
        strucSize(index,:) = size(llbehFM{1,index});
    end

%%  State
    rState      = size(stateData);
    StateNum    = rState(1) - 1;    % We subtract one b/c there is no upper boundary after 4
    
    % Create an automata state array to hold LLB labels (now used integers
    % instead of strings) in the six FT dimensions for each automata state (except Approach state).
    % stateLbl = cell{StateNum,NumForceAxis};   % Used in PivotApproach/PA10 and is composed of a 5x6 structure.
    stateLbl = zeros(StateNum,1,NumForceAxis);  % And a 4,m,6 structure that will grow m over tiem for SideApproach/HIRO
    
%%  High-Level Behavior Structure
%   1xStateNum vector of 1's and 0's, dictating whether or not HL Behs were
%   achieved.
	hlbehStruc = zeros(1,rState(1)-1);      % Currently 5 States for PivotApproach 
                                            % Currently 4 states for Side Approach

%% PivotApproach/PA10 Code
    if(~strcmp(StratTypeFolder,'\\ForceControl\\HIRO\\'))
        
        %% (1) Create a state x ForceElments Cell array structure

        % Keep a counter of which labels belong to a given state
        llLabelVector = cell(4,1);                  % Empirically determined size.

        % Fill each state's dimension with llbeh sequence of labels. 
        for state=1:StateNum

        %% Define TIME limits of prevprev/prev/current/next/nextnext states
            currStateEndTime   = stateData(state+1);        % Add 1 to capture the ENDING time

            % PrevPrevState
            if(state<3),            prevprevStateEndTime    = 0;
            else                    prevprevStateEndTime    = stateData(state-2);
            end

            % PrevState
            if(state<2),            prevStateEndTime        = 0;
            else                    prevStateEndTime        = stateData(state);     
            end        

            % NextState
            if(state < StateNum),     nextStateEndTime      = stateData(state+2);
            elseif(state == StateNum),nextStateEndTime      = currStateEndTime;
            end

            % NextNextState
            if(state < StateNum-1),   nextnextStateEndTime  = stateData(state+3);
            elseif(state == StateNum),nextnextStateEndTime  = nextStateEndTime;
            end


            %% For each AXIS FxyzMxyz, extract the labels according to time
            for axis=1:NumForceAxis

                % 1. Extract the llbehStruc data for each of the six dimensions
                llbehStruc = llbehFM{1,axis};

                % 2. For each label in llbehStruc. Traversing the structure. 
                for index=1:strucSize(axis,1)    

                    % 3. Extract a time vector
                    timeVec = [llbehStruc{index,T1S:T2E}];
                    minTime = min(timeVec);
                    maxTime = max(timeVec);      
                    if(maxTime>8.3)
                        maxTime=8.3;
                    end

                    % Get state limits
                    for stateTime=1:length(stateData)-1;
                        % Check to see in which state the min time starts.
                        s1 = stateData(stateTime);
                        s2 = stateData(stateTime+1);
                        % Lowerbound 
                        if(minTime>=s1 && minTime <= s2)
                            lowerState = stateTime;
                        end
                        % Upperbound
                        if(maxTime>=s1 && maxTime <= s2)
                            upperState = stateTime;
                        end                    
                    end

                    %% Put in stateLbl
                    for tt=lowerState:upperState

                        % Just make a copy of the current state we are in to
                        % avoid repetion in future states
                        if(tt==state)
                            % Compute length of labels in desired state
                            curLen = length(stateLbl(tt,axis));

                            % Copy current StateLbl to temp cell
                            temp = stateLbl(tt,axis);

                            % Place the new label in temp
                            temp(1,curLen+1) = llbehStruc(index,1);
                            
                            % Copy back to stateLbl
                            stateLbl(tt,axis) = temp;
                        end
                    end


                end
            end
        end 

        %% (2) Look for patterned sequence of low-level behaviors to determine if hlbeh's are present

        Fx=1;Fy=2;Fz=3;Mx=4;My=5;Mz=6;
        state2=2; state3=3; state4=4; state5=5;
        %%  Rotation (State 2). Conditions:
        %       Fy -> PL   
        %       Fz-> FX (with value not equal to zero)  
        %       Mx -> ALIGN

        % Save the contents of Fy, Fz, Mx
        tempFy=stateLbl{state2,Fy}; tempFz=stateLbl{state2,Fz}; tempMx=stateLbl{state2,Mx};

        % Look for conditions    
        if(findStrings(tempFy,llbehLbl{PULL}))
            if(findStrings(tempFz,llbehLbl{FIX}))
                if(findStrings(tempMx,llbehLbl{ALIGN}))
                    % All three conditions have been met. Set hlbehStruc for state 1 and 2 to true
                    hlbehStruc(1:2) = 1;
                end
            end
        end

        %%  ALIGNMENT
        %   Conditions: AL || SH + FX to show up in all axes (in our present case Fxyz, Mxyz). 
        %   However, the moment axis corresponding to the direction of motion in which 
        %   the insertion is taking place (Mz) could have just a FX reference or ALIGN->FX instead. 

        % Save the contents of Fx, Fy, Mx
        tempFx=stateLbl{state3,Fx}; tempFy=stateLbl{state3,Fy}; tempFz=stateLbl{state3,Fz};
        tempMx=stateLbl{state3,Mx}; tempMy=stateLbl{state3,My}; tempMz=stateLbl{state3,Mz};

        if( findStrings(tempFx,llbehLbl{ALIGN})|| findStrings(tempFx,llbehLbl{SHIFT},llbehLbl{FIX})) 
            if( findStrings(tempFy,llbehLbl{ALIGN})|| findStrings(tempFy,llbehLbl{SHIFT},llbehLbl{FIX})) 
                if( findStrings(tempFz,llbehLbl{ALIGN})|| findStrings(tempFz,llbehLbl{SHIFT},llbehLbl{FIX})) 
                    if( findStrings(tempMx,llbehLbl{ALIGN})|| findStrings(tempMx,llbehLbl{SHIFT},llbehLbl{FIX})) 
                        if( findStrings(tempMy,llbehLbl{ALIGN})|| findStrings(tempMy,llbehLbl{SHIFT},llbehLbl{FIX})) 
                            if( findStrings(tempMz,llbehLbl{ALIGN},llbehLbl{FIX}) || findStrings(tempMz,llbehLbl{FIX})) 

                                % All three conditions have been met. Set hlbehStruc for state 1 and 2 to true
                                hlbehStruc(3) = 1;
                            end
                        end
                    end
                end
            end
        end

        %%  SNAP INSERTION    
        %   Conditions: Fz = CT+AL and FxFyMxMyMz = ALIGN+FIX || SH + FIX || FX

        % Save the contents of Fx, Fy, Mx
        tempFx=stateLbl{state4,Fx}; tempFy=stateLbl{state4,Fy}; tempFz=stateLbl{state4,Fz};
        tempMx=stateLbl{state4,Mx}; tempMy=stateLbl{state4,My}; tempMz=stateLbl{state4,Mz};

        if( findStrings(tempFx,llbehLbl{ALIGN},llbehLbl{FIX}) || findStrings(tempFx,llbehLbl{FIX})) 
            if( findStrings(tempFy,llbehLbl{ALIGN},llbehLbl{FIX}) || findStrings(tempFy,llbehLbl{FIX})) 
                if( findStrings(tempFz,llbehLbl{CONTACT},llbehLbl{ALIGN})) 
                    if( findStrings(tempMx,llbehLbl{ALIGN},llbehLbl{FIX}) || findStrings(tempMx,llbehLbl{FIX})) 
                        if( findStrings(tempMy,llbehLbl{ALIGN},llbehLbl{FIX}) || findStrings(tempMy,llbehLbl{FIX})) 
                            if( findStrings(tempMz,llbehLbl{ALIGN},llbehLbl{FIX}) || findStrings(tempMz,llbehLbl{FIX})) 

                                % All three conditions have been met. Set hlbehStruc for state 1 and 2 to true
                                hlbehStruc(4) = 1;
                            end
                        end
                    end
                end
            end
        end

        %%  MATING    
        %   Conditions: Fz = FX

        % Save the contents of Fx, Fy, Mx
        tempFx=stateLbl{state5,Fx}; tempFy=stateLbl{state5,Fy}; tempFz=stateLbl{state5,Fz};
        tempMx=stateLbl{state5,Mx}; tempMy=stateLbl{state5,My}; tempMz=stateLbl{state5,Mz};

        if( findStrings(tempFx,llbehLbl{FIX}) ) 
            if( findStrings(tempFy,llbehLbl{FIX}) ) 
                if( findStrings(tempFz,llbehLbl{FIX}) ) 
                    if( findStrings(tempMx,llbehLbl{FIX}) ) 
                        if( findStrings(tempMy,llbehLbl{FIX}) ) 
                            if( findStrings(tempMz,llbehLbl{FIX}) ) 

                                % All three conditions have been met. Set hlbehStruc for state 1 and 2 to true
                                hlbehStruc(5) = 1;
                            end
                        end
                    end
                end
            end
        end


    %% Code for HIRO Simulation
    else
        %% (1) Create a state x ForceElments Cell array structure

        % Keep a counter of which labels belong to a given state
        llLabelVector = zeros(StateNum,1);                  % Empirically determined size.

        % Fill each state's dimension with llbeh sequence of labels. 
        for state=1:StateNum

        %% Define TIME limits of prevprev/prev/current/next/nextnext states
            currStateEndTime   = stateData(state+1);        % Add 1 to capture the ENDING time

            % PrevPrevState
            if(state<3),            prevprevStateEndTime    = 0;
            else                    prevprevStateEndTime    = stateData(state-2);
            end

            % PrevState
            if(state<2),            prevStateEndTime        = 0;
            else                    prevStateEndTime        = stateData(state);     
            end        

            % NextState
            if(state < StateNum),     nextStateEndTime      = stateData(state+2);
            elseif(state == StateNum),nextStateEndTime      = currStateEndTime;
            end

            % NextNextState
            if(state < StateNum-1),   nextnextStateEndTime  = stateData(state+3);
            elseif(state == StateNum),nextnextStateEndTime  = nextStateEndTime;
            end

            %% For each AXIS FxyzMxyz, extract the labels according to time
            for axis=1:NumForceAxis

                % 1. Extract the llbehStruc data for each of the six dimensions. It will contain the LLB label + all statistics.
                llbehStruc = llbehFM{1,axis};

                % 2. Traverse the llbehStruc for all of its label itmes 
                for index=1:strucSize(axis,1)    

                    % 3. Extract a time vector for the current automata state
                    timeVec = [llbehStruc(index,T1S:T2E)];  % Start and End time for LLB corresponding to index
                    minTime = min(timeVec);                 % Starting time
                    maxTime = max(timeVec);                 % Ending time (can be longer than one automata state)
                    if(maxTime>llbehStruc(end,T2E))
                        maxTime=llbehStruc(end,T2E);
                    end

                    % Get state limits for the current state We will loop through all state boundary times. If the startingLLB time is within startState_i Time/endState_i Time then set the 'lowerState' boundary. Similary, if the endingLLB time is within startState_i Time/endState_i then set that 'upperState' boundary. 
                    for stateTime=1:length(stateData)-1; % Assumes that the stateVector's last entry is equal to the end of the task. -1 is needed to compute s2.
                        % Check to see in which state the min time starts.
                        s1 = stateData(stateTime);      % startAutomataState
                        s2 = stateData(stateTime+1);    % endAutomataState
                        
                        % Set a lower and uperState bounds. First, Lowerbound for current state
                        if(minTime>=s1 && minTime <= s2)
                            lowerState = stateTime;
                        end
                        % Upperbound for current state
                        if(maxTime>=s1 && maxTime <= s2)
                            upperState = stateTime;
                        end                    
                    end

                    %% The next section was originally designed to work with a cell.
                    %% Fill in the stateLbl Matrix. Need to go through each automata state, through each axis, through each LLB and fill in this vector of ints. We will have a (4states,m LLB entries,6 force axis). If 0's, it means a null entry. This matrix will have many zeros because matlab has to keep matrix 2D size the same across the third dimension.
                    for tt=lowerState:upperState % Indicates that this LLB spans all these states
                        
                        % Copy the relevant LLB labels that belong to the state in turn. We have a big for loop going around all the states. 
                        if(tt==state)
                            
                            % 1. Compute length of labels in desired state
                            [zeroVal stateLblEntry] = min(stateLbl(tt,:,axis)); % This vector will have one or more zero's. Find the first entry that contains a zero. That will be where our next entry will be.

                            % 2. Place the new LLB label from llbehStruc into temp for the relevant state and axis in turn. 
                            stateLbl(tt,stateLblEntry,axis) = llbehStruc(index,1);
                            stateLbl(tt,stateLblEntry+1,axis) = 0;
                            
                        end % End if(tt==state)
                    end     % End for tt    =lowerState:upperState
                end         % End for index =1:strucSize(axis,1) 
            end             % End for axis  =1:NumForceAxis
        end                 % End for state =1:StateNum

        %% (2) Look for patterned sequence of low-level behaviors to determine if hlbeh's are present

        Fx=1;Fy=2;Fz=3;Mx=4;My=5;Mz=6;
        state2=2; state3=3; state4=4;
        
        %%  Rotation (State 2). Conditions:
        %       Fx-> FX (with value not equal to zero)    
        %       My -> Fx

        % Save the contents of key axes. 
        tempFx=stateLbl(state2,:,Fx)'; tempMy=stateLbl(state2,:,My)';
        len=length(tempFx);
        % Look for conditions   
        res=zeros(1,len);
        for i=1:length(tempFx);res(1,i)=intcmp(tempFx(i,1),llbehLbl(FIX));end;
               
        if(sum(res))       % This equation let'us know if the selected LLB exists in the state vector. The product produces ones and zeros. If sum is not zero, then true.
            res=zeros(1,len);
            for i=1:length(tempFx);res(1,i)=intcmp(tempFx(i,1),llbehLbl(FIX));end;            
            
            if(sum(res))
                    % All three conditions have been met. Set hlbehStruc for state 1 and 2 to true
                    hlbehStruc(1:2) = 1;
            end
        end

        %%  SNAP INSERTION    
        %   Conditions: Fz = CT and My = CT
        
        % Save the contents of Fz, My
        tempFz=stateLbl(state3,:,Fz)'; tempMy=stateLbl(state3,:,My)'; 
        
        % Look for conditions    
        res=zeros(1,len);
        for i=1:length(tempFz);res(1,i)=intcmp(tempFz(i,1),llbehLbl(FIX));end;
        
        if(intcmp(tempFz,llbehLbl(CONTACT)))
            
            % Look for conditions
            res=zeros(1,len);
            for i=1:length(tempMy);res(1,i)=intcmp(tempMy(i,1),llbehLbl(FIX));end;
            
            if(intcmp(tempMy,llbehLbl(CONTACT)))
                    % All three conditions have been met. Set hlbehStruc for state 1 and 2 to true
                    hlbehStruc(3) = 1;
            end
        end

        %%  MATING    
        %   Conditions: Fx-Mz = FX

        % Save the contents of Fx, Fy, Mx
        tempFx=stateLbl(state4,:,Fx)'; tempFy=stateLbl(state4,:,Fy)'; tempFz=stateLbl(state4,:,Fz)';
        tempMx=stateLbl(state4,:,Mx)'; tempMy=stateLbl(state4,:,My)'; tempMz=stateLbl(state4,:,Mz)';

        % Look for conditions
        res=zeros(1,len);
        for i=1:length(tempFx);res(1,i)=intcmp(tempFx(i,1),llbehLbl(FIX));end;
        
        if( intcmp(tempFx,llbehLbl(FIX)) ) 
            
            % Look for conditions
            res=zeros(1,len);
            for i=1:length(tempFy);res(1,i)=intcmp(tempFy(i,1),llbehLbl(FIX));end;
            
            if( intcmp(tempFy,llbehLbl(FIX)) ) 
                
                % Look for conditions
                res=zeros(1,len);
                for i=1:length(tempFz);res(1,i)=intcmp(tempFz(i,1),llbehLbl(FIX));end;
                
                if( intcmp(tempFz,llbehLbl(FIX)) ) 
                    
                    % Look for conditions
                    res=zeros(1,len);
                    for i=1:length(tempMx);res(1,i)=intcmp(tempMx(i,1),llbehLbl(FIX));end;
                    
                    if( intcmp(tempMx,llbehLbl(FIX)) ) 
                        
                        % Look for conditions
                        res=zeros(1,len);
                        for i=1:length(tempMy);res(1,i)=intcmp(tempMy(i,1),llbehLbl(FIX));end;
                        
                        if( intcmp(tempMy,llbehLbl(FIX)) ) 
                            
                            % Look for conditions
                            res=zeros(1,len);
                            for i=1:length(tempMz);res(1,i)=intcmp(tempMz(i,1),llbehLbl(FIX));end;
                            
                            if( intcmp(tempMz,llbehLbl(FIX)) ) 

                                % All three conditions have been met. Set hlbehStruc for state 1 and 2 to true
                                hlbehStruc(4) = 1;
                            end
                        end
                    end
                end
            end
        end        
    end % End if(strcmp(StratTypeFolder,'\\ForceControl\\HIRO\\'))
    
%% Plot
     plotHighLevelBehCompositions(curHandle,TL,BL,hlbehStruc,stateData,fPath,StratTypeFolder,FolderName);

%% Save to File
%TL,BL,fPath,StratTypeFolder,FolderName,
%% End of Function
end