function [MRSUT] = createEXIOBASEMRSUT(SUT_t,nreg,nprod,nind,nfd,nva)
        MRSUT.mrsup = (SUT_t.MRSUP)';
        MRSUT.mrbpdom = SUT_t.MRUSE; %MRUSE = MRSUT.mrbpimp + MRSUT.mrbpdom;
        MRSUT.mrbpdomfd = SUT_t.MRFD;
        for c=1:nreg
            MRSUT.mrbpdom(CouSthIndex(c,1,nprod):CouSthIndex(c,nprod,nprod),CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind)) = 0;
            MRSUT.mrbpdomfd(CouSthIndex(c,1,nprod):CouSthIndex(c,nprod,nprod),CouSthIndex(c,1,nfd):CouSthIndex(c,nfd,nfd)) = 0;
        end
        MRSUT.mrbpdomva = SUT_t.MRVA(1:nva,:);
        MRSUT.mrbpimp = SUT_t.MRUSE - MRSUT.mrbpdom; %MRUSE = MRSUT.mrbpimp + MRSUT.mrbpdom;
        MRSUT.mrbpimpfd = SUT_t.MRFD - MRSUT.mrbpdomfd; % MRFD = MRSUT.mrbpimpfd + MRSUT.mrbpdomfd;
        % ??? MRSUT.dom_exp = 
        % ??? MRSUT.re_exp = 
        MRSUT.year = SUT_t.year;
        MRSUT.currency = 'Euro';
        MRSUT.git = 'unknown';
        MRSUT.price = 'constant';
        MRSUT.vers = SUT_t.scenarioname;
        MRSUT.meta = SUT_t.meta;
end