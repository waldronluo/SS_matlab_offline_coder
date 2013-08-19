%% convertLLB2int
% Accepts a stringed tag for an LLB: {FX CT PS PL SH AL} and returns the
% corresponding index.

function llbTag = convertLLB2int(llbTag)

%% Return index according to string llb tag
    if(strcmp(llbTag,'FX')) 
        llbTag = 1;
    elseif(strcmp(llbTag,'CT')) 
        llbTag = 2;
    elseif(strcmp(llbTag,'PS')) 
        llbTag = 3;
    elseif(strcmp(llbTag,'PL')) 
        llbTag = 4;
    elseif(strcmp(llbTag,'SH')) 
        llbTag = 5;
    elseif(strcmp(llbTag,'AL')) 
        llbTag = 6;
    end
    
end