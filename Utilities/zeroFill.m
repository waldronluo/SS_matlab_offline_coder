%*************************** Documentation *******************************
% zeroFill is a function that takes 6 mx17 arrays. Because the size of the
% rows for each array is different we have to pad with zeros. The function
% will get the size of the larges array and use that to fill with zeros the
% rest of the arrays.
%
% Inputs:
% llbehFx-llbehMz: mx17 structures that contains all the fields of
% information generated in the pRCBHT 4th layer: Low-Level Behavior
% implementaiton. 
%
% Outputs:
% llbehFM:  A 3D array, mx17x6. 
% numElems: returns the last row that contians non-zero entrries for each
% of the siz structures.
%**************************************************************************
function [llbehFM,numElems] = zeroFill(llbehFx,llbehFy,llbehFz,llbehMx,llbehMy,llbehMz)

    % Create numElems column vector and rowPadding column vector
    numElems = zeros(1,6);
    rowPadding = zeros(1,6);
    
    % Retrieve the size
    [numElems(1,1),~] = size(llbehFx);
    [numElems(1,2),~] = size(llbehFy);
    [numElems(1,3),~] = size(llbehFz);
    [numElems(1,4),~] = size(llbehMx);
    [numElems(1,5),~] = size(llbehMy);
    [numElems(1,6),~] = size(llbehMz);
    
    % Find maximum value for number of rows
    maxRowNum = max(numElems);
        
    %% Perform Padding
    
    % Find the difference between max value and numElems
    for i=1:6
        
        % How many rows need padding
        rowPadding(1,i) = maxRowNum - numElems(i);
        
        % Fill
        if(i==1)
            llbehFx(end+1:end+rowPadding(1,i),:) = zeros(rowPadding(1,i),17);
        elseif(i==2)
            llbehFy(end+1:end+rowPadding(1,i),:) = zeros(rowPadding(1,i),17);
        elseif(i==3)
            llbehFz(end+1:end+rowPadding(1,i),:) = zeros(rowPadding(1,i),17);
        elseif(i==4)
            llbehMx(end+1:end+rowPadding(1,i),:) = zeros(rowPadding(1,i),17);
        elseif(i==5)
            llbehMy(end+1:end+rowPadding(1,i),:) = zeros(rowPadding(1,i),17);
        elseif(i==6)
            llbehMz(end+1:end+rowPadding(1,i),:) = zeros(rowPadding(1,i),17);            
        end
    end
    
    % Compound the structures into a 3D array.
    llbehFM = zeros(maxRowNum,17,6);
    llbehFM(:,:,1) = llbehFx;
    llbehFM(:,:,2) = llbehFy;
    llbehFM(:,:,3) = llbehFz;
    llbehFM(:,:,4) = llbehMx;
    llbehFM(:,:,5) = llbehMy;
    llbehFM(:,:,6) = llbehMz;
    
end