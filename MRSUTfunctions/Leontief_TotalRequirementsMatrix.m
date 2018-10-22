function [Lindprod,Lprodprod] = Leontief_TotalRequirementsMatrix(MRUSEcoefB,MRSUPcoefD,nreg,nprod,nind)
    % Total requirements matrix of size ind x prod
    % [D(I-BD)^1]
    %producteye = eye(nreg*nprod);
    %industryeye = eye(nreg*nind);
    temp = eye(nreg*nprod) - MRUSEcoefB*MRSUPcoefD; 
    Lprodprod = inv(temp);
    Lindprod = MRSUPcoefD * Lprodprod;
end