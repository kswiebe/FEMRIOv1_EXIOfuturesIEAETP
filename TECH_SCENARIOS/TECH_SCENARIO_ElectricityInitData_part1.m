%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% The renewable energy technology model for EXIOfuturesIEAETP
% The renewable energy technologies are
% 
% # Hydro
% # Wind onshore
% # Wind offshore
% # Biomass, large
% # Biomass, small
% # Biogas
% # Photovoltaik
% # CSP
% # Geothermal

nREtech = 9;
%% Load historical data 
%% 1) Load data for renewable energy technologies up to 2011/2014
% The variables for which we have historic data are
% 
% * Capacity installed in GW                             InstalledCapacity(tech,year,country)
% * Electricity produced GWh                           ElecProdGWh(tech,year,country)
% * Electricity produced in EUR from SUT        ElecProdEUR(tech,year,country)
% * Price per kW installed                                 PriceperkW(tech,year)
% * Capital cost shares                                     CapitalCostShares(tech,year,product)
% * Life span of technologies                            LifeSpan(tech,year)
% 
% Calculated data
% 
% * AddedCapacity = zeros(nREtech,ttlyears,nreg); in GW
% * ReplacedCapacity = zeros(nREtech,ttlyears,nreg);
% * NewCapacityScenarios = zeros(nREtech,ttlyears,nreg);
% 
% The data are collected in

