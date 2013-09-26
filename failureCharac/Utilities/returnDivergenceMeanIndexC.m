% returnDivergenceMeanIndex is a function that works directly with the new
% failureCharacterizationC code. It looks at the structure of historical
% average values for exemplars and also at the dimensionality of the
% deviation to return an appropriate index. 
%
% Deviation Dimensionality can be in either 1-dimension, 2-dimensions, or 3-dimension.
%
% Exemplar's: to identifiy deviations in:
%   x-dir are magntidues in My during rotation:         MyR
%   y-dir are amplitudes in Mz during rotation:         MzR
%   xYall-dir are amplitudes in Fz during approach:     FzA. 
% 
% The structure for these exemplars constitutes not only of mean values but
% also of a counter, c; an upper bound threshold, UB; and a lower-bound
% threshold, LB; according to the following chart:
% New AvgData = [MyRc     MyRm    MyRu    MyRl;
%                MzR1c    MzR1m   MzR1u   MzR1l;
%                MzR23c   MzR23m  MzR23u  MzR23l;
%                FzA1c    FzA1m   FzA1u   FzA1l;
%                FzA2c    FzA2m   FzA2u   FzA2l;
%                FzA3c    FzA3m   FzA3u   FzA3l];

function meanIndex=returnDivergenceMeanIndexC(devSum,whichAxis)

    %% 1D Analysis MyR=2; MzR1=2; FzA1=2
    if(devSum==1)
        meanIndex=2;
        
    %% 2D Analysis MyR=2; MzR23=6; FzA2=6;
    elseif(devSum==2 && whichAxis==My)
        meanIndex=2;
    elseif(devSum==2 && whichAxis~=My)
        meanIndex=6;
        
    %% 3D Analysis MyR=2; MzR23=6; FzA3=10;
    elseif(devSum==3 && whichAxis==My)
        meanIndex=2;
    elseif(devSum==3 && whichAxis==Mz)
        meanIndex=6; 
    elseif(devSum==3 && whichAxis==Fz)
        meanIndex=10;
    end
end