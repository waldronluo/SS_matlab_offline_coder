% updateHistStateData
% Loads the selected historically averaged data, and it then
% performes averaging and counter updating with the new data and then
% saves the file as a file.
%
% Output
% histData:        outputs the col vec with ctr and times info
%--------------------------------------------------------------------------
function histData=updateHistDataC(fPath,StratTypeFolder,data,matName)
    
%% --------------------- SUCCESSFUL -------------------------------------------------
% xDir-------------------------------------------------------------------------------
    if(strcmp(matName,'MyR.mat') )
        % Load the historical stateData structure
        [MyR,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
        MyR = averageHistData(data,MyR);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'MyR');
        
% yDirPos----------------------------------------------------------------------------           
        
    elseif(strcmp(matName,'MzR.mat') )
        % Load the historical stateData structure
        [MzR,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         MzR= averageHistData(data,MzR);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'MzR');
        
% YallDirPos----------------------------------------------------------------------------        
    elseif(strcmp(matName,'FzA.mat') )
        % Load the historical stateData structure
        [FzA,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         FzA= averageHistData(data,FzA);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'FzA');
    else
        histData=-1;
    end
    
end