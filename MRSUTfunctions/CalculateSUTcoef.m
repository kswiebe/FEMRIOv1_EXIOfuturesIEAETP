function [MRUSEcoefB,MRSUPcoefD,VAcoef] = CalculateSUTcoef(MRUSE,MRSUP,MRVA,guse,qsup)
    % Use coefficients B
    oneoverg = 1./guse;
    oneoverg(isinf(oneoverg))=0;
    MRUSEcoefB = MRUSE * diag(oneoverg);

    % VA coefficients
    VAcoef = MRVA * diag(oneoverg);
    
    % Market share coefficients D
    
    oneoverq = 1./qsup;
    oneoverq(isinf(oneoverq))=0.000000000001;
    MRSUPcoefD = transpose(MRSUP) * diag(oneoverq);
    
end