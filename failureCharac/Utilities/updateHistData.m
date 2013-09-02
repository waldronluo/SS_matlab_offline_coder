% updateHistStateData
% Loads the selected historically averaged data, and it then
% performes averaging and counter updating with the new data and then
% saves the file as a file.
%
% Output
% histData:        outputs the col vec with ctr and times info
%--------------------------------------------------------------------------
function histData=updateHistData(fPath,StratTypeFolder,data,matName)

%     % Load the historical stateData structure
%     [histData,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
% 
%     % Create specialized variable name
%     histName=genvarname(matName(1:end-4));
%     
%     % Do the averaging and update the historical data
%     eval('histName = averageHistData(data,histData)');
% 
%     % Save statData.mat to file
%     save(strcat(hisDataPath),'histName');
    
    if(strcmp(matName,    's_histMyRotAvgMag.mat') )
        % Load the historical stateData structure
        [s_histMyRotAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
        s_histMyRotAvgMag = averageHistData(data,s_histMyRotAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histMyRotAvgMag');
        
    elseif(strcmp(matName,'s_histFzRotAvgMag.mat') )
        % Load the historical stateData structure
        [s_histFzRotAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histFzRotAvgMag= averageHistData(data,s_histFzRotAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histFzRotAvgMag');
        
    elseif(strcmp(matName,'s_histMzRotPosAvgMag.mat') )
        % Load the historical stateData structure
        [s_histMzRotPosAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histMzRotPosAvgMag= averageHistData(data,s_histMzRotPosAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histMzRotPosAvgMag');
        
    elseif(strcmp(matName,'s_histMzRotMinAvgMag.mat') )
        % Load the historical stateData structure
        [s_histMzRotMinAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histMzRotMinAvgMag= averageHistData(data,s_histMzRotMinAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histMzRotMinAvgMag');
    
    elseif(strcmp(matName,'s_histFxAppAvgMag.mat') )
        % Load the historical stateData structure
        [s_histFxAppAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histFxAppAvgMag= averageHistData(data,s_histFxAppAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histFxAppAvgMag'); 
        
    elseif(strcmp(matName,'s_histFzAppAvgMag.mat') )
        % Load the historical stateData structure
        [s_histFzAppAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         s_histFzAppAvgMag= averageHistData(data,s_histFzAppAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'s_histFzAppAvgMag');
        
     %%-------------------------- Failure ---------------------------------
    elseif(strcmp(matName,'f_histMyRotAvgMag.mat') )
        % Load the historical stateData structure
        [f_histMyRotAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histMyRotAvgMag= averageHistData(data,f_histMyRotAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histMyRotAvgMag');   
        
    elseif(strcmp(matName,'f_histFzRotAvgMag.mat') )
        % Load the historical stateData structure
        [f_histFzRotAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histFzRotAvgMag= averageHistData(data,f_histFzRotAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histFzRotAvgMag'); 
        
    elseif(strcmp(matName,'f_histMzRotPosAvgMag.mat') )
        % Load the historical stateData structure
        [f_histMzRotPosAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histMzRotPosAvgMag= averageHistData(data,f_histMzRotPosAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histMzRotPosAvgMag');
        
    elseif(strcmp(matName,'f_histMzRotMinAvgMag.mat') )
        % Load the historical stateData structure
        [f_histMzRotMinAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histMzRotMinAvgMag= averageHistData(data,f_histMzRotMinAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histMzRotMinAvgMag');        
        
    elseif(strcmp(matName,'f_histFxAppAvgMag.mat') )
        % Load the historical stateData structure
        [f_histFxAppAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histFxAppAvgMag= averageHistData(data,f_histFxAppAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histFxAppAvgMag'); 
        
    elseif(strcmp(matName,'f_histFzAppAvgMag.mat') )
        % Load the historical stateData structure
        [f_histFzAppAvgMag,hisDataPath] = loadFCData(fPath,StratTypeFolder,matName);
        
         f_histFzAppAvgMag= averageHistData(data,f_histFzAppAvgMag);
        
        % Save statData.mat to file
        save(strcat(hisDataPath),'f_histFzAppAvgMag');  
    else
        data=-1;
    end
    
end