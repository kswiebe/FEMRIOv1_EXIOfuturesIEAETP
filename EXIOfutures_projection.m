%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Projection loop over years
% called from EXIOfutures_part2

%% initalize scenario data
SUT = SUThist;
SUT_t = SUT;
MacroData = MacroDatahist;
MacroData.scenarioname = scenarioname;
%MacroData.countrycodes = regioncodes;
MacroData.years = startyear:finalyear;
scenariopath = ['futures\',scenarioname,'\'];

% demand model
addpath('DemandModelPADS\');
run('initializePADSmodel.m'); % contains path to Eivind's USER on NTNU Indecol Server, demand model will be published seperately

% additional investment into RE technologies
AdditionalREinvestment = zeros(length(RenEnTech.CapitalCostShareConcordance(2:end,1)),ttlyears,reg);


for year = (endyear+1):finalyear
    disp(['Starting calculations of scenario ',scenarioname,' for ',num2str(year)])
    % SUT_t is always filled with last years values, but changed within here
    % if we need to access last years' values we use SUT (which is set to
    % SUT_t in the end). If we need the values from the last available
    % year, use SUThist 

    %year
    t = year-startyear+1;
    SUT_t.scenarioname = scenarioname;
    SUT_t.year = year; 
    %----------------------------------------------------------------------
    % Final Demand initializations
    %----------------------------------------------------------------------
    tic
    disp(['Final demand at macro level....'])
    % use scenario assumptions on growth rates in GDP = value added 
    % OR estimations (but need epsilon adjustment)
    if FDestimations == 0  
        MacroData.GDPTRtemp(:,t) = MacroData.GDPTRshouldbe(:,t-1) .* (1+ MacroData.GDPgrowth(:,t));
        MacroData.HOUS(:,t) = MacroData.HOUS(:,t-1) + MacroData.HOUS(:,t-1).*MacroData.GDPgrowth(:,t);
        %MacroData.HOUSpc(:,t) = MacroData.HOUSpc(:,t-1) + MacroData.HOUSpc(:,t-1).*MacroData.GDPgrowth(:,t);
        %MacroData.HOUS(:,t) = MacroData.HOUSpc(:,t).*MacroData.POPU(:,t);
        MacroData.NPSH(:,t) = MacroData.NPSH(:,t-1) + MacroData.NPSH(:,t-1).*MacroData.GDPgrowth(:,t);
        MacroData.GOVE(:,t) = MacroData.GOVE(:,t-1) + MacroData.GOVE(:,t-1).*MacroData.GDPgrowth(:,t);
        MacroData.GFCF(:,t) = MacroData.GFCF(:,t-1) + MacroData.GFCF(:,t-1).*MacroData.GDPgrowth(:,t);
    end
    MacroData.CIES(:,t) = MacroData.CIES(:,nyears) * 1^(1/(year-endyear));% fd cat 5 and 6
    if FDestimations == 1
        % what we want is to have GDPTR = GDPTRtemp (= GDPTRshouldbe, which
        % is implied as soon as the first equality holds)
        MacroData.GDPTRtemp(:,t) = MacroData.GDPTRshouldbe(:,t-1) .* (1+ MacroData.GDPgrowth(:,t));
        MacroData.HOUS(:,t) = regres.HOUS(:,1) + regres.HOUS(:,2).*MacroData.GDPTRtemp(:,t) - regres.HOUS_eps(:);
        %MacroData.HOUSpc(:,t) = regres.HOUSpc(:,1) + regres.HOUSpc(:,2).*(MacroData.GDPTRtemp(:,t)./MacroData.POPU(:,t)) - regres.HOUS_eps(:);
        %MacroData.HOUS(:,t) = MacroData.HOUSpc(:,t).*MacroData.POPU(:,t);
        MacroData.NPSH(:,t) = regres.NPSH(:,1) + regres.NPSH(:,2).*MacroData.GDPTRtemp(:,t) - regres.NPSH_eps(:);
        MacroData.GOVE(:,t) = regres.GOVE(:,1) + regres.GOVE(:,2).*MacroData.GDPTRtemp(:,t) - regres.GOVE_eps(:);
        MacroData.GFCF(:,t) = regres.GFCF(:,1) + regres.GFCF(:,2).*MacroData.GDPTRtemp(:,t) - regres.GFCF_eps(:);
    end
    % we need to ensure that global final demand equals global value added
    % from the scenario. Thus we may need to rescale
    FDmacroGDP = sum(MacroData.HOUS(:,t) + MacroData.NPSH(:,t) + MacroData.GOVE(:,t) + MacroData.GFCF(:,t) + MacroData.CIES(:,t));
    globalGDPtemp = sum(MacroData.GDPTRtemp(:,t));
    MacroData.HOUS(:,t) = MacroData.HOUS(:,t).* (globalGDPtemp/FDmacroGDP);
    MacroData.NPSH(:,t) = MacroData.NPSH(:,t).* (globalGDPtemp/FDmacroGDP);
    MacroData.GOVE(:,t) = MacroData.GOVE(:,t).* (globalGDPtemp/FDmacroGDP);
    MacroData.GFCF(:,t) = MacroData.GFCF(:,t).* (globalGDPtemp/FDmacroGDP);
    MacroData.CIES(:,t) = MacroData.CIES(:,t).* (globalGDPtemp/FDmacroGDP);
    % this would be scaling after the industry level calculations 
    % FDGDP = sum(sum(natFDnew));
    % natFDnew = natFDnew.* (globalGDPtemp/FDGDP);
    toc
    %----------------------------------------------------------------------
    % Final Demand estimations - INDUSTRY level
    %----------------------------------------------------------------------
    tic
    disp(['Final demand at industry level....'])
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %          make SUTagg.mrbpfd per year
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % set to endyear value for now and take growth rate relative to
    % endyear
    if changeConsStructure == 1 && usePADS == 1
        disp(['changeConsStructure == 1 && usePADS == 1']);
        disp(['Please choose only one household demand model!']);
        break;
    end
    
    %% initialize FD structure from base year
    natFDnew = SUThist.natFD;
    disp(['sum(sum(natFDnew)) 2014 = ',num2str(sum(sum(natFDnew))/1000000000)])
    disp(['min(min(natFDnew)) 2014 = ',num2str(min(min(natFDnew)))])
    
    MacroData.HOUSpc(:,t) = MacroData.HOUS(:,t)./MacroData.POPU(:,t);
    if usePADS == 1 && changeConsStructure == 0
        %pads model
        oldexp = SUT.natFD(:,1:nfd:end); % previous year's spending
        [newExpEXIO,PADS] = implementationPADSmodel(t,nyears,nreg,nprod,MacroData.HOUSpc,MacroData.POPU,PADS,oldexp);
        % scale to have total HOUS
        natFDnew(:,1:nfd:end)= newExpEXIO .* repmat(MacroData.HOUS(:,t)'./sum(newExpEXIO),nprod,1); 
        disp(['sum(sum(natFDnew)) after PADS = ',num2str(sum(sum(natFDnew))/1000000000)])
        disp(['min(min(natFDnew)) after PADS = ',num2str(min(min(natFDnew)))])
    end
    
    for reg=1:nreg
        %%% no changing consumption shares
        if changeConsStructure == 0 && usePADS == 0
            natFDnew(:,(reg-1)*nfd+1) = SUThist.natFD(:,(reg-1)*nfd+1) * (MacroData.HOUS(reg,t)/MacroData.HOUS(reg,nyears)); 
        end
        
        if changeConsStructure == 1 && usePADS == 0
            % changing HH consumption shares based on Alex Tisserants Engle curve estimations
            natFDnew(:,(reg-1)*nfd+1) = SUThist.natFD(:,(reg-1)*nfd+1) + (MacroData.HOUS(reg,t)-MacroData.HOUS(reg,nyears)) * SUT_t.MarginalConsumptionShares(:,reg);
            % based on PADS 
            % outside reg loop
        end
        % constant NPSH and GOVE consumpption shares
        natFDnew(:,(reg-1)*nfd+2) = SUThist.natFD(:,(reg-1)*nfd+2) * (MacroData.NPSH(reg,t)/MacroData.NPSH(reg,nyears));
        natFDnew(:,(reg-1)*nfd+3) = SUThist.natFD(:,(reg-1)*nfd+3) * (MacroData.GOVE(reg,t)/MacroData.GOVE(reg,nyears));
        
    end %for reg FDnew
    
    %disp('currently not changing energy use for NPSH and GOVE')
    if changeEnergyUse == 1
        % change energy use of government and NPSH according to 
        % IEA scenario for agriculture fishing and buildings
        fdcat = 1; %HOUS
        run('changeEnergyUSEfdcat.m');
        fdcat = 2; %NPSH
        run('changeEnergyUSEfdcat.m');
        fdcat = 3; %GOVE
        run('changeEnergyUSEfdcat.m');
    end
    disp(['sum(sum(natFDnew)) after energy = ',num2str(sum(sum(natFDnew))/1000000000)])
    disp(['min(min(natFDnew(:,1:nfd:end))) after energy = ',num2str(min(min(natFDnew(:,1:nfd:end))))])

   
    % for now, only make GFCF grow. the change in energy use will be
    % done below, when also considering the investment in the new RET
    for reg=1:nreg
        natFDnew(:,(reg-1)*nfd+4) = SUThist.natFD(:,(reg-1)*nfd+4) * (MacroData.GFCF(reg,t)/MacroData.GFCF(reg,nyears));
    end %for reg FDnew

    % Changes in inventories are going to zero, if they are not yet
    % zero
    for reg=1:nreg
        if MacroData.CIES(reg,nyears) ~= 0
            natFDnew(:,(reg-1)*nfd+5) = SUThist.natFD(:,(reg-1)*nfd+5)*(MacroData.CIES(reg,t)/MacroData.CIES(reg,nyears)); 
            natFDnew(:,(reg-1)*nfd+6) = SUThist.natFD(:,(reg-1)*nfd+6)*(MacroData.CIES(reg,t)/MacroData.CIES(reg,nyears));
        end
    end %for reg FDnew

    %disp(['1. sum(sum(natFDnew) = ',num2str(sum(sum(natFDnew)))])
    % adapt shares of electricity consumption
    %disp(['1. sum(sum(natFDnew))',num2str(sum(sum(natFDnew(elecprod,302:308))))])
       % disp('currently not changeElecConsShare for FD')

    
    if changeEnergyUse == 1
        newelectricitydemand = changeElectricityTypeUse(natFDnew,SUT.natFD,IEAEXIO.ElecGenAllYears,nreg,nfd,elecprod,t);
        %newelectricitydemand = changeElecConsShare(natFDnew,IEAEXIO.ElecGenAllYearsShares,nreg,nfd,elecind,t);
        natFDnew = newelectricitydemand;
        %disp(['2. sum(sum(natFDnew))',num2str(sum(sum(natFDnew(elecprod,302:308))))])
    end
    disp(['2. sum(sum(natFDnew)) after electricity = ',num2str(sum(sum(natFDnew))/1000000000)])
    disp(['2. min(min(natFDnew)) after electricity = ',num2str(min(min(natFDnew)))])
    
    % circular economy intervention 3 (service economy)
    if circulareconomy == 1
       run('CircularEconomy_ServiceEconomy.m');
    end % circulareconomy
    
    
    toc
    %----------------------------------------------------------------------
    % Change input coefficients  
    %----------------------------------------------------------------------
    tic
    disp(['Changing input coefficients....'])
    % initialization with last years value
    % 1) default coefficient change: no change 
    natUSEcoefBnew = SUT_t.natUSEcoefB;
    
    %disp(['1. min(min(natUSEcoefBnew) = ',num2str(min(min(natUSEcoefBnew)))])
    % Country-specific
    % 2) change energy input coefficients, i.e. rows, based on 
    %    IEAEPT2015 and rescale remaining  rows

    % 2.1) change electricity technology industry coef
    if changeElecTechCoef == 1
        % this not only changes the coefficients, but also the
        % corresponding required investment in RET
        run('changeElecTechCoef_iter1.m');
    end % changeElecTechCoef      
    %disp(['12. min(min(natUSEcoefBnew) = ',num2str(min(min(natUSEcoefBnew)))])
    %disp(['3. sum(sum(natFDnew) = ',num2str(sum(sum(natFDnew)))])
    if changeEnergyUse == 1 % adapt the GFCF energy use after changing the investment in the RET
        % change energy use according to IEA scenario for agriculture fishing and buildings
        fdcat = 4; %GFCF
        run('changeEnergyUSEfdcat.m');
    end
    %disp(['4. sum(sum(natFDnew) = ',num2str(sum(sum(natFDnew)))])
    
    % 2.2) change energy use coefficients according to IEA scenario
    if changeEnergyUse == 1
        run('changeEnergyUSEcoef.m');
    end
    %disp(['2. min(min(natUSEcoefBnew) = ',num2str(min(min(natUSEcoefBnew)))])
    
    % 2.3) change electricity technology use coefficients
        %disp('currently not changeElecConsShare for use coef')
    if changeEnergyUse == 1
       % newelectricitydemand = changeElecConsShare(natUSEcoefBnew,IEAEXIO.ElecGenAllYearsShares,nreg,nind,elecind,t);
        newelectricitydemand = changeElectricityTypeUse(natUSEcoefBnew,SUT.natUSEcoefB,IEAEXIO.ElecGenAllYears,nreg,nind,elecprod,t);
        natUSEcoefBnew = newelectricitydemand;
    end
    %disp(['3. min(min(natUSEcoefBnew) = ',num2str(min(min(natUSEcoefBnew)))])
    
    % circular economy intervention 2 (material efficiency)
    if circulareconomy == 1
       run('CircularEconomy_MaterialUseCoefficients.m');
    end % circulareconomy
    %disp(['4. min(min(natUSEcoefBnew) = ',num2str(min(min(natUSEcoefBnew)))])
    
    % adapting motor vehicle industry inputs accoring to electric vehicle
    % share increase
    natUSEcoefBcar = natUSEcoefBnew;
    if sum(IEAEXIO.EVshareincrease(:,t)) > 0
        natUSEcoefBcar(elecmachprod,motvehind:nind:end) = natUSEcoefBnew(elecmachprod,motvehind:nind:end) + ...
            IEAEXIO.EVelecmachincoef * IEAEXIO.EVshareincrease(:,t)';
        % rescale
        totalmot = sum(natUSEcoefBcar(:,motvehind:nind:end)) + sum(SUT_t.VAcoef(relVA,motvehind:nind:end));
        natUSEcoefBnew(:,motvehind:nind:end) = natUSEcoefBcar(:,motvehind:nind:end)./repmat(totalmot,nprod,1);
        SUT_t.VAcoef(relVA,motvehind:nind:end) = SUT_t.VAcoef(relVA,motvehind:nind:end)./repmat(totalmot,length(relVA),1);
    end
