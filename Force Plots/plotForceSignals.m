% Plots force and moment profiles for SnapAssemblies. 
% Selects appropriate directories based on the kind of snap assembly
% strategy assumed.
% 
% Read data from different files:
% Torques data from: Torques.dat
% Low-pass filtered torques from: filtTorques.da
%**************************************************************************
function plotForceSignals(StrategyType,FolderName)

%%  Debug Enable Commands
    PRINT = 0; % Used to indicated wheter to pring info to screen or not

%%  Select Path
    % Assing appropriate directoy based on Ctrl Strategy 
    if(ISPC)
        if StrategyType=='S'
            StratTypeFolder = '../Results/PositionControl/StraightLineApproach-NewIKinParams/';				% Straight Line with new IKin params
        elseif StrategyType=='SN'
            StratTypeFolder = '../Results/PositionControl/StraightLineApproach-NewIkinParams-Noise/';			% Straight Line with new IKin params with noise
        elseif StrategyType=='P'
            StratTypeFolder = '../Results/PositionControl/PivotApproach-NewIkinParams/';				% Pivot approach with new IKin Params
        elseif StrategyType=='PN'
            StratTypeFolder = '../Results/PositionControl/PivotApproach-NewIKin-Noise/';				% Pivot approach with new IKin Params with noise
        elseif StrategyType=='FS'
            StratTypeFolder = '../Results/ForceControl/StraightLineApproach/';
        elseif StrategyType=='FP'
            StratTypeFolder = '../Results/ForceControl/PivotApproach/';    
        else
            StratTypeFolder = '';
            FolderName='';
        end
    else
        if StrategyType=='S'
            StratTypeFolder = 'PositionControl/StraightLineApproach-NewIKinParams/';				% Straight Line with new IKin params
        elseif StrategyType=='SN'
            StratTypeFolder = 'PositionControl/StraightLineApproach-NewIkinParams-Noise/';			% Straight Line with new IKin params with noise
        elseif StrategyType=='P'
            StratTypeFolder = 'PositionControl/PivotApproach-NewIkinParams/';				% Pivot approach with new IKin Params
        elseif StrategyType=='PN'
            StratTypeFolder = 'PositionControl/PivotApproach-NewIKin-Noise/';				% Pivot approach with new IKin Params with noise
        elseif StrategyType=='FS'
            StratTypeFolder = 'ForceControl/StraightLineApproach/';
        elseif StrategyType=='FP'
            StratTypeFolder = 'ForceControl/PivotApproach/';		
        else
            StratTypeFolder = '';
            FolderName='';
        end
    end

%% Folder Name    
    % Assign the right folder name
    if(ISPC)
        torques=strcat('../Results/',StratTypeFolder,FolderName,'/Torques.dat');
        filtTorques=strcat('../Results/',StratTypeFolder,FolderName,'/filtTorques.dat');
    else
        torques=strcat('/home/juan/Documents/Results/',StratTypeFolder,FolderName,'/Torques.dat');
        filtTorques=strcat('/home/juan/Documents/Results/',StratTypeFolder,FolderName,'/filtTorques.dat');
    end

%% Load the data
    T=load(torques);
    S=load(filtTorques);

%%  Plot Force
    % Force/Moment and their filtered counterparts 
    figure(1),

    %% Plot Force
    subplot(2,2,1),F1=plot(T(:,1),T(:,11:13));
    title('Force Plot'); xlabel('Time (secs)'); ylabel('Force (N)');

    % Adjust axis
    [y i]=min(min(T(1:length(T),11:13))); %we want to find the max and min value in the area of contact not before that.
    [x i]=max(max(T(1:length(T),11:13)));

    if(PRINT)
        if(ISPC)
            fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
        else
            printf('The max and min values for the Force plot is: %f, %f\n',x,y);
        end
    end
    axis([T(1,1) T(length(T),1) y-(0.02*y) x+(0.02*y)])

%% Plot Filtered Force
    subplot(2,2,2),F2=plot(S(:,1),S(:,2:4));
    title('Filtered Force Plot'); xlabel('Time (secs)'); ylabel('Force (N)');
    legend ('Fx','Fy','Fz','location','NorthEastOutside');

    % Adjust axis
    [y i]=min(min(S(1:length(S),2:4))); %we want to find the max and min value in the area of contact not before that.
    [x i]=max(max(S(1:length(S),2:4)));

    if(PRINT)
        if(ISPC)
            fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
        else
            printf('The max and min values for the Force plot is: %f, %f\n',x,y);
        end
    end
    axis([S(1,1) S(length(S),1) y-(0.02*y) x+(0.02*y)])
    legend ('Fx','Fy','Fz','location','NorthEastOutside');

%% Plot Moment
    subplot(2,2,3), M1=plot(T(:,1),T(:,14:16));
    title('Moment Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

    % Adjust axis
    [y i]=min(min(T(1:length(T),14:16)));
    [x i]=max(max(T(1:length(T),14:16)));
    if(PRINT)
        if(ISPC)
            fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
        else
            printf('The max and min values for the Force plot is: %f, %f\n',x,y);
        end
    end
    axis([T(1,1) T(length(T),1) y-(0.02*y) x+(0.02*x)]);
    legend ('Tx','Ty','Tz','location','NorthEastOutside');

%% Plot Filtered Moment
    subplot(2,2,4), M2=plot(S(:,1),S(:,5:7));
    title('Filtered Moment Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

    % Adjust axis
    [y i]=min(min(S(1:length(S),5:7)));
    [x i]=max(max(S(1:length(S),5:7)));
    if(PRINT)
        if(ISPC)
            fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
        else
            printf('The max and min values for the Force plot is: %f, %f\n',x,y);
        end
    end
    axis([S(1,1) S(length(S),1) y-(0.02*y) x+(0.02*y)]);
    legend ('Tx','Ty','Tz','location','NorthEastOutside');

%%  Save plot to file
    if(ISPC)
         Name = strcat(P,FolderName,Diagonal,FolderName);
         saveas(F,Name,'epsc');
         saveas(F,Name,'fig');
         saveas(F,Name,'png');
    else
        print -deps Multiplot.eps;
        print -dfig   Multiplot.fig;
        print -dpng Multiplot.png;
    end
end
