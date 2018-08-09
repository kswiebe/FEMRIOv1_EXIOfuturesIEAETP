function [trade_pxp] = calctradematrix_pxp(LYdiag,S,char,nreg,nind)
% Y contains one column per country
% Y can also be replaced by exports
% S is the full stressor matrix
   
    % usual prod and cons
    trade_pxp = zeros(nreg*nind,nreg*nind,size(char,1));
    
    for c = 1:size(char,1)
        charcS = diag(char(c,:) * S);
        trade_pxp(:,:,c) = charcS * LYdiag;
    end


end %calctradematrix_pxp