%    disp(['5. min(min(natUSEcoefBnew) = ',num2str(min(min(natUSEcoefBnew)))])
    
    if greenagriculture == 1
        run('GreenAgr_EXIOfuturesprojection.m');
    end %greenagriculture

    disp(['max(sum(natUSEcoefBnew) = ',num2str(max(sum(natUSEcoefBnew)))])
    disp(['min(sum(natUSEcoefBnew) = ',num2str(min(sum(natUSEcoefBnew)))])
    disp(['max(max(natUSEcoefBnew) = ',num2str(max(max(natUSEcoefBnew)))])
    disp(['min(min(natUSEcoefBnew) = ',num2str(min(min(natUSEcoefBnew)))])

    % setting extraterritorial organizations to zero
    natUSEcoefBnew(end,:)=0;
    natUSEcoefBnew(:,nind:nind:end)=0;
    
    %disp(['sum(natUSEcoefBnew(118,:)) = ',num2str(sum(natUSEcoefBnew(118,:)))])
    %disp(['sum(natUSEcoefBnew(120,:)) = ',num2str(sum(natUSEcoefBnew(120,:)))])
    
 %   [natUSEcoefBnew,SUT_t.VAcoef] = rescale_MRUSEB_VAcoef_to_one(natUSEcoefBnew,SUT_t.VAcoef,nreg,nind,relVA);
    [MRUSEcoefBnew] = DisaggregateNational2MR(natUSEcoefBnew,SUT_t.ImpShareTTL,SUT_t.ImpShareBilateral,nreg,nind,nprod);
    [MRFDnew] = DisaggregateNational2MR(natFDnew,SUT_t.FDimpShareTTL,SUT_t.FDimpShareBilateral,nreg,nfd,nprod);
    
   
    disp(['min(min(MRUSEcoefBnew) = ',num2str(min(min(MRUSEcoefBnew)))])
    disp(['sum(sum(MRUSEcoefBnew) = ',num2str(sum(sum(MRUSEcoefBnew)))])
    disp(['max(sum(MRUSEcoefBnew) = ',num2str(max(sum(MRUSEcoefBnew)))])
    MRUSEcoefBnew(MRUSEcoefBnew<0)=0.0000000001;
    %[MRUSEcoefBnew,SUT_t.VAcoef] = rescale_MRUSEB_VAcoef_to_one(MRUSEcoefBnew,SUT_t.VAcoef,nreg,nind,relVA);
    
    % make sure that USE coef + relevant VAcoef relVA add up to
    % what they were originally
    tempvec = (sum(MRUSEcoefBnew,1) + sum(SUT_t.VAcoef(relVA,:),1));
