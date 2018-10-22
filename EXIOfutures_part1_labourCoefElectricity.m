%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe 


%% Part1: calculating the historical database
% This part loads the MRSUTs from 1995 to 2014 and stores the macro data in 
% struct MacroData and the MRSUT for the last year available in the struct SUT.

% for the macro-economic regressions we need the data in constant prices
% but we will start from the 2014 table in current prices, we therefore
% need to rebase the constant price data into 2014 prices

% this version changes the labour compensation coefficients for the
% electricity according to newly available data

% Note that this only works when connected to the NTNUs servers, as this is
% where the orginal EXIOBASE tables are stored. Also, the format of the
% tables available within NTNU might differ from those available for
% download from www.exiobase.eu. We therefore supply this script only for
% documentary porposes. It is not meant to be run by anyone else. But we
% think it is important to share this code nonetheless.

%% clear all

%% Initializations for EXIOfuturesIEAEPT 
run('EXIOfutures_init.m');


%% Path to Exiobase

MRIOs_path = '\\winfil.it.ntnu.no\EPT_eksperimentell\Indecol\Projects\MRIOs\';
MRIO_data_path_constant='X:\indecol\Projects\DESIRE\wp5_eeio\const_time_series\MRSUT\processed\';
% 2018-09-12 change to base historic data on current price series
MRIO_data_path_current='X:\indecol\Projects\DESIRE\wp5_eeio\coeff_time_series\MRSUT\processed\';


%% 1) loading data
disp('1) Loading data....')

% Load the data and store it in a comparable format:
updateMacroDataBASE = 1;
%updated on Sept 13 to have both constant and current and rebased final
%constant in 2014 prices, so we can use the 2014 MRIO in current prices as
%a starting point for the scenarios, with the rebased constant price
%macrodata for the macroregressions


% Multiregional matrices
% * MRSUP[nreg*nprod,nreg*nind] - only for the last available year
% * MRUSE[nreg*nind,nreg*nprod] - only for the last available year
% * MRSUPcoefD[nreg*nprod,nreg*nind,ttlyears] - for all years
% * MRUSEcoefB[nreg*nind,nreg*nprod] - assumed to be constant for now, so no 
% year index
% * MRVA[nva,nreg*nind] - only for the last available year
% * MRVAcoef[nva,nreg*nind,ttlyears] - assumed to be constant for now, but will 
% need to be changed
% * MRFD[nreg*nprod,nreg*nfd]
% * ImpShareTTL[nprod,nreg,t] - share of imports in total, domestic and import, 
% by product
% * ImpShareBilateral[nprod,nreg,nreg,t] - Share of exporting country in total 
% imports by product
% 
% National matrices
% 
% * natSUPcoeff
% * natUSEcoeff
% * natFD
% * FDimpShareTTL
% 
% Macro-economic variables all of size [nreg,ttlyears] and their column / 
% row in the FD / VA matrices
% 
% * HOUS 1
% * NPSH 2
% * GOVE 3
% * GFCF 4
% * CIES 5:6
% * TAX 1 + 4 or 2:4
% * WAGE 5 or 6:8
% * NOS 9:12
% * VAttl = TAX + WAGE + NOS
% * POPU
% * HOUSpc = HOUS./POPU
% * WAGEpc = WAGE./POPU
% * NOSpc = NOS./POPU

if updateMacroDataBASE == 1
    currentprices = 0;
    MRIO_data_path = MRIO_data_path_constant;
    run('EXIOfutures_make_macrodata.m')
    MRIO_data_path = MRIO_data_path_current; % and it's meant to be this path for the remainder
    MacroDataCons = MacroData;
    currentprices = 1;
    run('EXIOfutures_make_macrodata.m')
    MacroDataCurr = MacroData;    
    run('EXIOfutures_rebase_macrodata.m');
    % save the rebased constant price version
    save('EXIOhist\MacroDatabase.mat','MacroData');
    save('EXIOhist\MacroDatabaseCurr.mat','MacroDataCurr');
    save('EXIOhist\MacroDatabaseCons.mat','MacroDataCons');
