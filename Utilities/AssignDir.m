%%*************************** Documentation *******************************
% Function used for Snap Assembly strategies. 
% Assigns appropriate strategy path based on the kind of approach used.
%**************************************************************************
function StratTypeFolder = AssignDir(StrategyType)

% Assign a directory path based on the StrategyType used. 
    if strcmp(StrategyType,'S')
        StratTypeFolder = '/PositionControl/StraightLineApproach-NewIKinParams/';            % Straight Line with new IKin params
    elseif strcmp(StrategyType,'SN')
        StratTypeFolder = '/PositionControl/StraightLineApproach-NewIkinParams-Noise/';      % Straight Line with new IKin params with noise
    elseif strcmp(StrategyType,'P')
        StratTypeFolder = '/PositionControl/PivotApproach-NewIkinParams/';                   % Pivot approach with new IKin Params
    elseif strcmp(StrategyType,'PN')
        StratTypeFolder = '/PositionControl/PivotApproach-NewIKin-Noise/';                   % Pivot approach with new IKin Params with noise
    elseif strcmp(StrategyType,'FS')
        StratTypeFolder = '/ForceControl/StraightLineApproach/';                             % Used with PA10 Simulation
    elseif strcmp(StrategyType,'FP')
        StratTypeFolder = '/ForceControl/PivotApproach/';                                    % Used with PA10 PivotApproach Simulation
    elseif strcmp(StrategyType,'HSA')
        StratTypeFolder = '/ForceControl/SideApproach/';                                     % Used with HIRO SideApproach Simulation and Physical
    elseif strcmp(StrategyType, 'ErrorCharac')
        StratTypeFolder = '/ForceControl/ErrorCharac/';                                      % Used with HIRO SideApproach to compute error characteristics
    else
        StratTypeFolder = '';
%        FolderName='';
    end
end