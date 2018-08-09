function [natUSEcoefB,impUSEcoefB,natSUPcoefD] = AggregateMRSUTcoef2national(MRUSEcoefB,MRSUPcoefD,nreg,nprod,nind)
    natSUPcoefD = zeros(nind,nreg*nprod);
    natUSEcoefB = zeros(nprod,nreg*nind);
    impUSEcoefB = zeros(nprod,nreg*nind);
    domUSEcoefB = zeros(nprod,nreg*nind);
    for reg = 1:nreg
        indix1 = CouSthIndex(reg,1,nind);
        indix2 = CouSthIndex(reg,nind,nind);
        prodix1 = CouSthIndex(reg,1,nprod);
        prodix2 = CouSthIndex(reg,nprod,nprod);
        natSUPcoefD(:,prodix1:prodix2) = MRSUPcoefD(indix1:indix2,prodix1:prodix2);
        domUSEcoefB(:,indix1:indix2) = MRUSEcoefB(prodix1:prodix2,indix1:indix2);
        natUSEcoefB = natUSEcoefB + MRUSEcoefB(prodix1:prodix2,:);
    end
    impUSEcoefB = natUSEcoefB - domUSEcoefB;  
end