% Performs a weighed Average according to the following function:   
% (Ctr/Ctr+1)*histAvgData+(1/Ctr+1)*newData
function avg=weightedAverage(ctr,newData,histData)
        avg = ( ctr/(ctr+1) )*histData + 1/(ctr+1)*(newData);
end