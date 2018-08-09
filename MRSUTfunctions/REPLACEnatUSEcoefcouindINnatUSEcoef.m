function [natUSEcoef] = REPLACEnatUSEcoefcouindINnatUSEcoef(natUSEcoef, natUSEcoefcouind,country,industry,nind)
    cx = CouSthIndex(country,industry,nind);
    natUSEcoef(:,cx) = natUSEcoefcouind;
end