%     figure()
%     plot(1:7987,tempvec,'*')
%     title('use B plus VA coef old')
    
    MRUSEcoefBnew = MRUSEcoefBnew./(repmat(tempvec,nprod*nreg,1));
    VAcoefnew = SUT_t.VAcoef./(repmat(tempvec,nva+1,1));
    MRUSEcoefBnew(isnan(MRUSEcoefBnew)) = 0;
    VAcoefnew(isnan(VAcoefnew)) = 0;
   %     sum(sum(SUT_t.VAcoef(6:8,:)))/sum(sum(VAcoefnew(6:8,:)))
%      tempvec = (sum(MRUSEcoefBnew,1) + sum(VAcoefnew(relVA,:),1));
%      figure()
%      plot(1:7987,tempvec,'*')
%      title('use B plus VA coef after')
%    disp(['sum(sum(MRUSEcoefBnew)) + sum(sum(VAcoefnew)) = ',num2str(sum(sum(MRUSEcoefBnew)) + sum(sum(VAcoefnew)))])
    disp(['after rescaling sum(sum(MRUSEcoefBnew) = ',num2str(sum(sum(MRUSEcoefBnew)))])
    disp(['max(sum(MRUSEcoefBnew) = ',num2str(max(sum(MRUSEcoefBnew)))])


    
    % The market share matrix D, calculated from the supply matrix of the
    % last available year may change   
    MRSUPcoefDnew = SUT_t.MRSUPcoefD;
