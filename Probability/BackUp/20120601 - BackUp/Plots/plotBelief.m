%% plotBelief
%
% This function plots the posterior (also known as belief) for the CBHT,
% where we have a {6 x time x axes} structure. The rows represent the six
% low-level behaviors of the CBHT, the columns represent the duration of
% the trial, and it is repeated across 6 dimensions for each of the six
% force axis elements for which it was computed. 
%
% A different line is assigned to the probability of an llb. Six subplots
% are generated for each of the six axes. 
% 
% The automata Approach State is skipped since it does not contribute info.
%
% The plot is saved at the end in .png, .fig, and .eps formats.
%%
function plotBelief(Path,StratTypeFolder,FolderName,time,posterior,stateTimes)

%% Global Variables

    % Number of Forces Axes
    NumAxes = 6;

    % Global Indeces
    handle = zeros(NumAxes,1);    
    
%% Plot the posterior probability for each of the llbs across the 3 automata states for the Fx axes


    for axes = 1:NumAxes
        handle(axes)=subplot(3,2,axes); 
        plot( time, posterior(1,:,axes),'k',...     % FX - black
              time, posterior(2,:,axes),'g',...     % CT - green
              time, posterior(3,:,axes),'b',...     % PS - blue
              time, posterior(4,:,axes),'c',...     % PL - cyan
              time, posterior(5,:,axes),'g',...     % SH - magenta
              time, posterior(6,:,axes),'r');       % AL - red
        
        % Labels
        title('Belief in Corresponding LLBs'); 
        xlabel('Time (secs)'); 
        ylabel('Posterior Probability'); 

        % Axis adjustment
        Max = 1.1; % Probability can be 1.0 max.
        Min = 0.0;         
        axis([time(1) time(end) Min Max])
        
        % Insert State lines        
        FillFlag = 0;   % For this plot eliminate the Approch state
        insertStates(stateTimes,Max,Min,FillFlag)
    end
    
    % Print a single legend. It will be associated with the last subplot:
    [legend_h,object_h,plot_h,text_strings]=legend('FX','CT','PS','PL','SH','AL','Orientation','horizontal');   
    
    % Get the legend's position
    lg = get(legend_h,'Position'); % 4 position vector ([left bottom width height]) 
    
    % Establish the new coordinates for left and bottom points of the
    % legend box. These were derived empirically. 
    lg(1) = 0.3;
    lg(2) = 0.01;
    
    % Set the legend position
    set(legend_h,'Position',lg)
    

%% Save plot to the results file
    if(ispc)
        % Make matlab folder
        Name = strcat(Path,StratTypeFolder,FolderName,'\\snapData3','ProbabilityPlot');
        saveas(handle(1),Name,'epsc');
        saveas(handle(1),Name,'png');         
        saveas(handle(1),Name,'fig');
    else
        print -depsc    ProbabilityPlot.eps;
        print -dpslatex ProbabilityPlot.eps;
        print -dfig     ProbabilityPlot.fig;
        print -dpng     ProbabilityPlot.png;
        print '\home\juan\Documents\Results\SideApproach\snapData3\' -depsc ProbabilityPlot.eps
    end
end