RawDataPath = [thispath,'\RawData\'];
%% Reorganizing data
% The data are loaded as matrices. We need to reorganize it into data cubes 
% of dimensions 
% 
% # tech
% # year
% # (country / product)
% 
% The third dimension, if it exists, is achieved through putting the technology-year 
% matrices under each other in Excel


% need to convert from IRENA regions to EXIOBASE regions
EXIOIRENA.countryconc = xlsread([RawDataPath,'RenEnTech\EXIOIRENAcountryconcordance.xlsx'],'Sheet1','B2:AX54');
EXIOIRENA.countryconc(isnan(EXIOIRENA.countryconc)) = 0;
RenEnTechTemp.InstalledCapacityTemp = xlsread([RawDataPath,'RenEnTech\IRENAQueryForEXIOfutures.xlsx'],'Query result','D9:S485');% in MW
RenEnTechTemp.InstalledCapacityTemp(isnan(RenEnTechTemp.InstalledCapacityTemp)) = 0;
RenEnTechTemp.ElecProdGWhTemp = xlsread([RawDataPath,'RenEnTech\IRENAQueryForEXIOfutures.xlsx'],'Query result','D486:R962');% in GWh
RenEnTechTemp.ElecProdGWhTemp(isnan(RenEnTechTemp.ElecProdGWhTemp)) = 0;

% these are independent of region
RenEnTechTemp.PricePerkWTemp = xlsread([RawDataPath,'RenEnTech.xlsx'],'PricePerkW','C2:BA10'); % 2010 2020 2040
RenEnTechTemp.CapitalCostSharesTemp = xlsread([RawDataPath,'RenEnTech.xlsx'],'CapitalCostShares','C2:BA55');
RenEnTech.CapitalCostShareConcordance = xlsread([RawDataPath,'RenEnTech.xlsx'],'CapitalCostShareConcordance','B3:C8');
RenEnTech.LifeSpan = xlsread([RawDataPath,'RenEnTech.xlsx'],'LifeSpan','C2:BK40');
RenEnTech.REbaseProdInd = xlsread([RawDataPath,'RenEnTech.xlsx'],'IOindprodconcordance','C2:F10');%elecProd elecInd prod ind
%% Reorganizing into cubes (countries)

for c = 1:(size(EXIOIRENA.countryconc,1))
    c1=(c-1)*nREtech+1;
    c2=c*nREtech;
    RenEnTechTemp.InstalledCapacityTemp2(1:nREtech,:,c) = RenEnTechTemp.InstalledCapacityTemp(c1:c2,:);
    RenEnTechTemp.ElecProdGWhTemp2(1:nREtech,:,c) = RenEnTechTemp.ElecProdGWhTemp(c1:c2,:);
    % is already in cou PricePerkW(1:nREtech,:,c) = PricePerkWTemp(c1:c2,:);
end
%concord into EXIOBASE regions
for i=1:nREtech % currently only possible if nyears = 20, i.e. endyear = 2014
    EXIOIRENA.InstalledCapacity(i,6:nyears,:) =  squeeze(RenEnTechTemp.InstalledCapacityTemp2(i,1:(nyears-5),:)) * EXIOIRENA.countryconc;
    EXIOIRENA.ElecProdGWh(i,6:nyears,:) =  squeeze(RenEnTechTemp.ElecProdGWhTemp2(i,1:(nyears-5),:)) * EXIOIRENA.countryconc;
end

%clear ElecProdGWhTemp2 InstalledCapacityTemp2 InstalledCapacityTemp ElecProdGWhTemp

% interpolate and extrapolate for price per kW
RenEnTech.availableyears = [2010 2020 2040];
temp = RenEnTechTemp.PricePerkWTemp(:, [1 11 31]);
intyears = [2010 : 2040];
x = [RenEnTech.availableyears];
for p=1:size(RenEnTechTemp.PricePerkWTemp,1);
    v = [temp(p,:)];
    xq = intyears;
    RenEnTech.PricePerkW(p,(2010-startyear+1):(2040-startyear+1)) = interpn(x,v,xq,'linear');
end
RenEnTech.PricePerkW(:,(2040-startyear+2):(2050-startyear+1)) =  repmat(RenEnTech.PricePerkW(:,(2040-startyear+1)),1,10);
clear x; clear v; clear xq; clear intyears;
%% Reorganizing into cubes (products for capital cost shares)

RenEnTech.availableyears = [2010 2020 2040];
temp = RenEnTechTemp.CapitalCostSharesTemp(:, [1 11 31]);
intyears = [2010 : 2040];
x = [RenEnTech.availableyears];
for p=1:size(RenEnTechTemp.CapitalCostSharesTemp,1);
    v = [temp(p,:)];
    xq = intyears;
    RenEnTechTemp.CapitalCostSharesTemp2(p,(2010-startyear+1):(2040-startyear+1)) = interpn(x,v,xq,'linear');
end
RenEnTechTemp.CapitalCostSharesTemp2(:,(2040-startyear+2):(2050-startyear+1)) =  repmat(RenEnTechTemp.CapitalCostSharesTemp2(:,(2040-startyear+1)),1,10);

RenEnTech.nprodCCS = 6; % six different products for GFCF
for c = 1:RenEnTech.nprodCCS
    c1=(c-1)*nREtech+1;
    c2=c*nREtech;
    RenEnTech.CapitalCostShares(1:nREtech,:,c) = RenEnTechTemp.CapitalCostSharesTemp2(c1:c2,:);
end

%% From these we can calculate
% 
% * Electricity price

RenEnTech.ElecPrice = zeros(nREtech,ttlyears,nreg);
for country = 1:nreg
    for year = 1:nyears
        for REtech = 1:nREtech
            RenEnTech.ElecPrice(REtech,year,country) = RenEnTechSUT.ElecProdEUR(REtech,year,country)/EXIOIRENA.ElecProdGWh(REtech,year,country);
        end
    end
end
% price for after startyear depends on price development of technology
% TBM to be modelled

% * Added capacity

RenEnTech.AddedCapacity = zeros(nREtech,ttlyears,nreg);
RenEnTech.ReplacedCapacity = zeros(nREtech,ttlyears,nreg);
RenEnTech.NewCapacityScenarios = zeros(nREtech,ttlyears,nreg);
RenEnTech.NewCapacityScenarios(:,2:size(EXIOIRENA.InstalledCapacity,2),:) = EXIOIRENA.InstalledCapacity(:,2:end,:) - EXIOIRENA.InstalledCapacity(:,1:(end-1),:) ;
for country = 1:nreg
    for year = 1:nyears % ReplacedCapacity is zero for all years < endyear/nyears anyways
        for REtech = 1:nREtech
            RenEnTech.AddedCapacity(REtech,year,country) = RenEnTech.ReplacedCapacity(REtech,year,country) + RenEnTech.NewCapacityScenarios(REtech,year,country);
        end
    end
end
% this is true for furture years as well....
% * Replaced capacity 

for country = 1:nreg
    for year = 1:nyears % ReplacedCapacity is zero for all years < endyear/nyears 
        for REtech = 1:nREtech
            if year+RenEnTech.LifeSpan(REtech,year) <= ttlyears
                RenEnTech.ReplacedCapacity(REtech,year+RenEnTech.LifeSpan(REtech,year),country) = RenEnTech.ReplacedCapacity(REtech,year+RenEnTech.LifeSpan(REtech,year),country) + RenEnTech.AddedCapacity(REtech,year,country);
            end
        end
    end
end


%% 2) Load RE technology use coefficient vectors (provided by DIW Berlin, Dietmar Edler)
% Only Kirsten and Johannes are allowed to use these data. Cite as: 
% 
% “Lehr,U., C. Lutz, D.Edler, M.O’Sullivan, K. Nienhaus, J.Nitsch, B. Breitschopf, 
% P. Bickel und M. Ottmüller (2011) Kurz- und langfristige Auswirkungen des Ausbaus 
% der erneuerbaren Energien auf den deutschen Arbeitsmarkt, Studie im Auftrag 
% des Bundesministeriums für Umwelt, Naturschutz und und Reaktorsicherheit, Osnabrück.”
% 
% Coefficient vectors per technology (product x technology)
RenEnTechTemp.REtechCoefTEMP = xlsread(filenameREtechCoef,'EXIOBASEconcordance','D176:L246');
RenEnTech.REtechVAcoef = xlsread(filenameREtechCoef,'EXIOBASEconcordance','D247:L256');
% Concordance to EXIOBASE products (RE classification x EXIOBASE classification)
RenEnTech.ConcordanceREtechEXIO = xlsread(filenameREtechCoef,'EXIOBASEconcordance','P176:HG246');

