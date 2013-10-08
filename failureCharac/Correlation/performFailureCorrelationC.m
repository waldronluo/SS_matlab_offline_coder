% performFailureCorrelationC
% This function 

function [MyR1,MzR1,MzR23,FzA1,FzA2,FzA3]=performFailureCorrelationC(MyR_mean,MyR,MzR,FzA)

    %% Create index values for historical averaged data: counters, means, upper_bounds, and lower_bounds
    % MyR
    %MyRc=MyR(1,1); 
    MyRm=MyR(2,1); MyR_UB=MyR(3,1); MyR_LB=MyR(4,1);

    % MzR
    % 1D
    %MzR1c=MzR(1,1);  
    MzR1m=MzR(2,1);  MzR1_UB=MzR(3,1);  MzR1_LB=MzR(4,1);
    % 2D or 3D
    %MzR23c=MzR(5,1); 
    MzR23m=MzR(6,1); MzR23_UB=MzR(7,1); MzR23_LB=MzR(8,1);

    % FzA
    % 1D
    %FzA1c=FzA(1,1); 
    FzA1m=FzA(2,1);  FzA1_UB=FzA(3,1);  FzA1_LB=FzA(4,1);
    
    %FzA2c=FzA(5,1); 
    FzA2m=FzA(6,1);  FzA2_UB=FzA(7,1);  FzA2_LB=FzA(8,1);
    
    %FzA3c=FzA(9,1); 
    FzA3m=FzA(10,1); FzA3_UB=FzA(11,1); FzA3_LB=FzA(12,1);

    ratio=MyR_mean/MyR(MyRm,fCol);      if( ratio>=MyR_UB || ratio <= MyR_LB ); MyR1=1;         else MyR1=0;        end; 
    %-----------------------------------------------------------------------------------------------------------------------------------------------
    ratio=MyR_mean/MzR(MzR1m, fCol);    if( ratio>=MzR1_UB  || ratio <= MzR1_LB  ); MzR1=1;     else MzR1=0;        end;  
    ratio=MyR_mean/MzR(MzR23m,fCol);    if( ratio>=MzR23_UB || ratio <= MzR23_LB ); MzR23=1;    else MzR23=0;       end;
    %-----------------------------------------------------------------------------------------------------------------------------------------------
    ratio=MyR_mean/FzA(FzA1m,fCol);     if( ratio>=FzA1_UB || ratio <= FzA1_LB ); FzA1=1;       else FzA1=0;        end;  
    ratio=MyR_mean/FzA(FzA2m,fCol);     if( ratio>=FzA2_UB || ratio <= FzA2_LB ); FzA2=1;       else FzA2=0;        end;
    ratio=MyR_mean/FzA(FzA3m,fCol);     if( ratio>=FzA3_UB || ratio <= FzA3_LB ); FzA3=1;       else FzA3=0;        end;  


end