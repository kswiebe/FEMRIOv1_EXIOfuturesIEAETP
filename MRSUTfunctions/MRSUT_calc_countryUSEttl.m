function [mrbpttl,mrbpimpttl,mrbpdomttl] = MRSUT_calc_countryUSEttl(SUT,noregions,noindustries,noproducts)
    mrbpimpttl = zeros(noproducts,noregions*noindustries);
    mrbpdomttl = zeros(noproducts,noregions*noindustries);
    for r = 1:noregions
        r1 = (r-1)*noproducts+1;
        r2 = r*noproducts;
        mrbpimpttl = mrbpimpttl + SUT.mrbpimp(r1:r2,:);
        mrbpdomttl = mrbpdomttl + SUT.mrbpdom(r1:r2,:);
    end
    mrbpttl = mrbpimpttl + mrbpdomttl;
    
end