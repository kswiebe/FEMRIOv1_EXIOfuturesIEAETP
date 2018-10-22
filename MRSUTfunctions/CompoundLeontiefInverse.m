function [Lstar] = CompoundLeontiefInverse(MRUSEcoefB,MRSUPcoefD,nreg,nprod,nind)
    % compound Leontief inverse Lstar
    producteye = eye(nreg*nprod);
    industryeye = eye(nreg*nind);
    compound = [producteye,-MRUSEcoefB;-MRSUPcoefD,industryeye]; 
    Lstar = inv(compound);
end