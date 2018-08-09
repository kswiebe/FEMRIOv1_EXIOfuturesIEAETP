function [MRUSEcoef] = DisaggregateNational2MRUSEcoef(natUSEcoef,ImpShareTTL,ImpShareBilateral,nreg,nind,nprod)
% can also be used to disaggregate final demand matrix
% DisaggregateNational2MRUSEcoef(natFD,FDimpShareTTL,FDimpShareBilateral,nreg,nfd,nprod)
    impUSEcoef = ImpShareTTL.*natUSEcoef;
    domUSEcoef = natUSEcoef - impUSEcoef;
    MRUSEcoef = ImpShareBilateral.*repmat(impUSEcoef,nreg,1);
    for reg=1:nreg
        indix1 = CouSthIndex(reg,1,nind);
        indix2 = CouSthIndex(reg,nind,nind);
        prodix1 = CouSthIndex(reg,1,nprod);
        prodix2 = CouSthIndex(reg,nprod,nprod);
        MRUSEcoef(prodix1:prodix2,indix1:indix2) = domUSEcoef(:,indix1:indix2);
    end
end