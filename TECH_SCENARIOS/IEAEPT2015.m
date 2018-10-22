%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% IEA ETP 2015 Scenario data
%% 1) Load scenario data

%datapath = [thispath,'\RawData\IEAEPTscenario\'];
datapath = [myDropboxPath,'Data\IEAEPT2015\'];
filename = 'ETP2015_scenario_summary.xlsx';
countryconcordancefile = [thispath,'\RawData\IEAEPT2015ScenarioConcordances.xlsx'];
%% 
% Added a sheet "regionnames" to the original file. Set number of IEA regions

nIEAreg = 12;

meta = 'B5:B125';
yeardata = 'C2:J2';


for r = 1:nIEAreg
    [num,txt,raw] = xlsread([datapath,filename],'regionnames',['A',num2str(r),':A',num2str(r)]);
    regname =strjoin(txt);
    tempdata = xlsread([datapath,filename],regname,scen);
    if r==1
        IEA.years = xlsread([datapath,filename],regname,yeardata);
        [num,IEA.regnames,raw] = xlsread([datapath,filename],'regionnames','A1:A12');
        [num,txt,raw] = xlsread([datapath,filename],regname,meta);
        IEA.TPESmeta = txt(1:8);
        IEA.FuelElecHeatmeta = txt(11:24);
        IEA.FENDmeta = txt(27:35);
        IEA.FENDindmeta = txt(38:46);
        IEA.FENDnonenmeta = txt(49);
        IEA.FENDtransmeta = txt(52:58);
        IEA.FENDothermeta = txt(61:69);
        IEA.ElecGenmeta = txt(72:88);
        IEA.ElecCapmeta = txt(91:107);
        IEA.CO2emmeta = txt(110:115);
        IEA.CO2csmeta = txt(118:121);
    end
    IEA.TPES(:,:,r) = tempdata(1:8,:);
    IEA.FuelElecHeat(:,:,r) =  tempdata(11:24,:);
    IEA.FEND(:,:,r) =  tempdata(27:35,:);
    IEA.FENDind(:,:,r) =  tempdata(38:46,:);
    IEA.FENDnonen(:,:,r) =  tempdata(49,:);
    IEA.FENDtrans(:,:,r) =  tempdata(52:58,:);
    IEA.FENDother(:,:,r) =  tempdata(61:69,:);
    IEA.ElecGen(:,:,r) =  tempdata(72:88,:);
    IEA.ElecCap(:,:,r) =  tempdata(91:107,:);
    IEA.CO2em(:,:,r) =  tempdata(110:115,:);
    IEA.CO2cs(:,:,r) =  tempdata(118:121,:);

end
%% 2) IEA to EXIOBASE 

IEAEXIO.meta.TPES = IEA.TPESmeta;
IEAEXIO.meta.FuelElecHeat = IEA.FuelElecHeatmeta;
IEAEXIO.meta.FEND = IEA.FENDmeta;
IEAEXIO.meta.FENDind = IEA.FENDindmeta;
IEAEXIO.meta.FENDnonen = IEA.FENDnonenmeta;
IEAEXIO.meta.FENDtrans = IEA.FENDtransmeta;
IEAEXIO.meta.FENDoth = IEA.FENDothermeta;
%IEAEXIO.meta.ElecGen = IEA.ElecGenmeta;
%IEAEXIO.meta.ElecCap = IEA.ElecCapmeta;
IEAEXIO.meta.CO2em = IEA.CO2emmeta;
IEAEXIO.meta.CO2cs = IEA.CO2csmeta;
%% 
% Load country concordance

IEAEXIO.countries = xlsread(countryconcordancefile,'countries','D2:O50');
% for the mini model
if nreg == 5
    IEAEXIO.countries = xlsread(countryconcordancefile,'countriesMini','D2:O6');
end

for c = 1:nreg 
    IEAEXIO.couvec(c) = find(IEAEXIO.countries(c,:)==1);
end
%% 
% Load product concordances

IEAEXIO.Electricity = xlsread(countryconcordancefile,'electricity','B2:R13');
IEAEXIO.Electricity(isnan(IEAEXIO.Electricity)) = 0;
[num,txt,weissichnichtmehr] = xlsread(countryconcordancefile,'electricity','A2:A13');
IEAEXIO.meta.ElecGen = txt;
IEAEXIO.meta.ElecCap = txt;
IEAEXIO.ElectricityREtech = xlsread(countryconcordancefile,'electricityREtech','B2:M10');
IEAEXIO.ElectricityREtech(isnan(IEAEXIO.ElectricityREtech)) = 0;
IEAEXIO.EnergyUseIndFD = xlsread(countryconcordancefile,'EnergyUseIndFD_prod','D2:L201');
IEAEXIO.EnergyUseIndFD(isnan(IEAEXIO.EnergyUseIndFD)) = 0;
IEAEXIO.prodvec = zeros(nprod,1);
for p = 1:nprod 
    if sum(IEAEXIO.EnergyUseIndFD(p,:))>0
        IEAEXIO.prodvec(p) = find(IEAEXIO.EnergyUseIndFD(p,:)==1);
    end
end
IEAEXIO.EnergyUseIndFDstressors = xlsread(countryconcordancefile,'EnergyUseIndFD_Stressors','E2:L1331');
IEAEXIO.EnergyUseIndFDstressors(isnan(IEAEXIO.EnergyUseIndFDstressors)) = 0;
% for rescaling 
IEAEXIO.prodvecINV = IEAEXIO.prodvec; IEAEXIO.prodvecINV(:) = 0;
IEAEXIO.prodvecINV(IEAEXIO.prodvec(:)==0) = 1;
%% set industries/products to which concordances apply
% industries
IEAEXIO.iInd = [35:95, 108:114]; % manufacturing incl energy services and construction
IEAEXIO.iAgrFishBuild = [1:19 , 115:163]; %Agriculture and fishing is clear, but buildings mainly refer to services and final demand,
IEAEXIO.iMiningTPED = 20:34; % this should also use the "industry sector data", but these industries are those who are demanded of less
IEAEXIO.iElec = 96:107;
% products
IEAEXIO.pIndind = [43:127, 140:152]; % manufacturing incl energy services and construction
IEAEXIO.pAgrFishBuild = [1:19 , 152:200]; %Agriculture and fishing is clear, but buildings mainly refer to services and final demand,
IEAEXIO.pMiningTPED = 20:42; % this should also use the "industry sector data", but these industries are those who are demanded of less
IEAEXIO.pElec = 128:139;

% not sure yet how to deal with transport. as transport in IOTs/SUT is in all industries, not a special transport industry
IEAEXIO.EnergyUseTransport = xlsread(countryconcordancefile,'EnergyUseTransport_prod','D2:K201');
%% 3) Concord into EXIOBASE regions and products
% GDPgrowth(reg,t), but the IRENA data in TECH_SCENARIO_ElectricityInitData.mlx 
% is stored as (energy, t, reg), so we'll go with those dimensions here. Which 
% is also better considering the product concordance matrices and the IEAEXIOcouvec

