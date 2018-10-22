% calculate compound Leontief inverse Lstar for MRSUT

function [Lstar,FDtot,guse,qsup] = MRSUT_calc_Lstar_FDtot(SUT,noregions,noindustries,noproducts)
    % total product output q
    qsup = sum(SUT.mrsup,2);
    quse = sum(SUT.mrbpdom,2) + sum(SUT.mrbpimp,2) + sum(SUT.mrbpdomfd,2) + sum(SUT.mrbpimpfd,2);
    sum(qsup-quse)/sum(qsup); % this is not zero.... but less than 0.00001% difference

    % total industry output g
    gsup = sum(SUT.mrsup,1);
    guse = sum(SUT.mrbpdom,1) + sum(SUT.mrbpimp,1) + sum(SUT.mrbpdomva,1);
    sum(gsup-guse); % this is not zero.... but less than 0.00001% difference


    % check total supply side qsup + guse is equal to toal demand side gsup + quse
    sum(qsup)+sum(guse);
    sum(gsup)+sum(quse);

    % total use table
    SUT.mrbpuse = SUT.mrbpdom + SUT.mrbpimp;
    % Use coefficients B
    oneoverg = 1./guse;
    oneoverg(isinf(oneoverg))=0;
    SUT.B = SUT.mrbpuse * diag(oneoverg);

    % market share coefficients D
    oneoverq = 1./qsup;
    oneoverq(isinf(oneoverq))=0;
    SUT.D = transpose(SUT.mrsup) * diag(oneoverq);

    % compound Leontief inverse Lstar
    producteye = eye(noregions*noproducts);
    industryeye = eye(noregions*noindustries);
    compound = [producteye,-SUT.B;-SUT.D,industryeye]; 
    Lstar = inv(compound);

    % va shares
    % vashares = SUT.mrbpdomva * diag(oneoverg);

    % final demand
    FDtot = SUT.mrbpdomfd + SUT.mrbpimpfd;
end