
for year=startyear:endyear
        t = year-startyear+1;
        load([MRIO_data_path,'MRSUT_',num2str(year),'.mat']);
        MRSUP = MRSUT.mrsup; % MRMAKE = transpose(SUTagg.mrsup);
        MRUSE = MRSUT.mrbpimp + MRSUT.mrbpdom;
        MRFD = MRSUT.mrbpimpfd + MRSUT.mrbpdomfd;
        MRSUT.mrbpdomva(5:8,:)=abs(MRSUT.mrbpdomva(5:8,:));
        MRVA = MRSUT.mrbpdomva;
        MRVA(end+1,:) = sum(MRSUT.mrbpdomva(relVA,:),1);
    
        if year == endyear && currentprices == 1
            SUT.scenarioname = 'EXIOhist';
            SUT.year = year; 
            SUT.meta = MRSUT.meta;
            SUT.MRSUP = MRSUP;
            SUT.MRUSE = MRUSE;
            SUT.MRFD = MRFD;
            SUT.MRVA = MRVA;
        end
        
        % Macro variables
        fdvec = sum(MRFD,1);%column sum
        for c = 1:nreg
            MacroData.HOUS(c,t) = fdvec(CouSthIndex(c,1,nfd));
            MacroData.NPSH(c,t) = fdvec(CouSthIndex(c,2,nfd));
            MacroData.GOVE(c,t) = fdvec(CouSthIndex(c,3,nfd));
            MacroData.GFCF(c,t) = fdvec(CouSthIndex(c,4,nfd));
            MacroData.CIES(c,t) = fdvec(CouSthIndex(c,5,nfd))+fdvec(CouSthIndex(c,6,nfd));
            MacroData.TAX(c,t) = sum(sum(MRVA(1:4,CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))));
            MacroData.WAGE(c,t) = sum(sum(MRVA(5:8,CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))));
            MacroData.NOS(c,t) = sum(sum(MRVA(9:12,CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))));
        end
        % trade
        for c = 1:nreg
            DOMUSE = sum(sum(MRUSE(CouSthIndex(c,1,nprod):CouSthIndex(c,nprod,nprod),CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))));
            DOMFD = sum(sum(MRUSE(CouSthIndex(c,1,nprod):CouSthIndex(c,nprod,nprod),CouSthIndex(c,1,nfd):CouSthIndex(c,nfd,nfd))));
            EXPUSEtemp = sum(sum(MRUSE(CouSthIndex(c,1,nprod):CouSthIndex(c,nprod,nprod),:)));
            EXPFDtemp = sum(sum(MRUSE(CouSthIndex(c,1,nprod):CouSthIndex(c,nprod,nprod),:)));
            IMPUSEtemp = sum(sum(MRUSE(:,CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))));
            IMPFDtemp = sum(sum(MRUSE(:,CouSthIndex(c,1,nfd):CouSthIndex(c,nfd,nfd))));
            MacroData.IMPUSE(c,t) = IMPUSEtemp - DOMUSE;
            MacroData.EXPUSE(c,t) = EXPUSEtemp - DOMUSE;
            MacroData.IMPFD(c,t) = IMPFDtemp - DOMFD;
            MacroData.EXPFD(c,t) = EXPFDtemp - DOMFD;
            MacroData.EXP(c,t) = MacroData.EXPUSE(c,t) + MacroData.EXPFD(c,t);
            MacroData.IMP(c,t) = MacroData.IMPUSE(c,t) + MacroData.IMPFD(c,t);
        end
    end