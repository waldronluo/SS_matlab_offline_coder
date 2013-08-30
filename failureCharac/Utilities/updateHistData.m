% updateHistStateData
% Loads the selected historically averaged data, and it then
% performes averaging and counter updating with the new data and then
% saves the file as a file.
%
% Output
% histData:        outputs the col vec with ctr and times info
%--------------------------------------------------------------------------
function histData=updateHistData(fPath,StratTypeFolder,data,matName)

    % Load the historical stateData structure
    [histData,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);

    % Do the averaging and update the historical data
    histData = averageHistData(data,histData);

    % Save statData.mat to file
    save(strcat(hisDataPath,'.mat'),'histData');
    
end