%--------------------- Documentation --------------------------------------
% Average two values. In particular this helps when one number is negative
% and the other positive. 
% 
% We also distinguish here between which number is max and min, so that
% this also helps to compute the correct value for amplitudes. 
%--------------------------------------------------------------------------
function avgVal = computeAmplitudeDifference(val1,val2)
    avgMax=max(val1,val2);
    avgMin=min(val1,val2);
    if(avgMax>=0 && avgMin >=0 || avgMax<=0 && avgMin<=0);
        avgVal = (avgMax+avgMin)/2;                
    % One number positive, the other negative.         
    else
        avgVal = avgMax - ( (abs(avgMax)+abs(avgMin))/2 ); 
    end    
end