% product concordance
% this is only necessary for those for which there is a 
% 2 or more IEA to 1 EXIOBASE concordance, hence only for
% electricity generation and electricity capacity
for c=1:(size(IEA.ElecGen(:,:,:),3))
    IEA.ElecGenTEMP(:,:,c) = IEAEXIO.Electricity * IEA.ElecGen(:,:,c);
    IEA.ElecCapTEMP(:,:,c) = IEAEXIO.Electricity * IEA.ElecCap(:,:,c);
end

IEAEXIO.years = IEA.years;

% region concordance 
for c = 1:nreg 
    ieacou = IEAEXIO.couvec(c);
    IEAEXIO.TPES(:,:,c) = IEA.TPES(:,:,ieacou);
    IEAEXIO.FuelElecHeat(:,:,c) = IEA.FuelElecHeat(:,:,ieacou);
    IEAEXIO.FEND(:,:,c) = IEA.FEND(:,:,ieacou);
    IEAEXIO.FENDind(:,:,c) = IEA.FENDind(:,:,ieacou);
    IEAEXIO.FENDnonen(:,:,c) = IEA.FENDnonen(:,:,ieacou);
    IEAEXIO.FENDtrans(:,:,c) = IEA.FENDtrans(:,:,ieacou);
    IEAEXIO.FENDother(:,:,c) = IEA.FENDother(:,:,ieacou);
    IEAEXIO.ElecGen(:,:,c) = IEA.ElecGenTEMP(:,:,ieacou);
    IEAEXIO.ElecCap(:,:,c) = IEA.ElecCapTEMP(:,:,ieacou);
    IEAEXIO.CO2em(:,:,c) = IEA.CO2em(:,:,ieacou);
    IEAEXIO.CO2cs(:,:,c) = IEA.CO2cs(:,:,ieacou);