%     % set extraterritorial organisations to zero before scaling and after
    MRSUPcoefDnew(nind:nind:end,:)=0;
    MRSUPcoefDnew(:,nprod:nprod:end)=0;
    tmeps=sum(MRSUPcoefDnew);
    MRSUPcoefDnew = MRSUPcoefDnew./(repmat(tmeps,nind*nreg,1));
    MRSUPcoefDnew(isnan(MRSUPcoefDnew)) = 0;
    
    for i=1:(nreg*nprod)
        if sum(MRSUPcoefDnew(:,i)) == 0
            j = mod(i,nprod); 
            if j==0 j=nprod; end
            jj = find(ProdIndConcordance(j,:));
            c = (i-j)/nprod + 1;
            ind = (c-1)*nind + jj;
            MRSUPcoefDnew(ind,i) = 1.0000;
           %disp(['industry ',num2str(i),' did not sum to one']);
        end
    end
    % set extraterritorial organisations to zero before scaling and after
    MRSUPcoefDnew(nind:nind:end,:)=0;
    MRSUPcoefDnew(:,nprod:nprod:end)=0;
    disp(['sum(sum(MRSUPcoefDnew) = ',num2str(sum(sum(MRSUPcoefDnew)))])
    
    % circular economy intervention 1 (market shares)
    if circulareconomy == 1
       run('CircularEconomy_MarketShares.m');
       disp(['after circular economy sum(sum(MRSUPcoefDnew) = ',num2str(sum(sum(MRSUPcoefDnew)))])
    end % circulareconomy
    

    toc
    %----------------------------------------------------------------------
    % Leontief calculation  
    %----------------------------------------------------------------------
    tic
    disp(['Leontief calculation....'])

    % final demand vector
    yc = sum(MRFDnew,2);

    [Lindprod,Lprodprod] = Leontief_TotalRequirementsMatrix(MRUSEcoefBnew,MRSUPcoefDnew,nreg,nprod,nind);
