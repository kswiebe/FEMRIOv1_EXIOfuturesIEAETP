function [MR] = DisaggregateNational2MR(nat,ImpShareTTL,ImpShareBilateral,nreg,nspalte,nzeile)
% nspalte = number of columns = nind in use table, nfd in FD
% nzeile = number of rows, usually equal to nprod
% can also be used to disaggregate final demand matrix
% DisaggregateNational2MRUSEcoef(natFD,FDimpShareTTL,FDimpShareBilateral,nreg,nfd,nprod)
    imp = ImpShareTTL.*nat;
    dom = nat - imp;
    %fill import blocks. the diagonal blocks are zero in ImpSharebilateral
    MR = ImpShareBilateral.*repmat(imp,nreg,1);
    % fill diagonal matrix block = domestic
    for reg=1:nreg
        indix1 = CouSthIndex(reg,1,nspalte);
        indix2 = CouSthIndex(reg,nspalte,nspalte);
        prodix1 = CouSthIndex(reg,1,nzeile);
        prodix2 = CouSthIndex(reg,nzeile,nzeile);
        MR(prodix1:prodix2,indix1:indix2) = dom(:,indix1:indix2);
    end
end