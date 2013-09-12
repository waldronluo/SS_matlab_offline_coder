function finalStatisticalUpdate(fPath,StratTypeFolder,avgData,boolFCData,successFlag)

    if(successFlag)

            %% x-Dir
            if(xDirTest)
                % Do these if there was no failure, ie boolFCData is zero.
                if(boolFCData(1,1)==0)          % Order of indeces is connected to the specific names of variables.
                    % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(1,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histMyRotAvgMag.mat');
                end
                if(boolFCData(2,1)==0)
                    % 2) Update Historically Averaged Fz.Rot.AvgMag
                    avgData = fcAvgData(1,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFzRotAvgMag.mat');
                end
            end
            %% y-Dir
            if(yDirTest)
                if(boolFCData(3,1)==0)
                    % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(1,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histMzRotPosAvgMag.mat');
                end
                if(boolFCData(4,1)==0)
                    % 1) Update Historically Averaged Mz.Rot.Min.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(2,2);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histMzRotMinAvgMag.mat');            
                end
            end
           %% xRoll-DirPos
           if(xRollDirTest)
               if(boolFCData(5,1)==0)
                    % 1) Update Historically Averaged Fx.App.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(3,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFxAppPosAvgMag.mat');
               end

               if(boolFCData(6,1)==0)
                    % 2) Update Historically Averaged Fz.App.AvgMag
                    avgData = fcAvgData(3,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFzAppPosAvgMag.mat');        
               end


               %% xRoll-DirMin
               if(boolFCData(7,1)==0)
                    % 1) Update Historically Averaged Fx.App.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(4,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFxAppMinAvgMag.mat');
               end

               if(boolFCData(8,1)==0)
                    % 2) Update Historically Averaged Fz.App.AvgMag
                    avgData = fcAvgData(4,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'s_histFzAppMinAvgMag.mat');        
               end
           end           

	%% If the assembly was unsuccessful update the historical values for those key parameters of failure    
    else
        

            %% x-Dir
            if(xDirTest)
                % Do these if there was failure, ie fcbool is 1.
                if(boolFCData(1,1))
                    % 1) Update Historically Averaged My.Rot.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(1,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histMyRotAvgMag.mat');
                end
                if(boolFCData(2,1))
                    % 2) Update Historically Averaged Fz.Rot.AvgMag
                    avgData = fcAvgData(1,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFzRotAvgMag.mat');
                end
            end
            %% y-Dir
            if(yDirTest)
                if(boolFCData(3,1))
                    % 1) Update Historically Averaged Mz.Rot.Pos.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(2,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histMzRotPosAvgMag.mat');
                end
                if(boolFCData(4,1))
                    % 2) Update Historically Averaged Mz.Rot.Min.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(2,2);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histMzRotMinAvgMag.mat');            
                end
            end
            %% xRollDir-Pos       
            if(xRollDirTest)
                %% xRollDirPos
                if(boolFCData(5,1))
                    % 1) Update Historically Averaged Fx.App.Min.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(3,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFxAppPosAvgMag.mat');
                end

                if(boolFCData(6,1))
                    % 2) Update Historically Averaged Fz.App.Min.AvgMag
                    avgData = fcAvgData(3,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFzAppPosAvgMag.mat');          
                end

                %% xRollDir-Min
                if(boolFCData(7,1))
                    % 1) Update Historically Averaged Fx.App.Min.AvgMag data as well as counter time for successful assemblies        
                    avgData = fcAvgData(4,1);
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFxAppMinAvgMag.mat');
                end

                if(boolFCData(8,1))
                    % 2) Update Historically Averaged Fz.App.Min.AvgMag
                    avgData = fcAvgData(4,2);        
                    updateHistData(fPath,StratTypeFolder,avgData,'f_histFzAppMinAvgMag.mat');          
                end            
            end
    end
    save(strcat('/home/vmrguser/Documents/School/Research/AIST/Results/',StratTypeFolder,FolderName,'/','MATs','/output.mat'),'fcAvgData','boolFCData');
end