function [MRSUPcoefD] = National2MRSUPcoef(natSUPcoef,nreg,nind,nprod)
    for reg=1:nreg
        indix1 = CouSthIndex(reg,1,nind);
        indix2 = CouSthIndex(reg,nind,nind);
        prodix1 = CouSthIndex(reg,1,nprod);
        prodix2 = CouSthIndex(reg,nprod,nprod);
        MRSUPcoefD(indix1:indix2,prodix1:prodix2) = natSUPcoef(:,prodix1:prodix2);
    end
end