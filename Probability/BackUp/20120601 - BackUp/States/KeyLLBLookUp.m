%% KeyLLBLookUp
% This function returns a string LLB tag ('FX' or 'CT' or 'PS' or 'PL' or
% 'SH' or 'AL'or 'AF') the last term 'AF' is union of two AL and FX.
% Their selection depends on what Higher-level state we are looking for. If
% no match, return ''.
%
% Currently we just compute successful states like: 
% - 'ROT' - rotation, 
% - 'SNP' - snap,
% - 'MAT' - mating.
%
% Inputs:
% HLB_State          - String in the form 
% llbStruc          - this is a (n x 4) structure continaing:
%                     {'llbtag' StartingTime EndingTime Duration}
% HLB_State string  - one of the tree mentioned above.
%
% Outputs:
% currLLB            - an LLB encoded as an integer according to the LLB
%                     struc. The result is used the in the system model as part of the
%                     prediction stage of the bayes filtering computation.
% prevLLB            - 
%%
function currLLB = KeyLLBLookUp(HLB_State,Axes)

%% Policies according to HLB state for a given axes
    ROT     = ['FX';     'NA';    'FX';    'NA';    'FX';    'NA']; % For string vectors, we need all elements to have the same length.
    SNAP    = ['CT';     'AF';    'FX';    'AF';    'CT';    'AF'];
    MAT     = ['FX';     'FX';    'FX';    'FX';    'FX';    'FX'];
    
    % Retun for rotation
	if(strcpy(HLB_State,'ROT'))
        currLLB= ROT(Axes);
        %prevLLB= currLLB;
        
    elseif(strcpy(HLB_State,'SNP'))
        currLLB= SNAP(Axes);
        %prevLLB= currLLB;        
        
    elseif(strcpy(HLB_State,'MAT'))
        currLLB= MAT(Axes);      
        %prevLLB= currLLB;
    else
        currLLB = '';
    end
        
%% Convert string into into integer
    currLLB = convertLLB2int(currLLB);
    %prevLLB = convertLBL2int(prevLLB);

end