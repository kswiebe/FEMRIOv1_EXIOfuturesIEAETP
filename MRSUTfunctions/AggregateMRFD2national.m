function [natFD,FDimpShareTTL,FDimpShareBilateral] = AggregateMRFD2national(MRFD,nreg,nprod,nfd)
    natFD = zeros(nprod,nreg*nfd);
    domFD = zeros(nprod,nreg*nfd);
    
    for reg = 1:nreg
        fdix1 = CouSthIndex(reg,1,nfd);
        fdix2 = CouSthIndex(reg,nfd,nfd);
        prodix1 = CouSthIndex(reg,1,nprod);
        prodix2 = CouSthIndex(reg,nprod,nprod);
        domFD(:,fdix1:fdix2) = MRFD(prodix1:prodix2,fdix1:fdix2);
        natFD = natFD + MRFD(prodix1:prodix2,:);
    end
    impFD = natFD - domFD;
    
    FDimpShareTTL = impFD./natFD;
    FDimpShareTTL(isnan(FDimpShareTTL)) = 0;
    FDimpShareTTL(isinf(FDimpShareTTL)) = 0;
    
    FDimpShareBilateral = MRFD./repmat(impFD,nreg,1);
    FDimpShareBilateral(isnan(FDimpShareBilateral)) = 0;
    FDimpShareBilateral(isinf(FDimpShareBilateral)) = 0;
    %set diagonals to zero
     for reg = 1:nreg
        fdix1 = CouSthIndex(reg,1,nfd);
        fdix2 = CouSthIndex(reg,nfd,nfd);
        prodix1 = CouSthIndex(reg,1,nprod);
        prodix2 = CouSthIndex(reg,nprod,nprod);
        FDimpShareBilateral(prodix1:prodix2,fdix1:fdix2)=0;
    end
end