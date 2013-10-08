% averageHistStateData
% This function takes a historical averaged figure of automata state data
% tranistions times and averages a new value into it.
% Average mean,upper,lower bounds. 
% 
% Outputs bool and then an array struc of 1x4 with counter, mean, upperBound, lowerBound
%
%
% Finally increase the counter by one.
%
% Inputs:
% isSuccess:        tells whether the assembly was successful or not.
% data:             current averaged data (1x1).
% histStateData:    a pre-selected 4x1 col vector of historical averaged
%                   automata data. In updateHistData, the original 12x2
%                   histStatData is filtered to select the correct segment
%                   for the data structure: either successful or failure,
%                   and whether there are deviations in 1,2, or 3
%                   directions.
%--------------------------------------------------------------------------
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
% MyR (4x2)
%--------------------------------------------------------------------------
% [ s_ctr   f_ctr;
%   s_mean  f_mean;
%   s_upper f_upper;
%   s_lower f_lower] = [s1 | f1]
%
%--------------------------------------------------------------------------
% MzR (8x2)
%--------------------------------------------------------------------------
% [s    |   f1;
%  ---  |   f23];
%
%--------------------------------------------------------------------------
% FzA (12x2)
%--------------------------------------------------------------------------
% [ s   | f1;
%   --- | f2;
%   --- | f3];
%--------------------------------------------------------------------------
function histData = averageHistData(avgData,histData)

    % Indeces
    ctrIndex=1;
    meanIndex=2;
    UB_index=3;
    LB_index=4;
    
    % Set values
    ctr      =histData(ctrIndex,1);
    %--------------------------------
    histMean =histData(meanIndex,1);
    %---------------------------------
    UB       =histData(UB_index,1);
    LB       =histData(LB_index,1);
    %---------------------------------
    
    % (1) Check to see if counter is 0
    if(ctr==0)
        
        % Mean Assign current mean as an entry to the historical data
        histMean=avgData;
        
        % Setup the Upper Bound as mean+0.5*mean and  Lower Bound: mean-0.5*mean
        UB = avgData+(0.5*avgData);       
        LB = avgData-(0.5*avgData);
        
    else
        % (2) Update Mean
        % Perform the Mean weighted average using: avg=weightedAverage(ctr,newData,histData)
        histMean=weightedAverage(ctr,avgData,histMean);
        
        % (3) Update UB
        % Simple comparision. Compare current mean with UB. If larger, replace it, otherwise
        % keep it. Later we can consider other forms of comparison, for
        % example, using std dev's (needs a history of averages) or other
        % statistical methods.
        if(avgData>UB)  
            UB=avgData; % Not sure if we could do a ceiling, or an average here.
                        
        % (4) Update LB
        % Compare current mean with LB. If smaller, replate it, otherwise
        % keep it.    
        elseif(avgData<LB)                
            LB=avgData;
        end
    end
    
    %% Increase Counter by one
    ctr = ctr+1;    
    
    %% Reassign historical values
    histData(ctrIndex,1)=ctr;
    %--------------------------------
    %avgData(meanIndex,1)=mean;
    histData(meanIndex,1)=histMean;
    %---------------------------------
    histData(UB_index,1)=UB;
    histData(LB_index,1)=LB;
end