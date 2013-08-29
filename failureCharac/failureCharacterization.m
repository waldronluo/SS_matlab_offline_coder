%%---------------------- Documentation -------------------------------------
% failureCharacterization
%
% X-Direction Deviation Characteristics:
% i)  First primitive starts after traditional rotation state time
% ii) The average values for LLBs in the Fz axis, in the Rotation state,
%     drop some threshold value (20%) below historical values. (Currently
%     hard-coded to 9.7)
%
% REFERENCE
% llbehStruc:   - [ actnClass,...
%                   avgMagVal1, avgMagVal2, AVG_MAG_VAL,
%                   rmsVal1,    rmsVal2,    AVG_RMS_VAL,
%                   ampVal1,    ampVal2,    AVG_AMP_VAL,
%                   mc1,mc2,
%                   T1S,T1_END,T2S,T2E,TAVG_INDEX ]
% Inputs
% fpath:            - path of working directory
% StrategyType      - type of strategy/experiment
% stateData         - col vec to automata state transition times
% llbehFM           - A mx17x6 structure of LLBs. m is the number of LLBs in an axis, 17 is the data elements, and 6 is the axis
% whichState        - indicates which automata state we want to analyze
%
% Output:
% analysisOutcome   - boolean. If 0 no failure, if 1 failure.
%-------------------------------------------------------------------------
function analysisOutcome=failureCharacterization(fPath,StratTypeFolder,stateData,llbehFM,whichState)

%% Local Variables

    % Set outcome to SUCCESS
    analysisOutcome = 0;

    % Automata State
    approachState=1; rotState=2; %snapState=3;matState=4;

    % Divergence Direction Analysis. 
    xDirAnalysis=1;yDirAnalysis=2;xRotAnalysis=4;yRotAnalysis=5;zRotAnalysis=6;
    
    % Standard indeces
    Fz=3;
    
    % X-direction Analysis
    T2E                 = 16;
    AVG_RMS_VAL         =  7;       % Average Amplitude Value Index for the LLB Structure 'llbehStruc'
    AvgRMSValThreshold  = 0.2;      % Threshold value for which condition 2 is set to be true 
    AvgRotStateTimeThreshold = 0.1;  % Threshold for time check
%% Approach State Analysis    
    if(whichState==approachState)

        %% Go through all the analysis states
        %for analysis=FxAnalysis:FxAnalysis. % May include later when more case
        %scenarios exist.
        analysis=xDirAnalysis;

        %% X-Direction Analysis
        if(analysis==xDirAnalysis)
            
            
            %% Analyze Deviation in X-Direction
            % Load historically averaged stateData
            [histStateData,~] = loadHistStateData(fPath,StratTypeFolder);

            % Load historically averaged Fz.Rot.LLB.AvgMagVal
            avgFzRotLLBAvgMagVal=9.7; % Currently hard-coded

            %% Test 1st condition
            if( histStateData(rotState+1,1)>stateData(rotState,1)*(1+AvgRotStateTimeThreshold) ) % If true, likely x-deviation

                %% Test 2nd condition
                % Find starting index and ending index
                len = length(llbehFM(:,1,1));
                for j=1:len
                    if( llbehFM(j,T2E,Fz)>stateData(2,1) )
                        rotStartIndex=j;
                        break;
                    end
                end
                for j=rotStartIndex:len
                    if( llbehFM(j,T2E,Fz)>stateData(3,1) )
                        rotEndIndex=j-1;
                        break;
                    end
                end

                % Sum the LLBs avg Magnitude value
                sumAvgVal=sum(llbehFM(rotStartIndex:rotEndIndex,AVG_RMS_VAL,Fz))/(rotEndIndex-rotStartIndex); % Sum the Average Values of LLbs in Fz.Rot

                % Check to see if average is > or < threshold
                ratio=sumAvgVal/avgFzRotLLBAvgMagVal;
                if( ratio>(1+AvgRMSValThreshold) || ratio < (1-AvgRMSValThreshold) )
                    analysisOutcome = 1;
                    % Time at which failure happens?
                    % Magnitudes?
                end
            end

            % Return data for recovery

        elseif(analysis==yDirAnalysis)



        elseif(analysis==xRotAnalysis)


        elseif(analysis==yRotAnalysis)


        elseif(analysis==zRotAnalysis)
        end     % End Axis Analysis
    end         % End State Analysis
end             % End Function