% Calculate REtech coefficient vectors in EXIOBASE product classification

RenEnTech.REtechCoef = zeros(nprod,nREtech);
for REtech=1:nREtech
    RenEnTech.REtechCoef(:,REtech) = transpose(transpose(RenEnTechTemp.REtechCoefTEMP(:,REtech))*RenEnTech.ConcordanceREtechEXIO);
end



%% 3) calculate share of RE in base industry and coefficients of base industry without the RE technolgoies

% products / industries of technologies
%REbaseProdInd[REtech,1=prod 2= ind]

for t = 1:nyears
    for REtech=1:nREtech
        RenEnTech.AddedCapacityGWEUR(REtech,t,:) = RenEnTech.AddedCapacity(REtech,t,:) * RenEnTech.PricePerkW(REtech,t);% it would need to be * 1000000; but SUT is in mio EUR     
    end
end
RenEnTech.AddedCapacityGWEUR(RenEnTech.AddedCapacityGWEUR<0) = 0;

% CapitalCostShareConcordance(ccs,1=prod 2=ind)
%CapitalCostShares(1:nREtech,year,ccs)
%REtechGFCF(REtech,t,reg,ccs)
for t=1:nyears
    for REtech=1:nREtech
        for r=1:nreg
            RenEnTech.REtechGFCF(REtech,t,r,:) = RenEnTech.AddedCapacityGWEUR(REtech,t,r) * RenEnTech.CapitalCostShares(REtech,t,:);
        end
    end
end
  
% to calculate the share in output we need to use
t=nyears;
for REtech=1:nREtech
    i = RenEnTech.REbaseProdInd(REtech,4);
    for r=1:nreg
        ri = (r-1)*nind + i;
        RenEnTech.ShareInBaseInd(REtech,t,r) = RenEnTech.REtechGFCF(REtech,t,r,1)/SUThist.g(ri);
    end
end

% calculating the industries ex RET (excluding renewable electricity  tech)
% aMEA(prod,reg) and aEMA(preod,reg) 
t=nyears;
SUThist.aMAE = SUThist.natUSEcoefB(:,MAEind:nind:end); % machinery and equipment
SUThist.aEMA = SUThist.natUSEcoefB(:,EMAind:nind:end); % electrical machinery and apparatus
RenEnTechTemp.aMAEtemp = SUThist.aMAE; RenEnTechTemp.aEMAtemp = SUThist.aEMA;
for reg = 1:nreg
    for REtech = 1:nREtech
        if RenEnTech.REbaseProdInd(REtech,4) == MAEind
            RenEnTechTemp.aMAEtemp(:,reg) = RenEnTechTemp.aMAEtemp(:,reg) - RenEnTech.ShareInBaseInd(REtech,t,reg) * RenEnTech.REtechCoef(:,REtech);
        end
        if RenEnTech.REbaseProdInd(REtech,4) == EMAind
            RenEnTechTemp.aEMAtemp(:,reg) = RenEnTechTemp.aEMAtemp(:,reg) - RenEnTech.ShareInBaseInd(REtech,t,reg) * RenEnTech.REtechCoef(:,REtech);
        end
    end %REtech
end %reg
RenEnTech.aMAEex = RenEnTechTemp.aMAEtemp; RenEnTech.aEMAex = RenEnTechTemp.aEMAtemp;
RenEnTech.aMAE = SUThist.aMAE;
RenEnTech.aEMA = SUThist.aEMA;

% adding to GFCF in prod
ccs=1;
p = RenEnTech.CapitalCostShareConcordance(ccs,1);
if RenEnTech.CapitalCostShareConcordance(ccs,1) == 0 %or if ccs == 1
    p = RenEnTech.REbaseProdInd(REtech,3);
end


%% Clear unnecessary variables

clear RenEnTechTemp;