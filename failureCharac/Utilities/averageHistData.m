% averageHistStateData
% This function takes a historical averaged figure of automata state data
% tranistions times and averages a new value into it.
%
% Finally increase the counter by one.
%
% Inputs:
% StrategyType:     what kind of strategy/experiment are we doing
% stateData:        col vector of automata transition state times
% histStateData:    col vector of historical averaged automata transition
%                   times. however, the 1st entry of this vector keeps a
%                   counter of how many times the averaging has been done
function histData = averageHistData(data,histData)

    % Indeces
    averagedIndex=2;
    
    %% Perform Averaging: new_tot_num-1*histAvgData + 1/new_tot_num*new_data
    histData(averagedIndex,1) = histData(averagedIndex,1)*( histData(1,1)/(histData(1,1)+1) ) + ...
                                ( data(averagedIndex-1,1)*              1/(histData(1,1)+1) );
      
    %% Increase Counter by one
    histData(1,1) = histData(1,1) + 1;
end