%---------------------------- Documentation -------------------------------
% This function takes either a motionComposition struc (motCompsFM: mx11x6) or
% an LLB structure (llbehFM: mx17x6); 
% Where m=num of data MCs/LLBs; 11 or 17 number of fields in struc, and 6, 
% is the number of axis.
% 
% The function returns the start and ending indeces for the structure in a 
% given axis for a given automata state defined by whichState. 
% To do so, we compare the ending time of each LLB and compare it with the 
% automata state transition col vector stateData.
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
% Inputs
% llbehFM       - LLB data structure
% stateData     - Col vec of state transition times
% axis          - what axis Fx-Mz do you want to study
% whichState    - which state Approach, Rotation, Insertion, Snap do you
%                 want to study.
%
% Output
% startIndex    - the startind index for the selected axis/state
% endIndex      - the ending index for the selected axis/state
%--------------------------------------------------------------------------
function [startIndex,endIndex]=getStateIndeces(data,stateData,whichAxis,whichState,dataFlag)

    %% Local Variables
    
    % States
    startState=whichState; 
    endState=startState+1;
    
    % Data Type
    MCs=2;  % Flag to indicate we are using motion compositions
    LLBs=3; % Flag to indicate we are using low-level behaviors   
    
    % Indeces
    mcT2E=10;   llbT2E=16;

    % Check to make sure the state length is appropriate for state analysis
    if(startState<=length(stateData+1))
        
        % Compute the length of the structure given only one axis. How many
        % LLBs?
        len = length(data(:,1,1));
        
        %% For MCs
        if(dataFlag == MCs)
            for index=1:len
                if( data(index,mcT2E,whichAxis)>stateData(startState,1) )
                    startIndex=index;
                    break;
                end
            end
            for index=startIndex:len
                if( data(index,mcT2E,whichAxis)>stateData(endState,1) ) % To compute the endTime we look at the nextIndex
                    endIndex=index;
                    break;
                end
            end
            
        %% For LLBs
        elseif(dataFlag==LLBs)
            for index=1:len
                if( data(index,llbT2E,whichAxis)>stateData(startState,1) )
                    startIndex=index;
                    break;
                end
            end
            for index=startIndex:len
                if( data(index,llbT2E,whichAxis)>stateData(endState,1) ) % To compute the endTime we look at the nextIndex
                    endIndex=index;
                    break;
                end
            end            
        else
            startIndex=-1; endIndex=-1;
        end
        
    % Not successful. Return -1 for indeces.
    else
        startIndex=-1; endIndex=-1;
    end
end