%[Lindprod,Lprodprod] = Leontief_TotalRequirementsMatrix(SUThist.MRUSEcoefB,MRSUPcoefDnew,nreg,nprod,nind);

    % industry output g
    g = Lindprod * sparse(yc);
    % product output q
    q = Lprodprod * sparse(yc); % needed for MRSUP calculation
    
    disp(['g/q = ',num2str(sum(g)/sum(q))])
    %disp(['q = ',num2str(sum(q))])
    
    disp(['SUT table....'])
    MRVA = VAcoefnew *sparse(diag(g));
    MRUSE = MRUSEcoefBnew * sparse(diag(g));
    MRSUP = MRSUPcoefDnew * sparse(diag(q));
    
    disp(['FD/VA = ',num2str(sum(sum(MRFDnew))/sum(sum(MRVA(relVA,:))))])
    
    disp(['product difference of use table = ',num2str(sum(abs(q-sum(MRUSE,2)-yc)))]) 
    disp(['industry difference of use table = ',num2str(sum(abs(g'-sum(MRUSE,1)-sum(MRVA(relVA,:)))))]) 
    disp(['product difference of sup table = ',num2str(sum(abs(q'-sum(MRSUP,1))))]) 
    disp(['industry difference of sup table = ',num2str(sum(abs(g-sum(MRSUP,2))))])
%     figure()
%     plot(1:(nreg*nind),g,'go',1:(nreg*nind),(sum(MRUSE,1)+sum(MRVA(relVA,:))),'r*')
if year==finalyear
    figure()
    temp2=sum(MRUSE,1)+sum(MRVA(relVA,:));
    temp1 = g'-temp2; 
    plot(1:(nreg*nind),temp1,'r*')
    title('industry difference of use table');
    figure()
    temp1 = q'-sum(MRSUP,1); 
    plot(1:(nreg*nprod),temp1,'r*')
    title('product difference of sup table'); 
end    
    toc   
    %----------------------------------------------------------------------
    % Trade - MACRO level
    %----------------------------------------------------------------------
    tic
    disp(['Trade....'])
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
    toc     
    %----------------------------------------------------------------------
    % Value added - INDUSTRY level
    %----------------------------------------------------------------------
    tic
    disp(['Value added....'])
    
    % compare VA to GDPTR
    VAtemp = sum(sum(MRVA([relVA],:)));
    GDPTRtemp = sum(MacroData.GDPTRtemp(:,t));
    disp(['VAtemp/GDPTRtemp = ',num2str(VAtemp/GDPTRtemp)])
    
    %----------------------------------------------------------------------
    % Value added - MACRO level
    %----------------------------------------------------------------------
    for c=1:nreg
     MacroData.TAX(c,t) = sum(sum(MRVA(1:4,CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))));
     MacroData.WAGE(c,t) = sum(sum(MRVA(5:8,CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))));
     MacroData.NOS(c,t) = sum(sum(MRVA(9:12,CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))));
    end
    toc

    %----------------------------------------------------------------------
    % putting it all into the structs
    %----------------------------------------------------------------------
    %disp(['storing1....'])
    
    MacroData.GDPTR(:,t) = MacroData.TAX(:,t)+MacroData.WAGE(:,t)+MacroData.NOS(:,t);
    %[MacroData.WAGE(:,t-1),MacroData.WAGE(:,t)]
    % domestic final demand
    MacroData.DFD(:,t) = MacroData.HOUS(:,t)+MacroData.NPSH(:,t)+MacroData.GOVE(:,t)+MacroData.GFCF(:,t);%+MacroData.CIES(:,t);
  
  
    % store entire MRIO
    SUT_t.MRVA = MRVA;
    SUT_t.VAcoef = VAcoefnew;
    SUT_t.MRFD = MRFDnew;
    SUT_t.MRUSEcoefB = MRUSEcoefBnew;
    SUT_t.MRSUPcoefD = MRSUPcoefDnew;
    SUT_t.MRUSE = MRUSE;
    SUT_t.MRSUP = MRSUP;
    SUT_t.g = g;
    SUT_t.q = q;
    SUT_t.natFD = natFDnew;
    %SUT_t.S = SUT.S; % default: no change in stressor intensities
    SUT_t.S_fd = SUT.S_fd; % default: no change in stressor intensities
    %SUT_t.natUSEcoefB = natUSEcoefBnew;

    
    
    %----------------------------------------------------------------------
    % change stressor intensities
    %----------------------------------------------------------------------
    disp(['change stressor intensities....'])
    
    if changeEnergyUse == 1
        % change stressor intensities according to IEA scenarios
        run('changeEnergyUSEandCO2stressors.m');
    else % that is, when not given bei IEA scenario
        % the energy use and CO2 stressors change with the change in the
        % energy use coefficients
        run('changeEnergyUSEandCO2stressors_defaultwithusecoef.m');
    end
       
    SUT_t.Extensions.labsF = SUT.Extensions.labsF;
    SUT_t.Extensions.labsC = SUT.Extensions.labsC;
    

    %----------------------------------------------------------------------
    % initialize SUT for the next year
    %----------------------------------------------------------------------
    SUT = SUT_t;
    
    %----------------------------------------------------------------------
    % saving
    %----------------------------------------------------------------------
    disp(['storing data for year ',num2str(year)])
    if exist(['futures\',scenarioname]) == 0
        mkdir(['futures\',scenarioname]);
    end

    if mod(year,5) == 0 && year > 2015
        %save([scenariopath,'SUT_t',num2str(year),'_pxi.mat'],'SUT_t','-v7.3');
        [MRSUT] = createEXIOBASEMRSUT(SUT_t,nreg,nprod,nind,nfd,nva);
        [guse,quse] = calculateIndProdOutput(SUT_t.MRUSE,SUT_t.MRSUP',SUT_t.MRVA(1:nva,:),SUT_t.MRFD);
        save([scenariopath,'MRSUT_',num2str(year),'.mat'],'MRSUT');
        Extensions.S = SUT_t.S;
        Extensions.S_fd = SUT_t.S_fd;
        Extensions.char = SUT_t.char;
        Extensions.labsF = SUT_t.Extensions.labsF;
        Extensions.labsC = SUT_t.Extensions.labsC;
        save([scenariopath,'Extensions_',num2str(year),'_ixi.mat'],'Extensions');
        run('PrepareMRSUTandCREATEixi.m');
        meta = SUT_t.meta;
        meta.labsF = Extensions.labsF;
        meta.labsC = Extensions.labsC;
        save([scenariopath,'final_IOT_',num2str(year),'_ixi.mat'], 'IO','meta');
    end
    toc
end%for years


save([scenariopath,'MacroData.mat'],'MacroData');
if changeEnergyUse == 1
    AddedCapacity = RenEnTech.AddedCapacity;
    save([scenariopath,'AddedCapacity.mat'],'AddedCapacity');
    %save([scenariopath,'AdditionalREinvestment.mat'],'AdditionalREinvestment');
    save([scenariopath,'AdditionalREinvestmentshare.mat'],'AdditionalREinvestmentshare');
    save([scenariopath,'IEAEXIO.mat'],'IEAEXIO');
    save([scenariopath,'EXIOIRENA.mat'],'EXIOIRENA');
end