else %updatemacrodatabase ~=1 
    load('EXIOhist\MacroDatabase.mat');
    MRIO_data_path = MRIO_data_path_current; 
    year=endyear;
    t = year-startyear+1;
    load([MRIO_data_path,'MRSUT_',num2str(year),'.mat']);
    MRSUP = MRSUT.mrsup; % MRMAKE = transpose(SUTagg.mrsup);
    MRUSE = MRSUT.mrbpimp + MRSUT.mrbpdom;
    MRFD = MRSUT.mrbpimpfd + MRSUT.mrbpdomfd;
    MRVA = MRSUT.mrbpdomva;
    MRVA(end+1,:) = sum(MRSUT.mrbpdomva(relVA,:),1);

    SUT.scenarioname = 'EXIOhist';
    SUT.year = year; 
    SUT.meta = MRSUT.meta;
    SUT.MRSUP = MRSUP;
    SUT.MRUSE = MRUSE;
    SUT.MRFD = MRFD;
    SUT.MRVA = MRVA;
    
    
end
  
vars = {'MRSUP','MRUSE','MRFD','MRVA','DOMUSE','DOMFD','EXPUSEtemp','EXPFDtemp','IMPUSEtemp','IMPFDtemp'};
clear(vars{:});



%% 2) Calculate variables in endyear (currently 2014)
disp('2) Calculate variables in endyear....')

% Total industry output g calucated from use table and value added and total 
% product output calculated from supply table

[SUT.g,SUT.q] = calculateIndProdOutput(SUT.MRUSE,SUT.MRSUP,SUT.MRVA(relVA,:),SUT.MRFD);
%% Supply and use coefficients and value added coefficients;

[SUT.MRUSEcoefB,SUT.MRSUPcoefD,SUT.VAcoef] = CalculateSUTcoef(SUT.MRUSE,SUT.MRSUP,SUT.MRVA,SUT.g,SUT.q);

%% 2A) Change labour coefficients for electricity industries
disp('2A) Change labour coefficients of electricity industries....')

SUT.VAcoefeleclab = SUT.VAcoef;
SUT.MRUSEcoefBeleclab =SUT.MRUSEcoefB;
% 2 by 8
% 2 Labour, Capital
% 8 electricity industries
selelecnames = {'Coal';'Gas';'Nuclear';'Hydro';'Wind';'Oil';'Biomass';'PV'};
selelec = 96:103;
ElecLABCAP = xlsread('RawData\Monetary_Labour_Input_Coefficients','electricity','P41:W42');
labourstuff = zeros(length(selelec),nreg);
capitalstuff = zeros(length(selelec),nreg);
for s = selelec
    labourstuff(s-95,:) = sum(SUT.VAcoef(5:8,s:nind:end),1);
    capitalstuff(s-95,:) = sum(SUT.VAcoef(9:12,s:nind:end),1);