end



%% 4) Calculate growth rates in EXIOBASE regions and populate cubes ...growth(reg,t,prod) or better ...growth(prod,t,reg) as for IRENA data

IEAEXIO.years
% endyear is at nyears and finalyear is at ttlyears and startyear is at 1
% growth rates are calculated as (var(t1)/var(t0))^(1/(t1-t0)) with t0 and t1 being in IEAEXIO.years
% these matrices have the size (number of energy products x ttlyears x nreg)
IEAEXIO.FENDindgrowth = calcIEAgrowthrates(nreg,IEAEXIO.years,IEAEXIO.FENDind,ttlyears,startyear);
IEAEXIO.FENDothgrowth = calcIEAgrowthrates(nreg,IEAEXIO.years,IEAEXIO.FENDother,ttlyears,startyear);
%transport has a different dim: 7 = Oil Coal Natural gas Electricity Biomass Hydrogen Total
IEAEXIO.FENDtragrowth = calcIEAgrowthrates(nreg,IEAEXIO.years,IEAEXIO.FENDtrans,ttlyears,startyear);
% FENDindgrowth is to be applied to industries EXIOiInd and EXIOiMiningTPED
% FENDothgrowth is to be applied to industries EXIOiAgrFishBuild and GOVE, NPSH, GFCF
IEAEXIO.CO2emgrowth = calcIEAgrowthrates(nreg,IEAEXIO.years,IEAEXIO.CO2em,ttlyears,startyear);
%% 
% 
% 
% IEAEXIO.TPED would need to be applied to the primary enery rows, but maybe, 
% if there is less demand for the other energy carriers that automatically translates 
% through the Leotief matrix and leaves the extraction of the materials lower.
% 
% 
%% 5) calculate development of electricity shares
% using linear interpolation on the absolute values first and then calculate 
% the shares

IEAEXIO.ElecGenAllYears = zeros(size(IEAEXIO.ElecGen,1),ttlyears,nreg);
IEAEXIO.ElecCapAllYears = zeros(size(IEAEXIO.ElecCap,1),ttlyears,nreg);
for r = 1:nreg
    for p = 1:size(IEAEXIO.ElecGen,1)
        t1 = IEAEXIO.years(1);
        t2 = IEAEXIO.years(end);
        tt1 = t1-startyear+1;
        tt2 = t2-startyear+1;
        x = [IEAEXIO.years];
        xq = (t1:1:t2);
        v = IEAEXIO.ElecGen(p,:,r);
        IEAEXIO.ElecGenAllYears(p,tt1:tt2,r) = interpn(x,v,xq,'linear');
        v = IEAEXIO.ElecCap(p,:,r);
        IEAEXIO.ElecCapAllYears(p,tt1:tt2,r) = interpn(x,v,xq,'linear');
    end
end

IEAEXIO.ElecGenAllYearsShares = zeros(size(IEAEXIO.ElecGen,1),ttlyears,nreg);
for r = 1:nreg
    tempsum = sum(IEAEXIO.ElecGenAllYears(:,1:ttlyears,r));
    IEAEXIO.ElecGenAllYearsShares(:,1:ttlyears,r) = IEAEXIO.ElecGenAllYears(:,1:ttlyears,r) ./ repmat(tempsum,size(IEAEXIO.ElecGenAllYears,1),1);
end
IEAEXIO.ElecGenAllYearsShares(isnan(IEAEXIO.ElecGenAllYearsShares)) = 0;
IEAEXIO.ElecGenAllYearsShares(isinf(IEAEXIO.ElecGenAllYearsShares)) = 0;