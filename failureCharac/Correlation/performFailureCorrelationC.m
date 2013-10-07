% performFailureCorrelationC
% This function 

function [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3]=performFailureCorrelationC(MyR_mean,MyR,MzR,FzA)

    %% Create index values for historical averaged data: counters, means, upper_bounds, and lower_bounds
    % MyR
    MyRc=1; MyRm=2; MyR_UB=3; MyR_LB=4;

    % MzR
    % 1D
    MzR1c=1;  MzR1m=2;  MzR1_UB=3;  MzR1_LB=4;
    % 2D or 3D
    MzR23c=5; MzR23m=6; MzR23_UB=7; MzR23_LB=8;

    % FzA
    % 1D
    FzA1c=1; FzA1m=2;  FzA1_UB=3;  FzA1_LB=4;
    FzA2c=5; FzA2m=6;  FzA2_UB=7;  FzA2_LB=8;
    FzA3c=9; FzA3m=10; FzA3_UB=11; FzA3_LB=12;

    ratio=MyR_mean/MyR(MyRm,fCol);      if( ratio>=MyR_UB || ratio <= MyR_LB ); MyR1=1;         else MyR1=0;        end; 
    %-----------------------------------------------------------------------------------------------------------------------------------------------
    ratio=MyR_mean/MzR(MzR1m, fCol);    if( ratio>=MzR1_UB  || ratio <= MzR1_LB  ); MzR1=1;     else MzR1=0;        end;  
    ratio=MyR_mean/MzR(MzR23m,fCol);    if( ratio>=MzR23_UB || ratio <= MzR23_LB ); MzR23=1;    else MzR23=0;       end;
    %-----------------------------------------------------------------------------------------------------------------------------------------------
    ratio=MyR_mean/FzA(FzA1m,fCol);     if( ratio>=FzA1_UB || ratio <= FzA1_LB ); FzA1=1;       else FzA1=0;        end;  
    ratio=MyR_mean/FzA(FzA2m,fCol);     if( ratio>=FzA2_UB || ratio <= FzA2_LB ); FzA2=1;       else FzA2=0;        end;
    ratio=MyR_mean/FzA(FzA3m,fCol);     if( ratio>=FzA3_UB || ratio <= FzA3_LB ); FzA3=1;       else FzA3=0;        end;  


end