end
figure()
boxplot(labourstuff')
set(gca,'XTick',1:length(selelecnames));
set(gca,'XTickLabel',selelecnames);
title('Labour shares')
hold on
plot(1:length(selelec),ElecLABCAP(1,:),'o')
plot(1:length(selelec),mean(labourstuff,2),'*')
hold off
labourstufffactor = ElecLABCAP(1,:)./mean(labourstuff,2)';

% multiply with the factor calculated from the actual to the observed mean
% does not work because some labour shares are zero...
% only if the labour shares are zero allocate 1/3 
% to each of the skill levels (the total sum(SUT.VAcoef(5,:)) = 0)
labourstuffmean = mean(labourstuff,2);
for s = selelec
    %VAcoeftemp(5:8,:,s-95) = labourstufffactor(s-95)*SUT.VAcoef(5:8,s:nind:end);
    
%     diffLAB(s-95,:) = repmat(labourstuffmean(s-95),1,nreg)-labourstuff(s-95,:);
%     VAcoeftempTTL(s-95,:) = repmat(ElecLABCAP(1,s-95),1,nreg) + diffLAB(s-95,:);
    for reg=1:nreg
       if sum(SUT.VAcoef(5:8,(reg-1)*nind+s)) ~= 0
           negativitycheck = 0;
           for tt = 6:8
               skillratio = SUT.VAcoef(tt,(reg-1)*nind+s)/sum(SUT.VAcoef(6:8,(reg-1)*nind+s));
               VAcoeftemp(tt,reg,s-95) = SUT.VAcoef(tt,(reg-1)*nind+s) + skillratio*(ElecLABCAP(1,s-95)-labourstuffmean(s-95));
               if VAcoeftemp(tt,reg,s-95) < 0 
                   negativitycheck = 1;
               end
           end
           if reg >= 45 % RoW regions
               negativitycheck = 1;
           end
               
           if negativitycheck == 1
               for tt = 6:8
                   skillratio = SUT.VAcoef(tt,(reg-1)*nind+s)/sum(SUT.VAcoef(6:8,(reg-1)*nind+s));
                   VAcoeftemp(tt,reg,s-95) = skillratio*(ElecLABCAP(1,s-95));
               end
           end
%            for tt = 5:8
%                VAcoeftemp(tt,reg,s) = VAcoeftempTTL(s-95,reg) * SUT.VAcoef(tt,(reg-1)*nind+s)/sum(SUT.VAcoef(5:8,(reg-1)*nind+s));
%            end
       end
       if sum(SUT.VAcoef(5:8,(reg-1)*nind+s)) <= 0 
           for tt = 6:8
               VAcoeftemp(tt,reg,s-95) = 1/3*ElecLABCAP(1,s-95);
           end
       end
    end
    figure()
    plot(1:49,VAcoeftemp(6:8,:,s-95),'*')
    title(selelecnames(s-95))
     hold on
     plot(1:49,SUT.VAcoef(5:8,s:nind:end),'o')
     hold off
     legend({'LSnew','MSnew','HSnew','LSold','MSold','HSold'})
end

% % for solar thermal 104 = 103 solar PV
% SUT.VAcoefeleclab(6:8,104:nind:end) = SUT.VAcoefeleclab(6:8,103:nind:end);
% % for tide wave oecean 105 = 100 wind
% SUT.VAcoefeleclab(6:8,105:nind:end) = SUT.VAcoefeleclab(6:8,100:nind:end);
% % for geothermal 106 = biomass 102
% SUT.VAcoefeleclab(6:8,106:nind:end) = SUT.VAcoefeleclab(6:8,102:nind:end);


% write into full VAcoef matrix
for s = selelec
    SUT.VAcoefeleclab(6:8,s:nind:end) = VAcoeftemp(6:8,:,s-95);
end

% figure()
% boxplot(capitalstuff')
% set(gca,'XTick',1:length(selelecnames));
% set(gca,'XTickLabel',selelecnames);
% title('Capital shares')
% hold on
% plot(1:length(selelec),ElecLABCAP(2,:),'o')
% hold off
% % capital shares are clearly completely off, but that would create too much noise.
%% 2B) Rescale MRUSEcoefB, VAcoef, MRSUPcoefD
% all coefficients should add up to one
disp('2B) Rescale MRUSEcoefB, VAcoef, MRSUPcoefD....')

%% 2B.1) Rescale MRuseCoefB and VAcoef

    tempvec = (sum(SUT.MRUSEcoefB,1) + sum(SUT.VAcoefeleclab(relVA,:),1));
    figure()
    plot(1:7987,tempvec,'*')
    title('use B plus VA coef old')
    
    SUT.MRUSEcoefBeleclab = SUT.MRUSEcoefB./(repmat(tempvec,nprod*nreg,1));
    SUT.VAcoefeleclab = SUT.VAcoefeleclab./(repmat(tempvec,nva+1,1));
    SUT.MRUSEcoefBeleclab(isnan(SUT.MRUSEcoefBeleclab)) = 0;
    SUT.VAcoefeleclab(isnan(SUT.VAcoefeleclab)) = 0;
     tempvec = (sum(SUT.MRUSEcoefBeleclab,1) + sum(SUT.VAcoefeleclab(relVA,:),1));
     figure()
     plot(1:7987,tempvec,'*')
     title('use B plus VA coef after')
    disp(['sum(sum(SUT.MRUSEcoefB) = ',num2str(sum(sum(SUT.MRUSEcoefB)))])
     disp(['sum(sum(SUT.MRUSEcoefBeleclab) = ',num2str(sum(sum(SUT.MRUSEcoefBeleclab)))])
     
