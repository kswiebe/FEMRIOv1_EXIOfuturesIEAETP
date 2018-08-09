function [natUSE,impUSE,natSUP] = AggregateMRSUT2national(MRUSE,MRSUP,nreg,nprod,nind)
    natSUP = zeros(nprod,nreg*nind);
    natUSE = zeros(nprod,nreg*nind);
    impUSE = zeros(nprod,nreg*nind);
    domUSE = zeros(nprod,nreg*nind);
    for reg = 1:nreg
        indix1 = CouSthIndex(reg,1,nind);
        indix2 = CouSthIndex(reg,nind,nind);
        prodix1 = CouSthIndex(reg,1,nprod);
        prodix2 = CouSthIndex(reg,nprod,nprod);
        natSUP(:,indix1:indix2) = MRSUP(prodix1:prodix2,indix1:indix2);
        domUSE(:,indix1:indix2) = MRUSE(prodix1:prodix2,indix1:indix2);
        natUSE = natUSE + MRUSE(prodix1:prodix2,:);
    end
    impUSE = natUSE - domUSE;
end
