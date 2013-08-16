% checkLLBExistance
% This function is a recursive function designed to check whether or not 
% the LLBs passed into the function for a given automata state (through the 
% structure stateLLBstruc) actually exist or not. This will help us to verify
% conditions. 
%
% Conditions could be used to verify whether a task is successful or
% whether an anomaly is present in case of malformed assemblies.
%
% Note:
% Another external function will be needed to iterative through: (a)
% different automata states, and (b) different conditions one wants to
% check, whether successful or anomalous.
%
% Inputs: 
%
% stateLbl:         this is a multidimensional array (4xmx6). That is 4
%                   automata states (Approach, Rotation, Insertion, Mating) with a un unknown
%                   number of lables. In fact, m is determined by the largest number of
%                   labels across all 4 states. This implies that mean elements in the array
%                   will be padded with zeros.
% stateLLBstruc:    This is a structure that contains as a field the
%                   axis we want to test, and as values the LLB labels that we want to check.
%                   These LLB labels will be represented by integers to ease conversion in
%                   matlab coder.
% testCondition     has a default value = 0. This value is changed and
% return to true if, the labels are present in the given axis. 
function exist = checkLLBExistance( stateLbl, stateLLBstruc, testCondition)



end