%% 2B.2) Fill "diagonals" in market share matrix D

% set extraterritorial organisations to zero before scaling and after
SUT.MRSUPcoefD(nind:nind:end,:)=0;
SUT.MRSUPcoefD(:,nprod:nprod:end)=0;
tmeps=sum(SUT.MRSUPcoefD);
SUT.MRSUPcoefD = SUT.MRSUPcoefD./(repmat(tmeps,nind*nreg,1));
SUT.MRSUPcoefD(isnan(SUT.MRSUPcoefD)) = 0;

for i=1:(nreg*nprod)
    if sum(SUT.MRSUPcoefD(:,i)) == 0
        j = mod(i,nprod); 
        if j==0 
            j=nprod; 
        end
        jj = find(ProdIndConcordance(j,:));
        c = (i-j)/nprod + 1;
        ind = (c-1)*nind + jj;
        SUT.MRSUPcoefD(ind,i) = 1.0000;
       % disp(['industry ',num2str(i),' did not sum to one']);
    end
end
% set extraterritorial organisations to zero before scaling and after
SUT.MRSUPcoefD(nind:nind:end,:)=0;
SUT.MRSUPcoefD(:,nprod:nprod:end)=0;
%% 2C) Recalculate MRSUT in endyear
disp('2C) Recalculate MRSUT in endyear....')
% if happy with the above VAcoef ¨USEcoefB graphs (which I am), replace 
% the MRUSEcoefB and VAcoef

SUT.MRUSEcoefB = SUT.MRUSEcoefBeleclab;
SUT.VAcoef = SUT.VAcoefeleclab;
%% 2C.1) recalculate product output q and industry output g,  
% given unchanged final demand

% final demand vector
yc = sum(SUT.MRFD,2);

[Lindprod,Lprodprod] = Leontief_TotalRequirementsMatrix(SUT.MRUSEcoefB,SUT.MRSUPcoefD,nreg,nprod,nind);
% industry output g
g = Lindprod * sparse(yc);
% product output q
q = Lprodprod * sparse(yc); % needed for MRSUP calculation

figure()
subplot(1,2,1)
plot(g,SUT.g)
title('Industry output g')
subplot(1,2,2)
plot(q,SUT.q)
title('Product output q')

disp(['g/q = ',num2str(sum(g)/sum(q))])

%continue, if happy with plots
SUT.g = g;
SUT.q = q;
%% 2C.2) Recalculate MRSUT

