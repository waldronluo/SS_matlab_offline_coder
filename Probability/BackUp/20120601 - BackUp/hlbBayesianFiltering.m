%% hlbBayesFiltering
% 
% Overview
% Computes the belief for each of the three -- force-containgin -- Side Approach (Pivot Approach
% with 4 Snaps) high-level-behavior (HLB) states: Rotation, Snap, and
% Mating.
%
% HLB Beliefs:
% The HLB beliefs are conceptualized as follows:
% Belief(Rotation), Belief(Snap|Rotation), Belief(Mating|Snap,Rotation)
%
% Conditional Probabilities:
% These conditional probabilities will be computed using joint
% distributions. The joint probabilities will be model with a linear
% distribution. Such that as Rotation is more likely to succeed, so is the
% Snap, in a linear fashion.
%
% HLB Prior Probabilities:
% The HLB prior probabilities are computed as the product of "key llb
% beliefs" for a given automata state for all force axes.
%
% A table is used to represent the desired llb's:

%%
function hlbBelief = hlbBayesFiltering(StrategyType,FolderName,llbBelief);

end