function [ImpShareTTL,ImpShareBilateral] = GetTradeShares(natUSE,impUSE,MRUSE,nreg,nprod,nind)
% natUSE,impUSE,MRUSE can be from flow matrix or from coefficient matrices
    ImpShareTTL = impUSE./natUSE;
    ImpShareTTL(isnan(ImpShareTTL)) = 0;
    ImpShareTTL(isinf(ImpShareTTL)) = 0;
    ImpShareBilateral = MRUSE./repmat(impUSE,nreg,1);
    % set diagonal blocks to zero
    for c = 1:nreg
        p1 = (c-1)*nprod+1;
        p2 = c*nprod;
        i1 = (c-1)*nind+1;
        i2 = c*nind;
        ImpShareBilateral(p1:p2,i1:i2) = zeros(nprod,nind);
    end
    ImpShareBilateral(isnan(ImpShareBilateral)) = 0;
    ImpShareBilateral(isinf(ImpShareBilateral)) = 0;  
end