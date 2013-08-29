%% ExtractCumDuration
% This function returns the cumulative duration up to that point in time for a selected LLB in a
% given automata state for a given force axis.
%
% There is a special condition when the union of two LLBs is desired.
% Namely, AL and FX.
%
% Inputs:
% llbTag     - numerical representation of what llb are we looking for. 
%            - [FX,CT,PS,PL,SH,AL] <==> [1,2,3,4,5,6].
% llbStruc   - a nx4x6 struc for all six force axes. The fields are as
%              follows: llbtag, StartTime, EndTime, Duration
%            - current simulation time
% axes       - the index for one of the six force axis: Fx...Mz
%
% Output:
% CumDir     - the cumulative duration of a given llb accross or multiple
%              instances of that llb in a given automata state in a given
%              axis.
%% 
function CumDur = ExtractCumDuration(llbTag,llbStruc,time,axes)

%% Initialize Variables
    IndexArray      = zeros(1,1);   % Preallocate the Index array
    TagIndex        = 1;            % Variable to indicate tag index.
    Ctr             = 1;            % Counter used to number an index array
    CumDur          = 0;            % Initialize the cumulative duration time
    StartTimeIndex  = 2;            % Pertains to the minimized llb structure
    
    r = size(llbStruc);
    
%% Extract LLBs    
    for elems = 1:r(1)
        % Identify which elements share the same tag
        if(llbTag==llbStruc(elems,TagIndex,axes)) 
            
            % Save the indeces of those itmes
            IndexArray(1,Ctr) = elems; %llbStruc(elems,TagIndex,axes);
            Ctr = Ctr + 1;
        end
    end

%% Compute Duration Up to That point
    r = length(IndexArray);
    
    for c = 1:r
        Duration = time - llbStruc(IndexArray(1,c),StartTimeIndex,axes);
        CumDur = CumDur + Duration;
    end
end