SUT.MRVA = SUT.VAcoef *sparse(diag(SUT.g));
SUT.MRUSE = SUT.MRUSEcoefB * sparse(diag(SUT.g));
SUT.MRSUP = SUT.MRSUPcoefD * sparse(diag(SUT.q));

    disp(['FD/VA = ',num2str(sum(sum(SUT.MRFD))/sum(sum(SUT.MRVA(relVA,:))))])
    
    disp(['product difference of use table = ',num2str(sum(abs(SUT.q-sum(SUT.MRUSE,2)-yc)))]) 
    disp(['industry difference of use table = ',num2str(sum(abs(SUT.g'-sum(SUT.MRUSE,1)-sum(SUT.MRVA(relVA,:)))))]) 
    disp(['product difference of sup table = ',num2str(sum(abs(SUT.q'-sum(SUT.MRSUP,1))))]) 
    disp(['industry difference of sup table = ',num2str(sum(abs(SUT.g-sum(SUT.MRSUP,2))))])
%% 2D) Aggregate to national tables & calculate trade shares

disp('2D) Aggregate to national tables & calculate trade shares....')

[SUT.natUSE,SUT.impUSE,SUT.natSUP] = AggregateMRSUT2national(SUT.MRUSE,SUT.MRSUP',nreg,nprod,nind);
[SUT.natUSEcoefB,SUT.impUSEcoefB,SUT.natSUPcoefD] = AggregateMRSUTcoef2national(SUT.MRUSEcoefB,SUT.MRSUPcoefD,nreg,nprod,nind);
%% 2E) Calculate trade shares: 
% 
% * ImpShareTTL = imports as a share of total intermediate demand of industry 
% i for product p 
% * ImpShareBilateral = share of exporting country in total demand for a product 
% by an industry (should be the same for all industries if we have full country 
% resolution)

[SUT.ImpShareTTL,SUT.ImpShareBilateral] = GetTradeShares(SUT.natUSE,SUT.impUSE,SUT.MRUSE,nreg,nprod,nind);
% Aggregate final demand and calculate final demand trade shares

[SUT.natFD,SUT.FDimpShareTTL,SUT.FDimpShareBilateral] = AggregateMRFD2national(SUT.MRFD,nreg,nprod,nfd);
%% Test if that's the same

%[MRUSEcoefBnew] = DisaggregateNational2MR(SUT.natUSEcoefB,SUT.ImpShareTTL,SUT.ImpShareBilateral,nreg,nind,nprod);
%[MRFDnew] = DisaggregateNational2MR(SUT.natFD,SUT.FDimpShareTTL,SUT.FDimpShareBilateral,nreg,nfd,nprod);

%sum(sum(MRUSEcoefBnew-SUT.MRUSEcoefB))
%sum(sum(MRFDnew-SUT.MRFD))
%close enough

%% 2Echeck) Compound Leontief inverse
%disp('2Echeck) Calculate Compound Leontief inverse....')
% %[SUT.Lstar] = CompoundLeontiefInverse(SUT.MRUSEcoefB,SUT.MRSUPcoefD,nreg,nprod,nind);
% 
% %Lstar2011 = SUT.Lstar;
% 
% [Lindprod,Lprodprod] = Leontief_TotalRequirementsMatrix(SUT.MRUSEcoefB,SUT.MRSUPcoefD,nreg,nprod,nind);
% 
% % industry output g
% 
% g = Lindprod * sum(SUT.MRFD,2);
% 
% sum(SUT.g-g')
% 
% figure()
% 
% plot(1:(nreg*nind),SUT.g./g','*')
% 
% % product output q
% 
% q = Lprodprod * sum(SUT.MRFD,2);
% 
% sum(SUT.q-q)
% 
% figure()
% 
% plot(1:(nreg*nprod),SUT.q./q,'*')
% 
% disp(['g/q = ',num2str(sum(g)/sum(q))])
% 
% % 
% 
% % for c=1:nreg
% 
% %     if sum(g(CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind)))/sum(SUT.g(CouSthIndex(c,1,nind):CouSthIndex(c,nind,nind))) 
% < 0.999
% 
% %         c
% 
% %     end
% 
% %     if sum(q(CouSthIndex(c,1,nprod):CouSthIndex(c,nprod,nprod)))/sum(SUT.q(CouSthIndex(c,1,nprod):CouSthIndex(c,nprod,nprod)))  
% < 0.999
% 
% %         c
% 
% %     end
% 
% % end


%% 2Fcheck) test if it is the same

% [Lindprodnew,Lprodprodnew] = Leontief_TotalRequirementsMatrix(MRUSEcoefBnew,SUT.MRSUPcoefD,nreg,nprod,nind);
% % industry output g
% g = Lindprodnew * sum(MRFDnew,2);
% sum(SUT.g-g')
% figure()
% plot(1:(nreg*nind),SUT.g./g','*')
% % product output q
% q = Lprodprodnew * sum(MRFDnew,2);
% sum(SUT.q-q)
% figure()
% plot(1:(nreg*nprod),SUT.q./q,'*')
%% 2Gcheck) Test if all is the same

%  MRUSE = MRUSEcoefBnew * diag(g);
%  MRVA = SUT.VAcoef*diag(g); 
%  sum(sum((MRSUT.mrbpdom + MRSUT.mrbpimp) - SUT.MRUSE))
%  sum(sum((MRSUT.mrbpdom + MRSUT.mrbpimp) - MRUSE))
%  sum(sum(MRSUT.mrbpdomva - MRVA(1:nva,:)))
%  sum(sum(MRSUT.mrbpdomva) - MRVA(13,:))
 
[MRSUTnew] = createEXIOBASEMRSUT(SUT,nreg,nprod,nind,nfd,nva);
save(['futures\EXIOhist\MRSUT_test_',num2str(year),'.mat'],'MRSUTnew');%,'-vEXIOfutures');

%% More checks
% Make sure to have a full use coefficient table. some industries in some 
% countries do not produce anything, but given structural change they might be 
% asked at some point to produce something.
% 
% For our scenarios to make sense, we first need to know which electricity 
% industries exist. for some countries we will have that they will produce solar 
% pv electricity in the future but do not have it yet. but also other industries 
% may have to emerge, for example to produce the technology. Here we also need 
% to make sure that trade shares exist

% find out which electricity industries are available
elecind = 96:107; elecprod = 128:139;
[SUT.elecprodavailability,SUT.elecindavailability] = electricitysectoravailability(MRSUT,nreg,nind,nprod,elecind, elecprod);


% find zero columns in use table and make sure to have coefficients for all readily available
SUT.indavailability = zeros(nreg,nind);
tempsum = sum(SUT.natUSEcoefB);



% high level info on coefficients
coefpath='\\winfil.it.ntnu.no\EPT_eksperimentell\indecol\Projects\DESIRE\wp5_eeio\aux_data_process\coefficients\';

SUT.basicUSEcoef = xlsread(['RawData\Monetary_Labour_Input_Coefficients.xlsx'],'monetary_coefficients','F15:FL214');
temp = xlsread(['RawData\Monetary_Labour_Input_Coefficients.xlsx'],'monetary_coefficients','F215:FL229');
SUT.basicVAcoef = temp([2:4 6:10 12:15],:);

% fill USE coef matrix
for i=1:(nreg*nind)
    if sum(SUT.natUSEcoefB(:,i))==0
        ind = mod(i,nind);
        if ind == 0 
            ind = nind; 
        end
        SUT.natUSEcoefB(:,i) = SUT.basicUSEcoef(:,ind)/100;
        SUT.VAcoef(1:nva,i) = SUT.basicVAcoef(:,ind)/100;
        SUT.VAcoef(end,i) = sum(SUT.VAcoef(1:nva,i));
        c = (i-ind)/nind+1;
    end
end
%% 3) Regressions of macro variables
% Get UN population data and calculate per capita values
MacroData.POPU = xlsread([MRIOs_path,'Auxiliary data\macro\pop_desire.xlsx'],'Sheet1','AO2:CR50');

% Calculate per capita values of the macro-economic data
MacroData.HOUSpc = MacroData.HOUS(:,1:nyears)./MacroData.POPU(:,1:nyears);
MacroData.WAGEpc = MacroData.WAGE(:,1:nyears)./MacroData.POPU(:,1:nyears);
MacroData.GOVEpc = MacroData.GOVE(:,1:nyears)./MacroData.POPU(:,1:nyears);
MacroData.TAXpc = MacroData.TAX(:,1:nyears)./MacroData.POPU(:,1:nyears);
MacroData.NOSpc = MacroData.NOS./MacroData.POPU(:,1:nyears);

% Get total value added & value added per capita
% it should be equal to MacroData.GDPTR
MacroData.VA = MacroData.TAX + MacroData.WAGE + MacroData.NOS;
MacroData.VApc = MacroData.VA./MacroData.POPU(:,1:nyears); 

% Do regressions and get regression coefficients
run('EXIOfutures_MacroRegressions.m');


%% 4) Scenario data

disp('4) Scenario data')
%% 4.1 Exogenous scenario data
disp('4.1) Exogenous scenario data')

%IEAEPTscenario = 'RawData\IEAEPTscenario\ScenarioSpecifications_macroEconomic.xls';
IEAEPTscenario = [myDropboxPath,'Data\IEAEPT2015\ScenarioSpecifications_macroEconomic.xls'];
GDPgrowthdata = xlsread(IEAEPTscenario,'EPTframeworkAssumptions','B11:D21'); % World is in B10
IEAEPTyears = [2020, 2030, 2050];
IEAEXIOcountryconcordance = xlsread('\RawData\IEAEPT2015scenarioConcordances.xlsx','countries','D2:O50');
IEAEXIOcountryconcordance(isnan(IEAEXIOcountryconcordance)) = 0; %first column is world
MacroData.GDPgrowth = zeros(nreg,ttlyears);
for t = endyear:(finalyear-1)
    i = 1;
    while IEAEPTyears(i) <= t
        i = i+1;
    end
    MacroData.GDPgrowth(:,t-startyear+1) = IEAEXIOcountryconcordance(:,2:end) * GDPgrowthdata(:,i)/100;
end
MacroData.GDPgrowth(:,ttlyears) = MacroData.GDPgrowth(:,ttlyears-1);


%% 4.2 GDP growth for scenarios
disp('4.2) GDP growth data data')
% need IEAEPT2015 GDP growth rates, which have been initialized in EXIOfutures_part1.mlx 
% replaced by IMF growth rates until 2012 - 2022, after 2022 relative
% distance between regional IEA growth rates and country IMF of 2022

MacroData.IEAGDPgrowth = MacroData.GDPgrowth;
IMFGDPgrowthratesALL = xlsread('\RawData\IMFWEO\imf-dm-export-20170801.xls','NGDP_RPCH','AH3:AR228');
IMFcountries = xlsread('\RawData\IMFWEO\IMF_EXIOBASE_countryconcordance.xlsx','Ark1','B2:AX227');
MacroData.IMFGDPgrowth = zeros(nreg,ttlyears);
for t = (2012-startyear+1):(2022-startyear+1)
    MacroData.IMFGDPgrowth(:,t) = IMFcountries' * IMFGDPgrowthratesALL(:,t-2012+startyear)/100;
end
% simple forecast of IMF rates based on its difference to IEA rates
t = (2022-startyear+1);
GDPgrowthdiff =  MacroData.IEAGDPgrowth(:,t) -  MacroData.IMFGDPgrowth(:,t);
for t =  (2023-startyear+1):ttlyears
    MacroData.IMFGDPgrowth(:,t) = MacroData.IEAGDPgrowth(:,t) - GDPgrowthdiff;
end


MacroData.GDPgrowth =  MacroData.IMFGDPgrowth;
% MacroData.GDPgrowth =  MacroData.IEAGDPgrowth;

% as long as no trade balancing, we need to crosscheck  GDP 
% also we need these this for the estimations
MacroData.GDPTR = MacroData.TAX+MacroData.WAGE+MacroData.NOS;
MacroData.GDPTRshouldbe = MacroData.TAX+MacroData.WAGE+MacroData.NOS;
for t = (nyears+1):ttlyears
    MacroData.GDPTRshouldbe(:,t) = MacroData.GDPTRshouldbe(:,t-1) .* (1+ MacroData.GDPgrowth(:,t));
end
MacroData.DFD = MacroData.HOUS+MacroData.NPSH+MacroData.GOVE+MacroData.GFCF;%+MacroData.CIES;

% for estimations we need the epsilon difference in the last year, i.e. the
% distance between the actual and the projected value. This then needs to
% be subtracted from the estimated value below
regres.HOUS_eps = regres.HOUS(:,1) + regres.HOUS(:,2).*MacroData.GDPTR(:,nyears) - MacroData.HOUS(:,nyears);
regres.HOUSpc_eps = regres.HOUSpc(:,1) + regres.HOUSpc(:,2).*(MacroData.GDPTR(:,nyears)./MacroData.POPU(:,nyears)) - MacroData.HOUSpc(:,nyears);
regres.NPSH_eps = regres.NPSH(:,1) + regres.NPSH(:,2).*MacroData.GDPTR(:,nyears) - MacroData.NPSH(:,nyears);
regres.GOVE_eps = regres.GOVE(:,1) + regres.GOVE(:,2).*MacroData.GDPTR(:,nyears) - MacroData.GOVE(:,nyears);
regres.GFCF_eps = regres.GFCF(:,1) + regres.GFCF(:,2).*MacroData.GDPTR(:,nyears) - MacroData.GFCF(:,nyears);


%% 5) Load stressor data
disp('5) stressor data')
load([MRIOs_path,'EXIOBASE3\EXIOBASE_3_4_constant_price\Matlab structure\Extensions_',num2str(endyear),'_ixi.mat']); 

%% get employment coefficeints in electricity industry right
disp('5A) get employment coefficeints right ')

elecemplskillgendern = zeros(6,1);
elecCoEskill = zeros(3,1);
elecEMPL = zeros(3,1); % total electricity employment by skill
for r = 1:nreg
    regelecind = (r-1)*nind+elecind;
    elecEMPL(1) = sum(sum(Extensions.F(LSidx,regelecind)));
    elecEMPL(2) = sum(sum(Extensions.F(MSidx,regelecind)));
    elecEMPL(3) = sum(sum(Extensions.F(HSidx,regelecind)));
    elecCoEskill = sum(SUT.VAcoef(6:8,regelecind),2);
    elecCoEskillbyind = SUT.VAcoef(6:8,regelecind) ./ repmat(elecCoEskill,1,length(elecind));
    LSgender = Extensions.F(LSidx,regelecind)./ repmat(sum(Extensions.F(LSidx,regelecind),1),2,1);
    MSgender = Extensions.F(MSidx,regelecind)./ repmat(sum(Extensions.F(MSidx,regelecind),1),2,1);
    HSgender = Extensions.F(HSidx,regelecind)./ repmat(sum(Extensions.F(HSidx,regelecind),1),2,1);
    LSgender(isnan(LSgender)) = 0.5;
    MSgender(isnan(MSgender)) = 0.5;
    HSgender(isnan(HSgender)) = 0.5;
    % LS gender is the gender shares within each skill level,
    % elecCoEskillbyind is the share of each industry for each of the skill
    % levels seperately
    % elecCoEskill is total electricity employment by skill level
    LS = elecEMPL(1) * LSgender .* repmat(elecCoEskillbyind(1,:),2,1);
    MS = elecEMPL(2) * MSgender .* repmat(elecCoEskillbyind(2,:),2,1);
    HS = elecEMPL(3) * HSgender .* repmat(elecCoEskillbyind(3,:),2,1);
    Extensions.F(LSidx,regelecind) = LS;
    Extensions.F(MSidx,regelecind) = MS;
    Extensions.F(HSidx,regelecind) = HS;
end

%% create all stressor intensities S
t = nyears;
SUT.F = Extensions.F;
SUT.S = Extensions.F./repmat(SUT.g',size(Extensions.F,1),1);
SUT.S(isnan(SUT.S)) = 0;
SUT.S(isinf(SUT.S)) = 0;
for reg=1:nreg
    r1 = ((reg-1)*nfd);
    SUT.S_fd(:,reg,1) = Extensions.F_hh(:,r1+1)/MacroData.HOUS(reg,t);
    SUT.S_fd(:,reg,2) = Extensions.F_hh(:,r1+2)/MacroData.NPSH(reg,t);
    SUT.S_fd(:,reg,3) = Extensions.F_hh(:,r1+3)/MacroData.GOVE(reg,t);
    SUT.S_fd(:,reg,4) = Extensions.F_hh(:,r1+4)/MacroData.GFCF(reg,t);
end
SUT.S_fd(isnan(SUT.S_fd)) = 0;
SUT.S_fd(isinf(SUT.S_fd)) = 0; 
%% Impact calculation

% GHG and other characterization
SUT.char = Extensions.char;
SUT.Extensions.labsF = Extensions.labsF;
SUT.Extensions.labsC = Extensions.labsC;


%% 6) Store historical dataset

disp(['Store historical ',' dataset '])
SUThist = SUT;
MacroDatahist = MacroData;

if exist('EXIOhist') == 0
    mkdir EXIOhist;
end

% check NANs and inf in coefficeints
SUThist.MRUSEcoefB(isnan(SUThist.MRUSEcoefB)) = 0;
SUThist.MRSUPcoefD(isnan(SUThist.MRSUPcoefD)) = 0;
SUThist.natUSEcoefB(isnan(SUThist.natUSEcoefB)) = 0;
SUThist.VAcoef(isnan(SUThist.VAcoef)) = 0;


save('EXIOhist\SUThist.mat','SUThist', '-v7.3');
save('EXIOhist\MacroDatahist.mat','MacroDatahist');
save('regres\regres.mat','regres');



Extensions.S = SUT.S;
Extensions.S_fd = SUT.S_fd;
Extensions.char = SUT.char;
Extensions.labsF = SUT.Extensions.labsF;
Extensions.labsC = SUT.Extensions.labsC;
save(['futures\EXIOhist\','Extensions_',num2str(year),'_ixi.mat'],'Extensions','-v7.3');
